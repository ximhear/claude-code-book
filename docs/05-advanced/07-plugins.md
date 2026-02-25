<!-- last_updated: 2026-02-25 -->

# 25. 플러그인

> Skills, Hooks, MCP 서버, 에이전트를 하나의 배포 단위로 묶는 플러그인 시스템을 다룹니다.

---

## 플러그인이란?

플러그인은 Claude Code의 확장 기능들을 **하나의 패키지로 묶어 설치·배포·관리**할 수 있게 해주는 시스템입니다. 플러그인은 `name@marketplace` 형식으로 식별되며, 마켓플레이스를 통해 검색하고 설치합니다.

Anthropic의 공식 마켓플레이스(`claude-plugins-official`)에는 **60개 이상의 플러그인**이 기본 제공됩니다. LSP 언어 지원(TypeScript, Python, Go, Rust 등), MCP 외부 연동(GitHub, Jira, Notion, Slack 등), 개발 워크플로우(커밋, PR 리뷰, 보안 검사 등)를 바로 설치할 수 있습니다.

### 개별 설정 vs 플러그인

| 방식 | 설정 위치 | 배포 | 적합한 경우 |
|------|----------|------|------------|
| **개별 설정** | `.claude/` 디렉토리에 직접 배치 | Git 커밋 또는 수동 복사 | 프로젝트 전용 설정, 개인 사용 |
| **플러그인** | `.claude-plugin/plugin.json`으로 패키징 | 마켓플레이스를 통해 배포 | 팀 공유, 재사용, 버전 관리 |

### 플러그인이 담을 수 있는 것들

| 구성 요소 | 설명 |
|-----------|------|
| **Skills** | 커스텀 슬래시 커맨드 (`/review`, `/deploy` 등) |
| **Commands** | 내부 명령어 정의 |
| **Agents** | 커스텀 에이전트 타입 |
| **Hooks** | 이벤트 기반 자동화 스크립트 |
| **MCP 서버** | 외부 도구/데이터 소스 연결 |
| **LSP 서버** | Language Server Protocol 통합 |
| **Rules** | 프로젝트 규칙 파일 |

하나의 플러그인에 여러 구성 요소를 조합하여 **통합된 워크플로우**를 제공할 수 있습니다.

### 설치 스코프

| 스코프 | 설명 | 공유 범위 |
|--------|------|----------|
| **User** (기본값) | 모든 프로젝트에서 사용 | 본인만 |
| **Project** | `.claude/settings.json`에 추가 | 저장소 전체 협업자 |
| **Local** | 이 저장소에서만 사용 | 본인만 (커밋 안 됨) |
| **Managed** | 관리자가 배포 | 조직 전체 (변경 불가) |

---

## 플러그인 설치와 관리

### `/plugin` 인터랙티브 UI

인터랙티브 세션에서 `/plugin`을 입력하면 **4개 탭**으로 구성된 관리 UI가 열립니다:

| 탭 | 기능 |
|----|------|
| **Discover** | 마켓플레이스에서 플러그인 탐색 |
| **Installed** | 설치된 플러그인 관리 |
| **Marketplaces** | 마켓플레이스 소스 관리 |
| **Errors** | 플러그인 오류 진단 |

### 슬래시 커맨드

```bash
# 플러그인 관리
/plugin install name@marketplace           # 설치
/plugin uninstall name@marketplace         # 제거
/plugin enable name@marketplace            # 활성화
/plugin disable name@marketplace           # 비활성화

# 마켓플레이스 관리
/plugin marketplace add <source>           # 마켓플레이스 추가
/plugin marketplace list                   # 마켓플레이스 목록
/plugin marketplace update <name>          # 마켓플레이스 새로고침
/plugin marketplace remove <name>          # 마켓플레이스 제거 (플러그인도 함께 제거)

# 유효성 검증
/plugin validate .                         # 마켓플레이스/플러그인 JSON 검증
```

> `/plugin market`은 `/plugin marketplace`의 축약형, `rm`은 `remove`의 축약형입니다.

### 설치 예시

