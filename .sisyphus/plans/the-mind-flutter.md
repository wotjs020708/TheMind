# The Mind - Flutter 디지털 구현 계획

## 프로젝트 개요

Wolfgang Warsch의 협력 카드 게임 "The Mind"를 Flutter로 디지털화하는 프로젝트입니다.

## 기술 스택 (확정)

| 항목 | 기술 | 이유 |
|------|------|------|
| **프론트엔드** | Flutter 3.x | 크로스플랫폼 (iOS, Android, Web) |
| **언어** | Dart 3.x | Null safety, 타입 안전 |
| **백엔드** | Supabase | PostgreSQL + Realtime, BaaS |
| **상태 관리** | Riverpod | 타입 안전, 컴파일 타임 체크 |
| **애니메이션** | flutter_animate | 선언적 API, 카드 효과 최적 |
| **라우팅** | go_router | 선언적 라우팅 |
| **데이터 모델** | freezed + json_serializable | 불변 객체, JSON 직렬화 |
| **배포 (Web)** | Vercel | 빠른 배포, 무료 티어 |
| **배포 (모바일)** | App Store, Google Play | 네이티브 앱 배포 |

## 아키텍처 개요

### 폴더 구조 (Feature-First)

```
lib/
├── main.dart
├── core/
│   ├── constants/          # 게임 상수 (레벨별 설정 등)
│   ├── router/             # go_router 설정
│   └── theme/              # 앱 테마, 색상
├── features/
│   ├── home/               # 홈 화면
│   │   ├── presentation/
│   │   └── widgets/
│   ├── lobby/              # 로비 (방 생성/참가)
│   │   ├── data/           # Supabase 연동
│   │   ├── domain/         # Room 모델
│   │   ├── presentation/   # 화면
│   │   └── providers/      # Riverpod providers
│   ├── game/               # 게임 플레이
│   │   ├── data/
│   │   ├── domain/         # GameState, Card, Player 모델
│   │   ├── presentation/
│   │   ├── providers/
│   │   └── widgets/        # 카드, 덱 등
│   └── result/             # 결과 화면
├── shared/
│   ├── models/             # 공통 모델
│   ├── providers/          # 전역 providers (Supabase 등)
│   └── widgets/            # 공통 위젯
└── utils/                  # 유틸리티 함수
```

### Supabase 스키마 설계

