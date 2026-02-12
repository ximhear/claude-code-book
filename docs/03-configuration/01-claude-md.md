<!-- last_updated: 2026-02-11 -->

# 9. CLAUDE.md — 프로젝트 지침 파일

> Claude Code의 핵심 설정 파일인 CLAUDE.md의 역할, 로딩 순서, 작성법을 마스터합니다.

---

## CLAUDE.md란?

CLAUDE.md는 Claude Code에게 프로젝트에 대한 **영구적인 지침**을 전달하는 마크다운 파일입니다. 세션이 시작될 때 자동으로 로드되며, Claude가 프로젝트의 규칙, 빌드 방법, 코딩 스타일, 디렉토리 구조 등을 이해하는 데 사용됩니다.

CLAUDE.md가 없으면 Claude는 매 세션마다 프로젝트를 처음부터 탐색해야 합니다. CLAUDE.md가 있으면:

- **반복 설명을 줄일 수 있습니다** — "npm test로 테스트를 실행해"를 매번 말할 필요 없음
- **일관된 코딩 스타일을 유지합니다** — 프로젝트 규칙을 자동으로 따름
- **팀 전체가 같은 지침을 공유합니다** — 버전 관리에 커밋하여 팀원 전체에 적용
- **Claude의 첫 응답 품질이 높아집니다** — 맥락을 처음부터 파악

---

## 파일 위치와 범위

CLAUDE.md는 여러 위치에 존재할 수 있으며, 각 위치마다 범위가 다릅니다.

