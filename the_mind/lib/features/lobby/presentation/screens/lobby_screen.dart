import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/lobby_provider.dart';
import '../../../../shared/widgets/connection_status_banner.dart';

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
      appBar: AppBar(
        title: const Text('대기실'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaveLobby,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 연결 상태 배너
            const ConnectionStatusBanner(),

            // 기존 컨텐츠
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 방 코드 표시
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '방 코드',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.roomCode,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 플레이어 목록
                    Text(
                      '플레이어 (${lobbyState.players.length}/${lobbyState.room!.playerCount})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: ListView.builder(
                        itemCount: lobbyState.players.length,
                        itemBuilder: (context, index) {
                          final player = lobbyState.players[index];
                          final isCurrentPlayer =
                              player.id == currentPlayer?.id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color:
                                isCurrentPlayer
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                    : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                player.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing:
                                  player.isReady
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                      : const Icon(
                                        Icons.schedule,
                                        color: Colors.grey,
                                      ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 준비 버튼
                    ElevatedButton(
                      onPressed: _hasJoined ? _toggleReady : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isReady ? Colors.grey : null,
                      ),
                      child: Text(
                        isReady ? '준비 취소' : '준비',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 게임 시작 버튼 (방장만)
                    if (lobbyState.isHost)
                      ElevatedButton(
                        onPressed:
                            lobbyState.allPlayersReady ? _startGame : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '게임 시작',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
