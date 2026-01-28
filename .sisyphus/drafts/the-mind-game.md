# Draft: The Mind Digital Game Implementation (Flutter)

## Requirements (confirmed)
- **원본 규칙 파일**: `/Users/jaesun/Developer/TheMind/The_Mind_Rule.md` 분석 완료
- **플레이어 수**: 2-4인 지원
- **레벨 시스템**: 2인(12레벨), 3인(10레벨), 4인(8레벨)
- **생명 시스템**: 2인(2개), 3인(3개), 4인(4개) 시작
- **수리검 시스템**: 모든 인원 1개 시작, 사용 시 모든 플레이어 최저 카드 제거
- **보상 시스템**: 레벨 2,5,8,11에서 수리검 +1, 레벨 3,6,9에서 생명 +1
- **무언의 소통**: 타이밍 기반 긴장감 구현 필요
- **변형 규칙**: 블라인드 모드, 짧은 게임, 익스트림 모드, 초보자 모드

## Technical Decisions (CONFIRMED)
- **프론트엔드**: Flutter (iOS, Android, Web 크로스플랫폼) ✅ 확정
- **상태 관리**: Riverpod (추천 - Flutter 3.x 권장, 타입 안전, 컴파일 타임 체크)
- **실시간 통신**: Firebase Realtime Database (추천 - Flutter 공식 지원, 빠른 프로토타이핑)
  - 대안: socket_io_client + 별도 Node.js 서버 (완전한 제어 필요 시)
- **애니메이션**: flutter_animate (추천 - 선언적 API, 카드 효과에 최적)
- **타겟 플랫폼**: iOS + Android 우선, Web은 베타
- **테스트 전략**: (결정 필요 - 사용자 확인 대기)
- **AI 봇**: (결정 필요 - 사용자 확인 대기)

## Research Findings (Flutter 생태계)
- **Flutter Animation**: GestureDetector + AnimationController 조합으로 카드 드래그 구현
  - physics simulation (spring animation) 지원
  - DraggableCard 패턴 확인 (공식 문서)
- **Riverpod**: Notifier<T> 패턴으로 게임 상태 관리
  - NotifierProvider로 GameState 노출
  - state getter/setter로 상태 업데이트
- **flutter_animate**: 
  - FadeEffect, SlideEffect, ScaleEffect 조합 가능
  - 선언적 API: `.animate().fadeIn().scale()`
  - ShakeEffect, TintEffect로 에러 피드백
- **Firebase Realtime Database (Flutter)**:
  - `FirebaseDatabase.instance.ref()` 패턴 확인
  - onValue 리스너로 실시간 동기화
  - 여러 프로덕션 앱에서 사용 중 (immich, breez 등)
- **socket_io_client (Dart)**:
  - rikulo/socket.io-client-dart 패키지 존재
  - IO.io() 패턴으로 연결
  - WebSocket 전송 지원

## Open Questions (REMAINING)
1. ~~프론트엔드 프레임워크~~ → Flutter 확정
2. 백엔드: Firebase Realtime DB (추천) vs Socket.IO + Node.js - **추천 수락 또는 변경?**
3. AI 플레이어(봇) 포함 여부?
4. 테스트 전략: TDD vs 구현 후 테스트 vs 수동 검증?

## Scope Boundaries
- **INCLUDE**: 
  - 2-4인 멀티플레이어 게임
  - 모든 공식 규칙
  - 변형 규칙 4종
  - 한국어 UI
  - iOS, Android, Web 지원
- **EXCLUDE**:
  - 5인 이상 지원
  - Desktop (macOS, Windows, Linux) - Phase 1에서 제외
  - 다국어 지원 (i18n 구조만 준비)
