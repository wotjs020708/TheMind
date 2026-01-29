# The Mind - Phase 2: 카드 버그 수정 + QR 기능 + 설명서 확인

## TL;DR

> **Quick Summary**: 치명적인 카드 공유 버그 수정 (최우선), QR 코드 방 참여 기능 추가, 게임 설명서 동작 확인
> 
> **Deliverables**:
> - 각 플레이어가 자신만의 고유 카드를 보고 플레이하도록 수정
> - 로비에서 QR 코드로 방 공유 기능
> - 게임 설명서 다이얼로그 동작 확인
> 
> **Estimated Effort**: Medium-High (3-4 hours)
> **Parallel Execution**: NO - 순차 실행 (버그 수정이 핵심)
> **Critical Path**: Bug Fix → QR Feature → Verification

---

## Context

### Original Request
사용자가 3가지 요청:
1. QR로 방 참여할 수 있게
2. 카드가 다들 똑같고 하나 내면 다른 사용자도 카드가 내져 (심각한 버그!)
3. 홈 화면에 설명서 추가 (이미 존재 - 확인 필요)

### Research Findings

**Bug 2 - 카드 버그 (심각!):**
- **근본 원인**: `game_screen.dart` 라인 154-155에서 `_currentPlayerId`가 항상 첫 번째 플레이어로 설정됨
  ```dart
  _currentPlayerId ??= gameState.players.isNotEmpty ? gameState.players.first.id : null;
  ```
- 로비에서 받은 `playerId`를 게임 화면으로 전달하지 않음
- 결과: 모든 클라이언트가 같은 플레이어(첫 번째)의 카드를 보고 조작함
- 서버 로직은 정상 (카드 분배/제거는 플레이어별로 올바르게 동작)

**QR 기능:**
- 현재 QR 관련 패키지 없음
- 필요: `qr_flutter` (QR 생성), `share_plus` (공유)
- 라우팅은 `/lobby/:roomCode` 형태로 이미 지원

**설명서:**
- `home_screen.dart`에 이미 구현됨 (라인 156-164, 319-348)
- `showAdaptiveDialog()` 사용
- 배포 확인 또는 플랫폼 호환성 확인 필요

---

## Work Objectives

### Core Objective
카드 버그를 수정하여 게임이 정상적으로 플레이되도록 함

### Concrete Deliverables
1. `app_router.dart`: 게임 화면에 `playerId` 전달하도록 수정
2. `lobby_screen.dart`: 게임 시작 시 `playerId`를 라우트 파라미터로 전달
3. `game_screen.dart`: 라우트에서 `playerId` 받아서 사용
4. `pubspec.yaml`: `qr_flutter`, `share_plus` 패키지 추가
5. `lobby_screen.dart`: QR 코드 표시 및 공유 버튼 추가

### Definition of Done
- [ ] 4명이 게임 시작 → 각자 다른 카드를 봄
- [ ] 한 명이 카드를 내면 그 플레이어의 카드만 사라짐
- [ ] 로비에서 QR 버튼 클릭 → QR 다이얼로그 표시
- [ ] QR 스캔 또는 링크 공유로 방 참여 가능
- [ ] 홈 화면 "게임 설명서" 버튼 동작 확인

### Must Have
- playerId를 로비 → 게임 화면으로 안전하게 전달
- QR 코드에 방 코드 또는 딥링크 포함
- 기존 기능 유지

### Must NOT Have (Guardrails)
- SharedPreferences 사용 금지 (라우트 파라미터로 충분)
- 복잡한 딥링크 설정 금지 (단순 QR 코드로 시작)
- 서버 로직 수정 금지 (클라이언트만 수정)

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO
- **User wants tests**: Manual verification
- **QA approach**: 4명 수동 테스트

---

## TODOs

