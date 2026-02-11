<!-- last_updated: 2026-02-11 -->

# 12. Rules — 모듈식 규칙 파일

> `.claude/rules/` 디렉토리를 활용하여 지침을 모듈식으로 관리하는 방법을 다룹니다.

---

## Rules란?

Rules는 프로젝트 지침을 **여러 개의 독립적인 마크다운 파일**로 분리하여 관리하는 시스템입니다. 하나의 큰 CLAUDE.md 대신 주제별로 파일을 나누어 관리합니다.

```
.claude/rules/
├── code-style.md        # 코딩 스타일 가이드라인
├── testing.md           # 테스트 규칙
├── security.md          # 보안 요구사항
├── api-design.md        # API 설계 패턴
└── frontend/
    └── react.md         # React 특화 규칙
```

`.claude/rules/` 디렉토리의 모든 `.md` 파일은 **자동으로 프로젝트 메모리로 로드**됩니다.

---

## CLAUDE.md vs Rules

| 특성 | CLAUDE.md | .claude/rules/ |
|------|-----------|----------------|
| **구조** | 단일 파일 | 여러 파일 (모듈식) |
| **크기** | 간결하게 유지 | 주제별 상세 기술 가능 |
| **경로 조건** | 전체 적용 | YAML frontmatter로 특정 파일에만 적용 가능 |
| **적합한 경우** | 빌드 명령어, 빠른 참조, 프로젝트 개요 | 도메인별 상세 규칙, 대규모 프로젝트 |
| **관리** | 단일 파일 편집 | 주제별 소유권 분배 가능 |

**선택 기준**:
- 프로젝트가 간단하고 규칙이 적으면 → CLAUDE.md 하나로 충분
- 규칙이 많거나, 도메인별로 다른 규칙이 필요하면 → Rules 사용
- 두 가지를 함께 사용할 수 있습니다 — CLAUDE.md는 공통 규칙, Rules는 세부 규칙

---

## 디렉토리 구조

### 기본 구조

```
your-project/
├── .claude/
│   ├── CLAUDE.md           # 메인 프로젝트 지침
│   └── rules/
│       ├── code-style.md   # 코딩 스타일
│       ├── testing.md      # 테스트 규칙
│       └── security.md     # 보안 규칙
```

### 하위 디렉토리 구조

규칙이 많으면 하위 디렉토리로 조직합니다:

```
.claude/rules/
├── frontend/
│   ├── react.md            # React 컴포넌트 규칙
│   └── styles.md           # CSS/스타일링 규칙
├── backend/
│   ├── api.md              # REST API 규칙
│   └── database.md         # 데이터베이스 규칙
├── devops/
│   └── deployment.md       # 배포 관련 규칙
└── general.md              # 공통 규칙
```

모든 `.md` 파일은 **재귀적으로 발견**됩니다.

---

## 규칙 파일 작성

### 기본 규칙 (무조건 적용)

`paths` frontmatter가 없으면 **모든 파일**에 적용됩니다:

```markdown
# 코딩 스타일 가이드

- 들여쓰기: 스페이스 2칸
- 변수명: camelCase
- 함수는 30줄 이내로 유지
- console.log 대신 로거 라이브러리 사용
- 주석은 "왜"를 설명, "무엇"은 코드가 설명
```

### 경로 조건부 규칙

YAML frontmatter에 `paths` 필드를 추가하면 **특정 파일 작업 시에만** 로드됩니다:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/routes/**/*.ts"
---

# API 개발 규칙

- 모든 엔드포인트에 입력 검증 필수
- 표준 에러 응답 형식 사용:
  ```ts
  { status: number, message: string, code: string }
  ```
- OpenAPI 문서 주석 포함
- 요청/응답 타입은 별도 파일로 분리
```

### 글로브 패턴

`paths` 필드는 표준 글로브 패턴을 지원합니다:

| 패턴 | 매칭 대상 |
|------|-----------|
| `**/*.ts` | 모든 디렉토리의 TypeScript 파일 |
| `src/**/*` | src/ 하위 모든 파일 |
| `*.md` | 프로젝트 루트의 마크다운 파일 |
| `src/components/*.tsx` | 특정 디렉토리의 React 컴포넌트 |

**여러 패턴 지정**:

```yaml
---
paths:
  - "src/**/*.ts"
  - "lib/**/*.ts"
  - "tests/**/*.test.ts"
---
```

**중괄호 확장**:

```yaml
---
paths:
  - "src/**/*.{ts,tsx}"         # .ts와 .tsx 모두
  - "{src,lib}/**/*.ts"         # src/와 lib/ 하위
---
```

---

## 규칙 파일 예제

### 테스트 규칙

```markdown
---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "tests/**/*"
---

# 테스트 작성 규칙

## 구조
- describe → context → it 패턴 사용
- 각 테스트는 독립적으로 실행 가능해야 함
- 테스트 데이터는 팩토리 함수로 생성

