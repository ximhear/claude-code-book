# Changelog

## [0.12.0] - 2026-07-07
> Claude Code 2.1.158 ~ 2.1.202 반영

### Added
- 8장/용어집: **Claude Sonnet 5** 모델 추가 (2.1.197) — Claude Code **새 기본 모델**. API ID `claude-sonnet-5`, 1M 컨텍스트, 기본 노력 수준 high, $3/$15(도입가 $2/$10, ~2026-08-31), "속도와 지능의 최적 조합". 2.1.197부터 이용 가능
- 8장/용어집: **Claude Fable 5** 모델 지원 추가 (2.1.170) — API ID `claude-fable-5`, Mythos급, GA 2026-06-09, $10/$50, 1M, adaptive thinking 상시. `[1m]` 접미사 자동 정규화(2.1.173)
- 8장: Gateway **Claude Platform on AWS**(`anthropicAws`) 업스트림 추가 (2.1.198), 모델 폐기·자동업데이트 경고 stderr 출력 (2.1.183, `-p`·에이전트 프론트매터 포함)
- 5장: `/cd` (프롬프트 캐시 유지 작업 디렉터리 이동, 2.1.169), `/dataviz` 스킬 (차트·대시보드 + 색상 팔레트 검증기, 2.1.198) 추가
- 5장: `/config key=value` 프롬프트 설정 (2.1.181), `/config --help` 단축키 목록 (2.1.183) 추가
- 5장: `/rewind` **신규 기능** — `/clear` 이전 지점부터 대화 재개 (2.1.191)
- 5장: 스택드 슬래시-스킬 `/skill-a /skill-b` 최대 5개 선행 로드 (2.1.199)
- 20장: Stop/SubagentStop 훅 `hookSpecificOutput.additionalContext` 반환 (2.1.163), Self-hosted runner `post-session` 라이프사이클 훅 (2.1.169)
- 10장: `fallbackModel`(최대 3개 체인, 2.1.166), `enforceAvailableModels`(2.1.175), `sandbox.credentials`(2.1.187), `footerLinksRegexes`(2.1.176), `autoMode.classifyAllShell`(2.1.193), `requiredMinimumVersion`/`requiredMaximumVersion`(2.1.163), `disableBundledSkills`(2.1.169) 설정 추가
- 10장: 권한 규칙 `Tool(param:value)` 문법 (2.1.178, `*` 와일드카드, 예 `Agent(model:opus)`), deny 규칙 도구명 위치 glob (2.1.166)
- 10장: 조직 기본 모델 (2.1.196) — 콘솔 지정, `/model`에 "Org default"/"Role default" 표시(설정 키 아님), `/config` "Dynamic workflow size"(small/medium/large, 2.1.202)
- 10장/부록B: 환경 변수 `CLAUDE_CODE_ENABLE_AUTO_MODE`(2.1.158), `CLAUDE_CLIENT_PRESENCE_FILE`(2.1.181), `CLAUDE_CODE_DISABLE_MOUSE_CLICKS`(2.1.195), `CLAUDE_CODE_SAFE_MODE`(2.1.169), `CLAUDE_CODE_RETRY_WATCHDOG`(2.1.199 기본 재시도 300·상한 15 해제) 추가
- 10장: OTEL `OTEL_RESOURCE_ATTRIBUTES` 라벨화(2.1.161), `lines_of_code.count` `model` 속성(2.1.172), `claude_code.assistant_response` 이벤트+`OTEL_LOG_ASSISTANT_RESPONSES`(2.1.193), `workflow.run_id`/`workflow.name`(2.1.202)
- 부록B: `--safe-mode`(2.1.169), `claude mcp login/logout <name>`(2.1.186, `--no-browser`), `--tools` Grep/Glob 명시(2.1.162), `--json-schema`/workflow `agent({schema})` 구조화 출력(2.1.187), `CLAUDE_CODE_MAX_RETRIES` 상한 15(2.1.186)
- 19장/25장: 중첩 `.claude/skills`·`.claude/` 로드(충돌 시 `<dir>:<name>`, 2.1.178), 스킬 `\$` 이스케이프(2.1.163), `/plugin list`(`--enabled`/`--disabled`, 2.1.163), Installed 탭 Skills 섹션(2.1.186), 마켓플레이스 검색바(2.1.172)
- 22장: 서브에이전트 다단 중첩 최대 5단계 (2.1.172), `!` bash 명령 자동 응답 `respondToBashCommands`(2.1.186) + 라이브 경로 자동완성(2.1.193)

