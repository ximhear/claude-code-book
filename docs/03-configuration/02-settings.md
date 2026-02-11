<!-- last_updated: 2026-02-11 -->

# 10. settings.json 설정 가이드

> 전역/프로젝트/로컬 설정 파일의 구조, 주요 옵션, 환경 변수, 키바인딩을 상세히 다룹니다.

---

## 설정 파일 계층

Claude Code는 4개 범위의 설정 파일을 지원합니다. 높은 우선순위의 설정이 낮은 우선순위를 덮어씁니다.

| 우선순위 | 범위 | 위치 | 공유 |
|:--------:|------|------|:----:|
| 1 (최고) | **관리자 (Managed)** | 시스템 경로 | IT 배포 |
| 2 | **CLI 인자** | `claude --model opus` 등 | — |
| 3 | **로컬 프로젝트** | `.claude/settings.local.json` | 개인 |
| 4 | **프로젝트** | `.claude/settings.json` | 팀 (git) |
| 5 (최저) | **사용자 전역** | `~/.claude/settings.json` | 개인 |

### 관리자 설정 경로

| 플랫폼 | 경로 |
|--------|------|
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

관리자 설정은 **사용자가 덮어쓸 수 없습니다**. 조직 보안 정책을 강제하는 데 사용됩니다.

---

## 설정 파일 구조

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [],
    "deny": []
  },
  "env": {},
  "model": "sonnet",
  "defaultMode": "default",
  "hooks": {},
  "sandbox": { "enabled": true }
}
```

---

## 주요 설정 키 레퍼런스

### 권한 (permissions)

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git add *)",
      "Read(src/**)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Read(.env)"
    ]
  }
}
```

- `allow`: 승인 없이 자동 실행할 도구
- `deny`: 항상 차단할 도구
- 평가 순서: Deny > Ask > Allow

> 권한 문법의 자세한 내용은 [11장: 권한 시스템](03-permissions.md)에서 다룹니다.

### 모델 (model)

```json
{
  "model": "opus"
}
```

기본 모델을 지정합니다. 별칭 (`opus`, `sonnet`, `haiku`, `opusplan`) 또는 전체 모델 ID를 사용할 수 있습니다.

### 기본 모드 (defaultMode)

```json
{
  "defaultMode": "default"
}
```

| 값 | 동작 |
|----|------|
| `default` | 도구 사용 시 승인 요청 |
| `acceptEdits` | 파일 편집 자동 승인 |
| `plan` | 읽기 전용, 변경 불가 |
| `dontAsk` | 사전 승인된 도구만 실행 |
| `delegate` | 에이전트 팀 리더 모드 |
| `bypassPermissions` | 모든 승인 건너뜀 (위험) |

### 환경 변수 (env)

```json
{
  "env": {
    "NODE_ENV": "development",
    "DEBUG": "app:*"
  }
}
```

Claude Code 세션에서 사용할 환경 변수를 정의합니다.

### 출력 스타일 (outputStyle)

```json
{
  "outputStyle": "Concise"
}
```

| 값 | 설명 |
|----|------|
| `Explanatory` | 상세한 설명 포함 (기본) |
| `Concise` | 간결한 응답 |

### 훅 (hooks)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/validate.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

> 훅의 자세한 내용은 [20장: Hooks 자동화](../05-advanced/02-hooks.md)에서 다룹니다.

### 샌드박스 (sandbox)

```json
{
  "sandbox": { "enabled": true }
}
```

Bash 명령어 실행 시 OS 수준 샌드박싱을 활성화합니다.

### 추가 디렉토리 (additionalDirectories)

```json
{
  "additionalDirectories": ["/path/to/shared-lib", "~/other-project"]
}
```

Claude가 접근할 수 있는 추가 디렉토리를 등록합니다.

### 비허용 도구 (disallowedTools)

```json
{
  "disallowedTools": ["Task(Explore)"]
}
```

특정 에이전트나 도구를 비활성화합니다.

### API 키 헬퍼 (apiKeyHelper)

```json
{
  "apiKeyHelper": "/bin/generate_temp_api_key.sh"
}
```

동적으로 API 키를 생성하는 스크립트를 지정합니다.

---

## 설정 병합 규칙

여러 범위의 설정 파일이 있을 때:

- **일반 설정**: 높은 우선순위가 낮은 우선순위를 덮어씀
- **permissions.allow / permissions.deny**: **병합** (replace가 아닌 merge)
- **hooks**: 모든 범위의 훅이 **결합**되어 함께 실행

```
사용자 설정:   allow [npm run *],  deny [rm]
프로젝트 설정: allow [ls],         deny [curl]
결과:          allow [npm run *, ls], deny [rm, curl]
```

설정 변경 시 **타임스탬프 백업**이 자동으로 생성됩니다 (최근 5개 유지).

---

## 환경 변수 레퍼런스

### 인증 관련

| 변수 | 용도 |
|------|------|
| `ANTHROPIC_API_KEY` | Anthropic API 키 |
| `ANTHROPIC_BASE_URL` | 커스텀 API 엔드포인트 |
| `ANTHROPIC_AUTH_TOKEN` | 커스텀 Authorization 헤더 |
| `ANTHROPIC_CUSTOM_HEADERS` | 커스텀 HTTP 헤더 |

### 클라우드 프로바이더

| 변수 | 용도 |
|------|------|
| `CLAUDE_CODE_USE_BEDROCK` | Amazon Bedrock 활성화 |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API 키 |
| `CLAUDE_CODE_USE_VERTEX` | Google Vertex AI 활성화 |
| `ANTHROPIC_VERTEX_PROJECT_ID` | Vertex 프로젝트 ID |
| `CLAUDE_CODE_USE_FOUNDRY` | Microsoft Foundry 활성화 |
| `ANTHROPIC_FOUNDRY_API_KEY` | Foundry API 키 |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Foundry 리소스명 |

### 모델 및 추론

| 변수 | 용도 | 기본값 |
|------|------|--------|
| `ANTHROPIC_MODEL` | 기본 모델 지정 | — |
| `MAX_THINKING_TOKENS` | 사고 토큰 예산 | 31,999 |
| `CLAUDE_CODE_EFFORT_LEVEL` | 노력 수준 | high |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 출력 토큰 한도 | 32,000 |

### 동작 제어

| 변수 | 용도 | 기본값 |
|------|------|--------|
| `DISABLE_AUTOUPDATER` | 자동 업데이트 비활성화 | — |
| `DISABLE_PROMPT_CACHING` | 프롬프트 캐싱 전역 비활성화 | — |
| `DISABLE_PROMPT_CACHING_OPUS` | Opus 캐싱 비활성화 | — |
| `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION` | 프롬프트 제안 | true |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | 텔레메트리 활성화 | 1 |
| `CLAUDE_CODE_SHELL` | 셸 오버라이드 | 자동 감지 |
| `CLAUDE_CODE_TASK_LIST_ID` | 공유 태스크 리스트 ID | — |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | 스킬 컨텍스트 예산 | 자동 (2%) |

### 훅 관련

| 변수 | 용도 |
|------|------|
| `CLAUDE_ENV_FILE` | SessionStart 훅에서 환경 파일 경로 |
| `CLAUDE_PROJECT_DIR` | 훅에서 프로젝트 루트 |
| `CLAUDE_PLUGIN_ROOT` | 훅에서 플러그인 디렉토리 |

### 보안

| 변수 | 용도 |
|------|------|
| `CLAUDE_CODE_CLIENT_CERT` | mTLS 클라이언트 인증서 |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS 클라이언트 키 |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | mTLS 키 패스프레이즈 |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | API 키 헬퍼 갱신 간격 |

---

## 키바인딩 설정

### 파일 위치

```
~/.claude/keybindings.json
```

