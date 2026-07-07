<!-- last_updated: 2026-07-07 -->

# 20. Hooks — 이벤트 기반 자동화

> Hook 시스템으로 Claude Code의 동작을 커스터마이즈합니다.

---

## Hooks란?

Hooks는 Claude Code의 특정 **이벤트에 반응하여 셸 명령어를 자동 실행**하는 시스템입니다. 도구 실행 전후, 세션 시작, 응답 완료 등의 시점에 커스텀 로직을 삽입할 수 있습니다.

```
도구 실행 요청 → PreToolUse 훅 → 도구 실행 → PostToolUse 훅
```

---

## 이벤트 유형

| 이벤트 | 발생 시점 | 용도 |
|--------|----------|------|
| **PreToolUse** | 도구 실행 전 | 검증, 차단, 수정 |
| **PostToolUse** | 도구 실행 성공 후 | 포매팅, 검증, 알림 |
| **PostToolUseFailure** | 도구 실행 실패 후 | 에러 처리, 로깅 |
| **PermissionRequest** | 권한 대화상자 표시 시 | 자동 승인/거부 |
| **Notification** | Claude가 알림 발송 시 | 데스크톱 알림, 로깅 |
| **SessionStart** | 세션 시작/재개 시 | 환경 설정, 컨텍스트 주입 |
| **SessionEnd** | 세션 종료 시 | 정리, 로깅 |
| **UserPromptSubmit** | 사용자 프롬프트 제출 시 | 입력 검증, 변환 |
| **Stop** | Claude 응답 완료 시 | 후처리, 알림 |
| **StopFailure** | API 오류로 턴 종료 시 | 에러 알림, 재시도 로직 |
| **SubagentStart** | 서브에이전트 생성 시 | 추적, 설정 |
| **SubagentStop** | 서브에이전트 완료 시 | 결과 처리 |
| **TeammateIdle** | 팀 에이전트가 유휴 전환 시 | 종료 코드 2로 유휴 방지 가능 |
| **TaskCompleted** | 태스크 완료 표시 시 | 종료 코드 2로 완료 차단 가능 |
| **ConfigChange** | 설정 파일 변경 시 | 감사, 보안 정책 적용 |
| **CwdChanged** | 작업 디렉토리 변경 시 | 환경 재설정 (direnv 등) |
| **FileChanged** | 파일 변경 시 | 환경 반응형 관리 |
| **TaskCreated** | `TaskCreate`로 태스크 생성 시 | 태스크 추적, 알림 |
| **WorktreeCreate** | Worktree 생성 시 | 비-Git VCS 지원 (stdout으로 경로 반환) |
| **WorktreeRemove** | Worktree 제거 시 | VCS 정리 |
| **PreCompact** | 컨텍스트 압축 전 | 압축 전 처리, 종료 코드 2 또는 `{"decision":"block"}`으로 차단 가능 |
| **PostCompact** | 컨텍스트 압축 완료 후 | 압축 후 로깅, 후처리 |
| **Elicitation** | MCP 서버가 추가 정보 요청 시 | 엘리시테이션 제어, 자동 응답 |
| **ElicitationResult** | 엘리시테이션 결과 반환 시 | 결과 감사, 후처리 |
| **PermissionDenied** | 자동 모드에서 권한 거부 시 | `{retry: true}` 반환으로 재시도 |
| **InstructionsLoaded** | CLAUDE.md / rules 파일 로드 시 | 지침 감사, 동적 규칙 주입 |
| **MessageDisplay** | 어시스턴트 메시지 표시 직전 | 표시되는 메시지 텍스트 변형/숨김 (2.1.152) |

> **셀프호스트 러너 `post-session` 훅 (2.1.169)**: 셀프호스트 러너(self-hosted runner)용 라이프사이클 훅으로, 세션이 끝난 뒤 러너 정리 작업을 실행합니다. 함께 SIGTERM→SIGKILL 종료 윈도우 설정도 추가되어 정리 시간을 확보할 수 있습니다.