### Changed
- 8장/5장: 기본 모델 **Opus 4.8 → Sonnet 5** (2.1.197). Opus 4.8은 기본에서 강등, 복잡 에이전틱 코딩·엔터프라이즈 권장 모델로 유지 (`opus` 별칭은 여전히 Opus 4.8 지시)
- 5장/용어집: 다이나믹 워크플로우 트리거 키워드 **`workflow` → `ultracode`** (2.1.160). `ultracode`는 `/effort` 최상위 노력 레벨(xHigh 필요)이자 다이나믹 워크플로우 발동 키워드, 보라색 shimmer(2.1.178)
- 10장/부록B: 기본 권한 모드 **'default' → 'Manual'** (2.1.200), `--permission-mode manual`/`"defaultMode":"manual"` 수용, `AskUserQuestion` 기본 auto-continue 제거
- 22장: 서브에이전트 **기본 백그라운드 실행** (2.1.198)
- 5장: `/review <pr>` 2.1.202 기준 **빠른 단일 패스**로 회귀 (멀티에이전트는 `/code-review <level> <pr#>`), `/effort` 기본 유지 확인 UX(2.1.162)
- 부록B: `CLAUDE_CODE_MAX_RETRIES` 상한 15 (2.1.186), 무인 세션은 `CLAUDE_CODE_RETRY_WATCHDOG` 권장

### Deprecated
- 8장/10장/부록B/용어집: **`CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` 실제 제거(no-op)** (2.1.160). 직전 `[0.11.0]`의 "2026-06-01 제거 예정" 표기를 **2.1.160 실제 제거로 4곳 정정**(04-model-selection·02-settings·b-cli-reference·d-glossary)
- 22장: Agent teams **`TeamCreate`/`TeamDelete` 제거** (2.1.178, `team_name` 파라미터는 수용되나 무시·암묵적 단일 팀), **`/agents` 위저드 제거** (2.1.198)
- 6장: JetBrains 플러그인 설치 제안 제거 (2.1.160)

> **비고(단일출처·신중 반영)**: `wheelScrollAccelerationEnabled`(2.1.174), `sandbox.allowAppleEvents`(2.1.181), `teammateMode:"iterm2"`(2.1.186) 3건은 공식 CHANGELOG 원문에서만 확인되고 설정 문서 2차 교차검증 미확인 상태로 신중 반영됨.