```sql
-- rooms: 게임 방 정보
CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(6) UNIQUE NOT NULL,           -- 방 코드 (예: "ABC123")
  player_count INTEGER NOT NULL              -- 2, 3, 4
    CHECK (player_count BETWEEN 2 AND 4),
  status VARCHAR(20) NOT NULL                -- 'waiting', 'playing', 'finished'
    DEFAULT 'waiting',
  current_level INTEGER DEFAULT 1,
  lives INTEGER NOT NULL,                    -- 남은 생명
  shurikens INTEGER NOT NULL,                -- 남은 수리검
  played_cards INTEGER[] DEFAULT '{}',       -- 플레이된 카드 배열
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- players: 플레이어 정보
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,                     -- 익명 사용자 ID
  name VARCHAR(50) NOT NULL,
  position INTEGER NOT NULL                  -- 플레이어 순서 (0-3)
    CHECK (position BETWEEN 0 AND 3),
  cards INTEGER[] DEFAULT '{}',              -- 손패 (암호화 필요 시 고려)
  is_ready BOOLEAN DEFAULT FALSE,
  is_connected BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(room_id, position)
);

-- game_events: 게임 이벤트 (실시간 동기화)
CREATE TABLE game_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
  event_type VARCHAR(50) NOT NULL,           -- 'card_played', 'shuriken_proposed', 'vote_cast', 'level_complete', 'mistake'
  player_id UUID REFERENCES players(id),
  data JSONB,                                -- 이벤트별 데이터
  created_at TIMESTAMP DEFAULT NOW()
);

-- shuriken_votes: 수리검 투표
CREATE TABLE shuriken_votes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
  proposal_id UUID NOT NULL,                 -- 제안 ID (여러 제안 구분)
  player_id UUID REFERENCES players(id),
  vote BOOLEAN NOT NULL,                     -- true: 찬성, false: 반대
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(proposal_id, player_id)
);

-- 인덱스 생성
CREATE INDEX idx_rooms_code ON rooms(code);
CREATE INDEX idx_players_room ON players(room_id);
CREATE INDEX idx_events_room ON game_events(room_id, created_at DESC);
CREATE INDEX idx_votes_proposal ON shuriken_votes(proposal_id);

-- Row Level Security (RLS) 정책
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE shuriken_votes ENABLE ROW LEVEL SECURITY;

-- 누구나 읽기 가능
CREATE POLICY "rooms_select" ON rooms FOR SELECT USING (true);
CREATE POLICY "players_select" ON players FOR SELECT USING (true);
CREATE POLICY "events_select" ON game_events FOR SELECT USING (true);
CREATE POLICY "votes_select" ON shuriken_votes FOR SELECT USING (true);

-- 누구나 쓰기 가능 (실제 프로덕션에서는 제한 필요)
CREATE POLICY "rooms_insert" ON rooms FOR INSERT WITH CHECK (true);
CREATE POLICY "players_insert" ON players FOR INSERT WITH CHECK (true);
CREATE POLICY "events_insert" ON game_events FOR INSERT WITH CHECK (true);
CREATE POLICY "votes_insert" ON shuriken_votes FOR INSERT WITH CHECK (true);

-- 업데이트 정책
CREATE POLICY "rooms_update" ON rooms FOR UPDATE USING (true);
CREATE POLICY "players_update" ON players FOR UPDATE USING (true);
```

### Riverpod Provider 구조

```dart
// shared/providers/supabase_provider.dart
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// features/game/providers/game_providers.dart
final gameStateProvider = StateNotifierProvider.family<GameNotifier, GameState, String>((ref, roomId) {
  return GameNotifier(
    ref.watch(supabaseProvider),
    roomId,
  );
});

// Realtime 이벤트 스트림
final gameEventsProvider = StreamProvider.family<List<GameEvent>, String>((ref, roomId) {
  final supabase = ref.watch(supabaseProvider);
  return supabase
    .from('game_events')
    .stream(primaryKey: ['id'])
    .eq('room_id', roomId)
    .order('created_at')
    .map((events) => events.map((e) => GameEvent.fromJson(e)).toList());
});
```

---

## Phase 0: 프로젝트 초기 설정

**예상 시간**: 2-3시간

- [ ] Flutter 프로젝트 생성 (`flutter create the_mind`) (난이도: ⭐, 예상: 10분)
- [ ] pubspec.yaml 의존성 추가 (난이도: ⭐, 예상: 20분)
  ```yaml
  dependencies:
    flutter_riverpod: ^2.5.1
    go_router: ^14.0.0
    supabase_flutter: ^2.5.0
    flutter_animate: ^4.5.0
    freezed_annotation: ^2.4.1
    json_annotation: ^4.9.0
    uuid: ^4.3.3
    
  dev_dependencies:
    build_runner: ^2.4.8
    freezed: ^2.5.2
    json_serializable: ^6.7.1
    riverpod_lint: ^2.3.10
  ```
- [ ] 폴더 구조 생성 (feature-first) (난이도: ⭐, 예상: 15분)
- [ ] Supabase 프로젝트 생성 및 설정 (난이도: ⭐⭐, 예상: 30분)
- [ ] 환경변수 설정 (.env, Supabase URL/anon key) (난이도: ⭐, 예상: 15분)
- [ ] Supabase Flutter 초기화 코드 작성 (main.dart) (난이도: ⭐, 예상: 20분)
- [ ] README.md 업데이트 (프로젝트 설명, 설치 방법) (난이도: ⭐, 예상: 20분, parallelizable with: env-setup)
- [ ] .gitignore 업데이트 (.env, *.g.dart, *.freezed.dart) (난이도: ⭐, 예상: 5분)