---

## 설정 구조

### settings.json에서 설정

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "matcher": "Write|Edit",
      "type": "command",
      "command": ".claude/hooks/lint.sh",
      "timeout": 30
    }
  ]
}
```

### 설정 필드

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `event` | O | 이벤트 유형 |
| `type` | O | `"command"` (셸 명령어), `"http"` (HTTP POST) 또는 `"mcp_tool"` (MCP 도구 직접 호출) |
| `command` | △ | `type: "command"`일 때 실행할 명령어 또는 스크립트 경로 |
| `args` | | `type: "command"`의 **exec 형식**. `string[]`로 주면 셸을 거치지 않고 명령을 직접 실행 (인용/이스케이프 문제 회피) |
| `url` | △ | `type: "http"`일 때 POST 요청 대상 URL |
| `tool` | △ | `type: "mcp_tool"`일 때 호출할 MCP 도구 이름 (예: `mcp__github__create_issue`) |
| `headers` | | HTTP 훅 전용. 추가 헤더 (`$VAR_NAME` 환경변수 보간 지원) |
| `allowedEnvVars` | | HTTP 훅 전용. 헤더에서 보간 허용할 환경변수 목록 |
| `matcher` | | 도구 이름 필터 (정규식) |
| `if` | | 조건부 실행 필터 (권한 규칙 문법, 예: `"Bash(git *)"`) |
| `continueOnBlock` | | PostToolUse 전용. 차단(`block`) 결과를 Claude에 피드백으로 전달하고 작업을 계속 진행 |
| `timeout` | | 실행 시간 제한 (초) |

> △ = `type`에 따라 필수. `command` 타입이면 `command`, `http` 타입이면 `url`, `mcp_tool` 타입이면 `tool` 필수.

**exec 형식 (`args`)**: 셸 해석 없이 명령을 직접 실행하려면 `args` 배열을 사용합니다 (2.1.139). 경로에 공백·특수문자가 있어도 안전합니다.

```json
{
  "event": "PostToolUse",
  "type": "command",
  "command": "prettier",
  "args": ["--write", "$CLAUDE_FILE_PATHS"]
}
```

### 매처 패턴

매처는 **정규식**으로 도구 이름에 매칭됩니다:

```json
"matcher": "Write"              // Write 도구만
"matcher": "Write|Edit"         // Write 또는 Edit
"matcher": "Bash"               // Bash 도구만
"matcher": "mcp__.*__write.*"   // 모든 MCP 서버의 write 도구
```

매처를 생략하면 해당 이벤트의 모든 도구 호출에 실행됩니다.

> **참고**: `SessionStart`, `Stop`, `Notification` 같은 **라이프사이클 이벤트**는 특정 도구와 관련이 없으므로 `matcher` 필드가 무시됩니다. 이 이벤트들에 매처를 설정해도 효과가 없습니다.

### 훅 이벤트 공통 필드

모든 훅 이벤트의 stdin JSON에는 다음 공통 필드가 포함됩니다:

| 필드 | 설명 |
|------|------|
| `session_id` | 현재 세션 ID |
| `agent_id` | 이벤트를 발생시킨 에이전트 ID (메인 또는 서브에이전트) |
| `agent_type` | 에이전트 유형 (`"main"`, `"subagent"`, `"background"` 등) |

`agent_id`와 `agent_type`을 활용하면 서브에이전트별로 다른 훅 동작을 구현할 수 있습니다.

---

## 입출력 스키마

### 훅에 전달되는 입력 (stdin)

훅 스크립트는 **stdin으로 JSON**을 받습니다:

**공통 필드:**

```json
{
  "session_id": "abc-123",
  "transcript_path": "/path/to/transcript",
  "cwd": "/path/to/project",
  "hook_event_name": "PreToolUse",
  "permission_mode": "default",
  "effort": { "level": "high" }
}
```

- `effort.level`은 현재 활성 노력 수준입니다 (2.1.133). 같은 값이 `$CLAUDE_EFFORT` 환경 변수로도 훅·Bash 서브프로세스에 노출되어, 노력 수준에 따라 훅 동작을 분기할 수 있습니다

**도구 이벤트 추가 필드 (PreToolUse / PostToolUse):**

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "content": "..."
  },
  "tool_result": "...",
  "duration_ms": 145
}
```