## [0.11.0] - 2026-05-30
> Claude Code 2.1.149 ~ 2.1.157 반영
### Added
- 8장/용어집: **Claude Opus 4.8** 모델 추가 (2.1.154) — 현재 기본 모델, 기본 노력 수준 high, xhigh 지원. Opus 4.7은 이전 세대로 강등
- 8장/용어집: **Lean 시스템 프롬프트** 기본 적용 (Haiku/Sonnet/Opus 4.7 이하 제외)
- 5장/용어집: **`/workflows`** (다이나믹 워크플로우, 수십~수백 에이전트 오케스트레이션) 추가
- 5장: **`/reload-skills`** (스킬 디렉토리 재스캔) 추가
- 5장: **`/simplify`** 품질 정리 전용 리뷰로 재설계 (2.1.154, `/code-review`에서 다시 분리)
- 5장: `/code-review --fix` (리뷰 결과 워킹 트리 적용) 플래그 추가
- 5장: `/usage` 카테고리별 분석(스킬·서브에이전트·플러그인·MCP 서버별 비용) 추가
- 부록A: `/diff` 상세 뷰 키보드 스크롤(화살표/`j`·`k`/`PgUp`·`PgDn`/`Space`/`Home`·`End`), 모델 선택기 `s` 키 추가 (2.1.149/2.1.153)
- 20장: **`MessageDisplay`** 훅 이벤트 추가 (총 27개), SessionStart `reloadSkills`/`sessionTitle` 출력
- 19장(스킬): 새 스킬 추가 시 `/reload-skills` 재스캔 안내
- 25장/부록B: `claude plugin init`, `.claude/skills` 자동 로드(마켓플레이스 불필요), `claude plugin enable`(전이 의존성), `plugin marketplace remove --scope`, 매니페스트 `defaultEnabled`, 마켓플레이스 소스 `skipLfs`
- 10장: 관리자 설정 `pluginSuggestionMarketplaces`(2.1.152), `allowAllClaudeAiMcps`(2.1.149) 추가
- 10장/부록B: 환경 변수 `OTEL_LOG_TOOL_DETAILS`, `OTEL_METRICS_INCLUDE_ENTRYPOINT` 추가, statusline `COLUMNS`/`LINES` 전달
- 부록B: `--fallback-model`, `claude --bg --exec`, `claude doctor` 마지막 업데이트 결과 표시
### Changed
- 8장/5장: Fast 모드 기본 모델 **Opus 4.8** (표준 요금 2배 / 2.5배 속도), `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` 폐지(2026-06-01 제거)
- 8장/5장: `/model`이 선택 모델을 **새 세션 기본값으로 저장**, 세션 전용은 **`s` 키** (2.1.153, 이전 `d` 키에서 변경, 키바인딩 `modelPicker:thisSessionOnly`)
- 5장: `/effort` 슬라이더 레이블 "Speed"/"Intelligence" → "Faster"/"Smarter" (2.1.154)
- 5장: 스킬 프론트매터 `disallowed-tools`(스킬 활성 중 도구 제거) 설명 추가

## [0.10.0] - 2026-05-23
> Claude Code 2.1.133 ~ 2.1.148 반영
### Added
- 부록B/5장: **Agent View** (`claude agents`, 연구 프리뷰) — 모든 세션 통합 관리, `--json`, `--cwd`, 디스패치 설정 플래그(`--add-dir`/`--settings`/`--mcp-config`/`--plugin-dir`/`--permission-mode`/`--model`/`--effort`/`--dangerously-skip-permissions`)
- 부록B/5장: **백그라운드 세션** `claude --bg`, `/resume`에서 `bg` 표시
- 5장: `/goal` (완료 조건 기반 자율 진행) 슬래시 커맨드 추가
- 5장: `/scroll-speed` (마우스 휠 스크롤 속도) 슬래시 커맨드 추가
- 5장/8장: `/model`이 현재 세션에만 적용, 선택기 `d` 키로 기본값 지정
- 8장: Fast 모드 기본 모델 **Opus 4.7**로 변경 (`CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE`로 4.6 고정)
- 10장: 설정 `worktree.baseRef`(`fresh`/`head`), `worktree.bgIsolation`, `sandbox.bwrapPath`/`socatPath`, `parentSettingsBehavior`, `autoMode.hard_deny`
- 10장/부록B: 환경 변수 `CLAUDE_EFFORT`, `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE`, `CLAUDE_CODE_PLUGIN_PREFER_HTTPS`, `CLAUDE_CODE_POWERSHELL_RESPECT_EXECUTION_POLICY`, `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`, `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL`, `ANTHROPIC_WORKSPACE_ID`
- 20장: 훅 `args` exec 형식(셸 미경유), `continueOnBlock`(PostToolUse), `terminalSequence` 출력, `effort.level` 입력 + `$CLAUDE_EFFORT`
- 20장: Stop/SubagentStop 입력에 `background_tasks`/`session_crons`, MCP stdio에 `CLAUDE_PROJECT_DIR`
- 25장/부록B: `claude plugin details`(구성 요소+토큰 비용), `claude plugin disable` 의존성 강제, 루트 `SKILL.md` 단일 스킬 노출
- 용어집: Agent View, Background Session, Goal 추가, Fast Mode 갱신
### Changed
- 5장: `/simplify` → **`/code-review`** 이름 변경 (정확성 버그 보고, 노력 수준 인자, `--comment` PR 인라인 코멘트)

