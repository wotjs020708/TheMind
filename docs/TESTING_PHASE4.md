# Phase 4 Testing Guide

## Prerequisites

1. **Supabase Setup**
   - Follow `docs/SUPABASE_SETUP.md` to set up your Supabase project
   - Apply migration: `supabase/migrations/001_initial_schema.sql`
   - Enable Realtime for all tables: `rooms`, `players`, `game_events`, `shuriken_votes`
   - Update `.env` file with your Supabase credentials

2. **Environment Configuration**
   ```bash
   cd the_mind
   cp .env.example .env
   # Edit .env with your Supabase URL and ANON_KEY
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

## Testing 2-Player Game (End-to-End)

### Device 1: Host Player

1. **Launch App**
   ```bash
   flutter run
   ```

2. **Create Room**
   - Tap "2명" button on home screen
   - Note the 6-character room code (e.g., "ABC123")

3. **Join Lobby**
   - Enter your name (e.g., "Player 1")
   - Wait for Player 2 to join

4. **Start Game**
   - Tap "준비" button
   - Once both players are ready, tap "게임 시작"

### Device 2: Guest Player

1. **Launch App**
   ```bash
   flutter run -d <device_id>
   ```

2. **Join Room**
   - Enter the room code from Device 1
   - Enter your name (e.g., "Player 2")

3. **Get Ready**
   - Tap "준비" button
   - Wait for host to start game

## Test Scenarios

### 1. Card Play - Normal Flow
- **Goal**: Successfully play cards in ascending order
- **Steps**:
  1. Both players receive cards (Level 1 = 1 card each)
  2. Player with lowest card plays first
  3. Other player plays their card
  4. Level completes → Level 2 starts (2 cards each)

- **Expected**:
  - Cards appear in player's hand
  - Played cards show in center deck
  - Level advances automatically
  - Rewards appear at levels 2, 3, 5, 6, 8, 9, 11

### 2. Mistake Detection
- **Goal**: Verify mistake handling
- **Steps**:
  1. Player with higher card plays first (intentional mistake)
  
- **Expected**:
  - Life counter decreases by 1
  - All cards < played card are discarded
  - Continue with remaining cards

### 3. Shuriken Voting
- **Goal**: Test unanimous voting system
- **Steps**:
  1. Player 1 taps "수리검 사용 제안"
  2. Both players see voting dialog
  3. Both tap "찬성" (or one taps "반대")

- **Expected** (unanimous yes):
  - Dialog shows "✅ 수리검 사용!"
  - Lowest card from each player is removed
  - Shuriken count decreases by 1

- **Expected** (any no):
  - Dialog shows "❌ 거부됨"
  - No cards removed
  - Shuriken count unchanged

### 4. Game Victory
- **Goal**: Complete all levels for 2-player game (max level 8)
- **Steps**:
  1. Successfully complete levels 1-8
  
- **Expected**:
  - Navigate to result screen
  - Show victory message

### 5. Game Defeat
- **Goal**: Lose all lives
- **Steps**:
  1. Make intentional mistakes until lives reach 0

- **Expected**:
  - Navigate to result screen
  - Show defeat message

## Real-time Synchronization Tests

### Player List Updates
- **Test**: Player joins/leaves
- **Expected**: Both players see updates instantly

### Ready Status
- **Test**: Toggle ready button
- **Expected**: Status syncs across devices

### Card Play
- **Test**: One player plays card
- **Expected**: Other player sees card immediately in center deck

### Shuriken Vote
- **Test**: Vote cast
- **Expected**: Vote count updates for both players

## Known Limitations (Phase 4)

1. **No Reconnection**: If a player disconnects, they cannot rejoin
2. **No Game Pause**: No way to pause an active game
3. **Limited Error Handling**: Network errors may cause app to freeze
4. **No Animation**: Card plays and level transitions are instant

## Troubleshooting

### Room Not Found
- Check Supabase connection
- Verify `.env` configuration
- Check Supabase logs for errors

### Players Not Syncing
- Verify Realtime is enabled in Supabase dashboard
- Check that all tables have Realtime replication enabled
- Restart app and try again

### Cards Not Appearing
- Check `game_events` table in Supabase
- Verify `gameStarted` event was created
- Check `players` table for correct `cards` array

### Shuriken Vote Not Working
- Check `shuriken_votes` table
- Verify `proposal_id` matches across votes
- Check `game_events` for `shurikenProposed` event

## Next Phase

After successful testing, proceed to:
- **Phase 5**: Polish & Error Handling
- **Phase 6**: iOS/Android Deployment
- **Phase 7**: Web Deployment