- `tool_result`는 PostToolUse / PostToolUseFailure에서만 포함됩니다
- `duration_ms`는 PostToolUse / PostToolUseFailure에 포함되며, **사용자 프롬프트 시간을 제외한 실제 도구 실행 시간**입니다 (성능 측정/감사용)

**Stop / SubagentStop 추가 필드:**

```json
{
  "background_tasks": [ { "id": "...", "status": "running" } ],
  "session_crons": [ { "id": "...", "schedule": "0 */2 * * *" } ]
}
```

- `background_tasks`와 `session_crons`는 Stop/SubagentStop 훅 입력에 포함됩니다. 아직 실행 중인 백그라운드 작업이나 예약된 `/loop` 태스크가 있으면 종료(stop) 훅에서 이를 확인해 차단 여부를 결정할 수 있습니다

> **MCP stdio 서버 환경**: MCP stdio 서버도 이제 환경에서 `CLAUDE_PROJECT_DIR`를 받습니다 (2.1.139). 프로젝트 루트 기준 경로 해석이 필요한 서버에서 활용할 수 있습니다.

### 종료 코드

| 코드 | 의미 | 동작 |
|:----:|------|------|
| **0** | 성공/허용 | 도구 실행 허용, stdout 파싱 |
| **1** | 비차단 에러 | stderr가 verbose 모드에서 표시, 실행 계속 |
| **2** | 차단/거부 | 도구 실행 차단, stderr가 Claude에게 에러로 전달 |

### stdout 출력

종료 코드 0일 때, stdout의 JSON 출력으로 추가 동작을 지정할 수 있습니다:

```json
{
  "message": "린트 검사를 통과했습니다",
  "continue": true
}
```

**터미널 제어 시퀀스 — `terminalSequence`**:

훅이 제어 터미널 없이도 데스크톱 알림, 창 제목, 벨(bell) 등을 내보낼 수 있습니다 (2.1.141):

```json
{
  "terminalSequence": "]0;빌드 완료"
}
```

- 백그라운드/원격 환경에서 OS 알림을 띄우거나 터미널 탭 제목을 갱신할 때 사용합니다

**PreToolUse 전용 — `action` 필드**:

PreToolUse 훅에서는 `action` 필드로 도구 실행을 세밀하게 제어할 수 있습니다:

```json
// 명시적 허용 (권한 프롬프트 건너뜀)
{ "action": "allow", "message": "자동 승인됨" }

// 명시적 거부 (종료 코드 2와 동일)
{ "action": "deny", "message": "보안 정책에 의해 차단" }

// 사용자에게 확인 요청
{ "action": "ask", "message": "이 작업을 허용할까요?" }

// 결정 보류 — 다른 훅 또는 기본 정책에 위임
{ "action": "defer" }
```

> `action`을 생략하면 기본적으로 `"allow"`로 처리됩니다. `"defer"`는 여러 훅을 체이닝하면서 일부 훅이 결정을 다음 훅에 넘기고 싶을 때 사용합니다.

**PostToolUse 전용 — `hookSpecificOutput.updatedToolOutput`**:

PostToolUse 훅이 도구의 결과를 변형하여 Claude에 전달할 수 있습니다 (모든 도구에서 지원):

```json
{
  "hookSpecificOutput": {
    "updatedToolOutput": "린트 오류가 1건 자동 수정되었습니다.\n\n원본 출력:\n..."
  }
}
```

포매터/린터 결과를 후처리하거나, 비밀 정보를 마스킹한 결과를 Claude에 보여주는 데 활용합니다.

