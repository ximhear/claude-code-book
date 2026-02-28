<!-- last_updated: 2026-02-28 -->

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

### 클라우드 프로바이더

| 변수 | 용도 |
|------|------|
| `CLAUDE_CODE_USE_BEDROCK` | Amazon Bedrock |
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
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 출력 토큰 한도 | 32,000 |

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

### 보안

| 변수 | 용도 |
|------|------|
| `CLAUDE_CODE_CLIENT_CERT` | mTLS 인증서 |
| `CLAUDE_CODE_CLIENT_KEY` | mTLS 키 |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | API 키 헬퍼 갱신 간격 |
