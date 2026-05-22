<!-- last_updated: 2026-05-23 -->

# 부록 B: CLI 레퍼런스

> 모든 CLI 명령어와 플래그를 정리합니다.

---

## 메인 커맨드

```bash
claude [옵션] [초기 프롬프트]
```

---

## 플래그 레퍼런스

### 세션 관리

| 플래그 | 설명 |
|--------|------|
| `-c`, `--continue` | 최근 세션 이어가기 |
| `-r`, `--resume [ID\|이름]` | 특정 세션 재개, 인자 없으면 선택기 |
| `--fork-session` | 세션 포크 (`--continue`/`--resume`와 함께) |
| `--teleport` | 웹 세션을 터미널로 이전 |
| `--from-pr <PR>` | PR 컨텍스트로 세션 시작 |
| `-w`, `--worktree [이름]` | 격리된 Git worktree에서 세션 시작 |
| `-n`, `--name <이름>` | 세션 표시 이름 지정 |
| `--bg` | 백그라운드 세션으로 시작 (Agent View/`/resume`에 `bg`로 표시) |
| `--no-session-persistence` | 세션 저장 안 함 |

### 모델과 추론

| 플래그 | 설명 |
|--------|------|
| `--model <모델>` | 모델 지정 (opus, sonnet, haiku, opusplan) |
| `--permission-mode <모드>` | 권한 모드 (default, acceptEdits, plan, dontAsk, bypassPermissions) |

### 비대화형 모드

| 플래그 | 설명 |
|--------|------|
| `-p`, `--print` | 비대화형 출력 |
| `--output-format <형식>` | text, json, stream-json |
| `--input-format <형식>` | 입력 형식 지정 |
| `--json-schema <스키마>` | 구조화된 JSON 출력 |
| `--max-turns <N>` | 최대 턴 수 |
| `--max-budget-usd <금액>` | 비용 한도 (달러) |
| `--append-system-prompt <텍스트>` | 시스템 프롬프트 추가 |
| `--system-prompt <텍스트>` | 시스템 프롬프트 교체 |
| `--verbose` | 상세 로깅 |
| `--tools <도구들>` | 허용 도구 (쉼표 구분) |

### 기타

| 플래그 | 설명 |
|--------|------|
| `--version` | 버전 표시 |
| `--help` | 도움말 |
| `--remote` | 클라우드 세션 |
| `--status <ID>` | 세션 상태 확인 |
| `--mcp-debug` | MCP 디버그 모드 |
| `--channels <플러그인>` | 외부 플랫폼 채널 활성화 (Telegram, Discord) |
| `--bare` | 훅, LSP, 플러그인 동기화, 스킬 탐색을 건너뛰고 최소 모드로 실행 |
| `--tui` | 시작 시 풀스크린(TUI) 모드 |
| `--plugin-url <url>` | URL에서 플러그인 아카이브를 받아 현재 세션에 로드 |
| `--plugin-dir <경로\|.zip>` | 로컬 디렉토리 또는 zip 아카이브에서 플러그인 로드 |
| `--exclude-dynamic-system-prompt-sections <섹션>` | 시스템 프롬프트 동적 섹션 제외 |
| `--dangerously-skip-permissions` | 권한 프롬프트 우회 (`.claude/`, `.git/`, `.vscode/` 포함) |

---

## 서브커맨드

### `claude config`

```bash
claude config list                    # 설정 목록
claude config get <키>                # 설정 값 확인
claude config set <키> <값>           # 설정 변경
```

### `claude auth`

```bash
claude auth login                       # 로그인
claude auth login --email user@co.com   # 이메일 지정 로그인
claude auth login --sso                 # SSO 로그인
claude auth login --console             # 콘솔(API 과금) 인증
claude auth status                      # 인증 상태 확인
claude auth status --text               # 텍스트 출력 (종료 코드: 0=로그인, 1=미로그인)
claude auth logout                      # 로그아웃
```

### `claude mcp`

```bash
claude mcp add <이름> <명령어> [인자...]   # MCP 서버 추가
claude mcp add <이름> -e KEY=VAL <명령어>  # 환경 변수와 함께
claude mcp list                            # 서버 목록
claude mcp get <이름>                      # 서버 상세 정보
claude mcp remove <이름>                   # 서버 제거
```

