# Supabase 백엔드 설정 가이드

## 1. Supabase 프로젝트 생성

1. [Supabase](https://supabase.com) 접속
2. "New Project" 클릭
3. 프로젝트 정보 입력:
   - Name: `the-mind-flutter`
   - Database Password: 강력한 비밀번호 설정 (저장 필수!)
   - Region: Northeast Asia (Seoul) - 한국 사용자를 위해
4. 프로젝트 생성 대기 (약 2분)

## 2. 프로젝트 정보 확인

생성 완료 후 Settings > API에서 다음 정보 확인:
- `Project URL`
- `anon public` API key

이 정보를 `.env` 파일에 저장:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

## 3. 데이터베이스 테이블 생성

1. Supabase Dashboard > SQL Editor
2. 아래 SQL을 복사하여 실행

### 실행할 SQL

`supabase/migrations/001_initial_schema.sql` 파일 전체 내용을 복사하여 실행하세요.

## 4. Row Level Security (RLS) 정책 검증

Supabase Dashboard에서 각 테이블(rooms, players, game_events, shuriken_votes)에 대해:
- RLS가 활성화되어 있는지 확인
- SELECT, INSERT, UPDATE 정책이 설정되어 있는지 확인

## 5. Realtime 활성화

1. Supabase Dashboard > Database > Replication
2. 다음 테이블에 대해 Realtime 활성화:
   - rooms
   - players
   - game_events
   - shuriken_votes

## 6. 환경변수 설정

프로젝트 루트에서:

```bash
cp .env.example .env
```

`.env` 파일을 편집하여 Supabase 정보 입력:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**주의**: `.env` 파일은 절대 커밋하지 마세요. `.gitignore`에 포함되어 있습니다.

## 7. Flutter 앱에서 Supabase 초기화

`lib/main.dart`에서 다음을 확인:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

## 8. 연결 테스트

```bash
cd the_mind
flutter pub get
flutter run
```

로그에서 "Supabase initialized" 메시지를 확인하세요.

## 9. API 문서

- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/introduction)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Realtime Subscriptions](https://supabase.com/docs/guides/realtime)

## 문제 해결

### "API key not found" 에러
- `.env` 파일이 생성되었는지 확인
- `SUPABASE_URL`과 `SUPABASE_ANON_KEY`가 올바르게 입력되었는지 확인
- 앱을 다시 시작하세요

### RLS 정책 없음
- Supabase Dashboard > Database > 각 테이블 > RLS 확인
- 모든 정책이 활성화되어 있는지 확인

### Realtime 구독 작동 안 함
- Supabase Dashboard > Database > Replication에서 테이블이 활성화되었는지 확인
- 네트워크 연결 확인
