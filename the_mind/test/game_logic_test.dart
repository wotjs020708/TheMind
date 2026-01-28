import 'package:flutter_test/flutter_test.dart';
import 'package:the_mind/features/game/domain/services/game_logic_service.dart';
import 'package:the_mind/features/game/domain/models/game_config.dart';
import 'package:the_mind/features/game/domain/models/player.dart';
import 'package:the_mind/shared/models/game_card.dart';

void main() {
  late GameLogicService gameLogic;

  setUp(() {
    gameLogic = GameLogicService();
  });

  group('GameLogicService', () {
    test('generateDeck should create 100 unique cards', () {
      final deck = gameLogic.generateDeck();
      expect(deck.length, 100);
      final numbers = deck.map((c) => c.number).toSet();
      expect(numbers.length, 100);
    });

    test('deck should contain cards numbered 1-100', () {
      final deck = gameLogic.generateDeck();
      final numbers = deck.map((c) => c.number).toSet();
      expect(numbers.contains(1), true);
      expect(numbers.contains(100), true);
    });

    test('distributeCards for 2 players level 5 should give 5 cards each', () {
      final players = [
        const Player(id: '1', name: 'P1', position: 0, cards: []),
        const Player(id: '2', name: 'P2', position: 1, cards: []),
      ];

      final result = gameLogic.distributeCards(5, players);
      expect(result['1']?.length, 5);
      expect(result['2']?.length, 5);
    });

    test('distributeCards should sort cards in ascending order', () {
      final players = [
        const Player(id: '1', name: 'P1', position: 0, cards: []),
      ];

      final result = gameLogic.distributeCards(10, players);
      final cards = result['1']!;
      for (var i = 0; i < cards.length - 1; i++) {
        expect(cards[i].number < cards[i + 1].number, true);
      }
    });

    test('isValidCardPlay should validate card order', () {
      expect(gameLogic.isValidCardPlay(10, []), true);
      expect(gameLogic.isValidCardPlay(20, [10, 15]), true);
      expect(gameLogic.isValidCardPlay(5, [10]), false);
    });

    test('isValidCardPlay with equal number should fail', () {
      expect(gameLogic.isValidCardPlay(10, [10]), false);
    });

    test('handleMistake should discard cards below played card', () {
      final players = [
        const Player(
          id: '1',
          name: 'P1',
          position: 0,
          cards: [
            GameCard(number: 5),
            GameCard(number: 10),
            GameCard(number: 15),
          ],
        ),
        const Player(
          id: '2',
          name: 'P2',
          position: 1,
          cards: [GameCard(number: 3), GameCard(number: 12)],
        ),
      ];

      final discarded = gameLogic.handleMistake(8, players);
      expect(discarded.length, 2); // cards 5, 3
    });

    test('useShurikenEffect should remove first card from each player', () {
      final players = [
        const Player(
          id: '1',
          name: 'P1',
          position: 0,
          cards: [GameCard(number: 5), GameCard(number: 10)],
        ),
        const Player(
          id: '2',
          name: 'P2',
          position: 1,
          cards: [GameCard(number: 3), GameCard(number: 12)],
        ),
      ];

      final removed = gameLogic.useShurikenEffect(players);
      expect(removed['1']?.number, 5);
      expect(removed['2']?.number, 3);
    });

    test('useShurikenEffect with empty cards should return null', () {
      final players = [
        const Player(id: '1', name: 'P1', position: 0, cards: []),
      ];

      final removed = gameLogic.useShurikenEffect(players);
      expect(removed['1'], null);
    });

    test('applyLevelReward for level 2 should give shuriken', () {
      final rewards = gameLogic.applyLevelReward(2);
      expect(rewards['shurikens'], 1);
      expect(rewards['lives'], 0);
    });

    test('applyLevelReward for level 3 should give life', () {
      final rewards = gameLogic.applyLevelReward(3);
      expect(rewards['shurikens'], 0);
      expect(rewards['lives'], 1);
    });

    test('applyLevelReward for level 1 should give nothing', () {
      final rewards = gameLogic.applyLevelReward(1);
      expect(rewards['shurikens'], 0);
      expect(rewards['lives'], 0);
    });

    test('checkVictory should return true when currentLevel > maxLevel', () {
      expect(gameLogic.checkVictory(13, 12), true);
      expect(gameLogic.checkVictory(12, 12), false);
    });

    test('checkDefeat should return true when lives <= 0', () {
      expect(gameLogic.checkDefeat(0), true);
      expect(gameLogic.checkDefeat(-1), true);
      expect(gameLogic.checkDefeat(1), false);
    });

    test(
      'GameConfig.forPlayerCount should return correct 2-player settings',
      () {
        final config = GameConfig.forPlayerCount(2);
        expect(config.playerCount, 2);
        expect(config.maxLevel, 12);
        expect(config.initialLives, 2);
        expect(config.initialShurikens, 1);
      },
    );

    test(
      'GameConfig.forPlayerCount should return correct 3-player settings',
      () {
        final config = GameConfig.forPlayerCount(3);
        expect(config.playerCount, 3);
        expect(config.maxLevel, 10);
        expect(config.initialLives, 3);
        expect(config.initialShurikens, 1);
      },
    );

    test(
      'GameConfig.forPlayerCount should return correct 4-player settings',
      () {
        final config = GameConfig.forPlayerCount(4);
        expect(config.playerCount, 4);
        expect(config.maxLevel, 8);
        expect(config.initialLives, 4);
        expect(config.initialShurikens, 1);
      },
    );

    test('GameConfig.forPlayerCount should throw for invalid player count', () {
      expect(() => GameConfig.forPlayerCount(5), throwsA(isA<ArgumentError>()));
    });
  });
}
