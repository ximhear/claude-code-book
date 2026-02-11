<!-- last_updated: 2026-02-11 -->

# 5. 슬래시 커맨드 완전 가이드

> 모든 빌트인 슬래시 커맨드와 커스텀 스킬 커맨드의 사용법을 분류별로 정리합니다.

---

## 슬래시 커맨드 개요

Claude Code에서 `/`를 입력하면 사용 가능한 슬래시 커맨드 목록이 표시됩니다. 슬래시 커맨드는 두 종류입니다:

1. **빌트인 커맨드** — Claude Code에 내장된 명령어
2. **스킬 커맨드** — 사용자가 정의한 커스텀 명령어 (Skills 시스템)

```
> /          ← 전체 목록 표시
> /co        ← 'co'로 시작하는 명령어 필터링 (compact, config, copy, cost)
```

---

## 세션 관리

### `/clear` — 대화 초기화

현재 대화 히스토리를 비우고 새로운 대화를 시작합니다.

```
> /clear
```

- 세션 자체는 유지됩니다 (Claude Code를 종료하지 않음)
- 이전 대화의 컨텍스트가 모두 사라지므로 비용을 절약할 수 있습니다
- Git 상태, CLAUDE.md 등 환경 컨텍스트는 새 대화에서 다시 로드됩니다

### `/compact` — 컨텍스트 압축

대화 히스토리를 요약하여 토큰 사용량을 줄입니다.

```
> /compact
> /compact 인증 관련 내용만 유지해줘
```

- 선택적으로 **포커스 지침**을 인자로 전달하여 어떤 내용을 유지할지 지시할 수 있습니다
- 긴 세션에서 컨텍스트 윈도우 한계에 근접할 때 유용합니다
- Claude Code는 컨텍스트 한계 도달 시 자동으로 압축을 수행하기도 합니다

### `/resume` — 이전 세션 재개

이전 세션을 재개하거나 세션 선택 화면을 엽니다.

```
> /resume
> /resume auth-refactor
```

- 인자 없이 사용하면 세션 목록에서 선택할 수 있습니다
- 세션 이름이나 ID를 지정하면 해당 세션으로 바로 이동합니다
- CLI에서는 `claude --resume <name>` 또는 `claude --continue`로도 가능합니다

### `/rename` — 세션 이름 변경

현재 세션의 이름을 변경하여 나중에 쉽게 찾을 수 있게 합니다.

```
> /rename auth-refactor
```

### `/rewind` — 대화 되돌리기

대화를 특정 시점으로 되돌리거나 요약을 생성합니다.

```
> /rewind
```

- 이전 메시지 중 하나를 선택하여 해당 시점으로 되돌릴 수 있습니다
- 코드 변경도 함께 되돌릴 수 있습니다 (체크포인트 활용)

### `/teleport` — 원격 세션 재개

Claude.ai 웹에서 진행 중인 세션을 로컬 Claude Code로 가져옵니다.

```
> /teleport
```

- 구독자 전용 기능입니다 (Pro/Max/Teams)
- 웹에서 시작한 대화를 터미널로 이어서 작업할 때 유용합니다

---

## 설정 및 구성

### `/config` — 설정 인터페이스

전체 설정 화면을 엽니다.

```
> /config
```

설정 가능한 항목:
- 테마, 모델, Extended Thinking 토글
- 알림, 프롬프트 제안 활성화/비활성화
- 그 외 전역 설정

### `/model` — 모델 전환

AI 모델을 선택하거나 변경합니다.

```
> /model
> /model opus
> /model sonnet
> /model haiku
> /model opusplan
> /model sonnet[1m]
```

- 인자 없이 사용하면 모델 선택 화면이 나타납니다
- Opus 4.6 선택 시 좌/우 화살표로 **노력 수준** (effort level)을 조절할 수 있습니다
- 변경은 즉시 적용됩니다

> 자세한 내용은 [8장: 모델 선택과 전환](04-model-selection.md)에서 다룹니다.