| 레벨 | 유형 | 위치 | 범위 | 공유 |
|:----:|------|------|------|:----:|
| **관리자** | 관리자 정책 | 시스템 경로 (아래 참고) | 조직 전체 | 전체 |
| **사용자** | 사용자 메모리 | `~/.claude/CLAUDE.md` | 모든 프로젝트 | 개인 |
| **사용자** | 사용자 규칙 | `~/.claude/rules/*.md` | 모든 프로젝트 | 개인 |
| **프로젝트** | 프로젝트 메모리 | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` | 프로젝트 | 팀 (git) |
| **프로젝트** | 프로젝트 규칙 | `./.claude/rules/*.md` | 프로젝트 (모듈식) | 팀 (git) |
| **프로젝트** | 프로젝트 로컬 | `./CLAUDE.local.md` | 프로젝트 (개인) | 개인 |
| **자동** | 자동 메모리 | `~/.claude/projects/<hash>/memory/` | 프로젝트별 자동 | 개인 |

**관리자 정책 경로**:
- macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`
- Linux: `/etc/claude-code/CLAUDE.md`
- Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`

### 충돌 시 우선순위 원칙

> **"More specific instructions take precedence over broader ones."**
> — Claude Code 공식 문서

동일한 항목에 대해 서로 다른 CLAUDE.md 파일이 다른 지시를 내릴 경우, **더 구체적인 범위**의 지시가 우선합니다:

```
관리자 정책 (가장 넓음, 가장 낮은 우선순위)
  ↓
사용자 레벨 (~/.claude/CLAUDE.md, ~/.claude/rules/*.md)
  ↓
프로젝트 레벨 (./CLAUDE.md, .claude/rules/*.md, CLAUDE.local.md)
  ↓
하위 디렉토리 (./subdir/CLAUDE.md — 가장 좁음, 가장 높은 우선순위)
```

**예시**: 상위 폴더 A와 하위 폴더 B에 각각 CLAUDE.md가 있을 때:

```markdown
# A/CLAUDE.md
- 들여쓰기는 탭 사용
- 테스트는 Jest로 작성

# A/B/CLAUDE.md
- 들여쓰기는 스페이스 2칸 사용
```

B 폴더의 파일 수정 시:
- **들여쓰기** → 스페이스 2칸 (B의 지시가 우선)
- **테스트** → Jest (B에서 별도 언급이 없으므로 A의 지시가 유지)

같은 레벨 내(예: 사용자 메모리와 사용자 규칙)에서의 우선순위 차이는 공식 문서에서 명시되지 않습니다. 동일 레벨에서는 **충돌을 피하도록** 역할을 분리하는 것이 좋습니다.

---

## 로딩 순서

### 세션 시작 시

1. **관리자 정책** 로드 (있는 경우)
2. **사용자 전역** `~/.claude/CLAUDE.md` 로드
3. **사용자 규칙** `~/.claude/rules/*.md` 로드
4. 현재 디렉토리에서 **상위 디렉토리로 재귀 탐색**, 각 경로의 CLAUDE.md를 전부 로드
5. **프로젝트** `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` 로드
6. **프로젝트 규칙** `./.claude/rules/*.md` 로드
7. **프로젝트 로컬** `./CLAUDE.local.md` 로드
8. **자동 메모리** `MEMORY.md`의 처음 200줄만 로드

### 작업 중 (온디맨드)

- 하위 디렉토리의 파일을 읽을 때, 해당 디렉토리에 있는 CLAUDE.md를 **자동으로 발견하여 로드**
- 온디맨드로 로드된 하위 디렉토리의 CLAUDE.md는 **가장 높은 우선순위**를 가짐 (가장 구체적인 범위)
- 모노레포에서 패키지별 CLAUDE.md를 사용할 때 유용합니다

```
my-monorepo/
├── CLAUDE.md                    ← 세션 시작 시 로드
├── packages/
│   ├── frontend/
│   │   └── CLAUDE.md            ← frontend/ 파일 접근 시 로드
│   └── backend/
│       └── CLAUDE.md            ← backend/ 파일 접근 시 로드
```

---

## `/init` — 자동 생성

```
> /init
```

Claude가 현재 프로젝트를 분석하고 적절한 CLAUDE.md 초안을 제안합니다:

1. 프로젝트 구조 분석 (파일 패턴, 설정 파일)
2. 기술 스택 파악 (언어, 프레임워크, 빌드 도구)
3. 빌드/테스트 명령어 감지
4. 코딩 규칙 추론
5. 초안을 보여주고 수정 기회 제공

> **팁**: `/init`으로 시작한 뒤 직접 다듬는 것이 처음부터 작성하는 것보다 효율적입니다.

---

## 효과적인 CLAUDE.md 작성법

### 권장 섹션 구성

```markdown
# 프로젝트 개요
프로젝트의 목적과 핵심 기술 스택을 간략히 설명합니다.

## 빌드 및 테스트 명령어
- 빌드: `npm run build`
- 테스트: `npm test`
- 단일 테스트: `npm test -- --testPathPattern="파일명"`
- 린트: `npm run lint`
- 개발 서버: `npm run dev`

## 코딩 규칙
- 들여쓰기: 스페이스 2칸
- 변수/함수: camelCase
- 클래스/타입: PascalCase
- 상수: UPPER_SNAKE_CASE
- TypeScript strict 모드 사용
- 비동기 코드는 async/await 사용

## 디렉토리 구조
- src/components/ — React 컴포넌트
- src/services/ — API 클라이언트, 비즈니스 로직
- src/utils/ — 유틸리티 함수
- src/types/ — TypeScript 타입 정의
- tests/ — 테스트 파일

## 규칙
- 새 기능에는 반드시 테스트 작성
- 커밋 메시지는 Conventional Commits 형식
- console.log는 프로덕션 코드에서 금지
- 함수는 30줄 이내로 유지
- PR 전에 `npm run lint && npm test` 통과 필수
```

### 작성 원칙

**구체적으로**

```markdown
# 좋은 예 (✅)
- 들여쓰기: 스페이스 2칸
- 함수명: camelCase
- 테스트: `npm test -- --testPathPattern="파일명"`

# 모호한 예 (❌)
- 코드를 깔끔하게 작성
- 적절한 포맷팅 사용
```

**자주 사용하는 명령어를 포함**

```markdown
## 자주 쓰는 명령어
- 전체 빌드: `npm run build`
- 타입 검사: `npx tsc --noEmit`
- 특정 테스트: `npx jest path/to/test`
- DB 마이그레이션: `npx prisma migrate dev`
- 시드 데이터: `npx prisma db seed`
```

**하지 말아야 할 것을 명시**

```markdown
## 금지 사항
- package.json을 직접 수정하지 마세요 (npm 명령어 사용)
- node_modules를 커밋하지 마세요
- .env 파일의 실제 값을 코드에 하드코딩하지 마세요
- main 브랜치에 직접 푸시하지 마세요
```

### 크기 가이드라인

| 프로젝트 규모 | 권장 크기 | 토큰 수 |
|:-------------:|:---------:|:-------:|
| 소규모 | 500~800자 | ~200 토큰 |
| 중규모 | 800~2,000자 | ~500 토큰 |
| 대규모 | 2,000~5,000자 | ~1,500 토큰 |
| 최대 권장 | 10,000자 이하 | ~3,000 토큰 |

- CLAUDE.md가 너무 크면 코드 분석에 사용할 컨텍스트 공간이 줄어듭니다
- `/doctor`로 컨텍스트 사용량 경고를 확인하세요
- 너무 길어지면 `.claude/rules/`로 분리하세요

---

## `@` 임포트 문법

CLAUDE.md에서 다른 파일을 참조할 수 있습니다:

```markdown
# 프로젝트 지침

프로젝트 개요는 @README.md를 참고하세요.
- Git 워크플로우: @docs/git-instructions.md
- API 규칙: @docs/api-standards.md
- 개인 설정: @~/.claude/my-project-notes.md
```

- 상대 경로: 해당 CLAUDE.md 파일 기준으로 해석
- 절대 경로: `~`로 시작하면 홈 디렉토리
- 최대 재귀 깊이: 5단계
- 코드 블록 내부의 `@`는 무시됩니다
- 첫 발견 시 승인 대화 상자가 나타날 수 있습니다

---

## CLAUDE.md vs CLAUDE.local.md

| 특성 | CLAUDE.md | CLAUDE.local.md |
|------|-----------|-----------------|
| **목적** | 팀 공유 지침 | 개인 설정 |
| **Git 추적** | 커밋 대상 | .gitignore에 자동 추가 |
| **예시** | 빌드 명령어, 코딩 규칙 | 개인 샌드박스 URL, 선호 테스트 데이터 |

```markdown
# CLAUDE.local.md 예시

## 내 개발 환경
- 로컬 API 서버: http://localhost:3001
- 테스트 DB: postgresql://localhost:5432/test_db
- 선호하는 브라우저: Chrome
- 디버깅 시 항상 --verbose 플래그 사용
```

---

## 모노레포에서의 CLAUDE.md

대규모 모노레포에서는 패키지별 CLAUDE.md를 사용합니다:

```
monorepo/
├── CLAUDE.md                    # 전체 프로젝트 공통 규칙
├── packages/
│   ├── web/
│   │   └── CLAUDE.md            # React/Next.js 프론트엔드 규칙
│   ├── api/
│   │   └── CLAUDE.md            # Express/NestJS 백엔드 규칙
│   ├── mobile/
│   │   └── CLAUDE.md            # React Native 모바일 규칙
│   └── shared/
│       └── CLAUDE.md            # 공유 라이브러리 규칙
```

**루트 CLAUDE.md**: 모든 패키지에 공통인 빌드 명령어, Git 규칙, CI/CD 파이프라인

**패키지 CLAUDE.md**: 해당 패키지 고유의 기술 스택, 테스트 방법, 코딩 규칙

Claude가 `packages/web/` 내의 파일을 읽을 때 해당 디렉토리의 CLAUDE.md가 자동으로 로드되므로, 초기 컨텍스트를 불필요하게 부풀리지 않습니다.

---

## Rules와의 관계

CLAUDE.md와 `.claude/rules/`는 보완적입니다:

| 특성 | CLAUDE.md | .claude/rules/ |
|------|-----------|----------------|
| **구조** | 단일 파일 (모놀리식) | 여러 파일 (모듈식) |
| **적합한 상황** | 빌드 명령어, 빠른 참조, 온보딩 | 도메인별 상세 규칙 |
| **경로 조건** | 없음 (전체 적용) | YAML frontmatter로 경로 지정 가능 |

자세한 내용은 [12장: Rules](04-rules.md)에서 다룹니다.

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **목적** | 프로젝트별 영구 지침을 Claude에게 전달 |
| **위치** | 프로젝트 루트, `~/.claude/`, `.claude/`, 관리자 경로 |
| **로딩** | 세션 시작 시 자동, 하위 디렉토리는 온디맨드 |
| **생성** | `/init`으로 자동 생성 후 직접 다듬기 |
| **크기** | 10,000자 이하 권장, 넘으면 Rules로 분리 |
| **공유** | CLAUDE.md는 git 커밋, CLAUDE.local.md는 개인용 |
| **모노레포** | 패키지별 CLAUDE.md 사용, 온디맨드 로드 |

---

## 다음 챕터

[10장: settings.json 설정 가이드](02-settings.md)에서 전역/프로젝트/로컬 설정 파일의 구조와 옵션을 상세히 다룹니다.