**SessionStart 전용 — `reloadSkills` / `sessionTitle`** (2.1.152):

```json
{
  "reloadSkills": true,
  "hookSpecificOutput": {
    "sessionTitle": "결제 모듈 리팩토링"
  }
}
```

- `reloadSkills: true` — 스킬 디렉토리를 다시 스캔하여, 세션 시작 시 설치한 스킬을 **재시작 없이 같은 세션에서** 사용할 수 있게 합니다 (`/reload-skills` 커맨드와 동일한 효과)
- `hookSpecificOutput.sessionTitle` — 세션 시작/재개 시 세션 제목을 설정합니다

**MessageDisplay 전용** (2.1.152): 어시스턴트 메시지가 화면에 렌더링되기 직전에 텍스트를 변형하거나 숨길 수 있습니다. 민감 정보 마스킹, 표시용 후처리 등에 활용합니다.

**Stop / SubagentStop 전용 — `hookSpecificOutput.additionalContext`** (2.1.163):

Stop·SubagentStop 훅이 종료 시점에 **추가 컨텍스트를 반환**하여 다음 턴에 주입할 수 있습니다:

```json
{
  "hookSpecificOutput": {
    "additionalContext": "린트 결과: 경고 2건 남음. 다음 응답에서 처리 필요."
  }
}
```

- 종료 훅에서 얻은 정보(테스트 결과, 잔여 작업 등)를 다음 턴 컨텍스트로 전달할 때 사용합니다

---

## 실전 훅 예제

### 자동 포매팅 (PostToolUse)

파일을 수정한 후 자동으로 Prettier를 실행합니다:

```json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "Write|Edit",
      "type": "command",
      "command": ".claude/hooks/format.sh",
      "timeout": 10
    }
  ]
}
```

`.claude/hooks/format.sh`:

```bash
#!/bin/bash
# stdin에서 JSON 읽기
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -n "$file_path" ] && [[ "$file_path" == *.ts || "$file_path" == *.tsx ]]; then
  npx prettier --write "$file_path" 2>/dev/null
fi

exit 0
```

### 파일 보호 (PreToolUse)

특정 파일의 수정을 차단합니다:

```bash
#!/bin/bash
# protect-files.sh
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# 보호 대상 파일
protected_files=(".env" ".env.local" "secrets.json")

for protected in "${protected_files[@]}"; do
  if [[ "$file_path" == *"$protected"* ]]; then
    echo "보호된 파일입니다: $file_path" >&2
    exit 2  # 차단
  fi
done

exit 0  # 허용
```

### 테스트 검증 (PostToolUse)

Bash 명령어 실행 후 테스트가 통과하는지 확인합니다:

```json
{
  "event": "PostToolUse",
  "matcher": "Write|Edit",
  "type": "command",
  "command": ".claude/hooks/run-tests.sh",
  "timeout": 60
}
```

### 데스크톱 알림 (Notification)

작업 완료 시 알림을 보냅니다:

```bash
#!/bin/bash
# notify.sh
input=$(cat)
message=$(echo "$input" | jq -r '.message // "작업 완료"')

# macOS
osascript -e "display notification \"$message\" with title \"Claude Code\""

exit 0
```

### 환경 변수 주입 (SessionStart)

세션 시작 시 환경 변수를 설정합니다:

```bash
#!/bin/bash
# session-init.sh

# CLAUDE_ENV_FILE에 환경 변수 추가
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=development' >> "$CLAUDE_ENV_FILE"
  echo 'export DEBUG=app:*' >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

### MCP 도구 호출 훅 (`type: "mcp_tool"`)

훅이 셸을 거치지 않고 MCP 서버의 도구를 직접 호출할 수 있습니다. 예: 빌드 실패 시 GitHub 이슈 자동 생성.

```json
{
  "hooks": [
    {
      "event": "PostToolUseFailure",
      "matcher": "Bash",
      "if": "Bash(npm run build*)",
      "type": "mcp_tool",
      "tool": "mcp__github__create_issue",
      "input": {
        "title": "빌드 실패",
        "body": "${tool_result}"
      },
      "timeout": 30
    }
  ]
}
```

- `tool`은 MCP 도구의 정규화된 이름 (`mcp__<server>__<tool>`)
- `input`의 값에 훅 stdin 필드를 보간할 수 있습니다 (`${tool_name}`, `${tool_result}` 등)
- 외부 셸 스크립트 없이 자동화 워크플로우를 구성할 때 유용합니다

### HTTP 훅 (PreToolUse)

외부 서비스로 HTTP POST를 전송하는 웹훅 방식 훅입니다:

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "matcher": "Bash",
      "type": "http",
      "url": "http://localhost:8080/hooks/pre-tool-use",
      "timeout": 30,
      "headers": {
        "Authorization": "Bearer $MY_TOKEN"
      },
      "allowedEnvVars": ["MY_TOKEN"]
    }
  ]
}
```

HTTP 훅의 응답 처리:

| 응답 | 동작 |
|------|------|
| 2xx + 빈 바디 | 성공 (종료 코드 0과 동일) |
| 2xx + 텍스트 바디 | 성공, 텍스트가 컨텍스트에 추가 |
| 2xx + JSON 바디 | 성공, 표준 JSON 출력 스키마로 파싱 |
| non-2xx / 연결 실패 / 타임아웃 | **비차단 에러** — 실행 계속 진행 |

> command 훅과 달리 HTTP 훅은 연결 실패 시 **비차단**입니다. 도구 실행을 차단하려면 2xx 응답에서 `"decision": "block"`을 반환해야 합니다.

---

## 설정 범위

### 프로젝트 훅 (.claude/settings.json)

```json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "Write|Edit",
      "type": "command",
      "command": ".claude/hooks/format.sh"
    }
  ]
}
```

팀 전체에 적용됩니다.

### 사용자 훅 (~/.claude/settings.json)

개인 전용 훅입니다. 프로젝트 훅과 함께 **병합**되어 실행됩니다.

### 관리자 훅

조직에서 강제하는 훅입니다. 사용자가 비활성화할 수 없습니다.

---

## 보안 고려사항

### 훅 보안 키

| 설정 | 용도 |
|------|------|
| `allowManagedHooksOnly` | 관리자 훅만 실행 허용 |
| `disableAllHooks` | 모든 훅 비활성화 |

### 주의점

- 훅 스크립트는 **시스템 권한으로 실행**됩니다
- 외부 입력을 처리할 때 셸 인젝션에 주의
- 타임아웃을 설정하여 무한 실행 방지
- 프로젝트 훅은 코드 리뷰를 거쳐 커밋

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **이벤트** | PreToolUse, PostToolUse, SessionStart, Stop, MessageDisplay 등 27가지 |
| **훅 타입** | `command` (셸), `http` (HTTP POST), `mcp_tool` (MCP 도구 직접 호출) |
| **PreToolUse 결정** | `allow`, `deny`, `ask`, `defer` |
| **PostToolUse 후처리** | `hookSpecificOutput.updatedToolOutput`로 결과 변형 |
| **Stop/SubagentStop 후처리** | `hookSpecificOutput.additionalContext`로 다음 턴에 컨텍스트 주입 (2.1.163) |
| **성능 측정** | PostToolUse stdin의 `duration_ms` 필드 |
| **설정** | settings.json의 `hooks` 배열 |
| **매처** | 정규식으로 도구 이름 필터링 |
| **입력** | stdin으로 JSON (도구 이름, 입력, 결과) |
| **종료 코드** | 0=허용, 1=경고, 2=차단 |
| **범위** | 프로젝트, 사용자, 관리자 (병합 실행) |
| **보안** | `allowManagedHooksOnly`, `disableAllHooks` |

---

## 다음 챕터

[21장: MCP 서버 통합](03-mcp-servers.md)에서 외부 도구와 API를 Claude Code에 연결하는 방법을 배웁니다.