### `/permissions` — 권한 관리

도구별 권한 규칙을 확인하고 수정합니다.

```
> /permissions
```

- Allow / Deny 규칙을 관리합니다
- 세밀한 도구 지정자 (tool specifier) 문법을 지원합니다

> 자세한 내용은 [10장: 권한 시스템](../03-configuration/02-permissions.md)에서 다룹니다.

### `/vim` — Vim 모드

Vim 스타일 키 바인딩을 활성화합니다.

```
> /vim
```

- Normal, Insert, Visual 모드를 지원합니다
- `i`로 입력 모드, `Esc`로 일반 모드

### `/terminal-setup` — 터미널 최적화

터미널 설정을 최적화합니다.

```
> /terminal-setup
```

- Shift+Enter 멀티라인 입력 설정
- 키 바인딩 호환성 구성
- Option/Alt+T (Extended Thinking 토글) 활성화에 필요

### `/theme` — 테마 변경

색상 테마를 변경합니다.

```
> /theme
```

- 인터랙티브 테마 선택기가 나타납니다

### `/statusline` — 상태 표시줄 설정

하단 상태 표시줄의 UI를 설정합니다.

```
> /statusline
```

---

## 프로젝트 및 작업

### `/init` — CLAUDE.md 생성

프로젝트 초기화 가이드를 실행하여 CLAUDE.md 파일을 생성합니다.

```
> /init
```

- Claude가 프로젝트를 분석하고 적절한 CLAUDE.md 초안을 제안합니다
- 빌드 명령어, 코딩 규칙, 디렉토리 구조 등을 포함합니다

> 자세한 내용은 [9장: CLAUDE.md 설정](../03-configuration/01-claude-md.md)에서 다룹니다.

### `/review` — PR 리뷰

현재 브랜치의 풀 리퀘스트를 리뷰합니다.

```
> /review
```

- Git diff를 분석하고 코드 리뷰를 수행합니다
- 버그, 보안 문제, 코드 품질 등을 검사합니다

### `/pr-comments` — PR 코멘트 가져오기

GitHub 풀 리퀘스트의 리뷰 코멘트를 가져옵니다.

```
> /pr-comments
```

- `gh` CLI가 설치되어 있어야 합니다

### `/add-dir` — 작업 디렉토리 추가

추가 작업 디렉토리를 등록합니다.

```
> /add-dir ../shared-lib
> /add-dir ~/other-project/src
```

- 여러 프로젝트를 동시에 참조해야 할 때 유용합니다
- CLI에서는 `claude --add-dir ../apps --add-dir ../lib`으로도 가능합니다

### `/plan` — Plan 모드 진입

Plan 모드로 전환합니다.

```
> /plan
```

- 읽기 전용 도구만 사용하여 코드베이스를 분석합니다
- 실제 변경 없이 계획을 수립할 때 사용합니다
- Shift+Tab 두 번으로도 진입할 수 있습니다

---

## 정보 및 진단

### `/help` — 도움말

사용 가능한 모든 명령어와 키보드 단축키를 표시합니다.

```
> /help
```

### `/cost` — 비용 확인

현재 세션의 토큰 사용량과 비용을 표시합니다.

```
> /cost
```

출력 예시:
```
Total cost:            $0.55
Total duration (API):  6m 19.7s
Total duration (wall): 6h 33m 10.2s
Total code changes:    42 lines added, 12 lines removed
```

- API 사용자에게 특히 유용합니다
- 구독자는 `/usage`로 구독 사용량을 확인하세요

### `/usage` — 구독 사용량

구독 플랜의 사용량 한도와 레이트 리밋 상태를 표시합니다.

```
> /usage
```

- Pro/Max/Teams/Enterprise 구독자 전용입니다

### `/stats` — 사용 통계

일별 사용량, 세션 히스토리, 연속 사용일, 모델별 사용 빈도 등을 시각화합니다.

```
> /stats
```

### `/status` — 세션 상태