---

## Phase 1: 코어 게임 로직 (플랫폼 독립적)

**예상 시간**: 6-8시간

### 1.1 데이터 모델 정의

- [ ] `GameCard` 모델 생성 (@freezed, 번호 1-100) (난이도: ⭐, 예상: 20분)
  ```dart
  @freezed
  class GameCard with _$GameCard {
    const factory GameCard({
      required int number,  // 1-100
    }) = _GameCard;
  }
  ```
- [ ] `Player` 모델 생성 (난이도: ⭐, 예상: 30분)
  ```dart
  @freezed
  class Player with _$Player {
    const factory Player({
      required String id,
      required String name,
      required int position,
      required List<GameCard> cards,
      @Default(false) bool isReady,
      @Default(true) bool isConnected,
    }) = _Player;
    
    factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  }
  ```
- [ ] `GameConfig` 모델 생성 (인원별 설정) (난이도: ⭐, 예상: 40분)
  ```dart
  @freezed
  class GameConfig with _$GameConfig {
    const factory GameConfig({
      required int playerCount,      // 2, 3, 4
      required int maxLevel,          // 12, 10, 8
      required int initialLives,      // 2, 3, 4
      required int initialShurikens,  // 1, 1, 1
    }) = _GameConfig;
    
    factory GameConfig.forPlayerCount(int count) {
      switch (count) {
        case 2: return GameConfig(playerCount: 2, maxLevel: 12, initialLives: 2, initialShurikens: 1);
        case 3: return GameConfig(playerCount: 3, maxLevel: 10, initialLives: 3, initialShurikens: 1);
        case 4: return GameConfig(playerCount: 4, maxLevel: 8, initialLives: 4, initialShurikens: 1);
        default: throw ArgumentError('Invalid player count');
      }
    }
  }
  ```
- [ ] `GameState` 모델 생성 (난이도: ⭐⭐, 예상: 1시간)
  ```dart
  @freezed
  class GameState with _$GameState {
    const factory GameState({
      required String roomId,
      required GameConfig config,
      required List<Player> players,
      required int currentLevel,
      required int lives,
      required int shurikens,
      required List<int> playedCards,
      required GamePhase phase,
      String? winnerId,
    }) = _GameState;
    
    factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  }
  
  enum GamePhase { lobby, ready, playing, levelComplete, gameOver, victory }
  ```
- [ ] build_runner 실행 (코드 생성) (난이도: ⭐, 예상: 5분, depends on: all-models)

### 1.2 게임 로직 구현

- [ ] 카드 셔플 알고리즘 (Fisher-Yates) (난이도: ⭐⭐, 예상: 1시간)
  ```dart
  List<GameCard> generateDeck() {
    final cards = List.generate(100, (i) => GameCard(number: i + 1));
    cards.shuffle();
    return cards;
  }
  ```
- [ ] 레벨별 카드 배분 로직 (난이도: ⭐⭐, 예상: 1.5시간)
  ```dart
  Map<String, List<GameCard>> distributeCards(int level, List<Player> players) {
    final deck = generateDeck();
    final cardsPerPlayer = level;
    final result = <String, List<GameCard>>{};
    
    for (var i = 0; i < players.length; i++) {
      result[players[i].id] = deck.skip(i * cardsPerPlayer).take(cardsPerPlayer).toList();
    }
    
    return result;
  }
  ```
- [ ] 카드 검증 로직 (순서 체크) (난이도: ⭐⭐, 예상: 1시간)
  ```dart
  bool isValidCardPlay(int cardNumber, List<int> playedCards) {
    if (playedCards.isEmpty) return true;
    return cardNumber > playedCards.last;
  }
  ```
