<!-- last_updated: 2026-07-07 -->

# 10. settings.json 설정 가이드

> 전역/프로젝트/로컬 설정 파일의 구조, 주요 옵션, 환경 변수, 키바인딩을 상세히 다룹니다.

---

## 설정 파일 계층

Claude Code는 5개 범위의 설정을 지원합니다. 더 구체적인 범위의 설정이 넓은 범위를 덮어씁니다.

| 우선순위 | 범위 | 위치 | 공유 |
|:--------:|------|------|:----:|
| 1 (최고) | **관리자 (Managed)** | 시스템 경로 | IT 배포 |
| 2 | **CLI 인자** | `claude --model opus` 등 | — |
| 3 | **로컬 프로젝트** | `.claude/settings.local.json` | 개인 |
| 4 | **프로젝트** | `.claude/settings.json` | 팀 (git) |
| 5 (최저) | **사용자 전역** | `~/.claude/settings.json` | 개인 |

> **참고**: settings.json의 우선순위는 CLAUDE.md와 방향이 다릅니다. CLAUDE.md는 "하위 디렉토리(좁은 범위)가 우선"이지만, settings.json은 **관리자 설정이 최고 우선순위**이며 사용자가 덮어쓸 수 없습니다. 단, 관리자를 제외한 나머지 범위에서는 동일하게 "더 구체적인 범위가 우선"하는 원칙이 적용됩니다.

### 관리자 설정 경로

| 플랫폼 | 경로 |
|--------|------|
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

관리자 설정은 **사용자가 덮어쓸 수 없습니다**. 조직 보안 정책을 강제하는 데 사용됩니다.

**드롭인 디렉토리**: `managed-settings.d/` 디렉토리에 별도의 정책 파편 파일을 배치할 수 있습니다. 여러 팀이 독립적으로 정책을 배포할 때 유용하며, 파일은 알파벳순으로 병합됩니다.

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
- `ask`: 매번 사용자에게 승인을 요청할 도구
- `deny`: 항상 차단할 도구
- 평가 순서 (첫 번째 매칭이 적용): **Deny > Ask > Allow**

> **파라미터 단위 매칭 `Tool(param:value)` (2.1.178)**: 도구 파라미터 값으로 권한 규칙을 매칭할 수 있습니다. `*` 와일드카드를 지원하며, 예를 들어 `Agent(model:opus)`는 특정 모델을 사용하는 Agent 호출에만 적용됩니다. deny 규칙의 도구명 위치에 glob 패턴을 쓰는 문법은 2.1.166에서 추가되었습니다.

> 권한 문법의 자세한 내용은 [11장: 권한 시스템](03-permissions.md)에서 다룹니다.

### 모델 (model)

```json
{
  "model": "opus"
}
```

기본 모델을 지정합니다. 별칭 (`sonnet`, `opus`, `fable`, `haiku`, `opusplan`) 또는 전체 모델 ID를 사용할 수 있습니다. Claude Code의 기본 모델은 2.1.197부터 **Sonnet 5**(`claude-sonnet-5`)입니다.

> **조직 기본 모델 (2.1.196)**: 조직이 기본 모델을 지정하는 기능이 추가되었습니다. 이는 **settings.json 키가 아니라 조직 콘솔에서 지정**하며, `/model` 선택기에 **"Org default"**(또는 역할 기준 "Role default")로 표시됩니다. 조직이 모델을 제한한 경우 `/model`·`--model`·`ANTHROPIC_MODEL`에 "restricted by your organization's settings"가 표기되며(2.1.187), `availableModels`/`enforceAvailableModels`로 강제할 수 있습니다.

### 폴백 모델 (fallbackModel)

```json
{
  "fallbackModel": ["opus", "sonnet", "haiku"]
}
```

기본 모델을 사용할 수 없을 때 전환할 폴백 모델을 **최대 3개**까지 체인으로 지정합니다 (2.1.166). CLI의 `--fallback-model` 플래그(단일 모델)와는 **별개**이며, 설정 키는 여러 모델을 순서대로 시도합니다.

### 기본 모드 (defaultMode)

```json
{
  "defaultMode": "default"
}
```

| 값 | 동작 |
|----|------|
| `manual` | 도구 사용 시 승인 요청 (**기본**, 2.1.200에서 'default' → 'Manual'로 명칭 변경) |
| `default` | `manual`과 동일 (이전 명칭, 계속 수용) |
| `acceptEdits` | 파일 편집 자동 승인 |
| `plan` | 읽기 전용, 변경 불가 |
| `dontAsk` | 사전 승인된 도구만 실행 |
| `delegate` | 에이전트 팀 리더 모드 |
| `bypassPermissions` | 모든 승인 건너뜀 (위험) |

