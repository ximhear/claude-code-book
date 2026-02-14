<!-- last_updated: 2026-02-11 -->

# 19. Skills — 재사용 가능한 지식 패키지

> Skills 시스템으로 반복 작업을 자동화하는 방법을 다룹니다.

---

## Skills란?

Skills는 Claude Code에서 **커스텀 슬래시 커맨드**를 만드는 시스템입니다. SKILL.md 파일에 YAML 메타데이터와 마크다운 지시문을 작성하면, `/스킬명`으로 호출할 수 있는 재사용 가능한 명령어가 됩니다.

```
.claude/skills/
└── review/
    └── SKILL.md    →    /review로 호출 가능
```

---

## SKILL.md 구조

### 기본 구조

```markdown
---
name: review
description: "코드 품질, 보안, 성능 관점에서 리뷰합니다"
---

다음 코드를 리뷰해주세요:

$ARGUMENTS

확인 항목:
- 보안 취약점
- 성능 이슈
- 코드 스타일 준수
- 에지 케이스 처리
```

### YAML Frontmatter 필드

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | O | 스킬 이름 (최대 64자, 소문자/숫자/하이픈) |
| `description` | O | 스킬 설명 (최대 1024자) |
| `context` | | `fork` (격리) 또는 `inherit` (공유, 기본값) |
| `agent` | | 실행 에이전트 타입 |
| `disable-model-invocation` | | `true`면 Claude가 자동으로 호출하지 않음 |
| `tools` | | 허용 도구 목록 |
| `allowed-tools` | | 명시적 도구 허용 |
| `disallowed-tools` | | 도구 차단 목록 |

---

## 인자 전달

### $ARGUMENTS

사용자가 슬래시 커맨드 뒤에 입력한 전체 텍스트가 `$ARGUMENTS`로 치환됩니다:

```markdown
---
name: explain
description: "코드를 설명합니다"
---

다음을 설명해주세요: $ARGUMENTS
```

```
> /explain src/auth/token.ts의 갱신 로직
```

### 위치 인자 ($0, $1, $2, ...)

공백으로 구분된 인자를 위치별로 참조할 수 있습니다:

```markdown
---
name: migrate
description: "컴포넌트를 다른 프레임워크로 마이그레이션합니다"
---

$0 컴포넌트를 $1에서 $2로 마이그레이션해주세요.

변환 규칙:
- 기존 기능을 모두 유지
- 새 프레임워크의 관용적 패턴 사용
- 테스트도 함께 마이그레이션
```

```
> /migrate SearchBar React Vue
# $0=SearchBar, $1=React, $2=Vue
```

### 자동 추가

`$ARGUMENTS`가 SKILL.md 본문에 없으면, Claude가 자동으로 인자를 본문 끝에 추가합니다.

---

## 컨텍스트 모드

### inherit (기본값)

현재 대화의 컨텍스트를 공유합니다:

```markdown
---
name: fix
description: "현재 논의 중인 문제를 수정합니다"
context: inherit
---

위에서 논의한 문제를 수정해주세요.
$ARGUMENTS
```

**사용 예시:**

```
# 대화 중 에러에 대해 논의한 후:
> 이 함수에서 null 참조 에러가 나는 것 같아
> /fix

# 추가 지시와 함께:
> /fix 타입 가드를 추가하는 방향으로
```

`inherit` 모드는 지금까지의 대화 내용을 참조할 수 있으므로, `/fix`만 입력해도 앞서 논의한 에러의 맥락을 이해합니다. 진행 중인 작업과 연계된 스킬에 적합합니다.

### fork

격리된 서브에이전트에서 독립적으로 실행합니다:

```markdown
---
name: deep-research
description: "코드베이스를 심층 분석합니다"
context: fork
agent: Explore
---

$ARGUMENTS를 심층 분석해주세요:

1. 관련 파일을 검색하고 읽기
2. 코드 구조와 패턴 분석
3. 구체적인 파일 참조와 함께 결과 요약
```

**사용 예시:**

```
# 특정 모듈을 심층 분석
> /deep-research 인증 시스템의 토큰 갱신 로직

# 아키텍처 전반 분석
> /deep-research 데이터베이스 접근 패턴
```

`fork` 모드는 격리된 서브에이전트에서 실행되므로, `/deep-research`가 수십 개의 파일을 읽더라도 메인 대화의 컨텍스트는 깨끗하게 유지됩니다. 분석 결과만 요약되어 메인 대화로 돌아옵니다.

- 독립적인 컨텍스트 윈도우에서 실행
- 메인 대화의 컨텍스트를 오염시키지 않음
- 대량의 출력이 예상되는 분석 작업에 적합

---

## 에이전트 타입

스킬에 사용할 수 있는 내장 에이전트:

| 에이전트 | 특성 | 기본 컨텍스트 |
|---------|------|:----------:|
| **general-purpose** | 범용 작업 | inherit |
| **Plan** | 계획과 설계 | inherit |
| **Explore** | 코드 탐색과 분석 | fork |
| **code-reviewer** | 코드 품질 리뷰 | fork |
| **code-architect** | 아키텍처 설계 | fork |
| **code-simplifier** | 코드 최적화와 정리 | fork |