- [ ] 실수 처리 로직 (생명 감소, 카드 공개) (난이도: ⭐⭐, 예상: 1시간)
- [ ] 수리검 사용 로직 (모든 플레이어 최저값 제거) (난이도: ⭐⭐, 예상: 1시간)
  ```dart
  void useShurikenEffect(GameState state) {
    for (var player in state.players) {
      if (player.cards.isNotEmpty) {
        player.cards.removeAt(0);  // 최저값 제거 (정렬 가정)
      }
    }
    state.shurikens--;
  }
  ```
- [ ] 보상 시스템 구현 (레벨별) (난이도: ⭐, 예상: 40분)
  ```dart
  void applyLevelReward(int level, GameState state) {
    if ([2, 5, 8, 11].contains(level)) {
      state.shurikens++;
    }
    if ([3, 6, 9].contains(level)) {
      state.lives++;
    }
  }
  ```
- [ ] 승리/패배 조건 체크 (난이도: ⭐, 예상: 30분)
  ```dart
  bool checkVictory(GameState state) {
    return state.currentLevel > state.config.maxLevel;
  }
  
  bool checkDefeat(GameState state) {
    return state.lives <= 0;
  }
  ```

---

## Phase 2: Supabase 백엔드 설정

**예상 시간**: 3-4시간

- [ ] Supabase 프로젝트 생성 (웹 콘솔) (난이도: ⭐, 예상: 15분)
- [ ] 데이터베이스 테이블 생성 (SQL 실행) (난이도: ⭐⭐, 예상: 1시간)
  - rooms, players, game_events, shuriken_votes
  - 위 스키마 섹션 참조
- [ ] RLS 정책 설정 (난이도: ⭐⭐, 예상: 1시간)
- [ ] Realtime 활성화 (rooms, game_events 테이블) (난이도: ⭐, 예상: 20분)
- [ ] Supabase Flutter 클라이언트 초기화 테스트 (난이도: ⭐, 예상: 30분)
- [ ] 방 생성 API 함수 작성 (난이도: ⭐⭐, 예상: 1시간)
  ```dart
  Future<Room> createRoom(int playerCount) async {
    final code = generateRoomCode();  // 6자리 랜덤
    final config = GameConfig.forPlayerCount(playerCount);
    
    final response = await supabase.from('rooms').insert({
      'code': code,
      'player_count': playerCount,
      'lives': config.initialLives,
      'shurikens': config.initialShurikens,
    }).select().single();
    
    return Room.fromJson(response);
  }
  ```
- [ ] 방 참가 API 함수 작성 (난이도: ⭐⭐, 예상: 1시간)

---

## Phase 3: UI/UX 기본 구현

**예상 시간**: 10-12시간

### 3.1 공통 위젯

- [ ] 카드 위젯 (`CardWidget`) (난이도: ⭐⭐, 예상: 1.5시간, parallelizable with: home-screen)
  - 카드 번호 표시
  - 앞면/뒷면 디자인
  - 터치 영역 최소 48x48dp
- [ ] 생명 표시 위젯 (하트 아이콘) (난이도: ⭐, 예상: 30분, parallelizable with: card-widget)
- [ ] 수리검 표시 위젯 (별 아이콘) (난이도: ⭐, 예상: 30분, parallelizable with: card-widget)

### 3.2 화면 구현

- [ ] 홈 화면 (난이도: ⭐⭐, 예상: 2시간)
  - 게임 제목 표시
  - "게임 시작" 버튼
  - 인원 선택 (2/3/4인) 라디오 버튼
  - "방 참가" 버튼 (코드 입력)
- [ ] 로비 화면 (난이도: ⭐⭐⭐, 예상: 3시간, depends on: home-screen)
  - 방 코드 표시 (공유 가능)
  - 참가 플레이어 목록 (실시간 업데이트)
  - 준비 상태 표시
  - "게임 시작" 버튼 (방장만, 모두 준비 시 활성화)
  - 나가기 버튼