> **기본 권한 모드 명칭 변경 (2.1.200)**: 기본 권한 모드가 'default'에서 **'Manual'**로 이름이 바뀌었습니다. `--permission-mode manual`과 `"defaultMode": "manual"`을 모두 수용하며, 기존 `default` 값도 계속 동작합니다. 함께 `AskUserQuestion` 다이얼로그의 기본 auto-continue 동작이 제거되었습니다.

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

macOS에서 MITM 프록시(기업 프록시 등)로 인해 TLS 인증서 검증 오류가 발생하면:

```json
{
  "sandbox": {
    "enabled": true,
    "enableWeakerNetworkIsolation": true
  }
}
```

`enableWeakerNetworkIsolation`은 Go 프로그램(gh, gcloud, terraform 등)이 커스텀 CA 인증서를 사용할 수 있게 합니다.

`denyRead`로 읽기를 차단한 영역 내에서 `allowRead`로 특정 경로를 다시 허용할 수 있습니다. 자세한 내용은 아래 "샌드박스 읽기 허용" 섹션을 참조하세요.

`sandbox.failIfUnavailable`을 `true`로 설정하면 샌드박스를 시작할 수 없을 때 샌드박스 없이 실행하는 대신 에러로 종료합니다.

### Git 지침 제어 (includeGitInstructions)

```json
{
  "includeGitInstructions": false
}
```

Claude Code의 내장 Git 커밋/PR 워크플로우 지침을 제거합니다. CLAUDE.md에서 자체 Git 워크플로우를 정의할 때 내장 지침과의 충돌을 방지합니다.

환경 변수로도 설정할 수 있습니다: `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS=1`

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

### 모델 오버라이드 (modelOverrides)

```json
{
  "modelOverrides": {
    "opus": "us.anthropic.claude-opus-4-6-v1:0",
    "sonnet": "us.anthropic.claude-sonnet-4-6-v1:0"
  }
}
```

모델 선택기의 별칭을 커스텀 프로바이더 ID에 매핑합니다. Bedrock ARN이나 Vertex AI 모델 ID 등 클라우드 프로바이더 고유 식별자를 사용할 때 유용합니다.

### 자동 메모리 디렉토리 (autoMemoryDirectory)

```json
{
  "autoMemoryDirectory": "/path/to/custom/memory"
}
```

자동 메모리 파일이 저장되는 디렉토리를 변경합니다. 기본값은 `~/.claude/projects/<hash>/memory/`입니다.

### 샌드박스 읽기 허용 (allowRead)

`denyRead`로 차단된 영역 내에서 특정 경로의 읽기를 다시 허용합니다:

```json
{
  "sandbox": {
    "enabled": true,
    "denyRead": ["/etc"],
    "allowRead": ["/etc/hosts"]
  }
}
```

### Worktree 스파스 경로 (worktree.sparsePaths)

```json
{
  "worktree": {
    "sparsePaths": ["packages/core", "packages/shared", "apps/web"]
  }
}
```

대규모 모노레포에서 worktree 생성 시 지정된 경로만 체크아웃하여 성능을 개선합니다. Git sparse-checkout을 내부적으로 사용합니다.

### Worktree 베이스 레퍼런스 (worktree.baseRef)

```json
{
  "worktree": {
    "baseRef": "fresh"
  }
}
```

`--worktree`, `EnterWorktree`, 에이전트 격리 worktree가 어디서 분기할지 결정합니다 (2.1.133):

| 값 | 동작 |
|----|------|
| `fresh` | `origin/<기본 브랜치>`에서 분기 (깨끗한 시작) |
| `head` | 로컬 `HEAD`에서 분기 (현재 작업 상태 유지) |

### Worktree 백그라운드 격리 (worktree.bgIsolation)

```json
{
  "worktree": {
    "bgIsolation": "none"
  }
}
```

`"none"`으로 설정하면 백그라운드 세션이 `EnterWorktree` 없이 작업 복사본을 직접 편집합니다 (2.1.143). 별도 worktree 격리 없이 현재 디렉토리에서 바로 작업하게 됩니다.

### TUI 설정 (tui, autoScrollEnabled)