커스텀 에이전트도 `.claude/agents/` 디렉토리에 정의하여 사용할 수 있습니다.

---

## 스킬 디렉토리

### 프로젝트 스킬

```
.claude/skills/
├── review/
│   └── SKILL.md
├── test/
│   └── SKILL.md
└── deploy/
    └── SKILL.md
```

- Git에 커밋하여 팀 전체가 사용
- 프로젝트별 워크플로우 자동화

### 사용자 스킬

```
~/.claude/skills/
├── my-review/
│   └── SKILL.md
└── my-utils/
    └── SKILL.md
```

- 개인적으로 모든 프로젝트에서 사용
- 개인 워크플로우 최적화

### 플러그인 스킬

플러그인에 포함된 스킬은 플러그인 설치 시 자동으로 사용 가능합니다.

---

## 호출 제어

### disable-model-invocation

```markdown
---
name: deploy
description: "프로덕션에 배포합니다"
disable-model-invocation: true
---
```

`true`로 설정하면 Claude가 자동으로 이 스킬을 호출하지 않습니다. 반드시 사용자가 `/deploy`를 직접 입력해야 합니다.

배포, 삭제 등 위험한 작업에 적합합니다.

### 도구 제한

```markdown
---
name: safe-review
description: "읽기 전용 코드 리뷰"
tools: [Read, Glob, Grep]
disallowed-tools: [Write, Edit, Bash]
---
```

스킬이 사용할 수 있는 도구를 제한하여 안전성을 보장합니다.

---

## Hot Reload

스킬 파일은 **즉시 반영**됩니다:

1. SKILL.md 파일을 수정하고 저장
2. 다음 `/스킬명` 호출 시 최신 내용이 적용됨
3. 세션을 재시작할 필요 없음

개발 중에 스킬을 반복적으로 수정하고 테스트할 수 있습니다.

---

## 실전 스킬 예제

### 코드 리뷰 스킬

```markdown
---
name: review
description: "보안, 성능, 코드 품질 관점에서 리뷰합니다"
context: fork
agent: code-reviewer
---

다음 코드를 리뷰해주세요: $ARGUMENTS

리뷰 기준:
- 보안 취약점 (OWASP Top 10)
- 성능 병목
- 코드 스타일 일관성
- 에러 처리 완전성
- 테스트 가능성
```

### 테스트 생성 스킬

```markdown
---
name: test
description: "함수 또는 모듈의 테스트를 생성합니다"
---

$ARGUMENTS에 대한 테스트를 작성해주세요.

요구사항:
- 프로젝트의 기존 테스트 패턴 따르기
- 정상 케이스와 에지 케이스 포함
- 모킹은 최소한으로
- 각 테스트는 독립적으로 실행 가능
```

### 커밋 스킬

```markdown
---
name: commit
description: "변경 사항을 분석하고 커밋합니다"
disable-model-invocation: true
---

현재 변경 사항을 분석하고 커밋해주세요.

커밋 규칙:
- Conventional Commits 형식 (feat:, fix:, refactor:, docs:)
- 제목 50자 이내
- 본문에 변경 이유 설명
- 관련 파일만 선택적으로 스테이징
```

### API 문서 생성 스킬

```markdown
---
name: api-doc
description: "API 엔드포인트의 문서를 생성합니다"
context: fork
agent: Explore
---

$ARGUMENTS의 API 문서를 생성해주세요.

포함할 내용:
- 엔드포인트 URL과 메서드
- 요청/응답 스키마
- 인증 요구사항
- 에러 코드와 메시지
- 사용 예시
```

### 마이그레이션 스킬

```markdown
---
name: migrate-component
description: "React 컴포넌트를 마이그레이션합니다"
---

$0 컴포넌트를 마이그레이션해주세요.

대상: $1 → $2

마이그레이션 가이드:
- 기능을 동일하게 유지
- 새 프레임워크의 관용적 패턴 사용
- Props 인터페이스 보존
- 테스트 업데이트
```

---

## 스킬 크기 가이드라인

- SKILL.md 본문은 **500줄 이내** 권장
- 500줄을 초과하면 별도 파일로 분리하고 참조
- 헬퍼 스크립트, 템플릿은 스킬 디렉토리 내 하위 파일로

```
.claude/skills/deploy/
├── SKILL.md              # 메인 스킬 정의
├── templates/
│   └── deploy-config.yml  # 배포 템플릿
└── scripts/
    └── validate.sh        # 검증 스크립트
```

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **SKILL.md** | YAML frontmatter + 마크다운 지시문 |
| **인자** | `$ARGUMENTS` (전체), `$0`~`$N` (위치별) |
| **컨텍스트** | `inherit` (공유) vs `fork` (격리) |
| **에이전트** | general-purpose, Explore, code-reviewer 등 |
| **디렉토리** | `.claude/skills/` (프로젝트), `~/.claude/skills/` (사용자) |
| **호출 제어** | `disable-model-invocation`, 도구 제한 |
| **Hot Reload** | 파일 저장 즉시 반영 |
| **크기** | 500줄 이내 권장, 초과 시 분리 |

---

## 다음 챕터

[20장: Hooks — 이벤트 기반 자동화](02-hooks.md)에서 Claude Code의 이벤트에 반응하는 자동화 시스템을 배웁니다.
