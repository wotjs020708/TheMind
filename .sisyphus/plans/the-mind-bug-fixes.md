# The Mind - Bug Fixes and Feature Addition

## TL;DR

> **Quick Summary**: Fix 3 critical bugs from 4-player testing (host detection, ready sync, card distribution) and add game instructions screen.
> 
> **Deliverables**:
> - Fixed host detection using `created_at` timestamp
> - Working real-time ready status synchronization
> - Cards distributed automatically when game starts
> - Game instructions dialog on home screen
> 
> **Estimated Effort**: Medium (2-3 hours)
> **Parallel Execution**: NO - sequential (bugs are interconnected)
> **Critical Path**: Bug 1 → Bug 2 → Bug 3 → Feature

---

## Context

### Original Request
User tested the deployed Flutter app with 4 players and found 3 critical bugs:
1. Host changes based on join order instead of staying fixed as room creator
2. Ready status doesn't sync in real-time to other players
3. Cards are empty when game starts (not distributed)

Additionally: Add game instructions to the home screen.

### Research Findings

**Bug 1 - Host Detection**:
- Current `isHost` getter (line 56-59 in `lobby_provider.dart`) uses `players.first.id == currentPlayerId`
- Players are ordered by `position` in the database query
- Position is assigned as `state.players.length` when joining, which is unreliable
- **Solution**: Order by `created_at` to maintain consistent host (first joiner)

**Bug 2 - Ready Status Sync**:
- The `subscribeToplayers` stream in `player_repository.dart` should emit on changes
- Supabase Realtime works on row-level changes
- The stream IS being subscribed to in `lobby_provider.dart` line 138-149
- **Issue**: Stream might not be emitting because of ordering inconsistency
- **Solution**: Will be fixed along with Bug 1 (ordering change)

**Bug 3 - Card Distribution**:
- `lobby_provider.startGame()` (line 197-208) ONLY updates room status to 'playing'
- It does NOT call card distribution
- `game_state_provider.startGame()` (line 309-319) DOES distribute cards
- **Problem**: Lobby doesn't know about game_state_provider
- **Solution**: Move card distribution to game initialization, triggered by room status change

---

## Work Objectives

### Core Objective
Fix the 3 critical bugs to make the 4-player game fully functional.

### Concrete Deliverables
- `player_repository.dart`: Order players by `created_at`
- `getPlayersByRoom()`: Also order by `created_at`
- `game_state_provider.dart`: Distribute cards when status changes to 'playing'
- `home_screen.dart`: Add game instructions button and dialog

### Definition of Done
- [ ] Create room, join with 4 players → First player remains host throughout
- [ ] Toggle ready status → All players see update immediately
- [ ] Start game → All players receive their cards (level 1 = 1 card each)
- [ ] Home screen shows "게임 설명서" button that opens rules dialog

### Must Have
- Host determination based on `created_at` timestamp
- Real-time sync of player list including ready status
- Automatic card distribution on game start
- Korean language for instructions

### Must NOT Have (Guardrails)
- DO NOT add `host_id` column to database (use existing `created_at`)
- DO NOT change position logic (keep for display order in game)
- DO NOT modify Supabase schema
- DO NOT break existing realtime subscriptions

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO (no automated tests set up)
- **User wants tests**: Manual verification
- **QA approach**: Manual testing with deployed app

### Manual Verification Procedures

Each task includes specific browser-based verification using the deployed Vercel app.

---

## TODOs