현재 세션의 상태 정보를 표시합니다 (버전, 모델, 계정, 연결 상태).

```
> /status
```

### `/doctor` — 환경 진단

Claude Code 설치 환경의 건강 상태를 검사합니다.

```
> /doctor
> /doctor --performance
```

검사 항목:
- 설치 유형과 버전
- 자동 업데이트 상태
- ripgrep 가용성
- 설정 파일 유효성
- MCP 서버 상태
- 키바인딩 설정
- 컨텍스트 사용량 경고

### `/context` — 컨텍스트 시각화

현재 컨텍스트 사용량을 시각적 그리드로 보여줍니다.

```
> /context
```

- 컨텍스트 윈도우가 얼마나 사용되었는지 한눈에 파악할 수 있습니다
- 스킬 예산 초과 경고도 확인할 수 있습니다

### `/debug` — 디버그 로그

세션 디버그 로그를 읽어 문제를 진단합니다.

```
> /debug
> /debug 응답이 갑자기 끊겼어
```

- 선택적으로 문제 설명을 인자로 전달할 수 있습니다

---

## 유틸리티

### `/export` — 대화 내보내기

현재 대화를 파일이나 클립보드로 내보냅니다.

```
> /export
> /export conversation.md
```

### `/copy` — 응답 복사

Claude의 마지막 응답을 클립보드에 복사합니다.

```
> /copy
```

### `/tasks` — 백그라운드 태스크

백그라운드에서 실행 중인 태스크를 나열하고 관리합니다.

```
> /tasks
```

### `/todos` — TODO 목록

현재 TODO 항목을 나열합니다.

```
> /todos
```

### `/memory` — 메모리 편집

CLAUDE.md 메모리 파일을 직접 편집합니다.

```
> /memory
```

- 프로젝트별 또는 전역 메모리를 수정할 수 있습니다

### `/mcp` — MCP 서버 관리

MCP 서버 연결과 OAuth 인증을 관리합니다.

```
> /mcp
```

> 자세한 내용은 [21장: MCP 서버 통합](../05-advanced/03-mcp-servers.md)에서 다룹니다.

---

## 인증

### `/login` — 로그인

Claude 계정으로 인증합니다.

```
> /login
```

- 브라우저가 열리며 로그인 페이지로 이동합니다

### `/logout` — 로그아웃

현재 인증을 해제합니다.

```
> /logout
```

---

## 빌트인 커맨드 요약 테이블

| 분류 | 명령어 | 인자 | 설명 |
|------|--------|------|------|
| **세션** | `/clear` | — | 대화 초기화 |
| | `/compact` | `[지침]` | 컨텍스트 압축 |
| | `/resume` | `[세션명]` | 이전 세션 재개 |
| | `/rename` | `<이름>` | 세션 이름 변경 |
| | `/rewind` | — | 대화 되돌리기 |
| | `/teleport` | — | 원격 세션 가져오기 |
| **설정** | `/config` | — | 설정 화면 |
| | `/model` | `[모델명]` | 모델 전환 |
| | `/permissions` | — | 권한 관리 |
| | `/vim` | — | Vim 모드 토글 |
| | `/terminal-setup` | — | 터미널 최적화 |
| | `/theme` | — | 테마 변경 |
| | `/statusline` | — | 상태 표시줄 설정 |
| **작업** | `/init` | — | CLAUDE.md 생성 |
| | `/review` | — | PR 리뷰 |
| | `/pr-comments` | — | PR 코멘트 가져오기 |
| | `/add-dir` | `<경로>` | 작업 디렉토리 추가 |
| | `/plan` | — | Plan 모드 진입 |
| **정보** | `/help` | — | 도움말 |
| | `/cost` | — | 비용 확인 |
| | `/usage` | — | 구독 사용량 |
| | `/stats` | — | 사용 통계 |
| | `/status` | — | 세션 상태 |
| | `/doctor` | `[--performance]` | 환경 진단 |
| | `/context` | — | 컨텍스트 시각화 |
| | `/debug` | `[설명]` | 디버그 로그 |
| **유틸리티** | `/export` | `[파일명]` | 대화 내보내기 |
| | `/copy` | — | 마지막 응답 복사 |
| | `/tasks` | — | 백그라운드 태스크 |
| | `/todos` | — | TODO 목록 |
| | `/memory` | — | 메모리 편집 |
| | `/mcp` | — | MCP 서버 관리 |
| **인증** | `/login` | — | 로그인 |
| | `/logout` | — | 로그아웃 |
| **종료** | `/exit` | — | Claude Code 종료 |