### 기본 구조

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+enter": "chat:submit",
        "ctrl+e": "chat:externalEditor",
        "ctrl+s": "chat:stash"
      }
    },
    {
      "context": "Global",
      "bindings": {
        "ctrl+j": "app:toggleTodos"
      }
    }
  ]
}
```

### 키 문법

**수정자 키**:
- `ctrl` 또는 `control`
- `alt`, `opt`, 또는 `option`
- `shift`
- `meta`, `cmd`, 또는 `command`

**특수 키**: `escape`, `enter`, `tab`, `space`, `up`, `down`, `left`, `right`, `backspace`, `delete`

**코드 (chord)**: `ctrl+k ctrl+s` — 연속 입력

### 바인딩 해제

`null`로 설정하면 기존 바인딩을 해제합니다:

```json
{
  "context": "Chat",
  "bindings": {
    "ctrl+u": null
  }
}
```

### 변경 불가 키

- `Ctrl+C` — 인터럽트/취소 (하드코딩)
- `Ctrl+D` — 종료 (하드코딩)

### 주요 컨텍스트와 액션

| 컨텍스트 | 주요 액션 | 기본 키 |
|----------|-----------|---------|
| **Global** | `app:interrupt` | Ctrl+C |
| | `app:exit` | Ctrl+D |
| | `app:toggleTodos` | Ctrl+T |
| | `app:toggleTranscript` | Ctrl+O |
| **Chat** | `chat:submit` | Enter |
| | `chat:cancel` | Escape |
| | `chat:cycleMode` | Shift+Tab |
| | `chat:modelPicker` | Meta+P |
| | `chat:thinkingToggle` | Meta+T |
| | `chat:externalEditor` | Ctrl+G |
| | `chat:imagePaste` | Ctrl+V |
| **Autocomplete** | `autocomplete:accept` | Tab |
| | `autocomplete:dismiss` | Escape |
| **Confirmation** | `confirm:yes` | Y, Enter |
| | `confirm:no` | N, Escape |
| **ModelPicker** | `modelPicker:decreaseEffort` | Left |
| | `modelPicker:increaseEffort` | Right |
| **HistorySearch** | `historySearch:next` | Ctrl+R |
| | `historySearch:accept` | Escape, Tab |
| **Task** | `task:background` | Ctrl+B |

전체 액션 목록은 `/keybindings` 명령어로 확인할 수 있습니다.

---

## 관리자 설정 (엔터프라이즈)

조직 전체에 보안 정책을 강제하는 설정입니다.

### 관리자 전용 키

| 키 | 용도 |
|----|------|
| `disableBypassPermissionsMode` | `bypassPermissions` 모드 차단 |
| `allowManagedPermissionRulesOnly` | 관리자 권한 규칙만 적용 |
| `allowManagedHooksOnly` | 관리자 훅만 실행 |
| `disableAllHooks` | 모든 훅 비활성화 |
| `strictKnownMarketplaces` | 허용된 플러그인 소스만 |

### 예시: 엔터프라이즈 잠금 설정

```json
{
  "allowManagedPermissionRulesOnly": true,
  "allowManagedHooksOnly": true,
  "disableBypassPermissionsMode": "disable",
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Bash(npm test)",
      "Read(src/**)"
    ],
    "deny": [
      "Bash(curl *)",
      "Bash(wget *)",
      "Read(.env)",
      "Read(secrets/**)",
      "WebFetch"
    ]
  },
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "company/approved-plugins" }
  ]
}
```

### 서버 관리형 설정 (Server-Managed Settings)

Anthropic 서버에서 직접 설정을 전달하는 방식입니다 (공개 베타):

- MDM 인프라 없이 설정 배포 가능
- 시작 시 서버에서 가져오고, 1시간마다 폴링
- 오프라인 시 캐시된 설정 사용
- 민감한 설정 (셸 명령어, 환경 변수, 훅)은 사용자 승인 필요

---

## 자주 쓰는 설정 조합

### 팀 프로젝트 (.claude/settings.json)

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git add *)",
      "Bash(git commit *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(rm -rf *)"
    ]
  }
}
```

### 개인 전역 (~/.claude/settings.json)

```json
{
  "model": "opus",
  "permissions": {
    "allow": [
      "Bash(docker compose *)"
    ]
  }
}
```

### 개인 프로젝트 오버라이드 (.claude/settings.local.json)

```json
{
  "env": {
    "DATABASE_URL": "postgresql://localhost:5432/my_test_db"
  }
}
```

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **파일 계층** | Managed > CLI > Local > Project > User |
| **병합 규칙** | 일반 키는 덮어쓰기, permissions/hooks는 병합 |
| **주요 키** | `permissions`, `model`, `defaultMode`, `env`, `hooks` |
| **환경 변수** | 인증, 모델, 캐싱, 동작 제어 등 30개 이상 |
| **키바인딩** | `~/.claude/keybindings.json`, 20개 컨텍스트, 60개 이상 액션 |
| **관리자** | `allowManagedPermissionRulesOnly` 등으로 조직 정책 강제 |

---

## 다음 챕터

[11장: 권한(Permissions) 시스템](03-permissions.md)에서 도구 실행 권한을 세밀하게 제어하는 방법을 배웁니다.
