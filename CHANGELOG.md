# Changelog

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