## [0.9.0] - 2026-05-07
### Added
- 8장: **Claude Opus 4.7** 모델 추가 (Max/Team Premium 기본), **xhigh** 노력 수준
- 8장: **Auto Mode** (`/model auto`) 추가 — 작업/한도 기반 모델 자동 선택 (Max 구독자)
- 5장: `/ultrareview` (클라우드 멀티에이전트 코드 리뷰) 슬래시 커맨드 추가
- 5장: `/ultraplan` (클라우드 자동 계획+환경 구성) 슬래시 커맨드 추가
- 5장: `/tui` (풀스크린 토글), `/focus` (포커스 모드) 슬래시 커맨드 추가
- 5장: `/less-permission-prompts` (권한 프롬프트 자동화 가이드) 슬래시 커맨드 추가
- 5장: `/usage`로 `/cost`+`/stats` 통합, 사용량 드라이버 표시
- 5장: `/effort` 인터랙티브 슬라이더, `xhigh`/`auto` 옵션
- 5장: `/theme` 커스텀 테마 (`~/.claude/themes/`, `themes/` 플러그인 디렉토리)
- 20장: 훅 `type: "mcp_tool"` (MCP 도구 직접 호출) 추가
- 20장: PreToolUse `"defer"` 결정, PostToolUse `hookSpecificOutput.updatedToolOutput`
- 20장: PostToolUse stdin `duration_ms` 필드 (도구 실행 시간 측정)
- 10장: `tui`, `autoScrollEnabled`, `prUrlTemplate`, `skillOverrides` 설정 추가
- 10장: `sandbox.network.deniedDomains`, MCP `alwaysLoad`, `statusLine.refreshInterval`
- 10장: 환경 변수 14개 추가 (`ANTHROPIC_BEDROCK_SERVICE_TIER`, `CLAUDE_CODE_HIDE_CWD`, `DISABLE_UPDATES`, `AI_AGENT`, `CLAUDE_CODE_FORK_SUBAGENT`, `CLAUDE_CODE_USE_POWERSHELL_TOOL`, `CLAUDE_CODE_CERT_STORE`, `CLAUDE_CODE_FORCE_SYNC_OUTPUT`, `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE`, `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY`, `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN`, `CLAUDE_CODE_SESSION_ID`, `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`, `OTEL_LOG_RAW_API_BODIES`)
- 10장: 관리자 설정 4개 추가 (`allowManagedDomainsOnly`, `allowManagedReadPathsOnly`, `blockedMarketplaces`, `wslInheritsWindowsSettings`)
- 25장: 플러그인 `themes/`, `monitors/` 디렉토리 (`experimental` 블록)
- 25장: `claude plugin prune`, `claude plugin tag` CLI 추가
- 25장: `--plugin-url`, `--plugin-dir <.zip>` 임시 로딩 옵션
- CLI 레퍼런스: `claude project purge`, `claude ultrareview`, `--tui`, `--exclude-dynamic-system-prompt-sections`, `--dangerously-skip-permissions` 추가
- 용어집: Auto Mode, Native Binary, Opus 4.7, TUI, Ultraplan, Ultrareview 추가
### Changed
- 8장: 기본 모델 Opus 4.6 → **Opus 4.7** 반영, 노력 수준에 xhigh 추가
- 5장: `/cost`, `/stats` → `/usage` 통합 안내