### `claude project`

```bash
claude project purge [path]                # 프로젝트의 모든 Claude Code 상태 삭제
claude project purge --dry-run             # 삭제 대상 미리보기
claude project purge -y                    # 확인 없이 삭제
claude project purge -i                    # 인터랙티브 선택
claude project purge --all                 # 모든 프로젝트 상태 삭제
```

### `claude agents` (Agent View, 연구 프리뷰)

실행 중인 모든 Claude 세션(인터랙티브 + 백그라운드)을 한 화면에서 관리합니다 (2.1.139 연구 프리뷰).

```bash
claude agents                              # 모든 세션을 하나의 목록으로 표시
claude agents --json                       # 세션 목록을 JSON으로 출력 (스크립팅/상태바용)
claude agents --cwd <경로>                 # 특정 디렉토리로 세션 목록 범위 한정
```

세션을 디스패치할 때 설정을 함께 지정할 수 있습니다 (2.1.142~):

```bash
claude agents --add-dir <경로> \
              --settings <파일> \
              --mcp-config <파일> \
              --plugin-dir <경로> \
              --permission-mode <모드> \
              --model <모델> \
              --effort <수준> \
              --dangerously-skip-permissions
```

- 세션을 시작하고, 백그라운드로 보내고, 상태와 마지막 응답을 엿보고, 입력이 필요할 때만 다시 들어갈 수 있습니다
- `--json` 출력은 tmux-resurrect, 상태바, 세션 피커 등 스크립팅에 활용합니다
- 백그라운드 세션(`claude --bg`)도 같은 목록에 `bg`로 표시됩니다

### `claude plugin`

```bash
claude plugin validate <경로>              # 매니페스트 유효성 검증
claude plugin prune                        # 고아 의존성 제거
claude plugin tag                          # 릴리스용 git 태그 생성
claude plugin details <이름>               # 플러그인 구성 요소 인벤토리 + 세션당 예상 토큰 비용
claude plugin disable <이름>               # 비활성화 (다른 플러그인이 의존하면 거부)
claude plugin marketplace add <소스>       # 마켓플레이스 등록
```

### `claude ultrareview`

```bash
claude ultrareview [target]                # 비대화형 클라우드 코드 리뷰 (CI/스크립트용)
```

### `/plugin`

```bash
/plugin                                    # 인터랙티브 관리 UI (4탭)
/plugin install name@marketplace           # 플러그인 설치
/plugin uninstall name@marketplace         # 플러그인 제거
/plugin enable name@marketplace            # 활성화
/plugin disable name@marketplace           # 비활성화
/plugin marketplace add <source>           # 마켓플레이스 추가
/plugin marketplace list                   # 마켓플레이스 목록
/plugin marketplace update <name>          # 마켓플레이스 새로고침
/plugin marketplace remove <name>          # 마켓플레이스 제거
/plugin validate .                         # 마켓플레이스/플러그인 JSON 검증
```

> 플러그인 시스템의 전체 구조와 활용법은 [25장: 플러그인](../05-advanced/07-plugins.md)을 참고하세요.

---

## 환경 변수 레퍼런스

### 인증

| 변수 | 용도 |
|------|------|
| `ANTHROPIC_API_KEY` | API 키 |
| `ANTHROPIC_BASE_URL` | 커스텀 API 엔드포인트 |
| `ANTHROPIC_AUTH_TOKEN` | 커스텀 Authorization 헤더 |
| `ANTHROPIC_CUSTOM_HEADERS` | 커스텀 HTTP 헤더 |
| `ANTHROPIC_WORKSPACE_ID` | 워크로드 ID 페더레이션용 워크스페이스 식별자 |

### 클라우드 프로바이더

