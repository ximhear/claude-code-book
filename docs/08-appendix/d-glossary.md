<!-- last_updated: 2026-02-11 -->

# 부록 D: 용어집

> Claude Code 관련 주요 용어를 정리합니다.

---

| 용어 | 설명 |
|------|------|
| **Agent Teams** | 여러 Claude 세션이 병렬로 협력하는 실험적 기능. 공유 태스크 리스트와 직접 메시징 지원 |
| **Agentic Loop** | Claude Code의 핵심 실행 주기: 컨텍스트 수집 → 행동 → 검증 |
| **CLAUDE.md** | 프로젝트별 영구 지침 파일. 세션 시작 시 자동 로드 |
| **Checkpoint** | 파일 수정 전 자동 생성되는 스냅샷. `/rewind`로 복원 가능. 30일 보관 |
| **Compact** | 대화 이력을 압축하여 컨텍스트 공간 확보. `/compact` 명령어 |
| **Context Window** | Claude가 한 번에 처리할 수 있는 토큰의 총량 (200K 또는 1M) |
| **Effort Level** | Extended Thinking의 추론 깊이 제어. Low, Medium, High 세 단계. 모델 선택기에서 조절 |
| **Extended Thinking** | Claude가 응답 전 내부적으로 추론하는 기능. Opus는 적응형 |
| **Fast Mode** | 동일한 모델에서 빠른 출력을 제공하는 모드. `/fast` 토글 |
| **Fork** | 세션을 복사하여 독립적으로 진행. `--fork-session` |
| **Headless Mode** | `-p` 플래그로 실행하는 비대화형 모드 |
| **Hooks** | 이벤트에 반응하는 자동화 시스템 (PreToolUse, PostToolUse 등) |
| **MCP** | Model Context Protocol. AI 도구 통합을 위한 오픈 소스 표준 |
| **Memory** | `~/.claude/projects/<hash>/memory/`의 자동 메모리 시스템 |
| **Opusplan** | Opus 4.6 (추론)과 Sonnet 4.5 (도구)를 결합한 하이브리드 모드 |
| **Permission Mode** | 도구 실행 권한을 제어하는 모드 (Default, Plan, Accept Edits 등) |
| **Plan Mode** | 읽기 전용 분석 모드. 코드를 변경하지 않고 탐색만 수행 |
| **Plugin** | Claude Code의 기능을 확장하는 패키지. 스킬, 에이전트, 훅 포함 |
| **Prompt Caching** | 반복 전송되는 콘텐츠를 캐싱하여 비용과 지연 시간 절감 |
| **Remote Session** | Anthropic 클라우드에서 실행되는 세션. `--remote` 플래그 또는 웹 인터페이스에서 사용 |
| **Rules** | `.claude/rules/`의 모듈식 지침 파일. 경로 조건 지정 가능 |
| **Sandbox** | OS 수준에서 실행 환경을 격리하는 보안 메커니즘 |
| **Session** | Claude와의 하나의 대화 단위. 자동 저장되며 재개 가능 |
| **Skills** | SKILL.md로 정의하는 커스텀 슬래시 커맨드 |
| **Subagent** | 격리된 컨텍스트에서 전문 작업을 수행하는 하위 Claude 인스턴스 |
| **Teleport** | 웹 세션을 로컬 터미널로 이전하는 기능 |
| **Tool Search** | MCP 도구가 컨텍스트의 10% 초과 시 자동 활성화되는 동적 도구 검색 메커니즘 |
| **Tool Specifier** | 권한 규칙에서 도구를 지정하는 패턴 (예: `Bash(npm run *)`) |
| **Transcript** | Claude의 내부 사고 과정과 도구 사용을 표시하는 상세 로그. `Ctrl+O`로 토글 |
| **Worktree** | Git의 기능으로, 하나의 저장소에서 여러 작업 디렉토리를 동시에 유지 |