```json
{
  "tui": true,
  "autoScrollEnabled": true
}
```

`tui`를 `true`로 설정하면 시작 시 풀스크린 모드로 진입합니다. `autoScrollEnabled`는 풀스크린 자동 스크롤 동작을 제어합니다 (스크롤한 채 입력해도 화면이 점프하지 않도록).

### PR URL 템플릿 (prUrlTemplate)

```json
{
  "prUrlTemplate": "https://gitlab.company.com/{owner}/{repo}/-/merge_requests/{number}"
}
```

코드 리뷰 링크를 GitHub 외 호스트(GitLab, Bitbucket, GitHub Enterprise)로 생성하도록 템플릿을 지정합니다. `{owner}`, `{repo}`, `{number}` 플레이스홀더를 지원합니다.

### 스킬 호출 모드 오버라이드 (skillOverrides)

```json
{
  "skillOverrides": {
    "deploy-to-prod": "off",
    "format-code": "user-invocable-only",
    "scan-secrets": "name-only"
  }
}
```

| 값 | 동작 |
|----|------|
| `off` | 스킬을 완전히 비활성화 |
| `user-invocable-only` | `/skill-name`로 명시 호출만 허용, Claude 자동 호출 차단 |
| `name-only` | 이름만 컨텍스트에 노출 (본문은 호출 시점에 로드) |

스킬 매니페스트를 변경하지 않고 사용자/관리자 설정으로 호출 정책을 조정합니다.

### 샌드박스 거부 도메인 (sandbox.network.deniedDomains)

```json
{
  "sandbox": {
    "enabled": true,
    "network": {
      "deniedDomains": ["*.internal.company.com", "metadata.google.internal"]
    }
  }
}
```

샌드박스 내에서 특정 도메인으로의 네트워크 접근을 차단합니다. 사내 메타데이터 엔드포인트, 비밀 게이트웨이 등을 보호하는 데 사용합니다.

### 샌드박스 바이너리 경로 (sandbox.bwrapPath, sandbox.socatPath)

```json
{
  "sandbox": {
    "enabled": true,
    "bwrapPath": "/opt/tools/bwrap",
    "socatPath": "/opt/tools/socat"
  }
}
```

Linux/WSL에서 bubblewrap(`bwrap`)과 `socat` 바이너리가 표준 경로에 없을 때 위치를 직접 지정합니다 (2.1.133, 관리자 설정). 사내 이미지나 비표준 설치 환경에서 샌드박스를 활성화할 때 사용합니다.

### MCP 서버 alwaysLoad

```json
{
  "mcpServers": {
    "primary-tools": {
      "command": "primary-tools-server",
      "alwaysLoad": true
    }
  }
}
```

`alwaysLoad: true`로 설정한 MCP 서버는 Tool Search의 동적 지연 로딩을 건너뛰고 시작 시점부터 도구를 항상 노출합니다.

### Status Line 갱신 주기 (refreshInterval)

```json
{
  "statusLine": {
    "command": "~/.claude/statusline.sh",
    "refreshInterval": 5
  }
}
```

상태 표시줄 명령어의 갱신 주기를 초 단위로 지정합니다 (기본: 0 = 변경 시 재실행).

> **`COLUMNS`/`LINES` 환경 변수 (2.1.153)**: 상태 표시줄 명령어 실행 시 터미널의 열·행 크기가 `COLUMNS`와 `LINES` 환경 변수로 전달됩니다. 스크립트가 출력 폭을 터미널 너비에 맞춰 조절할 수 있습니다.

### 번들 스킬 비활성화 (disableBundledSkills)

```json
{
  "disableBundledSkills": true
}
```

내장 번들 스킬·워크플로우·내장 슬래시 커맨드를 숨깁니다 (2.1.169). 환경 변수 `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS`로도 설정할 수 있습니다.

### 샌드박스 자격증명 차단 (sandbox.credentials)

```json
{
  "sandbox": {
    "enabled": true,
    "credentials": "block"
  }
}
```

샌드박스에서 실행되는 명령에 자격증명 노출을 차단합니다 (2.1.187).

### 푸터 링크 정규식 (footerLinksRegexes)

```json
{
  "footerLinksRegexes": ["JIRA-\\d+", "#\\d+"]
}
```

정규식에 매칭되는 텍스트를 푸터에 링크 배지로 표시합니다 (2.1.176).

### 셸 명령 자동 분류 (autoMode.classifyAllShell)

```json
{
  "autoMode": {
    "classifyAllShell": true
  }
}
```

