<!-- last_updated: 2026-02-11 -->

# 29. 프로젝트별 CLAUDE.md 템플릿

> 다양한 프로젝트 유형에 맞는 CLAUDE.md 작성 예제를 제공합니다.

---

## React / Next.js 프로젝트

```markdown
# 프로젝트 개요
Next.js 14 기반 웹 애플리케이션. App Router 사용.

## 빌드 및 테스트
- 개발 서버: `npm run dev`
- 빌드: `npm run build`
- 테스트: `npm test`
- 단일 테스트: `npx jest path/to/test`
- 린트: `npm run lint`
- 타입 체크: `npx tsc --noEmit`

## 코딩 규칙
- TypeScript strict 모드
- 함수형 컴포넌트만 사용 (클래스 금지)
- 들여쓰기: 스페이스 2칸
- Props: interface로 정의
- 상태 관리: Zustand (전역), TanStack Query (서버)
- 스타일: Tailwind CSS

## 디렉토리 구조
- app/ — 페이지와 라우팅
- components/ — 재사용 컴포넌트
- lib/ — 유틸리티, API 클라이언트
- types/ — 타입 정의

## 금지 사항
- console.log를 프로덕션 코드에 남기지 마세요
- any 타입 사용 금지
- 인라인 스타일 금지
```

---

## Python / Django 프로젝트

```markdown
# 프로젝트 개요
Django 5.0 REST API 서버. DRF 사용.

## 빌드 및 테스트
- 서버 실행: `python manage.py runserver`
- 테스트: `pytest`
- 단일 테스트: `pytest tests/test_file.py::test_name -v`
- 린트: `ruff check .`
- 포맷: `ruff format .`
- 마이그레이션: `python manage.py migrate`
- 마이그레이션 생성: `python manage.py makemigrations`

## 코딩 규칙
- Python 3.12
- 타입 힌트 필수
- docstring: Google 스타일
- 변수/함수: snake_case
- 클래스: PascalCase
- 줄 길이: 88자 (ruff 기본)

## 디렉토리 구조
- apps/ — Django 앱
- core/ — 공통 모듈
- tests/ — 테스트
- config/ — 설정 파일

## 규칙
- 모든 엔드포인트에 시리얼라이저 검증
- DB 쿼리는 ORM 사용 (raw SQL 금지)
- 새 모델에는 마이그레이션 필수
```

---

## Go 백엔드 프로젝트

```markdown
# 프로젝트 개요
Go 1.22 기반 마이크로서비스. gRPC + REST API.

## 빌드 및 테스트
- 빌드: `go build ./...`
- 테스트: `go test ./...`
- 단일 테스트: `go test -run TestName ./path/to/package`
- 린트: `golangci-lint run`
- 프로토: `buf generate`

## 코딩 규칙
- 표준 Go 포맷 (gofmt)
- 에러는 즉시 처리 (panic 금지)
- 인터페이스는 사용하는 쪽에서 정의
- context.Context는 첫 번째 인자
- 테이블 주도 테스트 패턴

## 디렉토리 구조
- cmd/ — 엔트리포인트
- internal/ — 비공개 패키지
- pkg/ — 공개 패키지
- api/ — 프로토 정의
```

---

## 모노레포 프로젝트

```markdown
# 프로젝트 개요
pnpm workspace 기반 모노레포. 프론트엔드 + 백엔드 + 공유 라이브러리.

## 빌드 및 테스트
- 전체 빌드: `pnpm build`
- 전체 테스트: `pnpm test`
- 특정 패키지: `pnpm --filter @app/web test`
- 린트: `pnpm lint`
- 타입 체크: `pnpm typecheck`

## 패키지 구조
- packages/web — Next.js 프론트엔드
- packages/api — Express 백엔드
- packages/shared — 공유 타입과 유틸리티
- packages/ui — 디자인 시스템

## 규칙
- 패키지 간 의존성은 workspace 프로토콜 사용
- 공유 타입은 @app/shared에서 관리
- 각 패키지의 CLAUDE.md 참조
```

---

## 라이브러리 / 패키지 프로젝트

```markdown
# 프로젝트 개요
TypeScript 유틸리티 라이브러리. npm 패키지로 배포.

## 빌드 및 테스트
- 빌드: `npm run build`
- 테스트: `npm test`
- 테스트 (watch): `npm run test:watch`
- 린트: `npm run lint`
- 번들 분석: `npm run analyze`

## 코딩 규칙
- 모든 공개 API에 JSDoc
- 100% 타입 커버리지
- 번들 크기 최소화 (tree-shaking 지원)
- 하위 호환성 유지

## 배포
- 시맨틱 버저닝 (semver)
- CHANGELOG.md 업데이트 필수
- npm publish 전 빌드와 테스트 통과 필수

## 금지 사항
- 런타임 의존성 추가 시 반드시 논의
- 공개 API 변경 시 마이너 버전 이상 올리기
```

---

## 오픈소스 프로젝트

```markdown
# 프로젝트 개요
오픈소스 CLI 도구. MIT 라이선스.

## 기여 가이드
- PR 전에 이슈 먼저 생성
- 커밋 메시지: Conventional Commits
- 모든 변경에 테스트 포함
- README 업데이트 필수

## 빌드 및 테스트
- 빌드: `npm run build`
- 테스트: `npm test`
- E2E 테스트: `npm run test:e2e`

## 코딩 규칙
- ESLint + Prettier 설정 따르기
- 모든 공개 API에 TypeDoc 주석
- Node.js 18+ 지원

## CI/CD
- PR 시 자동 테스트 실행
- main 브랜치 푸시 시 자동 배포
- npm 배포 전 수동 승인 필요
```

---

## 모바일 프로젝트 (React Native)

```markdown
# 프로젝트 개요
React Native + Expo 기반 모바일 앱

## 명령어
- 개발: `npx expo start`
- iOS: `npx expo run:ios`
- Android: `npx expo run:android`
- 테스트: `jest --watchAll`
- 린트: `npx eslint src/`
- 타입 체크: `npx tsc --noEmit`

## 코드 스타일
- TypeScript strict 모드
- 함수형 컴포넌트 + hooks
- 스타일: StyleSheet.create() 사용 (인라인 스타일 금지)
- 네비게이션: React Navigation v6

## 구조
- src/screens/ — 화면 컴포넌트
- src/components/ — 재사용 UI 컴포넌트
- src/hooks/ — 커스텀 hooks
- src/services/ — API 클라이언트, 스토리지
- src/navigation/ — 네비게이션 설정

## 규칙
- 플랫폼별 코드는 .ios.tsx / .android.tsx 확장자 사용
- 하드코딩된 문자열 금지 → i18n 키 사용
- 모든 API 호출에 에러 핸들링 필수
- SafeAreaView로 노치/홈 인디케이터 대응
```

---

## 템플릿 활용 팁

1. `/init`으로 초안을 생성한 후 필요한 섹션만 추가
2. 프로젝트 성장에 따라 점진적으로 확장
3. 500줄을 넘으면 `.claude/rules/`로 분리
4. 팀원의 피드백을 반영하여 정기적으로 업데이트

---

## 다음 챕터

[30장: 실전 워크플로우 패턴](02-workflow-patterns.md)에서 실제 개발에서 바로 적용할 수 있는 워크플로우 패턴을 배웁니다.