- [ ] 1. 카드 버그 수정 - playerId 전달 체계 구축

  **What to do**:
  
  **Step 1: 라우터 수정** (`app_router.dart`)
  - 게임 라우트에 `playerId` 쿼리 파라미터 추가
  - `/game/:roomCode?playerId=xxx` 형태로 변경
  
  **Step 2: 로비 화면 수정** (`lobby_screen.dart`)
  - 게임 시작 시 `context.go('/game/${widget.roomCode}?playerId=${lobbyState.currentPlayerId}')` 형태로 이동
  
  **Step 3: 게임 화면 수정** (`game_screen.dart`)
  - 생성자에 `playerId` 파라미터 추가
  - `_currentPlayerId`를 생성자에서 받은 값으로 초기화
  - fallback 로직 제거 또는 경고 표시

  **Must NOT do**:
  - SharedPreferences 사용 금지
  - 서버 로직 수정 금지

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 여러 파일 수정, 라우팅 로직 변경
  - **Skills**: None needed
  
  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Blocks**: All other tasks
  - **Blocked By**: None

  **References**:
  - `the_mind/lib/core/router/app_router.dart:21-28` - 게임 라우트 정의
  - `the_mind/lib/features/lobby/presentation/screens/lobby_screen.dart:157-162` - 게임 시작 시 이동 로직
  - `the_mind/lib/features/game/presentation/screens/game_screen.dart:21-28` - GameScreen 클래스 정의
  - `the_mind/lib/features/game/presentation/screens/game_screen.dart:154-155` - 버그 있는 currentPlayerId 설정

  **Code Changes**:

  **File 1: `the_mind/lib/core/router/app_router.dart`**
  
  변경 전 (라인 22-28):
  ```dart
  GoRoute(
    path: '/game/:roomCode',
    name: 'game',
    builder: (context, state) {
      final roomCode = state.pathParameters['roomCode']!;
      return GameScreen(roomCode: roomCode);
    },
  ),
  ```
  
  변경 후:
  ```dart
  GoRoute(
    path: '/game/:roomCode',
    name: 'game',
    builder: (context, state) {
      final roomCode = state.pathParameters['roomCode']!;
      final playerId = state.uri.queryParameters['playerId'];
      return GameScreen(roomCode: roomCode, playerId: playerId);
    },
  ),
  ```

  **File 2: `the_mind/lib/features/game/presentation/screens/game_screen.dart`**
  
  변경 전 (라인 21-28):
  ```dart
  class GameScreen extends ConsumerStatefulWidget {
    final String roomCode;

    const GameScreen({super.key, required this.roomCode});

    @override
    ConsumerState<GameScreen> createState() => _GameScreenState();
  }
  ```
  
  변경 후:
  ```dart
  class GameScreen extends ConsumerStatefulWidget {
    final String roomCode;
    final String? playerId;

    const GameScreen({super.key, required this.roomCode, this.playerId});

    @override
    ConsumerState<GameScreen> createState() => _GameScreenState();
  }
  ```

  그리고 라인 32에 `_currentPlayerId` 초기화 수정:
  
  변경 전:
  ```dart
  String? _currentPlayerId;
  ```
  
  변경 후:
  ```dart
  late String? _currentPlayerId;
  
  @override
  void initState() {
    super.initState();
    _currentPlayerId = widget.playerId;  // 라우트에서 받은 playerId 사용
    _loadRoomId();
  }
  ```

  그리고 라인 154-155의 fallback 로직 수정:
  
  변경 전:
  ```dart
  _currentPlayerId ??=
      gameState.players.isNotEmpty ? gameState.players.first.id : null;
  ```
  
  변경 후:
  ```dart
  // playerId가 없으면 에러 표시 (fallback 제거)
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
  ```

  **File 3: `the_mind/lib/features/lobby/presentation/screens/lobby_screen.dart`**
  
  변경 전 (라인 157-162):
  ```dart
  if (lobbyState.room!.status == 'playing') {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/game/${widget.roomCode}');
    });
  }
  ```
  
  변경 후:
  ```dart
  if (lobbyState.room!.status == 'playing') {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerId = lobbyState.currentPlayerId;
      context.go('/game/${widget.roomCode}?playerId=$playerId');
    });
  }
  ```

  **Acceptance Criteria**:
  
  **Manual Verification (Browser)**:
  - [ ] 4개 브라우저에서 같은 방 접속
  - [ ] 전원 준비 → 게임 시작
  - [ ] 각 브라우저에서 "내 카드" 섹션 확인 → 모두 다른 카드 표시
  - [ ] 한 명이 카드 내기 → 그 플레이어의 카드만 사라짐
  - [ ] 다른 플레이어들의 카드 수는 변하지 않음

  **Commit**: YES
  - Message: `fix(game): pass playerId from lobby to game screen to fix card sharing bug`
  - Files: `app_router.dart`, `game_screen.dart`, `lobby_screen.dart`

