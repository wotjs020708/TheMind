class GameConstants {
  // 카드 범위
  static const int minCardNumber = 1;
  static const int maxCardNumber = 100;
  static const int totalCards = 100;

  // 플레이어 수 제한
  static const int minPlayers = 2;
  static const int maxPlayers = 4;

  // 보상 레벨
  static const List<int> shurikenRewardLevels = [2, 5, 8, 11];
  static const List<int> lifeRewardLevels = [3, 6, 9];

  // 인원별 설정
  static const Map<int, Map<String, int>> playerCountSettings = {
    2: {'maxLevel': 12, 'initialLives': 2, 'initialShurikens': 1},
    3: {'maxLevel': 10, 'initialLives': 3, 'initialShurikens': 1},
    4: {'maxLevel': 8, 'initialLives': 4, 'initialShurikens': 1},
  };
}