모든 셸 명령을 Auto Mode 분류기로 평가하도록 강제합니다 (2.1.193).

### 스크롤·터미널 관련 설정 (도입 버전 병기, 신중 반영)

다음 설정 키는 도입 CLI 버전의 CHANGELOG에서 확인되었습니다. 환경과 버전에 따라 동작이 달라질 수 있으므로 도입 버전을 병기합니다.

```json
{
  "wheelScrollAccelerationEnabled": false,
  "sandbox": { "allowAppleEvents": true },
  "teammateMode": "iterm2"
}
```

| 키 | 도입 | 동작 |
|----|------|------|
| `wheelScrollAccelerationEnabled` | 2.1.174 | 마우스 휠 스크롤 가속을 켜고 끕니다 |
| `sandbox.allowAppleEvents` | 2.1.181 | macOS 샌드박스에서 Apple Events를 옵트인합니다 |
| `teammateMode` (`"iterm2"`) | 2.1.186 | iTerm2 팀메이트 모드. `it2` CLI가 없으면 경고를 표시합니다 |

> **`/config` "Dynamic workflow size" (2.1.202)**: 다이나믹 워크플로우의 크기 권고치(small/medium/large)를 `/config` 화면에서 조정할 수 있습니다.

---

## 설정 병합 규칙

여러 범위의 설정 파일이 있을 때, 설정 키 유형에 따라 병합 방식이 다릅니다:

| 설정 유형 | 병합 방식 | 설명 |
|-----------|-----------|------|
| **일반 설정** (`model`, `defaultMode` 등) | 덮어쓰기 | 높은 우선순위가 완전히 대체 |
| **permissions** (`allow`, `ask`, `deny`) | 병합 (merge) | 모든 범위의 규칙이 합산됨 |
| **hooks** | 결합 (collect) | 모든 범위의 훅이 함께 실행 |
| **env** | 키별 병합 | 동일 키는 높은 우선순위가 덮어씀 |

```
사용자 설정:   allow [npm run *],  deny [rm]
프로젝트 설정: allow [ls],         deny [curl]
결과:          allow [npm run *, ls], deny [rm, curl]
```