```bash
# 공식 마켓플레이스에서 설치
/plugin install commit-commands@claude-plugins-official

# 사내 마켓플레이스에서 설치
/plugin install security-scanner@company-tools

# 프로젝트 스코프로 설치 (팀 전체 공유)
/plugin install formatter@company-tools --scope project
```

### 플러그인 캐시

설치된 플러그인은 `~/.claude/plugins/cache/`에 복사됩니다. 플러그인 내부에서 상위 디렉토리(`../`)를 참조하는 경로는 동작하지 않습니다.

공식 마켓플레이스의 플러그인은 **자동 업데이트**가 기본 활성화되어 있고, 서드파티 마켓플레이스는 기본 비활성화입니다. UI에서 마켓플레이스별로 토글할 수 있습니다.

---

## 플러그인 구조

### 디렉토리 레이아웃

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json      # 플러그인 매니페스트 (필수)
├── skills/              # 스킬 정의
│   ├── review/
│   │   └── SKILL.md
│   └── test/
│       └── SKILL.md
├── agents/              # 커스텀 에이전트
│   └── quality-agent.md
├── hooks/               # 훅 스크립트
│   ├── pre-commit-lint.sh
│   └── post-edit-format.sh
├── rules/               # 규칙 파일
│   └── coding-standards.md
└── README.md
```

> 핵심: 매니페스트 파일은 **루트가 아닌 `.claude-plugin/plugin.json`**에 위치합니다.

### plugin.json 필드

```json
{
  "name": "code-quality",
  "version": "1.2.0",
  "description": "코드 품질 검사 및 리뷰 자동화",
  "author": { "name": "DevTools Team" },
  "skills": [
    "skills/review",
    "skills/test"
  ],
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/post-edit-format.sh"
          }
        ]
      }
    ]
  },
  "agents": ["agents/quality-agent.md"],
  "mcpServers": {
    "lint-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/mcp/server.js"
    }
  }
}
```

### 주요 필드 설명

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | O | 플러그인 고유 이름 (kebab-case) |
| `version` | | 시맨틱 버전 |
| `description` | | 플러그인 설명 |
| `author` | | 작성자 (`name` 필수, `email` 선택) |
| `homepage` | | 문서 URL |
| `license` | | SPDX 라이선스 식별자 |
| `keywords` | | 검색용 태그 배열 |
| `skills` | | 스킬 디렉토리 경로 |
| `commands` | | 커맨드 파일/디렉토리 경로 |
| `agents` | | 에이전트 정의 파일 경로 |
| `hooks` | | 훅 설정 (이벤트별 정의) |
| `mcpServers` | | MCP 서버 설정 |
| `lspServers` | | LSP 서버 설정 |
| `strict` | | `true`(기본): plugin.json이 정의의 기준, `false`: 마켓플레이스 엔트리가 정의를 제어 |

### `${CLAUDE_PLUGIN_ROOT}`

훅 커맨드와 MCP/LSP 서버 설정에서 플러그인 설치 디렉토리를 참조하는 환경변수입니다. 플러그인은 캐시에 복사되므로, 파일 경로는 반드시 이 변수를 사용해야 합니다:

```bash
# hooks/auto-lint.sh 에서 플러그인 내 설정 파일 참조
CONFIG="${CLAUDE_PLUGIN_ROOT}/config/lint-rules.json"
eslint --config "$CONFIG" "$FILE_PATH"
```

---

## 플러그인 만들기

### 1단계: 디렉토리 초기화

```bash
mkdir -p my-plugin/.claude-plugin
mkdir -p my-plugin/skills/lint
mkdir -p my-plugin/hooks
```

### 2단계: .claude-plugin/plugin.json 작성

```json
{
  "name": "my-lint-plugin",
  "version": "0.1.0",
  "description": "프로젝트 린트 규칙 자동 적용",
  "skills": ["skills/lint"],
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/auto-lint.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### 3단계: 스킬 추가

```markdown
<!-- skills/lint/SKILL.md -->
---
name: lint
description: "코드 린트를 실행하고 결과를 분석합니다"
---

$ARGUMENTS 파일에 대해 린트를 실행하고 결과를 분석해주세요.

1. 프로젝트의 린트 도구를 실행
2. 경고와 에러를 분류
3. 자동 수정 가능한 항목은 수정
4. 수동 수정이 필요한 항목은 설명
```

### 4단계: 훅 추가

```bash
#!/bin/bash
# hooks/auto-lint.sh
# PostToolUse 훅: 파일 편집 후 자동 린트

FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

if [ -n "$FILE_PATH" ]; then
  case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx)
      npx eslint --fix "$FILE_PATH" 2>/dev/null
      ;;
    *.py)
      ruff check --fix "$FILE_PATH" 2>/dev/null
      ;;
  esac
fi
```

### 5단계: 검증과 테스트

```bash
# 플러그인 구조 유효성 검증
/plugin validate ./my-plugin

# 로컬 디렉토리를 마켓플레이스로 등록하여 테스트
/plugin marketplace add ./my-plugin
/plugin install my-lint-plugin@my-plugin
```

검증이 통과하면 스킬과 훅이 활성화됩니다:

```bash
# 스킬 실행
> /lint src/app.ts

# 파일 편집 시 훅이 자동 실행
> src/utils/helpers.ts를 수정해줘
# → 편집 후 auto-lint.sh가 자동으로 린트 실행
```

---

## 마켓플레이스

### 개념

마켓플레이스는 플러그인의 **카탈로그**입니다. 마켓플레이스를 추가하면 앱 스토어를 등록하는 것과 같으며, 스토어에서 원하는 플러그인을 개별 설치합니다.

- **공식 마켓플레이스** (`claude-plugins-official`): Claude Code 시작 시 자동으로 사용 가능, 60+ 플러그인 포함
- **서드파티 마켓플레이스**: `/plugin marketplace add`로 수동 등록

### 마켓플레이스 디렉토리 구조

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json       # 마켓플레이스 카탈로그 (필수)
└── plugins/
    ├── review-plugin/
    │   ├── .claude-plugin/
    │   │   └── plugin.json    # 플러그인 매니페스트
    │   └── skills/
    │       └── review/
    │           └── SKILL.md
    └── lint-plugin/
        ├── .claude-plugin/
        │   └── plugin.json
        └── hooks/
            └── lint.sh
```

### marketplace.json 구조

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "company-tools",
  "description": "사내 개발 도구 모음",
  "owner": {
    "name": "DevTools Team",
    "email": "devtools@company.com"
  },
  "plugins": [
    {
      "name": "review-plugin",
      "source": "./plugins/review-plugin",
      "description": "코드 리뷰 자동화",
      "version": "1.0.0"
    },
    {
      "name": "deploy-tools",
      "source": {
        "source": "github",
        "repo": "company/deploy-plugin",
        "ref": "v2.0.0"
      },
      "description": "배포 자동화 도구"
    }
  ]
}
```

### 필수 필드

| 필드 | 설명 |
|------|------|
| `name` | 마켓플레이스 식별자 (kebab-case). `name@marketplace`에서 `@` 뒤에 오는 이름 |
| `owner.name` | 마켓플레이스 관리자 이름 |
| `plugins` | 플러그인 목록 배열 |

### 플러그인 소스 유형

| 유형 | 형식 | 설명 |
|------|------|------|
| **상대 경로** | `"./plugins/foo"` | 마켓플레이스 내 로컬 디렉토리 |
| **GitHub** | `{ "source": "github", "repo": "owner/repo", "ref": "v1.0" }` | GitHub 저장소 |
| **Git URL** | `{ "source": "url", "url": "https://gitlab.com/org/repo.git" }` | 임의 Git URL |
| **npm** | `{ "source": "npm", "package": "@company/plugin", "version": "^2.0" }` | npm 패키지 |
| **pip** | `{ "source": "pip", "package": "claude-plugin-x" }` | pip 패키지 |

> 상대 경로는 Git 또는 로컬 경로로 추가된 마켓플레이스에서만 동작합니다. URL로 `marketplace.json`을 직접 가리키는 경우 상대 경로가 해석되지 않습니다.

### 마켓플레이스 CLI 관리

```bash
# GitHub에서 추가 (owner/repo 형식)
/plugin marketplace add anthropics/claude-code

# Git URL로 추가
/plugin marketplace add https://gitlab.com/company/plugins.git

# 특정 브랜치/태그 고정
/plugin marketplace add https://gitlab.com/company/plugins.git#v1.0.0

# 로컬 디렉토리에서 추가
/plugin marketplace add ./my-marketplace

# marketplace.json 직접 지정
/plugin marketplace add ./path/to/marketplace.json

# 목록 확인
/plugin marketplace list

# 새로고침
/plugin marketplace update company-tools

# 제거 (해당 마켓플레이스의 모든 플러그인도 함께 제거)
/plugin marketplace remove company-tools
```

### settings.json으로 마켓플레이스 등록

슬래시 커맨드 대신 `settings.json`에서 마켓플레이스를 사전 등록할 수 있습니다:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  }
}
```

### 자동 업데이트

- **공식 마켓플레이스**: 자동 업데이트 기본 활성화
- **서드파티 마켓플레이스**: 자동 업데이트 기본 비활성화

마켓플레이스별로 UI에서 자동 업데이트를 토글할 수 있습니다.

---

## 엔터프라이즈 관리

### strictKnownMarketplaces

조직에서 승인된 소스만 허용하여 비인가 플러그인 설치를 차단합니다:

```json
{
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "company/approved-plugins" },
    { "source": "hostPattern", "hostPattern": "^github\\.company\\.com$" }
  ]
}
```

이 설정이 활성화되면 목록에 없는 소스에서의 마켓플레이스 추가가 거부됩니다. `hostPattern`을 사용하면 특정 호스트의 모든 저장소를 허용할 수 있습니다.

### enabledPlugins

조직에서 허용하는 플러그인을 `name@marketplace` 키로 지정합니다:

```json
{
  "enabledPlugins": {
    "code-formatter@company-tools": true,
    "security-scanner@company-tools": true,
    "deploy-tools@company-tools": true
  }
}
```

### Managed 스코프

관리자가 조직 전체에 플러그인을 강제 배포합니다. managed 스코프로 설치된 플러그인은 사용자가 비활성화하거나 제거할 수 없습니다.

관리자 설정 경로의 `settings.json`에서 `enabledPlugins`와 `extraKnownMarketplaces`를 설정하면 조직 전체에 적용됩니다.

### 관리자 설정 경로

| 플랫폼 | 경로 |
|--------|------|
| **macOS** | `/Library/Application Support/ClaudeCode/` |
| **Linux** | `/etc/claude-code/` |
| **Windows** | `%ProgramData%\ClaudeCode\` |

관리자 경로의 설정은 사용자 설정보다 우선하며, 사용자가 변경할 수 없습니다.

---

## 기존 개념과의 관계

### 개별 설정 vs 플러그인 비교

| 기능 | 개별 설정 | 플러그인에 포함 |
|------|:--------:|:-------------:|
| **Skills** | `.claude/skills/` 직접 배치 | 플러그인 내 `skills/` 디렉토리 |
| **Hooks** | `settings.json`에 직접 정의 | `.claude-plugin/plugin.json`의 hooks |
| **Agents** | `.claude/agents/` 직접 배치 | 플러그인 내 `agents/` 디렉토리 |
| **MCP 서버** | `settings.json`에 직접 설정 | `.claude-plugin/plugin.json`의 mcpServers |
| **Rules** | `.claude/rules/` 직접 배치 | 플러그인 내 `rules/` 디렉토리 |

### 언제 플러그인을 사용할까?

| 시나리오 | 권장 방식 |
|---------|----------|
| 프로젝트 전용 스킬 1~2개 | 개별 설정 |
| 팀 공유가 필요한 워크플로우 | 플러그인 |
| 여러 기능을 조합한 도구 세트 | 플러그인 |
| 조직 전체 표준 적용 | managed 플러그인 |
| 개인 유틸리티 | 개별 설정 (`~/.claude/`) |
| 오픈소스 커뮤니티 공유 | 플러그인 (마켓플레이스) |

> 일반적인 필요(린팅, 포매팅, 보안 검사 등)는 공식 마켓플레이스(`claude-plugins-official`)에서 먼저 찾아보세요. 60개 이상의 플러그인이 이미 제공됩니다.

---

## 실전 예제: 코드 품질 플러그인

리뷰 스킬과 린트 훅을 조합한 **코드 품질 플러그인**을 만들어 봅니다.

### 디렉토리 구조

```
code-quality-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── quality-review/
│       └── SKILL.md
├── hooks/
│   └── post-edit-lint.sh
└── rules/
    └── quality-standards.md