- [ ] 1. Fix Player Ordering to Use `created_at`

  **What to do**:
  - In `player_repository.dart`, change `subscribeToplayers()` to order by `created_at` instead of `position`
  - In `player_repository.dart`, change `getPlayersByRoom()` to also order by `created_at`
  - This ensures the first player (by timestamp) is always first in the list, making them the host

  **Must NOT do**:
  - Don't change the `position` field - it's still used for game display order
  - Don't modify the `isHost` getter logic in `lobby_provider.dart` - it will work once ordering is fixed

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Simple 2-line change in one file
  - **Skills**: None needed
  
  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential (must complete before Bug 2 verification)
  - **Blocks**: Bug 2, Bug 3
  - **Blocked By**: None

  **References**:
  - `the_mind/lib/features/lobby/data/repositories/player_repository.dart:84-92` - `subscribeToplayers()` method to modify
  - `the_mind/lib/features/lobby/data/repositories/player_repository.dart:39-46` - `getPlayersByRoom()` method to modify
  - `the_mind/lib/features/lobby/presentation/providers/lobby_provider.dart:56-59` - `isHost` getter that relies on `players.first`

  **Code Changes**:
  
  File: `the_mind/lib/features/lobby/data/repositories/player_repository.dart`
  
  Change line 44 from:
  ```dart
  .order('position');
  ```
  To:
  ```dart
  .order('created_at');
  ```
  
  Change line 90 from:
  ```dart
  .order('position')
  ```
  To:
  ```dart
  .order('created_at')
  ```

  **Acceptance Criteria**:
  
  **Manual Verification (Browser)**:
  - [ ] Open deployed app in 4 browser windows
  - [ ] Player 1: Create room with 4 players, join as "Host"
  - [ ] Player 2-4: Join room with different names
  - [ ] Verify: Player 1 ("Host") shows 👑 crown icon
  - [ ] Player 2: Leave and rejoin the room
  - [ ] Verify: Player 1 still shows 👑 crown icon (host unchanged)
  - [ ] Screenshot evidence saved

  **Commit**: YES
  - Message: `fix(lobby): order players by created_at to fix host detection`
  - Files: `player_repository.dart`

---

- [ ] 2. Verify Ready Status Real-time Sync

  **What to do**:
  - After Bug 1 fix, verify that ready status syncs properly
  - The realtime subscription should already work - the ordering fix may resolve the issue
  - If still not working, check Supabase RLS policies and realtime configuration

  **Must NOT do**:
  - Don't add unnecessary workarounds
  - Don't poll instead of using realtime

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Verification task, may require no code changes
  - **Skills**: [`playwright`]
    - `playwright`: For browser-based testing across multiple windows
  
  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Bug 3
  - **Blocked By**: Bug 1

  **References**:
  - `the_mind/lib/features/lobby/data/repositories/player_repository.dart:49-58` - `updateReadyStatus()` method
  - `the_mind/lib/features/lobby/presentation/providers/lobby_provider.dart:138-149` - `_subscribeToPlayers()` subscription
  - `the_mind/lib/features/lobby/presentation/providers/lobby_provider.dart:182-194` - `toggleReady()` method

  **Acceptance Criteria**:
  
  **Manual Verification (Browser)**:
  - [ ] Deploy Bug 1 fix first
  - [ ] Open 4 browser windows in deployed app
  - [ ] All 4 join the same room
  - [ ] Player 2: Click "준비" (Ready) button
  - [ ] Verify: All other players see Player 2's "준비" badge appear within 2 seconds
  - [ ] Player 2: Click "준비 취소" (Cancel Ready)
  - [ ] Verify: All other players see Player 2's "준비" badge disappear within 2 seconds
  - [ ] Repeat for Player 3 and Player 4
  - [ ] Screenshot evidence saved

  **Commit**: NO (verification only, unless code changes needed)

---

- [ ] 3. Fix Card Distribution on Game Start

  **What to do**:
  - In `game_state_provider.dart`, modify `_initialize()` to distribute cards when phase is 'playing' and players have no cards
  - Alternative: Call `_distributeCards(1)` when `_mapRoomStatusToPhase` detects transition to 'playing'
  - This ensures cards are distributed when the game screen loads after status change

  **Must NOT do**:
  - Don't modify `lobby_provider.dart` to call game logic (keep separation of concerns)
  - Don't add Riverpod cross-provider dependencies in lobby

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: Small logic addition in one file
  - **Skills**: None needed
  
  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: None
  - **Blocked By**: Bug 1, Bug 2

  **References**:
  - `the_mind/lib/features/game/presentation/providers/game_state_provider.dart:73-134` - `_initialize()` method
  - `the_mind/lib/features/game/presentation/providers/game_state_provider.dart:150-164` - `_mapRoomStatusToPhase()` method
  - `the_mind/lib/features/game/presentation/providers/game_state_provider.dart:387-404` - `_distributeCards()` method
  - `the_mind/lib/features/game/domain/services/game_logic_service.dart` - Game logic for card distribution

  **Code Changes**:
  
  File: `the_mind/lib/features/game/presentation/providers/game_state_provider.dart`
  
  In `_initialize()` method, after line 80 where initial state is created, add card distribution logic:
  
  ```dart
  // After state = AsyncValue.data(_createGameState(room, players));
  
  // 게임이 이미 시작된 상태이고 플레이어들에게 카드가 없으면 배분
  if (room.status == 'playing') {
    final hasCards = players.any((p) => p.cards.isNotEmpty);
    if (!hasCards) {
      // 카드 배분 (레벨 = 각 플레이어당 카드 수)
      await _distributeCards(room.currentLevel);
    }
  }
  ```

  **Acceptance Criteria**:
  
  **Manual Verification (Browser)**:
  - [ ] Open 4 browser windows, all join same room
  - [ ] All players click "준비"
  - [ ] Host clicks "게임 시작"
  - [ ] All players automatically navigate to game screen
  - [ ] Verify: Each player sees exactly 1 card (Level 1)
  - [ ] Cards are numbers between 1-100, all different
  - [ ] Complete Level 1, verify Level 2 shows 2 cards each
  - [ ] Screenshot evidence saved

  **Commit**: YES
  - Message: `fix(game): distribute cards when game initializes in playing state`
  - Files: `game_state_provider.dart`