- [ ] 게임 플레이 화면 (난이도: ⭐⭐⭐⭐, 예상: 5시간, depends on: lobby-screen)
  - 상단: 레벨 표시, 생명, 수리검
  - 중앙: 플레이된 카드 덱 (스택)
  - 하단: 내 손패 (카드 배열)
  - 수리검 제안 버튼 (하단 중앙)
  - 플레이어 상태 표시 (카드 남은 수)
- [ ] 레벨 클리어 화면 (오버레이) (난이도: ⭐⭐, 예상: 1.5시간)
  - "레벨 N 클리어!" 메시지
  - 보상 표시 (생명/수리검 +1)
  - "다음 레벨" 버튼
- [ ] 결과 화면 (난이도: ⭐, 예상: 1시간)
  - 승리/패배 메시지
  - 최종 레벨 표시
  - "다시 하기" 버튼
  - "홈으로" 버튼

### 3.3 라우팅 설정

- [ ] go_router 설정 (난이도: ⭐⭐, 예상: 1시간)
  ```dart
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/lobby/:roomCode', builder: (context, state) => LobbyScreen(roomCode: state.pathParameters['roomCode']!)),
      GoRoute(path: '/game/:roomCode', builder: (context, state) => GameScreen(roomCode: state.pathParameters['roomCode']!)),
      GoRoute(path: '/result/:roomCode', builder: (context, state) => ResultScreen(roomCode: state.pathParameters['roomCode']!)),
    ],
  );
  ```

---

## Phase 4: 실시간 멀티플레이어

**예상 시간**: 8-10시간

### 4.1 방 관리

- [ ] 방 생성 로직 (6자리 코드 생성) (난이도: ⭐⭐, 예상: 1.5시간)
  ```dart
  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';  // 혼동 문자 제외
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
  ```
- [ ] 방 참가 로직 (코드 입력 검증) (난이도: ⭐⭐, 예상: 1.5시간)
- [ ] 플레이어 추가/제거 처리 (난이도: ⭐⭐, 예상: 1시간)

### 4.2 실시간 동기화

- [ ] Supabase Realtime 구독 설정 (난이도: ⭐⭐⭐, 예상: 2시간)
  ```dart
  void subscribeToRoom(String roomId) {
    supabase.from('rooms').stream(primaryKey: ['id'])
      .eq('id', roomId)
      .listen((data) {
        ref.read(gameStateProvider(roomId).notifier).updateFromRemote(data);
      });
  }
  ```
- [ ] 플레이어 상태 동기화 (난이도: ⭐⭐, 예상: 1.5시간)
- [ ] 카드 내기 이벤트 브로드캐스트 (난이도: ⭐⭐⭐, 예상: 2시간)
  ```dart
  Future<void> playCard(int cardNumber) async {
    await supabase.from('game_events').insert({
      'room_id': roomId,
      'event_type': 'card_played',
      'player_id': playerId,
      'data': {'card': cardNumber},
    });
  }
  ```
- [ ] 실수 처리 및 생명 감소 동기화 (난이도: ⭐⭐⭐, 예상: 2시간)
- [ ] 레벨 진행 동기화 (난이도: ⭐⭐, 예상: 1.5시간)

### 4.3 수리검 시스템

- [ ] 수리검 제안 UI 및 로직 (난이도: ⭐⭐⭐, 예상: 2시간)
- [ ] 투표 시스템 구현 (난이도: ⭐⭐⭐⭐, 예상: 3시간)
  - 제안 브로드캐스트
  - 각 플레이어 투표 (찬성/반대)
  - 만장일치 체크
  - 수리검 효과 실행
- [ ] 투표 UI (모달/오버레이) (난이도: ⭐⭐, 예상: 1.5시간)

### 4.4 연결 관리

- [ ] 연결 끊김 감지 (난이도: ⭐⭐⭐, 예상: 2시간)
- [ ] 재접속 처리 (난이도: ⭐⭐⭐, 예상: 2시간)
- [ ] 타임아웃 처리 (30초 무응답 시) (난이도: ⭐⭐, 예상: 1시간)