---

## 커스텀 슬래시 커맨드 (Skills)

빌트인 커맨드 외에 자신만의 슬래시 커맨드를 만들 수 있습니다. 이것이 **Skills 시스템**입니다.

### 스킬 생성하기

스킬은 `SKILL.md` 파일로 정의합니다:

**개인 스킬** (모든 프로젝트에서 사용):
```
~/.claude/skills/<skill-name>/SKILL.md
```

**프로젝트 스킬** (해당 프로젝트에서만):
```
<project>/.claude/skills/<skill-name>/SKILL.md
```

### SKILL.md 구조

```yaml
---
name: review-code
description: 코드를 리뷰하고 버그와 품질 이슈를 찾습니다
---

코드를 리뷰해주세요:
1. 버그와 로직 에러
2. 보안 취약점
3. 코드 품질 이슈
4. 베스트 프랙티스 준수 여부
```

이 스킬은 `/review-code`로 호출됩니다.

### 프론트매터 필드

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | 아니오 | 커맨드 이름 (소문자, 숫자, 하이픈만 가능, 최대 64자). 생략 시 디렉토리명 사용 |
| `description` | 권장 | 스킬 설명. Claude가 자동 호출 여부를 결정할 때 참조 |
| `disable-model-invocation` | 아니오 | `true`이면 Claude가 자동으로 호출하지 않음. 기본: `false` |
| `user-invocable` | 아니오 | `false`이면 `/` 메뉴에서 숨김. 기본: `true` |
| `allowed-tools` | 아니오 | 스킬 활성 시 승인 없이 사용 가능한 도구 |
| `argument-hint` | 아니오 | 자동완성에 표시될 인자 힌트. 예: `[issue-number]` |
| `model` | 아니오 | 스킬 실행 시 사용할 모델 |
| `context` | 아니오 | `fork`로 설정하면 격리된 서브에이전트에서 실행 |
| `agent` | 아니오 | `context: fork` 시 사용할 에이전트 유형 |
| `hooks` | 아니오 | 스킬 라이프사이클에 한정된 훅 |

### 인자 전달

스킬에 인자를 전달할 수 있습니다:

```yaml
---
name: fix-issue
description: GitHub 이슈를 수정합니다
disable-model-invocation: true
---

GitHub 이슈 $ARGUMENTS를 코딩 규칙에 따라 수정해주세요.

1. 이슈 내용을 읽고 요구사항 파악
2. 수정 구현
3. 테스트 작성
4. 커밋 생성
```

```
> /fix-issue 123
```

Claude는 `$ARGUMENTS`를 `123`으로 치환하여 실행합니다.

개별 인자에 접근하려면 `$ARGUMENTS[0]` 또는 `$0`, `$1`, `$2` 형식을 사용합니다:

```yaml
---
name: migrate-component
description: 컴포넌트를 한 프레임워크에서 다른 프레임워크로 마이그레이션
---

$0 컴포넌트를 $1에서 $2로 마이그레이션해주세요.
기존 동작과 테스트를 모두 보존하세요.
```

```
> /migrate-component SearchBar React Vue
```

### 호출 모드 제어

| 설정 | 사용자 호출 | Claude 자동 호출 | 용도 |
|------|:----------:|:---------------:|------|
| 기본값 | O | O | 범용 커맨드 |
| `disable-model-invocation: true` | O | X | 배포, 커밋 등 부작용이 있는 작업 |
| `user-invocable: false` | X | O | 참조 지식용 (배경 정보) |