| 변수 | 용도 |
|------|------|
| `CLAUDE_CODE_USE_BEDROCK` | Amazon Bedrock |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Bedrock 서비스 티어 (`default`, `flex`, `priority`) |
| `CLAUDE_CODE_USE_VERTEX` | Google Vertex AI |
| `ANTHROPIC_VERTEX_PROJECT_ID` | Vertex 프로젝트 ID |
| `CLAUDE_CODE_USE_FOUNDRY` | Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_API_KEY` | Foundry API 키 |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Foundry 리소스명 |

### 모델과 추론

| 변수 | 용도 | 기본값 |
|------|------|--------|
| `ANTHROPIC_MODEL` | 기본 모델 | — |
| `MAX_THINKING_TOKENS` | 사고 토큰 예산 | 31,999 |
| `CLAUDE_CODE_EFFORT_LEVEL` | 노력 수준 | high |
| `CLAUDE_EFFORT` | 활성 노력 수준 (훅·Bash 서브프로세스에 노출, 읽기 전용) | — |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 출력 토큰 한도 | 32,000 |
| `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` | Fast 모드를 Opus 4.6에 고정 (`1`, 기본은 4.7) | — |

### 동작 제어

| 변수 | 용도 |
|------|------|
| `DISABLE_AUTOUPDATER` | 자동 업데이트 비활성화 |
| `DISABLE_PROMPT_CACHING` | 프롬프트 캐싱 비활성화 |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | 텔레메트리 |
| `CLAUDE_CODE_SHELL` | 셸 오버라이드 |
| `CLAUDE_CODE_TASK_LIST_ID` | 공유 태스크 리스트 |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | 백그라운드 태스크 비활성화 |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | 에이전트 팀 활성화 |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | 내장 Git 커밋/PR 지침 비활성화 |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | claude.ai MCP 서버 사용 (`false`로 비활성화) |
| `CLAUDE_CODE_DISABLE_CRON` | `/loop`의 Cron 스케줄링 비활성화 |
| `CLAUDE_PLUGIN_DATA` | 플러그인 영구 데이터 디렉토리 |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | 서브프로세스에서 자격 증명 제거 |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | 스트리밍 유휴 감시 타임아웃 (기본 90초) |
| `ENABLE_PROMPT_CACHING_1H` | 1시간 프롬프트 캐시 TTL |
| `FORCE_PROMPT_CACHING_5M` | 5분 캐시 TTL 강제 |
| `CLAUDE_CODE_USE_MANTLE` | Bedrock Mantle 활성화 |
| `CLAUDE_CODE_PERFORCE_MODE` | Perforce 읽기 전용 파일 모드 |
| `CLAUDE_CODE_NO_FLICKER` | 플리커 없는 렌더링 |
| `MCP_CONNECTION_NONBLOCKING` | `-p` 모드 MCP 연결 비차단 |
| `CLAUDE_CODE_SCRIPT_CAPS` | 세션당 스크립트 호출 제한 |
| `CLAUDE_CODE_HIDE_CWD` | 시작 로고에서 CWD 숨김 |
| `DISABLE_UPDATES` | 모든 업데이트 경로 차단 |
| `AI_AGENT` | 서브프로세스 에이전트 출처 식별 |
| `CLAUDE_CODE_FORK_SUBAGENT` | 서브에이전트 fork 활성화 (외부 빌드/SDK) |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | PowerShell 도구 단계적 활성화 (Windows) |
| `CLAUDE_CODE_CERT_STORE` | 인증서 저장소 (`os`, `bundled`) |
| `CLAUDE_CODE_FORCE_SYNC_OUTPUT` | 동기화된 터미널 출력 강제 |
| `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` | Homebrew/WinGet 자동 업그레이드 |
| `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` | 게이트웨이 모델 자동 디스커버리 |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | 풀스크린 alt-screen 옵트아웃 |
| `CLAUDE_CODE_SESSION_ID` | Bash 서브프로세스에 세션 ID 노출 |
| `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` | 실험적 베타 기능 비활성화 |
| `OTEL_LOG_RAW_API_BODIES` | 원본 API 본문 OTel 로깅 (디버그) |
| `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` | GitHub 플러그인 소스를 SSH 대신 HTTPS로 클론 |
| `CLAUDE_CODE_POWERSHELL_RESPECT_EXECUTION_POLICY` | PowerShell 도구의 `-ExecutionPolicy Bypass` 옵트아웃 (`1`) |
| `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` | Stop 훅 연속 차단 한도(기본 8) 재정의 |
| `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` | 엔터프라이즈 세션 품질 설문 재활성화 |

### 보안

| 변수 | 용도 |
|------|------|
| `CLAUDE_CODE_CLIENT_CERT` | mTLS 인증서 |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS 키 |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | API 키 헬퍼 갱신 간격 |
