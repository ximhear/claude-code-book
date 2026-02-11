<!-- last_updated: 2026-02-11 -->

# 6. 도구(Tools) 시스템 이해하기

> Claude Code가 사용하는 내장 도구의 종류, 동작 방식, 권한 체계를 이해합니다.

---

## 도구 시스템 개요

Claude Code는 사용자의 요청을 수행하기 위해 **도구(Tools)**를 호출합니다. 사용자가 "이 파일을 읽어줘"라고 하면 Claude는 내부적으로 `Read` 도구를 호출하고, "테스트를 실행해줘"라고 하면 `Bash` 도구를 호출합니다.

도구 호출은 Claude의 에이전틱 루프의 핵심입니다:

```
사용자 요청 → Claude가 계획 수립 → 도구 호출 → 결과 확인 → 다음 도구 호출 또는 응답
```

도구는 세 가지 카테고리로 나뉩니다:

| 카테고리 | 승인 필요 | 도구 |
|----------|:---------:|------|
| **읽기 전용** | 아니오 | Read, Glob, Grep, LS, NotebookRead |
| **파일 수정** | 예 | Write, Edit, NotebookEdit |
| **명령어/외부** | 예 | Bash, WebFetch, WebSearch, Task |

---

## 파일 읽기 도구

### Read — 파일 내용 읽기

파일의 내용을 읽어 컨텍스트에 로드합니다.

```
Claude가 내부적으로 실행:
Read(file_path="/src/auth/login.ts")
```

- **승인 불필요** — 읽기 전용이므로 자동 실행됩니다
- 텍스트 파일뿐 아니라 **이미지** (PNG, JPG), **PDF**, **Jupyter 노트북** (.ipynb)도 읽을 수 있습니다
- 큰 파일은 줄 번호 범위를 지정하여 부분적으로 읽을 수 있습니다
- 기본적으로 2,000줄까지 읽으며, 2,000자를 초과하는 줄은 잘립니다

### Glob — 파일 패턴 검색

글로브 패턴으로 파일을 찾습니다.

```
Claude가 내부적으로 실행:
Glob(pattern="**/*.ts", path="/src")
```

- **승인 불필요**
- `**/*.tsx`, `src/**/*.test.js` 같은 글로브 패턴 지원
- 결과는 수정 시간순으로 정렬됩니다
- 어떤 크기의 코드베이스에서도 빠르게 동작합니다

### Grep — 내용 검색

파일 내용에서 정규식 패턴을 검색합니다.

```
Claude가 내부적으로 실행:
Grep(pattern="async function.*User", type="ts")
```

- **승인 불필요**
- ripgrep 기반으로 매우 빠른 검색 속도
- 출력 모드: `files_with_matches` (파일 경로만), `content` (매칭 라인), `count` (개수)
- 파일 타입 필터 (`type: "js"`) 또는 글로브 필터 (`glob: "*.tsx"`) 지원
- 멀티라인 검색: `multiline: true`로 여러 줄에 걸친 패턴 검색

### LS — 디렉토리 목록

디렉토리의 파일/폴더 목록을 조회합니다.

- **승인 불필요**
- 프로젝트 구조 파악에 사용됩니다

### NotebookRead — 노트북 읽기

Jupyter 노트북 (.ipynb)의 셀과 출력을 읽습니다.

- **승인 불필요**
- 코드 셀, 마크다운 셀, 출력을 모두 표시합니다

---

## 파일 수정 도구

### Edit — 파일 편집

기존 파일의 특정 부분을 수정합니다.

```
Claude가 내부적으로 실행:
Edit(
  file_path="/src/utils.ts",
  old_string="function validate(input) {",
  new_string="function validate(input: string): boolean {"
)
```

- **승인 필요** — 변경 전 diff가 표시됩니다
- 정확한 문자열 매칭으로 교체 위치를 결정합니다
- `replace_all: true`로 파일 내 모든 일치 항목을 교체할 수 있습니다
- Claude는 반드시 파일을 먼저 읽은 후에 편집합니다