### 동적 컨텍스트 주입

`` !`command` `` 문법으로 셸 명령어 출력을 스킬에 주입할 수 있습니다:

```yaml
---
name: pr-summary
description: PR 변경 사항을 요약합니다
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## PR 컨텍스트
- PR diff: !`gh pr diff`
- PR 코멘트: !`gh pr view --comments`
- 변경 파일: !`gh pr diff --name-only`

## 작업
이 PR을 요약해주세요...
```

명령어는 Claude가 프롬프트를 받기 전에 실행되며, 출력이 해당 위치에 삽입됩니다.

### 서브에이전트에서 스킬 실행

`context: fork`를 추가하면 격리된 서브에이전트에서 스킬이 실행됩니다:

```yaml
---
name: deep-research
description: 주제를 심층 조사합니다
context: fork
agent: Explore
---

$ARGUMENTS를 심층 조사해주세요:

1. Glob과 Grep으로 관련 파일 찾기
2. 코드 분석
3. 파일 참조와 함께 결과 요약
```

**실행 흐름:**

```
사용자: /deep-research 인증 시스템

→ Claude가 격리된 서브에이전트 생성
→ 시스템 프롬프트: agent 필드의 에이전트 유형(Explore)이 정의하는 기본 프롬프트
→ 태스크(사용자 메시지): SKILL.md의 본문 ("$ARGUMENTS를 심층 조사해주세요...")
→ $ARGUMENTS가 "인증 시스템"으로 치환됨
→ CLAUDE.md가 추가 컨텍스트로 로드됨
→ 서브에이전트가 독립적으로 작업 수행 후 결과 반환
```

`context: fork` 스킬은 **SKILL.md 자체가 서브에이전트의 작업 지시서**가 됩니다.

서브에이전트의 `skills` 필드로 스킬을 프리로드하는 방식도 있습니다. 이 경우 서브에이전트의 마크다운 본문이 시스템 프롬프트가 되고, Claude가 서브에이전트에 위임하는 메시지가 태스크가 됩니다:

```
# .claude/agents/analyzer.md
---
skills:
  - deep-research
  - code-review
---

코드 분석 전문 에이전트입니다.
분석 요청을 받으면 프리로드된 스킬을 활용하여...
```

```
사용자: "이 모듈을 분석해줘"

→ Claude가 analyzer 서브에이전트에 위임
→ 시스템 프롬프트: analyzer.md의 본문 ("코드 분석 전문 에이전트입니다...")
→ 태스크(사용자 메시지): Claude가 작성한 위임 메시지 ("이 모듈을 분석해달라는 요청입니다...")
→ 프리로드된 스킬(deep-research, code-review) + CLAUDE.md가 추가 컨텍스트로 로드됨
```

**두 접근 방식 비교:**

| | `context: fork` 스킬 | 스킬을 프리로드한 서브에이전트 |
|---|---|---|
| **시스템 프롬프트** | `agent` 필드의 에이전트 유형이 제공 | 서브에이전트 마크다운(.md) 본문 |
| **태스크** | SKILL.md 본문 내용 | Claude의 위임 메시지 |
| **추가 컨텍스트** | CLAUDE.md | 프리로드된 스킬 + CLAUDE.md |
| **호출 방식** | `/skill-name` 슬래시 커맨드 | Claude가 자동으로 위임 |
| **적합한 용도** | 사용자가 직접 실행하는 단일 작업 | 복합 작업에서 스킬을 조합하는 에이전트 |

### 스킬 배포 범위

| 범위 | 위치 | 공유 방법 |
|------|------|-----------|
| **프로젝트** | `.claude/skills/` | 버전 관리에 커밋 |
| **플러그인** | 플러그인 내 `skills/` 디렉토리 | 플러그인으로 배포 |
| **관리자 배포** | managed settings 경로 | 조직 전체에 배포 |

### 스킬 접근 제어

