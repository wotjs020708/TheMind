-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLES
-- ============================================

-- rooms: 게임 방 정보
CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(6) UNIQUE NOT NULL,
  player_count INTEGER NOT NULL CHECK (player_count BETWEEN 2 AND 4),
  status VARCHAR(20) NOT NULL DEFAULT 'waiting',
  current_level INTEGER DEFAULT 1,
  lives INTEGER NOT NULL,
  shurikens INTEGER NOT NULL,
  played_cards INTEGER[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- players: 플레이어 정보
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  name VARCHAR(50) NOT NULL,
  position INTEGER NOT NULL CHECK (position BETWEEN 0 AND 3),
  cards INTEGER[] DEFAULT '{}',
  is_ready BOOLEAN DEFAULT FALSE,
  is_connected BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(room_id, position)
);

-- game_events: 게임 이벤트 (실시간 동기화)
CREATE TABLE game_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
  event_type VARCHAR(50) NOT NULL,
  player_id UUID REFERENCES players(id),
  data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- shuriken_votes: 수리검 투표
CREATE TABLE shuriken_votes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
  proposal_id UUID NOT NULL,
  player_id UUID REFERENCES players(id),
  vote BOOLEAN NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(proposal_id, player_id)
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_rooms_code ON rooms(code);
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_players_room ON players(room_id);
CREATE INDEX idx_events_room ON game_events(room_id, created_at DESC);
CREATE INDEX idx_votes_proposal ON shuriken_votes(proposal_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE shuriken_votes ENABLE ROW LEVEL SECURITY;

-- 읽기 정책: 누구나 읽기 가능
CREATE POLICY "rooms_select" ON rooms FOR SELECT USING (true);
CREATE POLICY "players_select" ON players FOR SELECT USING (true);
CREATE POLICY "events_select" ON game_events FOR SELECT USING (true);
CREATE POLICY "votes_select" ON shuriken_votes FOR SELECT USING (true);

-- 쓰기 정책: 누구나 쓰기 가능 (개발 단계)
-- TODO: 프로덕션에서는 사용자 인증 기반으로 제한 필요
CREATE POLICY "rooms_insert" ON rooms FOR INSERT WITH CHECK (true);
CREATE POLICY "players_insert" ON players FOR INSERT WITH CHECK (true);
CREATE POLICY "events_insert" ON game_events FOR INSERT WITH CHECK (true);
CREATE POLICY "votes_insert" ON shuriken_votes FOR INSERT WITH CHECK (true);

-- 업데이트 정책
CREATE POLICY "rooms_update" ON rooms FOR UPDATE USING (true);
CREATE POLICY "players_update" ON players FOR UPDATE USING (true);

-- ============================================
-- FUNCTIONS
-- ============================================

-- updated_at 자동 업데이트 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- rooms 테이블에 트리거 적용
CREATE TRIGGER update_rooms_updated_at
  BEFORE UPDATE ON rooms
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- REALTIME
-- ============================================

-- Realtime 활성화는 Supabase Dashboard에서 수동 설정
-- Database > Replication > 다음 테이블 활성화:
-- - rooms
-- - players
-- - game_events
-- - shuriken_votes