### Write — 파일 생성/덮어쓰기

새 파일을 만들거나 기존 파일을 전체 교체합니다.

```
Claude가 내부적으로 실행:
Write(file_path="/src/helpers/string-utils.ts", content="...")
```

- **승인 필요**
- 기존 파일이 있으면 반드시 먼저 읽은 후에 덮어씁니다
- 새 파일 생성 시에도 승인이 필요합니다

### NotebookEdit — 노트북 셀 편집

Jupyter 노트북의 특정 셀을 수정, 삽입, 삭제합니다.

- **승인 필요**
- `edit_mode`: `replace` (교체), `insert` (삽입), `delete` (삭제)

---

## 실행 도구

### Bash — 셸 명령어 실행

터미널 명령어를 실행합니다.

```
Claude가 내부적으로 실행:
Bash(command="npm test", timeout=120000)
```

- **승인 필요** — 실행할 명령어가 표시됩니다
- 최대 타임아웃: 10분 (600,000ms), 기본: 2분
- 작업 디렉토리는 호출 간에 유지됩니다
- 백그라운드 실행 지원 (`run_in_background: true`)
- 출력이 30,000자를 초과하면 잘립니다

Claude는 Bash를 다음 용도로 사용합니다:
- 테스트 실행 (`npm test`, `pytest`, `go test`)
- 빌드 (`npm run build`, `cargo build`)
- Git 명령어 (`git status`, `git diff`, `git commit`)
- 패키지 관리 (`npm install`, `pip install`)
- 서버 실행 및 프로세스 관리

### WebFetch — 웹 페이지 가져오기

URL에서 콘텐츠를 가져와 처리합니다.

```
Claude가 내부적으로 실행:
WebFetch(url="https://docs.example.com/api", prompt="API 인증 방법을 찾아줘")
```

- **승인 필요**
- HTML을 마크다운으로 변환하여 분석합니다
- 15분 캐시가 적용됩니다
- 인증이 필요한 URL은 지원하지 않습니다

### WebSearch — 웹 검색

웹 검색을 수행하고 결과를 반환합니다.

```
Claude가 내부적으로 실행:
WebSearch(query="React 18 useEffect cleanup best practices")
```

- **승인 필요**
- 검색 결과를 기반으로 최신 정보를 제공합니다

---

## 에이전트 도구

### Task — 서브에이전트 생성

작업을 서브에이전트에 위임합니다.

```
Claude가 내부적으로 실행:
Task(
  subagent_type="Explore",
  prompt="src/auth/ 디렉토리의 인증 플로우를 분석해줘",
  description="인증 플로우 분석"
)
```

- **승인 가능** — 권한 설정에 따라 다름
- 사용 가능한 에이전트 유형:
  - `Explore` — 코드베이스 탐색 전문
  - `Plan` — 구현 계획 설계
  - `Bash` — 명령어 실행 전문
  - `general-purpose` — 범용 에이전트
  - 커스텀 에이전트 (`.claude/agents/`에 정의)
- 여러 서브에이전트를 **병렬로** 실행할 수 있습니다
- `run_in_background: true`로 백그라운드 실행 가능

### AskUserQuestion — 사용자에게 질문

Claude가 판단에 필요한 정보를 사용자에게 물어봅니다.

- 선택지를 제공하거나 자유 입력을 받을 수 있습니다
- 요구사항이 불명확하거나 구현 방향을 결정해야 할 때 사용됩니다

### EnterPlanMode / ExitPlanMode — Plan 모드 관리

Plan 모드에 진입하거나 빠져나옵니다. Plan 모드에서는 읽기 전용 도구만 사용됩니다.

### TodoWrite — TODO 관리

태스크 목록을 생성하고 관리합니다. 복잡한 작업의 진행 상황을 추적합니다.

---

## 병렬 도구 호출