---

- [ ] 4. Add Game Instructions to Home Screen

  **What to do**:
  - Add "게임 설명서" (Game Instructions) button to home screen
  - Create a dialog or bottom sheet with The Mind rules in Korean
  - Include: game objective, how to play, card rules, lives, shurikens, winning/losing conditions

  **Must NOT do**:
  - Don't create a separate screen (dialog is sufficient)
  - Don't add English translation (Korean only as per project convention)

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: UI component creation with styling
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: For consistent UI design matching existing app theme
  
  **Parallelization**:
  - **Can Run In Parallel**: YES (can be done independently)
  - **Parallel Group**: Can start after Bug 1
  - **Blocks**: None
  - **Blocked By**: None (but do after bugs for clean git history)

  **References**:
  - `the_mind/lib/features/home/presentation/screens/home_screen.dart` - Home screen to modify
  - `the_mind/lib/shared/widgets/adaptive/adaptive_dialog.dart` - Dialog pattern to follow
  - `the_mind/lib/shared/widgets/adaptive/adaptive_button.dart` - Button pattern to follow
  - `the_mind/lib/shared/theme/app_theme.dart` - Theme constants
  - `The_Mind_Rule.md` (project root) - Full game rules in Korean

  **UI Design**:
  - Button: Icon `Icons.help_outline` with text "게임 설명서"
  - Place between existing buttons on home screen
  - Dialog: Scrollable content with sections
    - 🎯 게임 목표
    - 🃏 게임 방법
    - ❤️ 생명
    - ⭐ 수리검
    - 🏆 승리/패배 조건

  **Acceptance Criteria**:
  
  **Manual Verification (Browser)**:
  - [ ] Open home screen
  - [ ] Verify "게임 설명서" button is visible
  - [ ] Click button → dialog opens
  - [ ] Dialog content is in Korean
  - [ ] Dialog is scrollable if content is long
  - [ ] Close button works
  - [ ] Screenshot evidence saved

  **Commit**: YES
  - Message: `feat(home): add game instructions dialog`
  - Files: `home_screen.dart`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `fix(lobby): order players by created_at to fix host detection` | player_repository.dart | Manual - 4 players test |
| 2 | (none - verification only) | - | Manual - ready sync test |
| 3 | `fix(game): distribute cards when game initializes in playing state` | game_state_provider.dart | Manual - game start test |
| 4 | `feat(home): add game instructions dialog` | home_screen.dart | Manual - dialog test |

After all tasks, push to main for Vercel deployment.

---

## Success Criteria

### Final Verification Flow
```bash
# After all commits pushed to main:
1. Open Vercel deployed URL in 4 browser windows
2. Player 1: Create room (4 players)
3. All players join
4. Verify host is Player 1 (creator)
5. All players ready → verify real-time sync
6. Host starts game → verify all players get cards
7. Complete level 1 → verify level 2 cards distributed
8. Return to home → verify instructions button works
```

### Final Checklist
- [ ] Host remains fixed as room creator throughout session
- [ ] Ready status updates appear on all clients within 2 seconds
- [ ] Cards are distributed immediately when game starts
- [ ] Game instructions dialog shows complete rules in Korean
- [ ] No regressions in existing functionality
