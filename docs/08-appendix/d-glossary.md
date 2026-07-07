<!-- last_updated: 2026-07-07 -->

# 부록 D: 용어집

> Claude Code 관련 주요 용어를 정리합니다.

---

| 용어 | 설명 |
|------|------|
| **Agent Teams** | 여러 Claude 세션이 병렬로 협력하는 실험적 기능. 공유 태스크 리스트와 직접 메시징 지원. `TeamCreate`/`TeamDelete` 도구는 제거되어(2.1.178) 이제 암묵적 단일 팀으로 동작하며, `team_name` 파라미터는 수용되나 무시됨 |
| **Agent View** | `claude agents`로 실행 중인 모든 세션(인터랙티브+백그라운드)을 한 화면에서 관리하는 연구 프리뷰. `--json`으로 스크립팅 가능 |
| **Agentic Loop** | Claude Code의 핵심 실행 주기: 컨텍스트 수집 → 행동 → 검증 |
| **Auto Mode** | `/model auto` — 작업 난이도와 사용량 한도에 따라 Opus/Sonnet/Haiku를 자동 선택하는 모델 모드. Max 구독자 점진적 출시 |
| **Background Session** | `claude --bg`로 백그라운드에서 실행되는 세션. Agent View와 `/resume`에 `bg`로 표시되며 나중에 재개 가능 |
| **Channels** | 외부 메시징 플랫폼(Telegram, Discord)에서 실행 중인 세션으로 이벤트를 푸시하는 MCP 서버 기반 기능. `--channels` 플래그로 활성화 |
| **Checkpoint** | 파일 수정 전 자동 생성되는 스냅샷. `/rewind`로 복원 가능. 30일 보관 |
| **CLAUDE.md** | 프로젝트별 영구 지침 파일. 세션 시작 시 자동 로드 |
| **Compact** | 대화 이력을 압축하여 컨텍스트 공간 확보. `/compact` 명령어 |
| **Context Window** | Claude가 한 번에 처리할 수 있는 토큰의 총량 (200K 또는 1M) |
| **Dynamic Workflows** | Claude에게 워크플로우 생성을 요청하면 수십~수백 개의 에이전트를 백그라운드에서 오케스트레이션하는 기능 (2.1.154). `/workflows`로 실행 목록 확인. 트리거 키워드는 2.1.160에서 `workflow` → **`ultracode`**로 변경되었고, 워크플로우 크기 권고치는 `/config`의 "Dynamic workflow size"로 조절 (2.1.202) |
| **Effort Level** | Extended Thinking의 추론 깊이 제어. ○ Low, ◐ Medium, ● High, ⬤ xHigh 네 단계 (기본 high, xHigh는 가장 어려운 작업 권장). `/effort` 슬라이더(레이블 "Faster"/"Smarter") 또는 모델 선택기에서 조절 |
| **Elicitation** | MCP 서버가 사용자에게 추가 정보를 요청하는 메커니즘. `Elicitation`/`ElicitationResult` 훅 이벤트로 제어 가능 |
| **Extended Thinking** | Claude가 응답 전 내부적으로 추론하는 기능. Opus는 적응형 |
| **Fable 5** | Claude Fable 5 (2.1.170). API ID `claude-fable-5`, "Mythos-class" 모델, GA 2026-06-09, $10/$50, 1M 컨텍스트, adaptive thinking 상시 활성. Anthropic이 널리 공개한 모델 중 최고 능력 |
| **Fast Mode** | 동일한 모델에서 빠른 출력을 제공하는 모드. `/fast` 토글. 기본 **Opus 4.8**(2.1.154)로 표준 요금의 2배에 2.5배 빠른 출력. (`CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE`는 폐지 후 2.1.160에서 제거되어 no-op) |
| **Fork** | 세션을 복사하여 독립적으로 진행. `--fork-session` |
| **Goal** | `/goal` — 완료 조건을 설정하면 Claude가 충족될 때까지 여러 턴에 걸쳐 자율 진행. `/loop`(간격 기반)와 대비되는 조건 기반 자동화 |
| **Headless Mode** | `-p` 플래그로 실행하는 비대화형 모드 |
| **Lean System Prompt** | Haiku, Sonnet, Opus 4.7 이하를 제외한 모든 모델에서 기본 적용되는 간결한 시스템 프롬프트 (2.1.154). 컨텍스트 여유 증가 |
| **Hooks** | 이벤트에 반응하는 자동화 시스템 (PreToolUse, PostToolUse 등) |
| **Loop** | `/loop`로 프롬프트를 반복 실행하는 스케줄링 기능. 시간 간격 또는 Cron 표현식 지원 |
| **Mantle** | Amazon Bedrock의 대안 런타임. `CLAUDE_CODE_USE_MANTLE=1`로 활성화 |
| **Marketplace** | 플러그인 카탈로그. `.claude-plugin/marketplace.json`으로 정의. `claude-plugins-official`이 기본 제공 |
| **MCP** | Model Context Protocol. AI 도구 통합을 위한 오픈 소스 표준 |
| **Memory** | `~/.claude/projects/<hash>/memory/`의 자동 메모리 시스템 |
| **Monitor** | 백그라운드 스크립트의 스트리밍 이벤트를 수신하는 도구 |
| **Native Binary** | 2.1.113부터 Claude Code가 플랫폼별 네이티브 바이너리로 실행됨 (번들 JS 대체). 시작 시간 단축 |
| **Opus 4.8** | 2026-05 출시된 Opus 모델 (2.1.154). 2.1.197에서 Sonnet 5에 기본 모델 자리를 넘겨주고 **복잡 에이전틱 코딩·엔터프라이즈 권장 모델**로 유지. 기본 노력 수준 high, xHigh 지원, Lean 시스템 프롬프트 적용 |
| **Opus 4.7** | 2026-04 출시된 이전 세대 Opus 모델. Opus 4.8 출시 전 기본. xHigh 노력 수준 지원 |
| **Opusplan** | Opus(추론)과 Sonnet 4.6(도구)을 결합한 하이브리드 모드 |
| **Permission Mode** | 도구 실행 권한을 제어하는 모드 (Default, Plan, Accept Edits 등) |
| **Plan Mode** | 읽기 전용 분석 모드. 코드를 변경하지 않고 탐색만 수행 |
| **Plugin** | Claude Code의 기능을 확장하는 패키지. `.claude-plugin/plugin.json`으로 정의하며 `name@marketplace` 형식으로 설치 |
| **Prompt Caching** | 반복 전송되는 콘텐츠를 캐싱하여 비용과 지연 시간 절감 |
| **Remote Control** | 로컬 세션을 모바일/웹 브라우저에서 원격 제어하는 기능. `/rc` 또는 `claude remote-control`. Max 플랜 필요 |
| **Remote Session** | Anthropic 클라우드에서 실행되는 세션. `--remote` 플래그 또는 웹 인터페이스에서 사용 |
| **Rules** | `.claude/rules/`의 모듈식 지침 파일. 경로 조건 지정 가능 |
| **Sandbox** | OS 수준에서 실행 환경을 격리하는 보안 메커니즘 |
| **Session** | Claude와의 하나의 대화 단위. 자동 저장되며 재개 가능 |
| **Skills** | SKILL.md로 정의하는 커스텀 슬래시 커맨드 |
| **Sonnet 5** | Claude Sonnet 5 (2.1.197). API ID `claude-sonnet-5`, Claude Code **새 기본 모델**. 네이티브 1M 컨텍스트, 기본 노력 수준 high, $3/$15(도입가 $2/$10, ~2026-08-31). "속도와 지능의 최적 균형" |
| **Subagent** | 격리된 컨텍스트에서 전문 작업을 수행하는 하위 Claude 인스턴스 |
| **Teleport** | 웹 세션을 로컬 터미널로 이전하는 기능 |
| **Tool Search** | MCP 도구가 컨텍스트의 10% 초과 시 자동 활성화되는 동적 도구 검색 메커니즘 |
| **Tool Specifier** | 권한 규칙에서 도구를 지정하는 패턴 (예: `Bash(npm run *)`) |
| **Transcript** | Claude의 내부 사고 과정과 도구 사용을 표시하는 상세 로그. `Ctrl+O`로 토글, `/`로 검색 |
| **TUI** | `/tui` 또는 `--tui`로 활성화하는 풀스크린 터미널 UI. `autoScrollEnabled` 설정으로 스크롤 동작 제어 |
| **Ultracode** | 다이나믹 워크플로우 트리거 키워드이자 `/effort`의 최상위 노력 레벨 (2.1.160, 이전 이름 `workflow`). `/effort ultracode`는 xHigh를 지원하는 모델에서만 제공되며 다이나믹 워크플로우를 발동 |
| **Ultraplan** | `/ultraplan` — 복잡한 기능/마이그레이션을 위한 단계별 계획과 클라우드 워크스페이스 자동 구성 |
| **Ultrareview** | `/ultrareview` — Anthropic 클라우드의 다중 에이전트 함대가 병렬로 PR/브랜치를 리뷰하는 사용자 트리거 기능 (별도 과금) |
| **Ultrathink** | 프롬프트에 포함하면 다음 턴에 Opus의 high effort가 활성화되는 키워드 |
| **Voice Mode** | `/voice`로 활성화하는 음성 입력 모드. 스페이스바 push-to-talk으로 프롬프트 입력 |
| **Worktree** | Git의 기능으로, 하나의 저장소에서 여러 작업 디렉토리를 동시에 유지 |