---

- [ ] 2. QR 코드 방 공유 기능 추가

  **What to do**:
  
  **Step 1: 패키지 추가** (`pubspec.yaml`)
  - `qr_flutter: ^4.1.0` 추가
  - `share_plus: ^7.2.0` 추가 (선택)
  
  **Step 2: 로비 화면에 QR 버튼 추가** (`lobby_screen.dart`)
  - 방 코드 표시 영역 옆에 QR 아이콘 버튼 추가
  - 클릭 시 QR 코드 다이얼로그 표시
  - QR 코드에는 방 코드 또는 웹 URL 인코딩

  **Must NOT do**:
  - 복잡한 딥링크 설정 (추후 확장)
  - QR 스캐너 기능 (카메라 권한 필요)

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: UI 컴포넌트 추가
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: QR 다이얼로그 디자인
  
  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Blocks**: None
  - **Blocked By**: Task 1

  **References**:
  - `the_mind/pubspec.yaml:30-58` - dependencies 섹션
  - `the_mind/lib/features/lobby/presentation/screens/lobby_screen.dart:204-243` - 방 코드 표시 영역
  - `the_mind/lib/shared/widgets/adaptive/adaptive_dialog.dart` - 다이얼로그 패턴

  **Code Changes**:

  **File 1: `pubspec.yaml`**
  
  dependencies 섹션에 추가 (라인 58 이후):
  ```yaml
  # QR Code
  qr_flutter: ^4.1.0
  share_plus: ^7.2.2
  ```

  **File 2: `lobby_screen.dart`**
  
  상단에 import 추가:
  ```dart
  import 'package:qr_flutter/qr_flutter.dart';
  import 'package:share_plus/share_plus.dart';
  ```
  
  방 코드 표시 영역 (라인 204-243) 수정 - QR 버튼 추가:
  ```dart
  // 방 코드 표시 Container 내부, 방 코드 Text 아래에 추가
  const SizedBox(height: AppTheme.spacingMd),
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // QR 코드 보기 버튼
      TextButton.icon(
        onPressed: () => _showQRDialog(context),
        icon: const Icon(Icons.qr_code, size: 20),
        label: const Text('QR 코드'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
        ),
      ),
      const SizedBox(width: AppTheme.spacingMd),
      // 공유 버튼
      TextButton.icon(
        onPressed: () => _shareRoomCode(),
        icon: const Icon(Icons.share, size: 20),
        label: const Text('공유'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
        ),
      ),
    ],
  ),
  ```
  
  새 메서드 추가 (`_LobbyScreenState` 클래스 내부):
  ```dart
  void _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'QR 코드로 참가',
          style: TextStyle(color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: widget.roomCode,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '방 코드: ${widget.roomCode}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'QR 코드를 스캔하거나\n방 코드를 직접 입력하세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareRoomCode() async {
    await HapticFeedbackUtils.light();
    await Share.share(
      '더 마인드 게임에 참여하세요!\n방 코드: ${widget.roomCode}',
      subject: '더 마인드 - 방 초대',
    );
  }
  ```

  **Acceptance Criteria**:
  
  **Manual Verification (Browser)**:
  - [ ] 로비 화면에서 "QR 코드" 버튼 표시됨
  - [ ] 버튼 클릭 → QR 코드 다이얼로그 표시
  - [ ] QR 코드가 방 코드를 인코딩함 (다른 기기에서 스캔하여 확인)
  - [ ] "공유" 버튼 클릭 → 시스템 공유 시트 표시 (모바일)
  - [ ] 웹에서는 공유 버튼이 클립보드 복사 또는 기본 공유 동작

  **Commit**: YES
  - Message: `feat(lobby): add QR code display and share functionality`
  - Files: `pubspec.yaml`, `lobby_screen.dart`