---

## Phase 5: 애니메이션 & 폴리시

**예상 시간**: 6-8시간

### 5.1 카드 애니메이션

- [ ] 카드 드래그앤드롭 (난이도: ⭐⭐⭐, 예상: 2.5시간)
  ```dart
  Draggable<GameCard>(
    data: card,
    feedback: CardWidget(card: card, isDragging: true),
    childWhenDragging: Opacity(opacity: 0.3, child: CardWidget(card: card)),
    child: CardWidget(card: card),
  )
  ```
- [ ] 햅틱 피드백 (카드 드래그/드롭 시) (난이도: ⭐, 예상: 30분)
  ```dart
  HapticFeedback.mediumImpact();
  ```
- [ ] 카드 배분 애니메이션 (한 장씩 날아가는 효과) (난이도: ⭐⭐⭐, 예상: 2시간)
  ```dart
  CardWidget(card: card)
    .animate()
    .fadeIn(duration: 200.ms)
    .then(delay: 100.ms)
    .slide(begin: Offset(0, -1), curve: Curves.easeOut);
  ```
- [ ] 카드 뒤집기 애니메이션 (난이도: ⭐⭐, 예상: 1시간)

### 5.2 피드백 효과

- [ ] 실수 발생 시 shake 효과 (난이도: ⭐⭐, 예상: 1시간)
  ```dart
  Container(...)
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .shake(duration: 300.ms, hz: 4);
  ```
- [ ] 레벨 클리어 축하 애니메이션 (난이도: ⭐⭐, 예상: 1.5시간)
  - 파티클 효과 또는 confetti
- [ ] 생명/수리검 증감 애니메이션 (난이도: ⭐, 예상: 1시간)
  ```dart
  Text('$lives')
    .animate()
    .scale(begin: Offset(1, 1), end: Offset(1.3, 1.3))
    .then()
    .scale(begin: Offset(1.3, 1.3), end: Offset(1, 1));
  ```

### 5.3 사운드 (선택)

- [ ] 카드 내는 소리 (난이도: ⭐, 예상: 30분, parallelizable with: mistake-sound)
- [ ] 실수 시 소리 (난이도: ⭐, 예상: 30분, parallelizable with: card-sound)
- [ ] 레벨 클리어 소리 (난이도: ⭐, 예상: 30분, parallelizable with: card-sound)

---

## Phase 6: Web 배포 (Vercel)

**예상 시간**: 2-3시간

- [ ] Flutter Web 빌드 설정 (난이도: ⭐, 예상: 20분)
  - `flutter build web --release --web-renderer canvaskit`
- [ ] 번들 크기 최적화 (난이도: ⭐⭐, 예상: 1시간)
  - Tree shaking 확인
  - 이미지 압축
- [ ] vercel.json 생성 (난이도: ⭐, 예상: 15분)
  ```json
  {
    "buildCommand": "flutter build web --release",
    "outputDirectory": "build/web",
    "framework": null,
    "rewrites": [
      { "source": "/(.*)", "destination": "/index.html" }
    ]
  }
  ```
- [ ] Vercel 프로젝트 생성 및 연결 (난이도: ⭐, 예상: 30분)
- [ ] 환경변수 설정 (Supabase URL/Key) (난이도: ⭐, 예상: 15분)
- [ ] 첫 배포 및 동작 테스트 (난이도: ⭐⭐, 예상: 1시간)
- [ ] 모바일 반응형 체크 (iOS Safari, Android Chrome) (난이도: ⭐⭐, 예상: 1시간)

---

## Phase 7: 모바일 빌드 & 배포

**예상 시간**: 4-6시간

### 7.1 iOS

