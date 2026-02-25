<!-- last_updated: 2026-02-25 -->

# 25. 플러그인

> Skills, Hooks, MCP 서버, 에이전트를 하나의 배포 단위로 묶는 플러그인 시스템을 다룹니다.

---

## 플러그인이란?

플러그인은 Claude Code의 확장 기능들을 **하나의 패키지로 묶어 설치·배포·관리**할 수 있게 해주는 시스템입니다.

### standalone 설정 vs 플러그인

| 방식 | 설정 위치 | 배포 | 적합한 경우 |
|------|----------|------|------------|
| **standalone** | `.claude/` 디렉토리에 직접 배치 | Git 커밋 또는 수동 복사 | 프로젝트 전용 설정, 개인 사용 |
| **플러그인** | 패키지로 묶어 설치 | 마켓플레이스, npm, GitHub | 팀 공유, 재사용, 버전 관리 |

### 플러그인이 담을 수 있는 것들

| 구성 요소 | 설명 |
|-----------|------|
| **Skills** | 커스텀 슬래시 커맨드 (`/review`, `/deploy` 등) |
| **Commands** | 내부 명령어 정의 |
| **Agents** | 커스텀 에이전트 타입 |
| **Hooks** | 이벤트 기반 자동화 스크립트 |
| **MCP 서버** | 외부 도구/데이터 소스 연결 |
| **LSP 설정** | Language Server Protocol 통합 |
| **Rules** | 프로젝트 규칙 파일 |

하나의 플러그인에 여러 구성 요소를 조합하여 **통합된 워크플로우**를 제공할 수 있습니다.

---

## 플러그인 설치와 관리

### `/plugin` UI

인터랙티브 세션에서 `/plugin`을 입력하면 플러그인 관리 UI가 열립니다:

```
> /plugin

플러그인 관리:
  [설치된 플러그인 목록]
  - code-quality v1.2.0 ✓
  - team-standards v0.9.1 ✓

  [사용 가능한 작업]
  - 설치 / 제거 / 활성화 / 비활성화 / 업데이트
```

### CLI 명령어

```bash
# 설치
claude plugin install <패키지>

# 목록 확인
claude plugin list

# 활성화/비활성화
claude plugin enable <이름>
claude plugin disable <이름>

# 제거
claude plugin remove <이름>

# 전체 업데이트
claude plugin update

# 특정 플러그인 업데이트
claude plugin update <이름>
```

### 설치 예시

```bash
# GitHub 저장소에서 설치
claude plugin install github:company/code-quality

# npm 패키지로 설치
claude plugin install npm:@company/claude-plugin-lint

# URL에서 직접 설치
claude plugin install https://example.com/plugins/my-plugin.tar.gz
```

---

## 플러그인 구조

### 디렉토리 레이아웃

```
my-plugin/
├── plugin.json          # 플러그인 메타데이터 (필수)
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
│   ├── coding-standards.md
│   └── security-rules.md
├── mcp/                 # MCP 서버 설정
│   └── config.json
└── README.md            # 플러그인 설명
```

### plugin.json 필드

```json
{
  "name": "code-quality",
  "version": "1.2.0",
  "description": "코드 품질 검사 및 리뷰 자동화",
  "author": "company",
  "license": "MIT",
  "engines": {
    "claude-code": ">=2.0.0"
  },
  "skills": [
    "skills/review",
    "skills/test"
  ],
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "Write|Edit",
      "command": "hooks/post-edit-format.sh",
      "timeout": 15
    }
  ],
  "agents": [
    "agents/quality-agent.md"
  ],
  "rules": [
    "rules/coding-standards.md",
    "rules/security-rules.md"
  ],
  "mcp": {
    "servers": {
      "lint-server": {
        "command": "node",
        "args": ["mcp/server.js"]
      }
    }
  },
  "dependencies": {
    "eslint": ">=8.0.0"
  }
}
```

### 주요 필드 설명

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | O | 플러그인 고유 이름 (소문자, 하이픈 허용) |
| `version` | O | 시맨틱 버전 (semver) |
| `description` | O | 플러그인 설명 |
| `author` | | 작성자 |
| `license` | | 라이선스 |
| `engines` | | 호환 Claude Code 버전 범위 |
| `skills` | | 포함된 스킬 디렉토리 경로 |
| `hooks` | | 훅 정의 배열 |
| `agents` | | 에이전트 정의 파일 경로 |
| `rules` | | 규칙 파일 경로 |
| `mcp` | | MCP 서버 설정 |
| `dependencies` | | 외부 의존성 |

---

## 플러그인 만들기

### 1단계: 초기화

```bash
mkdir my-plugin && cd my-plugin
```

### 2단계: plugin.json 작성

```json
{
  "name": "my-lint-plugin",
  "version": "0.1.0",
  "description": "프로젝트 린트 규칙 자동 적용",
  "engines": {
    "claude-code": ">=2.0.0"
  },
  "skills": ["skills/lint"],
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "Write|Edit",
      "command": "hooks/auto-lint.sh",
      "timeout": 30
    }
  ]
}
```

### 3단계: 스킬 추가

```bash
mkdir -p skills/lint
```

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
mkdir hooks
```

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

### 5단계: 로컬 테스트

`--plugin-dir` 플래그로 개발 중인 플러그인을 로컬에서 테스트합니다:

```bash
# 플러그인 디렉토리를 지정하여 Claude Code 실행
claude --plugin-dir /path/to/my-plugin