> **주의**: permissions가 병합되므로, 프로젝트에서 `deny`한 도구는 사용자 설정의 `allow`로 우회할 수 없습니다. `deny`는 항상 `allow`보다 우선합니다.

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
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Bedrock 서비스 티어 (`default`, `flex`, `priority`) |
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
| `CLAUDE_EFFORT` | 활성 노력 수준 (훅·Bash 서브프로세스에 노출, 읽기 전용) | — |
| `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` | ⚠️ **제거됨** (2.1.154 폐지 → **2.1.160 제거, no-op**). Fast 모드는 Opus 4.8 기본. 대신 `/model claude-opus-4-6` + `/fast on` 사용 | — |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 출력 토큰 한도 | 32,000 |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | 서드파티 프로바이더(Bedrock/Vertex/Foundry)에서 Opus 4.7/4.8 Auto Mode 옵트인 (2.1.158) | — |
| `CLAUDE_CODE_MAX_RETRIES` | 자동 재시도 횟수 (상한 15로 캡, 2.1.186) | — |
| `CLAUDE_CODE_RETRY_WATCHDOG` | 무인 세션용 재시도 워치독. 2.1.186 등장, 2.1.199부터 기본 재시도 300·`MAX_RETRIES` 상한 15 해제 | — |

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
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | 내장 Git 지침 비활성화 | — |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | claude.ai MCP 서버 사용 (`false`로 비활성화) | true |
| `CLAUDE_CODE_DISABLE_CRON` | `/loop`의 Cron 스케줄링 비활성화 | — |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | 서브프로세스에서 Anthropic/클라우드 자격 증명 제거 | — |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | 스트리밍 유휴 감시 타임아웃 (밀리초) | 90000 |
| `ENABLE_PROMPT_CACHING_1H` | 1시간 프롬프트 캐시 TTL 활성화 (API/Bedrock/Vertex/Foundry) | — |
| `FORCE_PROMPT_CACHING_5M` | 5분 TTL 강제 적용 | — |
| `CLAUDE_CODE_USE_MANTLE` | Amazon Bedrock Mantle 활성화 | — |
| `CLAUDE_CODE_PERFORCE_MODE` | 읽기 전용 파일에 `p4 edit` 힌트 표시 | — |
| `CLAUDE_CODE_NO_FLICKER` | 플리커 없는 alt-screen 렌더링 | — |
| `MCP_CONNECTION_NONBLOCKING` | `-p` 모드에서 MCP 연결 대기 건너뜀 (5초 상한) | — |
| `CLAUDE_CODE_SCRIPT_CAPS` | 세션당 스크립트 호출 횟수 제한 | — |
| `CLAUDE_CODE_HIDE_CWD` | 시작 로고에서 현재 작업 디렉토리 숨김 | — |
| `DISABLE_UPDATES` | 모든 업데이트 경로 차단 (`DISABLE_AUTOUPDATER`보다 강함) | — |
| `AI_AGENT` | 서브프로세스에 에이전트 출처 표시용 식별자 | — |
| `CLAUDE_CODE_FORK_SUBAGENT` | 외부 빌드/SDK에서 서브에이전트 fork 활성화 | — |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Windows에서 PowerShell 도구를 단계적 활성화 | — |
| `CLAUDE_CODE_CERT_STORE` | TLS 인증서 저장소 (`os`(기본), `bundled`) | os |
| `CLAUDE_CODE_FORCE_SYNC_OUTPUT` | 동기화된 터미널 출력 강제 | — |
| `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` | Homebrew/WinGet 백그라운드 자동 업그레이드 | — |
| `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` | 게이트웨이 `/v1/models` 자동 디스커버리 옵트인 | — |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | 풀스크린(alt-screen) 렌더러 옵트아웃 | — |
| `CLAUDE_CODE_SESSION_ID` | Bash 도구 서브프로세스에 노출되는 현재 세션 ID | 자동 |
| `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` | 실험적 베타 기능 전부 비활성화 | — |
| `CLAUDE_CODE_FORK_SUBAGENT` | SDK 비대화 모드에서 서브에이전트 fork | — |
| `OTEL_LOG_RAW_API_BODIES` | OpenTelemetry로 원본 API 본문 기록 (디버그용) | — |
| `OTEL_LOG_TOOL_DETAILS` | `tool_decision` 텔레메트리에 `tool_parameters`(bash 명령, MCP/스킬 이름) 포함 (2.1.157) | — |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | OpenTelemetry 메트릭에 세션 진입점(`app.entrypoint`) 속성 추가 (2.1.152) | — |
| `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` | GitHub 플러그인 소스를 SSH 대신 HTTPS로 클론 | — |
| `CLAUDE_CODE_POWERSHELL_RESPECT_EXECUTION_POLICY` | PowerShell 도구 `-ExecutionPolicy Bypass` 옵트아웃 | — |
| `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` | Stop 훅 연속 차단 한도 재정의 | 8 |
| `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` | 엔터프라이즈 세션 품질 설문 재활성화 | — |
| `CLAUDE_CLIENT_PRESENCE_FILE` | 클라이언트 presence 마커 파일 지정 (모바일 푸시 억제용) (2.1.181) | — |
| `CLAUDE_CODE_DISABLE_MOUSE_CLICKS` | 마우스 클릭 비활성화 (휠 스크롤은 유지) (2.1.195) | — |
| `CLAUDE_CODE_SAFE_MODE` | 모든 커스터마이즈를 비활성화한 안전 모드로 시작 (`--safe-mode` 플래그와 동일) (2.1.169) | — |
| `OTEL_LOG_ASSISTANT_RESPONSES` | `claude_code.assistant_response` 로그 이벤트 게이팅 (2.1.193) | — |

> **OpenTelemetry 속성·이벤트 추가**: `OTEL_RESOURCE_ATTRIBUTES` 라벨화(2.1.161), `lines_of_code.count` 메트릭에 `model` 속성 추가(2.1.172), `claude_code.assistant_response` 로그 이벤트(2.1.193, `OTEL_LOG_ASSISTANT_RESPONSES`로 게이팅), 워크플로우 관련 `workflow.run_id`·`workflow.name` 속성(2.1.202)이 도입되었습니다.

### 인증·페더레이션

| 변수 | 용도 |
|------|------|
| `ANTHROPIC_WORKSPACE_ID` | 워크로드 ID 페더레이션용 워크스페이스 식별자 |

### 훅 관련