Claude는 독립적인 작업을 **동시에** 실행할 수 있습니다:

```
사용자: "src/auth/와 src/api/의 구조를 비교해줘"

Claude의 내부 처리:
  [동시 실행]
  ├─ Glob(pattern="**/*", path="src/auth/")
  └─ Glob(pattern="**/*", path="src/api/")

  [결과를 종합하여 비교 분석]
```

병렬 실행의 이점:
- **속도 향상** — 독립적인 파일 읽기, 검색을 동시에 수행
- **효율적인 조사** — 여러 파일을 한 번에 분석
- **자동 판단** — Claude가 독립성을 자동으로 판단하여 병렬화

의존성이 있는 작업은 순차적으로 실행됩니다:
```
파일 읽기 → 분석 → 편집 결정 → 편집 실행 → 테스트 실행
```

---

## 도구 권한 체계

### 권한 규칙 구조

권한은 세 가지 레벨로 구성됩니다:

```
Allow (허용) — 자동으로 실행
Ask (질문) — 사용자에게 승인 요청 (기본)
Deny (거부) — 실행 차단
```

**평가 순서**: Deny > Ask > Allow (첫 번째 매칭 규칙 적용)

### 도구 지정자 (Tool Specifiers)

세밀한 권한 제어를 위한 문법입니다:

#### Bash 명령어 패턴

와일드카드 `*`를 사용하여 패턴 매칭:

```
Bash(npm run build)     # 정확한 명령어
Bash(npm run *)         # npm run으로 시작하는 모든 명령어
Bash(* --version)       # --version으로 끝나는 모든 명령어
Bash(git * main)        # git으로 시작하고 main으로 끝나는 명령어
```

> **주의**: 공백 위치가 중요합니다. `Bash(ls *)` (ls 뒤의 인자)와 `Bash(ls*)` (ls로 시작하는 명령어)는 다릅니다.

> **보안 경고**: `Bash(*)` 같은 광범위한 와일드카드는 **모든 Bash 명령어를 무조건 허용**하게 되어, `rm -rf /`나 `curl | sh` 같은 위험한 명령어도 승인 없이 실행됩니다. 가능한 한 `Bash(npm run *)`, `Bash(git *)` 등 **접두사를 한정**하여 허용 범위를 최소화하세요.

#### 파일 경로 패턴

Read/Edit 도구에 gitignore 스타일 패턴을 사용:

```
/src/**/*.ts            # 설정 파일 기준 상대 경로
~/Documents/*.pdf       # 홈 디렉토리 기준
//Users/alice/file      # 절대 경로 (슬래시 두 개로 시작)
*.env                   # 현재 디렉토리 기준
```

#### 도메인 필터

WebFetch 도구에 도메인 지정:

```
WebFetch(domain:docs.example.com)
```

#### MCP 도구 패턴

MCP 서버의 도구를 지정:

```
mcp__puppeteer__puppeteer_navigate    # 특정 도구
mcp__puppeteer__*                      # 서버의 모든 도구
```

#### 서브에이전트 지정

Task 도구의 에이전트 유형 지정:

```
Task(Explore)          # 특정 에이전트
Task(my-custom-agent)  # 커스텀 에이전트
```

### 권한 설정 위치

```json
// .claude/settings.json (프로젝트 공유)
{
  "permissions": {
    "allow": [
      "Bash(npm test)",
      "Bash(npm run build)",
      "Read(/src/**)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ]
  }
}
```

```json
// .claude/settings.local.json (개인용)
{
  "permissions": {
    "allow": [
      "Bash(docker compose *)"
    ]
  }
}
```

### 승인 시 선택 옵션

Claude가 승인이 필요한 도구를 호출하면:

| 옵션 | 키 | 동작 | 범위 |
|------|:---:|------|------|
| **Yes** | `y` | 이번만 허용 | 단발 |
| **No** | `n` | 거부 | 단발 |
| **Always allow** | `a` | 항상 허용 (설정에 저장) | 영구 |
| **Don't ask** | `d` | 이 세션 동안 묻지 않음 | 세션 |