# 스킬이 등록되었는지 확인
> /lint src/app.ts
```

로컬 테스트에서는 플러그인의 모든 구성 요소(스킬, 훅, 에이전트 등)가 즉시 활성화됩니다.

---

## 마켓플레이스

### 개념

마켓플레이스는 플러그인을 **검색하고 설치할 수 있는 소스**입니다. 기본 마켓플레이스 외에 커스텀 소스를 추가할 수 있습니다.

### 소스 유형

| 소스 | 형식 | 예시 |
|------|------|------|
| **GitHub** | `github:<owner>/<repo>` | `github:company/code-quality` |
| **npm** | `npm:<패키지명>` | `npm:@company/claude-plugin-lint` |
| **pip** | `pip:<패키지명>` | `pip:claude-plugin-analysis` |
| **URL** | 직접 URL | `https://example.com/plugin.tar.gz` |

### 마켓플레이스 추가

`settings.json`에서 커스텀 마켓플레이스를 설정합니다:

```json
{
  "marketplaces": [
    { "source": "github", "repo": "company/approved-plugins" },
    { "source": "npm", "scope": "@company" }
  ]
}
```

### 마켓플레이스 제거

```json
{
  "marketplaces": []
}
```

빈 배열로 설정하면 기본 마켓플레이스만 사용됩니다.

---

## 엔터프라이즈 관리

### strictKnownMarketplaces

조직에서 승인된 소스만 허용하여 비인가 플러그인 설치를 차단합니다:

```json
{
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "company/approved-plugins" },
    { "source": "npm", "scope": "@company" }
  ]
}
```

이 설정이 활성화되면 목록에 없는 소스에서의 플러그인 설치가 거부됩니다.

### Managed Plugins

관리자가 조직 전체에 플러그인을 강제 배포합니다:

```json
{
  "managedPlugins": [
    {
      "name": "company-standards",
      "source": "github:company/standards-plugin",
      "version": ">=1.0.0",
      "required": true
    }
  ]
}
```

| 필드 | 설명 |
|------|------|
| `required: true` | 사용자가 비활성화할 수 없음 |
| `version` | 허용 버전 범위 |
| `source` | 설치 소스 |

### enabledPlugins

특정 플러그인만 허용하는 화이트리스트 방식:

```json
{
  "enabledPlugins": [
    "company-standards",
    "code-quality",
    "security-scanner"
  ]
}
```

이 목록에 없는 플러그인은 설치되어 있어도 비활성화됩니다.

### 관리자 설정 경로

| 플랫폼 | 경로 |
|--------|------|
| **macOS** | `/Library/Application Support/ClaudeCode/` |
| **Linux** | `/etc/claude-code/` |
| **Windows** | `%ProgramData%\ClaudeCode\` |

관리자 경로의 설정은 사용자 설정보다 우선하며, 사용자가 변경할 수 없습니다.

---

## 기존 개념과의 관계

### standalone vs 플러그인 비교

| 기능 | standalone 사용 | 플러그인에 포함 |
|------|:----------------:|:---------------:|
| **Skills** | `.claude/skills/` 직접 배치 | `plugin/skills/` 디렉토리 |
| **Hooks** | `settings.json`에 직접 정의 | `plugin.json`의 hooks 배열 |
| **Agents** | `.claude/agents/` 직접 배치 | `plugin/agents/` 디렉토리 |
| **MCP 서버** | `settings.json`에 직접 설정 | `plugin.json`의 mcp 섹션 |
| **Rules** | `.claude/rules/` 직접 배치 | `plugin/rules/` 디렉토리 |

### 언제 플러그인을 사용할까?

| 시나리오 | 권장 방식 |
|---------|----------|
| 프로젝트 전용 스킬 1~2개 | standalone |
| 팀 공유가 필요한 워크플로우 | 플러그인 |
| 여러 기능을 조합한 도구 세트 | 플러그인 |
| 조직 전체 표준 적용 | managed 플러그인 |
| 개인 유틸리티 | standalone (`~/.claude/`) |
| 오픈소스 커뮤니티 공유 | 플러그인 (마켓플레이스) |

---

## 실전 예제: 코드 품질 플러그인

리뷰 스킬과 린트 훅을 조합한 **코드 품질 플러그인**을 만들어 봅니다.

### 디렉토리 구조

```
code-quality-plugin/
├── plugin.json
├── skills/
│   └── quality-review/
│       └── SKILL.md
├── hooks/
│   └── post-edit-lint.sh
└── rules/
    └── quality-standards.md
```

### plugin.json

```json
{
  "name": "code-quality",
  "version": "1.0.0",
  "description": "코드 편집 시 자동 린트 + 품질 리뷰 스킬",
  "author": "team",
  "engines": {
    "claude-code": ">=2.0.0"
  },
  "skills": ["skills/quality-review"],
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "Write|Edit",
      "command": "hooks/post-edit-lint.sh",
      "timeout": 30
    }
  ],
  "rules": ["rules/quality-standards.md"],
  "dependencies": {
    "eslint": ">=8.0.0"
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
# 플러그인 설치
claude plugin install github:team/code-quality-plugin

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
| **설치** | `claude plugin install <소스>` |
| **구조** | `plugin.json` + 기능별 디렉토리 |
| **테스트** | `--plugin-dir`로 로컬 테스트 |
| **마켓플레이스** | GitHub, npm, pip, URL 소스 지원 |
| **엔터프라이즈** | `strictKnownMarketplaces`, managed plugins |
| **vs standalone** | 배포와 공유가 필요하면 플러그인, 개인 사용은 standalone |

---

## 다음 챕터

Part VI: 확장과 통합에서 [26장: IDE 통합](../06-integrations/01-ide-integrations.md)을 통해 VS Code, JetBrains 등에서 Claude Code를 사용하는 방법을 배웁니다.