| 변수 | 용도 |
|------|------|
| `CLAUDE_ENV_FILE` | SessionStart 훅에서 환경 파일 경로 |
| `CLAUDE_PROJECT_DIR` | 훅에서 프로젝트 루트 |
| `CLAUDE_PLUGIN_ROOT` | 훅에서 플러그인 디렉토리 |
| `CLAUDE_SKILL_DIR` | SKILL.md에서 자기 디렉토리 참조 (`${CLAUDE_SKILL_DIR}`) |

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
| **Voice** | `voice:pushToTalk` | Space |
| **Chat** | `chat:killAgents` | Ctrl+X Ctrl+K |
| | `chat:fastMode` | — |
| | `chat:externalEditor` | Ctrl+G 또는 Ctrl+X Ctrl+E |

전체 액션 목록은 `/keybindings` 명령어로 확인할 수 있습니다.

> **Voice Mode 키 변경**: push-to-talk 키를 스페이스바 이외의 키로 변경하려면 `voice:pushToTalk`을 재설정합니다.

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
| `strictKnownMarketplaces` | 허용된 플러그인 마켓플레이스 소스만 |
| `extraKnownMarketplaces` | 사전 등록 마켓플레이스 (맵 형식) |
| `enabledPlugins` | 허용 플러그인 (`name@marketplace` 맵) |
| `allowedChannelPlugins` | 허용된 채널 플러그인 목록 |
| `disableDeepLinkRegistration` | `claude-cli://` 프로토콜 핸들러 등록 방지 |
| `forceRemoteSettingsRefresh` | 시작 시 원격 설정 강제 갱신 (실패 시 종료) |
| `disableSkillShellExecution` | 스킬/커맨드의 인라인 셸 실행 비활성화 |
| `allowManagedDomainsOnly` | 관리자 화이트리스트 도메인만 네트워크 허용 |
| `allowManagedReadPathsOnly` | 관리자 화이트리스트 경로만 읽기 허용 |
| `blockedMarketplaces` | 금지된 마켓플레이스 (호스트/경로 패턴 지원) |
| `wslInheritsWindowsSettings` | WSL이 Windows 호스트의 관리자 설정을 상속 |
| `parentSettingsBehavior` | SDK `managedSettings` 병합 정책 (`first-wins` \| `merge`) |
| `autoMode.hard_deny` | Auto Mode 분류기에서 무조건 차단할 규칙 |
| `pluginSuggestionMarketplaces` | 플러그인 추천에 사용할 조직 마켓플레이스 허용 목록 (2.1.152) |
| `allowAllClaudeAiMcps` | `managed-mcp.json`과 함께 claude.ai 클라우드 MCP 커넥터를 모두 로드 (2.1.149) |
| `enforceAvailableModels` | `availableModels` 목록을 강제 적용 (2.1.175) |
| `requiredMinimumVersion` | 조직이 허용하는 최소 CLI 버전 강제 (2.1.163) |
| `requiredMaximumVersion` | 조직이 허용하는 최대 CLI 버전 강제 (2.1.163) |

> `autoMode.hard_deny`는 Auto Mode(`/model auto`)의 분류기가 조건에 관계없이 항상 거부할 작업을 정의합니다 (2.1.136). `parentSettingsBehavior`는 SDK로 상위 관리 설정을 병합할 때 첫 정책을 유지(`first-wins`)할지 합칠지(`merge`) 결정합니다 (2.1.133).

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
    { "source": "github", "repo": "company/approved-plugins" },
    { "source": "hostPattern", "hostPattern": "^github\\.company\\.com$" }
  ],
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "company/approved-plugins" }
    }
  }
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
| **파일 계층** | Managed > CLI > Local > Project > User (구체적 범위 우선) |
| **병합 규칙** | 일반 키는 덮어쓰기, permissions/hooks는 병합, env는 키별 병합 |
| **주요 키** | `permissions`, `model`, `defaultMode`(기본 `manual`, 2.1.200), `fallbackModel`, `env`, `hooks` |
| **환경 변수** | 인증, 모델, 캐싱, 동작 제어 등 30개 이상 (`CLAUDE_CODE_ENABLE_AUTO_MODE`, `CLAUDE_CODE_RETRY_WATCHDOG` 등) |
| **키바인딩** | `~/.claude/keybindings.json`, 20개 컨텍스트, 60개 이상 액션 |
| **관리자** | `allowManagedPermissionRulesOnly`, `enforceAvailableModels`, `requiredMinimumVersion` 등으로 조직 정책 강제 |

---

## 다음 챕터

[11장: 권한(Permissions) 시스템](03-permissions.md)에서 도구 실행 권한을 세밀하게 제어하는 방법을 배웁니다.
