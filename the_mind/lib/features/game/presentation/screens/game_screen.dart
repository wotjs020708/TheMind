import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:the_mind/features/game/presentation/widgets/card_widget.dart';
import 'package:the_mind/features/game/presentation/widgets/lives_display.dart';
import 'package:the_mind/features/game/presentation/widgets/shurikens_display.dart';
import 'package:the_mind/features/game/presentation/widgets/player_status_widget.dart';
import 'package:the_mind/features/game/presentation/widgets/shuriken_vote_dialog.dart';
import 'package:the_mind/shared/models/game_card.dart';
import 'package:the_mind/features/game/presentation/providers/game_state_provider.dart';
import 'package:the_mind/features/game/presentation/providers/shuriken_proposal_provider.dart';
import 'package:the_mind/features/lobby/data/repositories/room_repository.dart';
import 'package:the_mind/shared/providers/supabase_provider.dart';
import 'package:the_mind/shared/widgets/connection_status_banner.dart';
import 'package:the_mind/shared/widgets/adaptive/adaptive_dialog.dart'
    as adaptive
    show showAdaptiveDialog, AdaptiveDialogAction;
import 'package:the_mind/core/utils/haptic_feedback_utils.dart';
import 'package:the_mind/shared/theme/app_theme.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String roomCode;
  final String? playerId;

  const GameScreen({super.key, required this.roomCode, this.playerId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String? _roomId;
  String? _currentPlayerId;
  String? _lastProposalId;

  @override
  void initState() {
    super.initState();
    _currentPlayerId = widget.playerId;
    _loadRoomId();
  }

  Future<void> _loadRoomId() async {
    final supabase = ref.read(supabaseProvider);
    final roomRepo = RoomRepository(supabase);
    final room = await roomRepo.findRoomByCode(widget.roomCode);

    if (room != null && mounted) {
      setState(() => _roomId = room.id);
    }
  }

  void _playCard(GameCard card) async {
    if (_currentPlayerId == null || _roomId == null) return;

    await HapticFeedbackUtils.medium();
    await ref
        .read(gameStateProvider(_roomId!).notifier)
        .playCard(playerId: _currentPlayerId!, cardNumber: card.number);
  }

  void _proposeShurikenUse() async {
    if (_currentPlayerId == null || _roomId == null) return;

    final gameState = ref.read(gameStateProvider(_roomId!));
    gameState.whenData((state) async {
      if (state.shurikens <= 0) return;

      await HapticFeedbackUtils.light();
      final shouldPropose = await adaptive
          .showAdaptiveDialog(
            context: context,
            title: '수리검 사용',
            content: const Text('수리검 사용을 제안하시겠습니까?\n모든 플레이어가 동의해야 사용됩니다.'),
            actions: [
              adaptive.AdaptiveDialogAction(text: '취소', onPressed: () {}),
              adaptive.AdaptiveDialogAction(
                text: '제안',
                isDefaultAction: true,
                onPressed: () {},
              ),
            ],
          )
          .then((_) => true)
          .catchError((_) => false);

      if (shouldPropose && mounted) {
        await HapticFeedbackUtils.heavy();
        ref
            .read(gameStateProvider(_roomId!).notifier)
            .proposeShurikenUse(_currentPlayerId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_roomId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 수리검 제안 이벤트 구독
    final proposalAsync = ref.watch(shurikenProposalProvider(_roomId!));
    proposalAsync.whenData((proposalId) {
      if (proposalId != null &&
          proposalId != _lastProposalId &&
          _currentPlayerId != null) {
        _lastProposalId = proposalId;

        // 현재 게임 상태에서 플레이어 수 가져오기
        final gameStateAsync = ref.read(gameStateProvider(_roomId!));
        gameStateAsync.whenData((gameState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => ShurikenVoteDialog(
                      roomId: _roomId!,
                      proposalId: proposalId,
                      currentPlayerId: _currentPlayerId!,
                      playerCount: gameState.players.length,
                    ),
              );
            }
          });
        });
      }
    });

    final gameStateAsync = ref.watch(gameStateProvider(_roomId!));

    return gameStateAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('오류: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('홈으로'),
                  ),
                ],
              ),
            ),
          ),
      data: (gameState) {
        // 현재 플레이어 ID가 없으면 에러 화면 표시
        if (_currentPlayerId == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('플레이어 정보를 찾을 수 없습니다'),
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

        final currentPlayer = gameState.players.firstWhere(
          (p) => p.id == _currentPlayerId,
          orElse: () => gameState.players.first,
        );

        final otherPlayers =
            gameState.players.where((p) => p.id != currentPlayer.id).toList();
        final playedCards =
            gameState.playedCards.map((n) => GameCard(number: n)).toList();

        // 게임 종료 상태 처리
        if (gameState.phase.toString().contains('victory') ||
            gameState.phase.toString().contains('gameOver')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/result/${widget.roomCode}');
          });
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 연결 상태 배너
                  const ConnectionStatusBanner(),

                  // 상단: 레벨 + 생명, 수리검
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: Column(
                      children: [
                        // 레벨 표시
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.exit_to_app,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () => context.go('/'),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingLg,
                                vertical: AppTheme.spacingSm,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusXl,
                                ),
                                boxShadow: AppTheme.glowEffect,
                              ),
                              child: Text(
                                '레벨 ${gameState.currentLevel}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppTheme.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 48), // 균형을 위한 공간
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        // 생명, 수리검
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            LivesDisplay(lives: gameState.lives),
                            ShurikensDisplay(shurikens: gameState.shurikens),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  // 다른 플레이어 상태
                  if (otherPlayers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                      ),
                      child: Wrap(
                        spacing: AppTheme.spacingSm,
                        runSpacing: AppTheme.spacingSm,
                        children:
                            otherPlayers.map((player) {
                              return PlayerStatusWidget(
                                playerName: player.name,
                                cardsRemaining: player.cards.length,
                              );
                            }).toList(),
                      ),
                    ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // 중앙: 플레이된 카드 덱
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '플레이된 카드',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          if (playedCards.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacingSm),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: CardWidget(
                                card: playedCards.last,
                                isPlayable: false,
                              ),
                            )
                          else
                            Container(
                              width: 70,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.textMuted,
                                  width: 2,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                              ),
                              child: Icon(
                                Icons.style_outlined,
                                size: 40,
                                color: AppTheme.textMuted.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 수리검 제안 버튼
                  if (gameState.shurikens > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg,
                        vertical: AppTheme.spacingSm,
                      ),
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _proposeShurikenUse,
                          icon: const Icon(Icons.star, size: 24),
                          label: const Text('수리검 사용 제안'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppTheme.spacingSm),

                  // 하단: 내 손패
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withValues(alpha: 0.7),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusXl),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              '내 카드',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        SizedBox(
                          height: 100,
                          child:
                              currentPlayer.cards.isEmpty
                                  ? Center(
                                    child: Text(
                                      '카드가 없습니다',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  )
                                  : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: currentPlayer.cards.length,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacingMd,
                                    ),
                                    separatorBuilder:
                                        (context, index) => const SizedBox(
                                          width: AppTheme.spacingMd,
                                        ),
                                    itemBuilder: (context, index) {
                                      final card = currentPlayer.cards[index];
                                      return CardWidget(
                                        card: card,
                                        onTap: () => _playCard(card),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
