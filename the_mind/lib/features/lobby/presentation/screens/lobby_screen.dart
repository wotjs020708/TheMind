import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/lobby_provider.dart';
import '../../../../shared/widgets/connection_status_banner.dart';
import '../../../../shared/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const LobbyScreen({super.key, required this.roomCode});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final _nameController = TextEditingController();
  bool _hasJoined = false;

  @override
  void initState() {
    super.initState();
    // 이름 입력 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNameDialog();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showNameDialog() async {
    if (_hasJoined) return;

    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('이름 입력'),
            content: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                hintText: '플레이어 이름',
              ),
              autofocus: true,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.of(context).pop(value.trim());
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    Navigator.of(context).pop(name);
                  }
                },
                child: const Text('참가'),
              ),
            ],
          ),
    );

    if (name != null && mounted) {
      final playerId = await ref
          .read(lobbyProvider(widget.roomCode).notifier)
          .joinLobby(name);
      if (playerId != null) {
        setState(() => _hasJoined = true);
      } else {
        if (mounted) context.go('/');
      }
    } else {
      if (mounted) context.go('/');
    }
  }

  Future<void> _toggleReady() async {
    await ref.read(lobbyProvider(widget.roomCode).notifier).toggleReady();
  }

  Future<void> _startGame() async {
    await ref.read(lobbyProvider(widget.roomCode).notifier).startGame();
  }

  Future<void> _leaveLobby() async {
    await ref.read(lobbyProvider(widget.roomCode).notifier).leaveLobby();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyProvider(widget.roomCode));

    // 로딩 중
    if (lobbyState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 에러 발생
    if (lobbyState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('오류: ${lobbyState.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('홈으로'),
              ),
            ],
          ),
        ),
      );
    }

    // 방 정보 없음
    if (lobbyState.room == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('방을 찾을 수 없습니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('홈으로'),
              ),
            ],
          ),
        ),
      );
    }

    // 게임이 시작되면 게임 화면으로 이동
    if (lobbyState.room!.status == 'playing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/game/${widget.roomCode}');
      });
    }

    final currentPlayer = lobbyState.currentPlayer;
    final isReady = currentPlayer?.isReady ?? false;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // 연결 상태 배너
              const ConnectionStatusBanner(),

              // 기존 컨텐츠
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 헤더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppTheme.textPrimary,
                            ),
                            onPressed: _leaveLobby,
                          ),
                          Text(
                            '대기실',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(width: 48), // 균형
                        ],
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: AppTheme.spacingLg),

                      // 방 코드 표시
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                          boxShadow: AppTheme.glowEffect,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.vpn_key,
                                  color: AppTheme.textPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Text(
                                  '방 코드',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              widget.roomCode,
                              style: Theme.of(
                                context,
                              ).textTheme.displayMedium?.copyWith(
                                letterSpacing: 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(),

                      const SizedBox(height: AppTheme.spacingXl),

                      // 플레이어 목록 헤더
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Text(
                            '플레이어',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMd,
                              vertical: AppTheme.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusXl,
                              ),
                            ),
                            child: Text(
                              '${lobbyState.players.length}/${lobbyState.room!.playerCount}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppTheme.accentColor),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: AppTheme.spacingMd),

                      // 플레이어 목록
                      Expanded(
                        child: ListView.separated(
                          itemCount: lobbyState.players.length,
                          separatorBuilder:
                              (context, index) =>
                                  const SizedBox(height: AppTheme.spacingSm),
                          itemBuilder: (context, index) {
                            final player = lobbyState.players[index];
                            final isCurrentPlayer =
                                player.id == currentPlayer?.id;
                            final isHost = index == 0;

                            return Container(
                                  padding: const EdgeInsets.all(
                                    AppTheme.spacingMd,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isCurrentPlayer
                                            ? AppTheme.primaryColor.withValues(
                                              alpha: 0.2,
                                            )
                                            : AppTheme.surfaceColor.withValues(
                                              alpha: 0.5,
                                            ),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                    border: Border.all(
                                      color:
                                          isCurrentPlayer
                                              ? AppTheme.primaryColor
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // 아바타
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient:
                                              isHost
                                                  ? AppTheme.primaryGradient
                                                  : null,
                                          color:
                                              isHost
                                                  ? null
                                                  : AppTheme.accentColor
                                                      .withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            isHost ? '👑' : '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppTheme.spacingMd),
                                      // 이름
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              player.name,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleLarge,
                                            ),
                                            if (isHost)
                                              Text(
                                                '방장',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          AppTheme.accentColor,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // 준비 상태
                                      if (player.isReady)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppTheme.spacingMd,
                                            vertical: AppTheme.spacingSm,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successColor,
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusSm,
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '준비',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.schedule,
                                          color: AppTheme.textMuted,
                                        ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: (400 + index * 100).ms)
                                .slideX(begin: -0.1, end: 0);
                          },
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      // 준비 버튼
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _hasJoined ? _toggleReady : null,
                          icon: Icon(isReady ? Icons.close : Icons.check),
                          label: Text(isReady ? '준비 취소' : '준비'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isReady
                                    ? AppTheme.textMuted
                                    : AppTheme.primaryColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingMd),

                      // 게임 시작 버튼 (방장만)
                      if (lobbyState.isHost)
                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed:
                                lobbyState.allPlayersReady ? _startGame : null,
                            icon: const Icon(Icons.play_arrow, size: 28),
                            label: const Text('게임 시작'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