- [ ] Xcode 프로젝트 설정 (Bundle ID, Team) (난이도: ⭐⭐, 예상: 1시간)
- [ ] 앱 아이콘 및 스플래시 스크린 (난이도: ⭐, 예상: 30분)
- [ ] TestFlight 빌드 (난이도: ⭐⭐, 예상: 1시간)
- [ ] App Store Connect 설정 (난이도: ⭐⭐, 예상: 1.5시간)
- [ ] 스크린샷 및 설명 작성 (난이도: ⭐, 예상: 1시간)

### 7.2 Android

- [ ] 서명 키 생성 (keystore) (난이도: ⭐, 예상: 20분)
- [ ] build.gradle 설정 (난이도: ⭐, 예상: 30분)
- [ ] 앱 아이콘 및 스플래시 스크린 (난이도: ⭐, 예상: 30분)
- [ ] Google Play Console 설정 (난이도: ⭐⭐, 예상: 1시간)
- [ ] 내부 테스트 트랙 배포 (난이도: ⭐, 예상: 1시간)
- [ ] 스크린샷 및 설명 작성 (난이도: ⭐, 예상: 1시간)

---

## Phase 8: 추가 기능 (후순위)

**예상 시간**: 15-20시간

### 8.1 변형 규칙

- [ ] 블라인드 모드 구현 (난이도: ⭐⭐, 예상: 2시간)
  - 다른 플레이어 상태 숨김
- [ ] 짧은 게임 모드 (목표 레벨 축소) (난이도: ⭐, 예상: 1시간)
- [ ] 익스트림 모드 (시작 생명 -1) (난이도: ⭐, 예상: 1시간)
- [ ] 초보자 모드 (레벨 1-3 생명 무적) (난이도: ⭐, 예상: 1시간)

### 8.2 게임 기록

- [ ] 게임 히스토리 저장 (Supabase) (난이도: ⭐⭐, 예상: 2시간)
- [ ] 통계 화면 (승률, 평균 레벨) (난이도: ⭐⭐, 예상: 3시간)
- [ ] 리더보드 (최고 레벨) (난이도: ⭐⭐⭐, 예상: 3시간)

### 8.3 AI 봇 (후순위)

- [ ] 간단한 AI 로직 설계 (난이도: ⭐⭐⭐⭐, 예상: 4시간)
  - 카드 분포 추정 (Bayesian 접근)
  - 타이밍 결정 (확률 기반)
- [ ] AI 플레이어 통합 (난이도: ⭐⭐⭐, 예상: 3시간)
- [ ] 1인 연습 모드 UI (난이도: ⭐⭐, 예상: 2시간)
- [ ] AI 난이도 조절 (쉬움/보통/어려움) (난이도: ⭐⭐⭐, 예상: 3시간)

### 8.4 다국어 지원

- [ ] i18n 패키지 추가 (flutter_localizations) (난이도: ⭐, 예상: 30분)
- [ ] 한국어/영어 번역 파일 작성 (난이도: ⭐⭐, 예상: 2시간)
- [ ] 언어 선택 UI (난이도: ⭐, 예상: 1시간)

---

## 테스트 계획 (구현 후)

**예상 시간**: 4-6시간

### 핵심 기능 테스트 (우선순위 높음)

- [ ] 카드 배분 알고리즘 단위 테스트 (난이도: ⭐, 예상: 1시간)
  ```dart
  test('2인 게임 레벨 5에서 각 플레이어 5장씩', () {
    final result = distributeCards(5, [player1, player2]);
    expect(result[player1.id].length, 5);
    expect(result[player2.id].length, 5);
  });
  ```
- [ ] 게임 로직 검증 테스트 (난이도: ⭐⭐, 예상: 2시간)
  - 카드 순서 검증
  - 보상 시스템
  - 승리/패배 조건
- [ ] Supabase 연결 테스트 (난이도: ⭐, 예상: 1시간)

### 선택적 테스트

- [ ] Widget 테스트 (카드 위젯, 버튼 등) (난이도: ⭐⭐, 예상: 2시간)
- [ ] Integration 테스트 (전체 게임 플로우) (난이도: ⭐⭐⭐, 예상: 3시간)

