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

class GameScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const GameScreen({super.key, required this.roomCode});

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

    await ref
        .read(gameStateProvider(_roomId!).notifier)
        .playCard(playerId: _currentPlayerId!, cardNumber: card.number);
  }

  void _proposeShurikenUse() async {
    if (_currentPlayerId == null || _roomId == null) return;

    final gameState = ref.read(gameStateProvider(_roomId!));
    gameState.whenData((state) async {
      if (state.shurikens <= 0) return;

      final shouldPropose = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('수리검 사용'),
              content: const Text('수리검 사용을 제안하시겠습니까?\n모든 플레이어가 동의해야 사용됩니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('제안'),
                ),
              ],
            ),
      );

      if (shouldPropose == true && mounted) {
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
        // 현재 플레이어 찾기 (로비에서 저장한 ID 사용 또는 첫 번째 플레이어)
        _currentPlayerId ??=
            gameState.players.isNotEmpty ? gameState.players.first.id : null;

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
          appBar: AppBar(
            title: Text('레벨 ${gameState.currentLevel}'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                context.go('/');
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 연결 상태 배너
                const ConnectionStatusBanner(),

                // 상단: 생명, 수리검
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LivesDisplay(lives: gameState.lives),
                      const SizedBox(width: 32),
                      ShurikensDisplay(shurikens: gameState.shurikens),
                    ],
                  ),
                ),

                const Divider(),

                // 다른 플레이어 상태
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        otherPlayers.map((player) {
                          return PlayerStatusWidget(
                            playerName: player.name,
                            cardsRemaining: player.cards.length,
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 중앙: 플레이된 카드 덱
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '플레이된 카드',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        if (playedCards.isNotEmpty)
                          CardWidget(card: playedCards.last, isPlayable: false)
                        else
                          Container(
                            width: 60,
                            height: 90,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.style,
                                size: 32,
                                color: Colors.grey,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: _proposeShurikenUse,
                      icon: const Icon(Icons.star),
                      label: const Text('수리검 사용 제안'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // 하단: 내 손패
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '내 카드',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child:
                            currentPlayer.cards.isEmpty
                                ? const Center(
                                  child: Text(
                                    '카드가 없습니다',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                                : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: currentPlayer.cards.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(width: 12),
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
        );
      },
    );
  }
}
