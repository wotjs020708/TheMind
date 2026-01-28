import 'dart:math';
import '../models/player.dart';
import '../../../../shared/models/game_card.dart';

class GameLogicService {
  // 카드 덱 생성 (Fisher-Yates 셔플)
  List<GameCard> generateDeck() {
    final cards = List.generate(100, (i) => GameCard(number: i + 1));
    final random = Random();

    for (var i = cards.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = cards[i];
      cards[i] = cards[j];
      cards[j] = temp;
    }

    return cards;
  }

  // 레벨별 카드 배분
  Map<String, List<GameCard>> distributeCards(int level, List<Player> players) {
    final deck = generateDeck();
    final cardsPerPlayer = level;
    final result = <String, List<GameCard>>{};

    for (var i = 0; i < players.length; i++) {
      final startIndex = i * cardsPerPlayer;
      final cards = deck.skip(startIndex).take(cardsPerPlayer).toList();
      // 카드를 오름차순 정렬
      cards.sort((a, b) => a.number.compareTo(b.number));
      result[players[i].id] = cards;
    }

    return result;
  }

  // 카드 검증 (순서 체크)
  bool isValidCardPlay(int cardNumber, List<int> playedCards) {
    if (playedCards.isEmpty) return true;
    return cardNumber > playedCards.last;
  }

  // 실수 처리 (카드 공개 및 제거)
  List<GameCard> handleMistake(int playedCardNumber, List<Player> players) {
    final discardedCards = <GameCard>[];

    for (var player in players) {
      final cardsToDiscard =
          player.cards.where((card) => card.number < playedCardNumber).toList();
      discardedCards.addAll(cardsToDiscard);
    }

    return discardedCards;
  }

  // 수리검 사용 (모든 플레이어 최저값 제거)
  Map<String, GameCard?> useShurikenEffect(List<Player> players) {
    final removedCards = <String, GameCard?>{};

    for (var player in players) {
      if (player.cards.isNotEmpty) {
        removedCards[player.id] = player.cards.first;
      } else {
        removedCards[player.id] = null;
      }
    }

    return removedCards;
  }

  // 보상 시스템 (레벨별)
  Map<String, int> applyLevelReward(int level) {
    final rewards = <String, int>{'shurikens': 0, 'lives': 0};

    // 수리검 보상: 레벨 2, 5, 8, 11
    if ([2, 5, 8, 11].contains(level)) {
      rewards['shurikens'] = 1;
    }

    // 생명 보상: 레벨 3, 6, 9
    if ([3, 6, 9].contains(level)) {
      rewards['lives'] = 1;
    }

    return rewards;
  }

  // 승리 조건 체크
  bool checkVictory(int currentLevel, int maxLevel) {
    return currentLevel > maxLevel;
  }

  // 패배 조건 체크
  bool checkDefeat(int lives) {
    return lives <= 0;
  }
}