---

- [ ] 3. 게임 설명서 동작 확인

  **What to do**:
  - 설명서는 이미 구현됨 (`home_screen.dart` 라인 156-164, 319-348)
  - 배포된 버전에서 동작 확인
  - 만약 동작하지 않으면 디버깅

  **Must NOT do**:
  - 불필요한 코드 수정

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 확인 작업
  - **Skills**: [`playwright`]
    - `playwright`: 브라우저 테스트
  
  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - `the_mind/lib/features/home/presentation/screens/home_screen.dart:156-164` - 버튼
  - `the_mind/lib/features/home/presentation/screens/home_screen.dart:319-348` - `_showGameInstructions()` 메서드

  **Acceptance Criteria**:
  
  **Manual Verification (Browser)**:
  - [ ] 홈 화면에서 "게임 설명서" 버튼 보임
  - [ ] 클릭 시 다이얼로그 표시
  - [ ] 다이얼로그에 게임 규칙 표시 (🎯, 🃏, ❤️, ⭐, 🏆)
  - [ ] "확인" 버튼으로 닫기 가능

  **Commit**: NO (코드 변경 없음, 확인만)

---

- [ ] 4. 빌드 및 배포

  **What to do**:
  - 패키지 추가 후 `flutter pub get`
  - Freezed 파일 재생성 필요 없음 (모델 변경 없음)
  - Git commit 및 push
  - Vercel 자동 배포 확인

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`git-master`]
  
  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Blocks**: None
  - **Blocked By**: Tasks 1, 2

  **Commands**:
  ```bash
  cd the_mind
  flutter pub get
  cd ..
  git add .
  git commit -m "fix(game): player card bug + feat(lobby): QR sharing"
  git push origin main
  ```

  **Acceptance Criteria**:
  - [ ] `flutter pub get` 성공
  - [ ] Git push 성공
  - [ ] Vercel 배포 완료

  **Commit**: Combined with previous tasks

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 1 | `fix(game): pass playerId from lobby to game screen to fix card sharing bug` | app_router.dart, game_screen.dart, lobby_screen.dart |
| 2 | `feat(lobby): add QR code display and share functionality` | pubspec.yaml, lobby_screen.dart |
| 3 | (none - verification) | - |
| 4 | (push all) | - |

---

## Success Criteria

### Final Verification Flow
```
1. 홈 화면에서 "게임 설명서" 버튼 클릭 → 규칙 다이얼로그 확인
2. 새 게임 생성 (4명)
3. 로비에서 "QR 코드" 버튼 클릭 → QR 다이얼로그 확인
4. 다른 3개 브라우저에서 방 코드로 참여
5. 전원 준비 → 게임 시작
6. 각 브라우저에서 서로 다른 카드 확인 (핵심!)
7. 한 명이 카드 내기 → 해당 플레이어만 카드 감소
8. 게임 정상 진행 확인
```

### Final Checklist
- [ ] 각 플레이어가 고유한 카드를 가짐
- [ ] 카드 플레이 시 해당 플레이어만 영향받음
- [ ] QR 코드로 방 코드 공유 가능
- [ ] 게임 설명서 다이얼로그 동작
- [ ] 기존 기능 정상 동작
