import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_mind/features/game/presentation/widgets/card_widget.dart';
import 'package:the_mind/features/game/presentation/widgets/lives_display.dart';
import 'package:the_mind/features/game/presentation/widgets/shurikens_display.dart';
import 'package:the_mind/features/game/presentation/widgets/player_status_widget.dart';
import 'package:the_mind/shared/models/game_card.dart';

class GameScreen extends StatefulWidget {
  final String roomCode;

  const GameScreen({super.key, required this.roomCode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // TODO: Phase 4에서 실제 게임 상태로 교체
  int _currentLevel = 1;
  int _lives = 3;
  int _shurikens = 1;
  final List<GameCard> _myCards = [
    const GameCard(number: 15),
    const GameCard(number: 42),
    const GameCard(number: 73),
  ];
  final List<GameCard> _playedCards = [const GameCard(number: 8)];

  void _playCard(GameCard card) {
    // TODO: Phase 4에서 실제 카드 내기 로직 구현
    print('카드 내기: ${card.number}');
    setState(() {
      _playedCards.add(card);
      _myCards.remove(card);
    });
  }

  void _proposeShurikenUse() {
    if (_shurikens <= 0) return;

    // TODO: Phase 4에서 수리검 투표 시스템 구현
    print('수리검 사용 제안');
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('수리검 사용'),
            content: const Text('수리검 사용을 제안하시겠습니까?\n모든 플레이어가 동의해야 사용됩니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 투표 시작
                },
                child: const Text('제안'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레벨 $_currentLevel'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            // TODO: 게임 나가기 확인
            context.go('/');
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 생명, 수리검
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LivesDisplay(lives: _lives),
                  const SizedBox(width: 32),
                  ShurikensDisplay(shurikens: _shurikens),
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
                children: const [
                  PlayerStatusWidget(playerName: '플레이어 2', cardsRemaining: 2),
                  PlayerStatusWidget(playerName: '플레이어 3', cardsRemaining: 1),
                ],
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
                    if (_playedCards.isNotEmpty)
                      CardWidget(card: _playedCards.last, isPlayable: false)
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
            if (_shurikens > 0)
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '내 카드',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _myCards.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final card = _myCards[index];
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
  }
}