## 네이밍
- describe: 테스트 대상 (클래스명 또는 함수명)
- it: "should ~" 형식

## 모킹
- 외부 API 호출은 항상 모킹
- 모킹 라이브러리: jest.mock 사용
- 모킹은 최소한으로 — 실제 구현 우선
```

### 보안 규칙

```markdown
# 보안 요구사항

- 사용자 입력은 항상 검증
- SQL 쿼리에 파라미터 바인딩 필수 (인라인 금지)
- 인증 토큰은 환경 변수로 관리
- 에러 메시지에 내부 정보 노출 금지
- CORS 설정은 화이트리스트 방식
- 비밀번호는 bcrypt 또는 argon2로 해싱
```

### React 컴포넌트 규칙

```markdown
---
paths:
  - "src/components/**/*.tsx"
  - "src/pages/**/*.tsx"
---

# React 컴포넌트 규칙

## 컴포넌트 구조
- 함수형 컴포넌트만 사용 (클래스 컴포넌트 금지)
- Props 타입은 컴포넌트 상단에 interface로 정의
- 커스텀 훅은 use- 접두사

## 상태 관리
- 로컬 상태: useState/useReducer
- 전역 상태: Zustand 스토어
- 서버 상태: TanStack Query

## 스타일링
- Tailwind CSS 유틸리티 클래스 사용
- 컴포넌트별 스타일 파일 금지
```

---

## 사용자 전역 규칙

개인적인 규칙을 모든 프로젝트에 적용할 수 있습니다:

```
~/.claude/rules/
├── preferences.md       # 개인 코딩 선호
└── workflows.md         # 선호하는 워크플로우
```

```markdown
# preferences.md
- 응답은 한국어로
- 커밋 메시지는 Conventional Commits 형식
- 코드 변경 후 항상 관련 테스트 실행
- 새 함수에는 JSDoc 주석 추가
```

사용자 규칙은 프로젝트 규칙보다 **낮은 우선순위**로 로드됩니다.

---

## 심링크를 활용한 규칙 공유

여러 프로젝트에서 공통 규칙을 공유하려면 심링크를 사용합니다:

```bash
# 공유 규칙 디렉토리 심링크
ln -s ~/shared-claude-rules .claude/rules/shared

# 개별 규칙 파일 심링크
ln -s ~/company-standards/security.md .claude/rules/security.md
```

- 심링크는 정상적으로 해석되어 내용이 로드됩니다
- 순환 심링크는 감지되어 안전하게 처리됩니다

---

## 팀 공유와 버전 관리

### Git에 커밋

```bash
git add .claude/rules/
git commit -m "Add project rules for team"
```

`.claude/rules/` 디렉토리는 Git에 커밋하여 팀 전체가 같은 규칙을 사용합니다.

### 플러그인을 통한 배포

규칙을 플러그인에 포함시켜 여러 프로젝트에 배포할 수 있습니다:

```
my-plugin/
├── skills/
│   └── ...
├── rules/
│   ├── company-style.md
│   └── company-security.md
└── plugin.json
```

### 조직 관리자 배포

관리자 경로에 규칙을 배포하면 조직 전체에 강제됩니다:

```
# macOS
/Library/Application Support/ClaudeCode/rules/
├── security.md
├── compliance.md
└── coding-standards.md
```

MDM, Group Policy, Ansible 등으로 배포합니다.

---

## 작성 베스트 프랙티스

1. **하나의 파일, 하나의 주제**: 각 파일은 하나의 주제만 다룹니다
2. **서술적 파일명**: `testing.md`, `api-design.md` (규칙1.md가 아님)
3. **경로 조건은 필요할 때만**: 진짜 특정 파일에만 해당하는 규칙만 `paths` 사용
4. **구체적으로 작성**: "코드를 잘 작성" (❌) → "2스페이스 들여쓰기" (✅)
5. **예제 포함**: 올바른 패턴과 안티패턴 모두 보여주기
6. **주기적 리뷰**: 프로젝트 발전에 따라 규칙도 업데이트

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **위치** | `.claude/rules/*.md` (프로젝트), `~/.claude/rules/` (전역) |
| **로딩** | 모든 `.md` 파일을 재귀적으로 자동 발견 |
| **경로 조건** | YAML frontmatter `paths` 필드로 특정 파일에만 적용 |
| **글로브 패턴** | `**/*.ts`, `{src,lib}/**/*.ts`, 중괄호 확장 지원 |
| **CLAUDE.md와 함께** | CLAUDE.md는 공통 규칙, Rules는 세부 규칙 |
| **공유** | Git 커밋, 심링크, 플러그인, 관리자 배포 |

---

## 다음 챕터

[13장: 메모리 시스템](05-memory.md)에서 Claude Code의 자동 메모리와 수동 메모리 관리를 배웁니다.