## [0.8.0] - 2026-04-16
### Added
- 5장: `/team-onboarding`, `/recap`, `/release-notes`, `/powerup` 슬래시 커맨드 추가
- 5장: `/undo` (`/rewind` 별칭), `/proactive` (`/loop` 별칭) 추가
- 5장: `effort` 프론트매터 필드 추가
- 20장: `PermissionDenied` 훅 이벤트 추가 (총 26개), 조건부 `if` 필드, PreCompact 차단 지원
- 10장: `ENABLE_PROMPT_CACHING_1H`, `CLAUDE_CODE_USE_MANTLE`, `CLAUDE_CODE_PERFORCE_MODE` 등 환경 변수 7개
- 10장: `forceRemoteSettingsRefresh`, `disableSkillShellExecution` 관리자 설정
- 25장: 플러그인 `bin/` 실행 파일 디렉토리
- CLI 레퍼런스: 환경 변수 7개 추가
- 용어집: Mantle, Monitor 용어 추가
### Changed
- 8장: 기본 노력 수준 medium → **high** 변경 반영 (API/Bedrock/Vertex/Foundry/Team/Enterprise)

## [0.7.1] - 2026-03-26
### Added
- 20장: `CwdChanged`, `FileChanged`, `TaskCreated` 훅 이벤트 추가 (총 25개)
- 10장: `managed-settings.d/` 드롭인 디렉토리, `sandbox.failIfUnavailable`, `allowedChannelPlugins`, `disableDeepLinkRegistration` 설정
- 10장: `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`, `CLAUDE_STREAM_IDLE_TIMEOUT_MS` 환경 변수
- 10장: `chat:killAgents`, `chat:fastMode`, `Ctrl+X Ctrl+E` 키바인딩
- 22장: 에이전트 `initialPrompt` 프론트매터 필드
- CLI 레퍼런스: `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`, `CLAUDE_STREAM_IDLE_TIMEOUT_MS`
- 용어집: Transcript 검색 기능 (`/`) 설명 보강

## [0.7.0] - 2026-03-21
### Added
- 30장: Channels 챕터 신규 추가 (Telegram/Discord 외부 플랫폼 연동, 페어링/보안 모델, 엔터프라이즈 관리)
- 5장: `/effort` 노력 수준 변경 슬래시 커맨드 섹션 추가
- 5장: `/branch` 세션 분기 슬래시 커맨드 섹션 추가 (`/fork` 별칭)
- 5장: `/loop` 공식 문서 기반 보강 (일회성 리마인더, 3일 만료, 지터, 50-태스크 한도)
- 5장: `/copy N` 인덱스 파라미터, `effort` 프론트매터 필드
- 10장: `modelOverrides`, `autoMemoryDirectory`, `allowRead`, `worktree.sparsePaths` 설정 키
- 13장: `autoMemoryDirectory` 설정 참조
- 20장: `PostCompact`, `Elicitation`, `ElicitationResult`, `StopFailure` 훅 이벤트 (총 22개)
- 25장: `${CLAUDE_PLUGIN_DATA}` 변수, `source: 'settings'` 인라인 플러그인 소스
- CLI 레퍼런스: `--channels`, `--bare`, `--console`, `-n`/`--name` 플래그, `CLAUDE_PLUGIN_DATA`
- 용어집: Channels, Elicitation 용어 추가
### Changed
- 8장: Opus 4.6 기본 최대 출력 64K 반영 (상한 128K)
- 챕터 번호 재정렬: 30장 삽입으로 기존 30~34장 → 31~35장