스킬 접근 제어는 Claude Code의 **권한 시스템** (`/permissions` 명령어 또는 `settings.json`의 `permissions`)에서 설정합니다. `Bash()`, `Read()` 등 다른 도구 권한과 동일한 문법을 사용합니다.

**허용 규칙 (allow):**

```
Skill(commit)         # "commit" 스킬만 정확히 허용
Skill(review-pr *)    # "review-pr"로 시작하는 모든 스킬 허용
                      # (review-pr, review-pr-comments 등)
```

**차단 규칙 (deny):**

```
Skill(deploy *)       # "deploy"로 시작하는 스킬 차단
Skill                 # 모든 스킬 실행 차단
```

**설정 예시 (settings.json):**

```json
{
  "permissions": {
    "allow": [
      "Skill(commit)",
      "Skill(review-pr *)"
    ],
    "deny": [
      "Skill(deploy *)"
    ]
  }
}
```

**문법 규칙:**

| 패턴 | 의미 | 예시 |
|------|------|------|
| `Skill(name)` | 정확히 해당 이름의 스킬만 매칭 | `Skill(commit)` → `commit`만 |
| `Skill(name *)` | 해당 접두사로 시작하는 모든 스킬 매칭 | `Skill(review *)` → `review`, `review-pr` 등 |
| `Skill` | 모든 스킬 매칭 (deny에 넣으면 전체 차단) | — |

> **참고**: 이 문법은 `Bash(npm *)`, `Read(src/*)` 같은 다른 도구 권한 규칙과 동일한 패턴입니다. 자세한 내용은 [10장: 권한 모드와 보안](../03-configuration/02-permissions.md)을 참조하세요.

---

## 실전 스킬 예제: 코드베이스 시각화

스킬은 Claude의 프롬프트뿐만 아니라 스크립트도 포함할 수 있습니다:

```
~/.claude/skills/codebase-visualizer/
├── SKILL.md
└── scripts/
    └── visualize.py
```

````yaml
# SKILL.md
---
name: codebase-visualizer
description: 코드베이스의 인터랙티브 트리 시각화를 생성합니다
allowed-tools: Bash(python *)
---

# Codebase Visualizer

프로젝트 루트에서 시각화 스크립트를 실행하세요:

```bash
python ~/.claude/skills/codebase-visualizer/scripts/visualize.py .
```

`codebase-map.html`이 생성되어 브라우저에서 열립니다.
````

이 패턴으로 의존성 그래프, 테스트 커버리지 보고서, API 문서, 데이터베이스 스키마 시각화 등 다양한 시각적 출력을 만들 수 있습니다.

---

## 스킬 트러블슈팅

### 스킬이 트리거되지 않음

1. `description`에 사용자가 자연스럽게 말할 키워드가 포함되어 있는지 확인
2. "어떤 스킬이 있어?" 라고 물어서 Claude가 인식하는지 확인
3. `/skill-name`으로 직접 호출 시도
4. 스킬 수가 많으면 컨텍스트 예산을 초과할 수 있음 — `/context`로 확인

### 스킬이 너무 자주 트리거됨

1. `description`을 더 구체적으로 작성
2. 수동 호출만 원한다면 `disable-model-invocation: true` 추가

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **빌트인 커맨드** | `/clear`, `/compact`, `/model`, `/config`, `/cost` 등 30개 이상 |
| **목록 표시** | `/` 입력 후 필터링 |
| **커스텀 커맨드** | `.claude/skills/<name>/SKILL.md`로 생성 |
| **인자 전달** | `$ARGUMENTS`, `$0`, `$1` 등 |
| **호출 제어** | `disable-model-invocation`, `user-invocable` |
| **서브에이전트** | `context: fork`로 격리 실행 |
| **배포** | 프로젝트, 플러그인, 관리자 설정으로 공유 |

---

## 다음 챕터

[6장: 도구(Tools) 시스템 이해하기](02-tools.md)에서 Claude Code가 사용하는 내장 도구의 동작 방식과 권한 체계를 배웁니다.