---

## MCP 도구와의 차이점

Claude Code는 빌트인 도구 외에 **MCP (Model Context Protocol)** 서버를 통해 외부 도구를 사용할 수 있습니다.

| 특성 | 빌트인 도구 | MCP 도구 |
|------|------------|----------|
| **가용성** | 항상 사용 가능 | MCP 서버 설정 필요 |
| **실행 환경** | Claude Code 내부 (샌드박스) | 외부 MCP 서버 |
| **설정 위치** | 불필요 | `.mcp.json` 또는 `~/.claude.json` |
| **도구 발견** | 고정 목록 | 동적 발견 (`list_tools()`) |
| **권한 문법** | `Bash(...)`, `Read(...)` 등 | `mcp__서버명__도구명` |
| **인증** | 불필요 | OAuth 또는 토큰 가능 |

MCP 도구의 예:
- `mcp__github__create_issue` — GitHub 이슈 생성
- `mcp__slack__post_message` — Slack 메시지 전송
- `mcp__jira__update_ticket` — Jira 티켓 업데이트

MCP 도구 설정은 세 가지 범위로 관리됩니다:

| 범위 | 위치 | 우선순위 |
|------|------|:--------:|
| **프로젝트** | `<project>/.mcp.json` | 최고 |
| **사용자** | `~/.claude.json` 내 MCP 설정 | 중간 |
| **설치된 서버** | Claude Code가 관리 | 최저 |

> MCP 서버 설정과 활용법은 [21장: MCP 서버 통합](../05-advanced/03-mcp-servers.md)에서 자세히 다룹니다.

---

## 도구 사용 팁

### Claude가 도구를 선택하는 방식

Claude는 사용자 요청의 의도를 파악하고 적절한 도구를 자동으로 선택합니다:

| 사용자 요청 | Claude가 사용하는 도구 |
|------------|----------------------|
| "이 파일을 보여줘" | `Read` |
| "TypeScript 파일을 찾아줘" | `Glob` |
| "TODO 주석을 검색해줘" | `Grep` |
| "이 함수를 수정해줘" | `Read` → `Edit` |
| "새 파일을 만들어줘" | `Write` |
| "테스트를 실행해줘" | `Bash` |
| "이 에러를 조사해줘" | `Grep` → `Read` → `Bash` (복합) |

### 효율적인 도구 사용을 위한 요청 방법

```
# 도구 선택을 도와주는 구체적 요청 (✅)
> @src/auth/login.ts 이 파일의 세션 만료 로직을 설명해줘

# 검색 범위를 좁혀주는 요청 (✅)
> src/api/ 디렉토리에서 인증 미들웨어를 찾아줘

# 모호한 요청 (❌ — Claude가 더 많은 도구를 호출해야 함)
> 인증 관련 코드를 찾아줘
```

`@` 멘션으로 파일을 직접 지정하면 Claude가 검색 과정을 건너뛰고 바로 해당 파일을 읽습니다.

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **도구 카테고리** | 읽기 전용 (자동), 파일 수정 (승인), 명령어/외부 (승인) |
| **주요 도구** | Read, Edit, Write, Bash, Glob, Grep, Task, WebFetch |
| **병렬 실행** | 독립적인 작업은 자동으로 동시 실행 |
| **권한 평가** | Deny > Ask > Allow 순서로 첫 매칭 적용 |
| **도구 지정자** | Bash 패턴, 파일 경로 패턴, 도메인, MCP 패턴 |
| **MCP 도구** | 외부 서버, 동적 발견, `mcp__서버__도구` 문법 |

---

## 다음 챕터

[7장: 확장된 사고 (Extended Thinking)](03-extended-thinking.md)에서 Claude의 심층 추론 기능과 효과적인 활용법을 배웁니다.