---

## 도전 과제 및 해결 방안

| 도전 과제 | 해결 방안 | 우선순위 |
|----------|----------|---------|
| **무언의 소통 구현** | 카드 호버 시 미묘한 글로우 효과, 플레이어 "집중" 인디케이터 | 높음 |
| **Supabase Realtime 지연** | Optimistic UI 업데이트 (로컬 상태 즉시 반영, 서버 확인 후 롤백) | 높음 |
| **Flutter Web 성능** | CanvasKit 렌더러, 이미지 최적화, Code splitting | 중간 |
| **동시 카드 내기 처리** | Supabase timestamp 기반 순서 결정, conflict resolution | 높음 |
| **모바일 터치 정확도** | 카드 크기 최소 48x48dp, 드래그 영역 확대 (padding) | 중간 |
| **카드 데이터 보안** | 손패를 클라이언트에만 저장, 서버는 암호화 또는 검증만 | 낮음 (프로토타입) |
| **네트워크 재연결** | Supabase 자동 재연결 + 로컬 큐 (실패 이벤트 재전송) | 중간 |

---

## 예상 타임라인

| Phase | 예상 시간 | 누적 시간 | 완료 기준 |
|-------|----------|----------|----------|
| Phase 0: 프로젝트 설정 | 2-3시간 | 3시간 | Flutter 앱 실행 + Supabase 연결 확인 |
| Phase 1: 코어 로직 | 6-8시간 | 11시간 | 모든 모델 정의 + 로직 단위 테스트 통과 |
| Phase 2: Supabase 설정 | 3-4시간 | 15시간 | 테이블 생성 + Realtime 구독 테스트 |
| Phase 3: UI/UX | 10-12시간 | 27시간 | 모든 화면 렌더링 (더미 데이터) |
| Phase 4: 멀티플레이어 | 8-10시간 | 37시간 | 2인 게임 end-to-end 플레이 성공 |
| Phase 5: 애니메이션 | 6-8시간 | 45시간 | 주요 애니메이션 동작 |
| Phase 6: Vercel 배포 | 2-3시간 | 48시간 | Web 버전 접속 가능 |
| Phase 7: 모바일 배포 | 4-6시간 | 54시간 | TestFlight / 내부 테스트 배포 |
| **Phase 1-7 총합** | **~54시간** | | **MVP 완성** |
| Phase 8: 추가 기능 | 15-20시간 | 74시간 | 변형 규칙 + AI 봇 (선택) |
| 테스트 | 4-6시간 | 80시간 | 핵심 기능 테스트 통과 |

**예상 개발 기간**: 약 10-12일 (하루 7-8시간 기준)

---

## 구현 우선순위 (MVP)

### Must Have (Phase 1-6)
1. 2-4인 멀티플레이어 기본 게임
2. 생명/수리검 시스템
3. 레벨 진행 및 보상
4. 실시간 동기화
5. Web 배포

### Should Have (Phase 7)
1. 모바일 앱 (iOS/Android)
2. 기본 애니메이션
3. 연결 끊김 처리

### Nice to Have (Phase 8)
1. 변형 규칙
2. 게임 통계
3. AI 봇
4. 다국어 지원

---

## 다음 단계

이 계획을 실행하려면:

1. **Atlas에게 계획 실행 요청**:
   ```
   Atlas, .sisyphus/plans/the-mind-flutter.md 실행해줘
   ```

2. **단계별 수동 실행** (권장 - 학습 목적):
   - Phase 0부터 순차적으로 체크박스 완료
   - 각 Phase 완료 후 검증
   - 문제 발견 시 즉시 수정

3. **병렬 작업 활용**:
   - `parallelizable with` 표시된 작업은 동시 진행 가능
   - 예: Phase 3에서 card-widget, home-screen 동시 개발

---

**문서 버전**: 1.0  
**최종 수정**: 2026-01-28  
**작성자**: Prometheus (Planning Agent)