## [0.6.0] - 2026-03-11
### Added
- 5장: `/loop` 반복 프롬프트 실행 섹션 추가 (시간 간격, Cron 스케줄링, cancel)
- 5장: `/color` 색상 변경 섹션 추가 (reset, default, gray, none 옵션)
- 5장: `/plan` 설명 인자 지원, `/copy` `w` 키 파일 쓰기
- 5장: Voice Mode `voice:pushToTalk` 키바인딩 재설정 안내
- 8장: 노력 수준 시각적 표시 (○ ◐ ●), "max" 수준 제거 명시
- 10장: `voice:pushToTalk` 키바인딩, `CLAUDE_CODE_DISABLE_CRON` 환경 변수
- 22장: `ExitWorktree` 도구 설명
- 26장: VS Code Spark 아이콘, MCP 관리, Plan 마크다운 뷰, URI 핸들러, 노력 수준 표시
- 용어집: Loop 용어 추가
- CLI 레퍼런스: `CLAUDE_CODE_DISABLE_CRON` 환경 변수

## [0.5.0] - 2026-03-06
### Added
- 5장: Voice Mode (`/voice`) 섹션 추가 — push-to-talk, 20개 언어, STT 무료
- 5장: `/simplify`, `/batch` 번들 슬래시 커맨드 섹션 추가
- 5장: `/copy` 코드 블록 피커 기능 설명 보강
- 8장: Opus 4.6 기본 노력 수준 medium, "ultrathink" 키워드 설명
- 10장: `sandbox.enableWeakerNetworkIsolation`, `includeGitInstructions` 설정 키
- 10장: `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS`, `ENABLE_CLAUDEAI_MCP_SERVERS` 환경 변수
- 13장: Auto-memory 자동 저장, worktree 간 프로젝트 설정/메모리 공유
- 20장: `InstructionsLoaded` 훅 이벤트, `agent_id`/`agent_type` 공통 필드
- 25장: `git-subdir` 소스 타입, `pathPattern`, `/reload-plugins`, `pluginTrustMessage`
- 용어집: Voice Mode, Ultrathink 용어 추가
- CLI 레퍼런스: 신규 환경 변수 2개

## [0.4.0] - 2026-02-28
### Added
- 17장: Remote Control 섹션 추가 (모바일/웹 원격 제어, 보안 모델, 요구사항, 제한사항)
- 20장: HTTP 훅 타입 추가 (`type: "http"`, URL/헤더/환경변수 보간), 10개 신규 이벤트 추가 (총 17개)
- CLI 레퍼런스: `claude auth` 서브커맨드 (login/status/logout), `--worktree` 플래그
- 15장: `--worktree` CLI 플래그 사용법 추가
- 22장: 서브에이전트 Worktree 격리 (`isolation: worktree`) 섹션 추가
- 용어집: Remote Control 용어 추가
### Changed
- Sonnet 4.5 → Sonnet 4.6 전체 업데이트 (모델 ID, 별칭, 가격표, 클라우드 프로바이더 등 8개 파일)

## [0.3.0] - 2026-02-25
### Changed
- 25장 플러그인 챕터를 공식 문서 기반으로 전면 수정
  - `.claude-plugin/plugin.json` 매니페스트 구조, `name@marketplace` 설치 문법, `/plugin` 슬래시 커맨드
  - `marketplace.json` 스키마, 소스 유형, 공식 마켓플레이스(`claude-plugins-official`) 소개
  - `extraKnownMarketplaces`, `enabledPlugins` 맵 형식, `hostPattern` 엔터프라이즈 설정
- CLI 레퍼런스, 엔터프라이즈, settings.json, Rules, 용어집 교차 참조 동기화

## [0.2.0] - 2026-02-25
### Added
- 25장: 플러그인 챕터 신규 추가 (플러그인 구조, 설치/관리, 마켓플레이스, 엔터프라이즈 관리, 실전 예제)
- 플러그인 관련 교차 참조 추가 (Skills, CLI 레퍼런스, 엔터프라이즈, Rules, 슬래시 커맨드)
### Changed
- 챕터 번호 재정렬: 25장 삽입으로 기존 25~33장이 26~34장으로 변경
- README.md 목차 업데이트

## [0.1.0] - 2026-02-11
### Added
- 프로젝트 초기 구조 설정
- 목차 및 챕터 구성