```

### .claude-plugin/plugin.json

```json
{
  "name": "code-quality",
  "version": "1.0.0",
  "description": "코드 편집 시 자동 린트 + 품질 리뷰 스킬",
  "author": { "name": "DevTools Team" },
  "skills": ["skills/quality-review"],
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/post-edit-lint.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### 리뷰 스킬

```markdown
<!-- skills/quality-review/SKILL.md -->
---
name: quality-review
description: "코드 품질 종합 리뷰 (보안, 성능, 스타일)"
context: fork
agent: code-reviewer
---

다음 코드를 품질 관점에서 리뷰해주세요: $ARGUMENTS

## 리뷰 항목

1. **보안**: OWASP Top 10 기준 취약점 검사
2. **성능**: 불필요한 연산, 메모리 누수, N+1 쿼리
3. **스타일**: 프로젝트 코딩 컨벤션 준수
4. **에러 처리**: 에지 케이스, 에러 전파 경로
5. **테스트 가능성**: 의존성 주입, 모킹 용이성

## 출력 형식

각 항목에 대해 심각도(Critical/High/Medium/Low)와 함께 보고해주세요.
```

### 린트 훅

```bash
#!/bin/bash
# hooks/post-edit-lint.sh
# 파일 편집 후 자동으로 린트 실행

FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 플러그인 내 설정 파일 참조
CONFIG="${CLAUDE_PLUGIN_ROOT}/config/eslint.json"

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx)
    RESULT=$(npx eslint --fix "$FILE_PATH" 2>&1)
    if [ $? -ne 0 ]; then
      echo "린트 경고: $RESULT"
    fi
    ;;
  *.py)
    RESULT=$(ruff check --fix "$FILE_PATH" 2>&1)
    if [ $? -ne 0 ]; then
      echo "린트 경고: $RESULT"
    fi
    ;;
esac
```

### 규칙 파일

```markdown
<!-- rules/quality-standards.md -->
# 코드 품질 표준

- 모든 함수는 단일 책임 원칙을 따른다
- 매직 넘버 대신 명명된 상수를 사용한다
- 공개 API에는 JSDoc/docstring을 작성한다
- 에러는 구체적인 타입으로 처리한다
- 사용하지 않는 import와 변수는 제거한다
```

### 사용

```bash
# 마켓플레이스에서 설치
/plugin install code-quality@team-marketplace

# 리뷰 스킬 실행
> /quality-review src/auth/login.ts

# 파일 편집 시 린트 훅이 자동 실행
> src/utils/helpers.ts를 수정해줘
# → 편집 후 post-edit-lint.sh가 자동으로 ESLint 실행
```

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **플러그인** | Skills, Hooks, Agents, MCP 등을 하나로 패키징 |
| **설치** | `/plugin install name@marketplace` |
| **구조** | `.claude-plugin/plugin.json` + 기능별 디렉토리 |
| **테스트** | `/plugin validate .` + 로컬 마켓플레이스 등록 |
| **마켓플레이스** | `.claude-plugin/marketplace.json`으로 카탈로그 정의 |
| **공식 마켓플레이스** | `claude-plugins-official` (60+ 플러그인 기본 제공) |
| **엔터프라이즈** | `strictKnownMarketplaces`, `enabledPlugins` |
| **캐시** | `~/.claude/plugins/cache/` |

---

## 다음 챕터

Part VI: 확장과 통합에서 [26장: IDE 통합](../06-integrations/01-ide-integrations.md)을 통해 VS Code, JetBrains 등에서 Claude Code를 사용하는 방법을 배웁니다.
