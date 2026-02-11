<!-- last_updated: 2026-02-11 -->

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
| **PostToolUse** | 도구 실행 후 | 포매팅, 검증, 알림 |
| **Notification** | Claude가 알림 발송 시 | 데스크톱 알림, 로깅 |
| **SessionStart** | 세션 시작/재개 시 | 환경 설정, 컨텍스트 주입 |
| **UserPromptSubmit** | 사용자 프롬프트 제출 시 | 입력 검증, 변환 |
| **Stop** | Claude 응답 완료 시 | 후처리, 알림 |
| **SubagentStop** | 서브에이전트 완료 시 | 결과 처리 |

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
| `type` | O | `"command"` (셸 명령어) |
| `command` | O | 실행할 명령어 또는 스크립트 경로 |
| `matcher` | | 도구 이름 필터 (정규식) |
| `timeout` | | 실행 시간 제한 (초) |

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
  "permission_mode": "default"
}
```

**도구 이벤트 추가 필드 (PreToolUse / PostToolUse):**

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "content": "..."
  },
  "tool_result": "..."
}
```

`tool_result`는 PostToolUse에서만 포함됩니다.

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

**PreToolUse 전용 — `action` 필드**:

PreToolUse 훅에서는 `action` 필드로 도구 실행을 세밀하게 제어할 수 있습니다:

```json
// 명시적 허용 (권한 프롬프트 건너뜀)
{ "action": "allow", "message": "자동 승인됨" }

// 명시적 거부 (종료 코드 2와 동일)
{ "action": "deny", "message": "보안 정책에 의해 차단" }

// 사용자에게 확인 요청
{ "action": "ask", "message": "이 작업을 허용할까요?" }
```

> `action`을 생략하면 기본적으로 `"allow"`로 처리됩니다.

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
| **이벤트** | PreToolUse, PostToolUse, SessionStart, Stop 등 7가지 |
| **설정** | settings.json의 `hooks` 배열 |
| **매처** | 정규식으로 도구 이름 필터링 |
| **입력** | stdin으로 JSON (도구 이름, 입력, 결과) |
| **종료 코드** | 0=허용, 1=경고, 2=차단 |
| **범위** | 프로젝트, 사용자, 관리자 (병합 실행) |
| **보안** | `allowManagedHooksOnly`, `disableAllHooks` |

---

## 다음 챕터

[21장: MCP 서버 통합](03-mcp-servers.md)에서 외부 도구와 API를 Claude Code에 연결하는 방법을 배웁니다.
