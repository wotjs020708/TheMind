# Vercel 배포 가이드

## 개요

이 문서는 The Mind Flutter Web 앱을 Vercel에 배포하는 방법을 설명합니다.

## 사전 준비

1. **Vercel 계정**: https://vercel.com 에서 계정 생성
2. **GitHub 연동**: Vercel과 GitHub 계정 연결
3. **Supabase 정보**: 환경변수에 필요한 값
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

## 배포 단계

### 1. Vercel 프로젝트 생성

1. Vercel 대시보드에서 "Add New" → "Project" 클릭
2. GitHub 저장소 `wotjs020708/TheMind` 선택
3. 프로젝트 설정 확인:
   - **Framework Preset**: Other
   - **Build Command**: 자동 감지 (vercel.json 사용)
   - **Output Directory**: 자동 감지 (vercel.json 사용)
   - **Install Command**: 자동 감지 (vercel.json 사용)

### 2. 환경변수 설정

**Environment Variables** 섹션에서 다음 변수 추가:

| 키 | 값 | 환경 |
|----|----|----|
| `SUPABASE_URL` | `https://your-project.supabase.co` | Production, Preview, Development |
| `SUPABASE_ANON_KEY` | `your-anon-key` | Production, Preview, Development |

> **주의**: 실제 Supabase URL과 키는 `.env` 파일에서 확인하세요.

### 3. 첫 배포

1. "Deploy" 버튼 클릭
2. 빌드 로그 확인 (약 5-10분 소요)
3. 배포 완료 후 제공되는 URL로 접속

예상 URL 형식:
```
https://the-mind-{random-id}.vercel.app
```

### 4. 배포 확인

다음 항목을 테스트:

- [ ] 홈 화면 로딩
- [ ] 방 생성 기능
- [ ] Supabase 연결 (콘솔에서 에러 확인)
- [ ] 다른 기기에서 접속 테스트

## 자동 배포 설정

`main` 브랜치에 푸시하면 자동으로 프로덕션 배포됩니다.
PR 생성 시 Preview 배포가 자동으로 생성됩니다.

## 빌드 상세 정보

### vercel.json 설정

```json
{
  "buildCommand": "cd the_mind && flutter build web --release",
  "outputDirectory": "the_mind/build/web",
  "framework": null,
  "installCommand": "git clone https://github.com/flutter/flutter.git -b stable --depth 1 && export PATH=\"$PATH:$PWD/flutter/bin\" && flutter doctor && flutter config --enable-web",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

**주요 설정 설명**:
- `installCommand`: Flutter SDK를 Vercel 빌드 환경에 설치
- `buildCommand`: Flutter Web 릴리즈 빌드 실행
- `outputDirectory`: 빌드 결과물 위치
- `rewrites`: SPA 라우팅 지원 (모든 경로를 index.html로 리다이렉트)

### 빌드 최적화

현재 빌드 크기: **~28MB**

**자동 적용된 최적화**:
- ✅ Tree shaking (아이콘 폰트 99%+ 감소)
- ✅ 코드 압축 (--release 모드)
- ✅ 불필요한 에셋 제거

## 문제 해결

### 빌드 실패

**증상**: "flutter: command not found"
- **원인**: Flutter SDK 설치 실패
- **해결**: Vercel 빌드 로그에서 `installCommand` 실행 확인

**증상**: "Supabase connection failed"
- **원인**: 환경변수 미설정
- **해결**: Vercel 대시보드에서 환경변수 재확인

### 라우팅 문제

**증상**: 새로고침 시 404 에러
- **원인**: SPA 라우팅 설정 누락
- **해결**: `vercel.json`의 `rewrites` 설정 확인

### 느린 초기 로딩

**증상**: 첫 로딩이 느림
- **원인**: Flutter Web 특성 (28MB 번들)
- **해결**: 
  - 캐싱 활성화 (Vercel 자동 지원)
  - 향후 Code Splitting 고려

## 모바일 접속

모바일 브라우저에서 접속 시 주의사항:

- **iOS Safari**: WebGL 지원 확인 필요
- **Android Chrome**: 정상 작동 예상
- **반응형**: 화면 크기에 따라 레이아웃 조정

## 다음 단계

배포 완료 후:

1. **커스텀 도메인 설정** (선택)
   - Vercel 대시보드 → Domains
   - 본인 소유 도메인 연결

2. **성능 모니터링**
   - Vercel Analytics 활성화
   - Core Web Vitals 확인

3. **사용자 테스트**
   - 다양한 기기에서 테스트
   - 피드백 수집 및 개선

---

**작성일**: 2026-01-28  
**관련 이슈**: #12  
**Phase**: 6
