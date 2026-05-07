<!-- last_updated: 2026-05-07 -->

# 5. 슬래시 커맨드 완전 가이드

> 모든 빌트인 슬래시 커맨드와 커스텀 스킬 커맨드의 사용법을 분류별로 정리합니다.

---

## 슬래시 커맨드 개요

Claude Code에서 `/`를 입력하면 사용 가능한 슬래시 커맨드 목록이 표시됩니다. 슬래시 커맨드는 두 종류입니다:

1. **빌트인 커맨드** — Claude Code에 내장된 명령어
2. **스킬 커맨드** — 사용자가 정의한 커스텀 명령어 (Skills 시스템)

```
> /          ← 전체 목록 표시
> /co        ← 'co'로 시작하는 명령어 필터링 (compact, config, copy, cost)
```

---

## 세션 관리

### `/clear` — 대화 초기화

현재 대화 히스토리를 비우고 새로운 대화를 시작합니다.

```
> /clear
```

- 세션 자체는 유지됩니다 (Claude Code를 종료하지 않음)
- 이전 대화의 컨텍스트가 모두 사라지므로 비용을 절약할 수 있습니다
- Git 상태, CLAUDE.md 등 환경 컨텍스트는 새 대화에서 다시 로드됩니다

### `/compact` — 컨텍스트 압축

대화 히스토리를 요약하여 토큰 사용량을 줄입니다.

```
> /compact
> /compact 인증 관련 내용만 유지해줘
```

- 선택적으로 **포커스 지침**을 인자로 전달하여 어떤 내용을 유지할지 지시할 수 있습니다
- 긴 세션에서 컨텍스트 윈도우 한계에 근접할 때 유용합니다
- Claude Code는 컨텍스트 한계 도달 시 자동으로 압축을 수행하기도 합니다

### `/resume` — 이전 세션 재개

이전 세션을 재개하거나 세션 선택 화면을 엽니다.

```
> /resume
> /resume auth-refactor
```

- 인자 없이 사용하면 세션 목록에서 선택할 수 있습니다
- 세션 이름이나 ID를 지정하면 해당 세션으로 바로 이동합니다
- CLI에서는 `claude --resume <name>` 또는 `claude --continue`로도 가능합니다

### `/rename` — 세션 이름 변경

현재 세션의 이름을 변경하여 나중에 쉽게 찾을 수 있게 합니다.

```
> /rename auth-refactor
```

### `/rewind` — 대화 되돌리기

대화를 특정 시점으로 되돌리거나 요약을 생성합니다.

```
> /rewind
```

- 이전 메시지 중 하나를 선택하여 해당 시점으로 되돌릴 수 있습니다
- 코드 변경도 함께 되돌릴 수 있습니다 (체크포인트 활용)
- `/undo`를 별칭으로 사용할 수 있습니다

### `/branch` — 세션 분기

현재 세션을 분기하여 독립적인 새 세션을 생성합니다.

```
> /branch
```

- 현재 대화 히스토리를 복사한 새 세션이 생성됩니다
- 원본 세션은 영향받지 않습니다
- 이전 이름인 `/fork`도 별칭으로 계속 사용 가능합니다

### `/teleport` — 원격 세션 재개

Claude.ai 웹에서 진행 중인 세션을 로컬 Claude Code로 가져옵니다.

```
> /teleport
```

- 구독자 전용 기능입니다 (Pro/Max/Teams)
- 웹에서 시작한 대화를 터미널로 이어서 작업할 때 유용합니다

---

## 설정 및 구성

### `/config` — 설정 인터페이스

전체 설정 화면을 엽니다.

```
> /config
```

설정 가능한 항목:
- 테마, 모델, Extended Thinking 토글
- 알림, 프롬프트 제안 활성화/비활성화
- 그 외 전역 설정

### `/model` — 모델 전환

AI 모델을 선택하거나 변경합니다.

```
> /model
> /model opus
> /model sonnet
> /model haiku
> /model opusplan
> /model sonnet[1m]
```

- 인자 없이 사용하면 모델 선택 화면이 나타납니다
- Opus 4.6 선택 시 좌/우 화살표로 **노력 수준** (effort level)을 조절할 수 있습니다
- 변경은 즉시 적용됩니다

> 자세한 내용은 [8장: 모델 선택과 전환](04-model-selection.md)에서 다룹니다.

### `/permissions` — 권한 관리

도구별 권한 규칙을 확인하고 수정합니다.

```
> /permissions
```

- Allow / Deny 규칙을 관리합니다
- 세밀한 도구 지정자 (tool specifier) 문법을 지원합니다

> 자세한 내용은 [10장: 권한 시스템](../03-configuration/02-permissions.md)에서 다룹니다.

### `/vim` — Vim 모드

Vim 스타일 키 바인딩을 활성화합니다.

```
> /vim
```

- Normal, Insert, Visual 모드를 지원합니다
- `i`로 입력 모드, `Esc`로 일반 모드

### `/terminal-setup` — 터미널 최적화

터미널 설정을 최적화합니다.

```
> /terminal-setup
```

- Shift+Enter 멀티라인 입력 설정
- 키 바인딩 호환성 구성
- Option/Alt+T (Extended Thinking 토글) 활성화에 필요

### `/theme` — 테마 변경 / 커스텀 테마

색상 테마를 선택, 생성, 편집합니다.

```
> /theme
> /theme create my-pastel
```

- 인터랙티브 테마 선택기가 나타납니다
- **"Auto (match terminal)"** 옵션을 선택하면 터미널의 light/dark 모드에 자동 맞춤
- **커스텀 테마**: `~/.claude/themes/<name>.json`에 색상 팔레트를 정의하면 선택기에 노출됩니다
- 플러그인이 `themes/` 디렉토리로 테마를 배포할 수 있습니다 (플러그인 매니페스트 `experimental` 블록)
- Remote Control과 연동되어 터미널/`claude.ai` 양쪽 색상이 동기화됩니다 (`/color` 사용)

### `/color` — 색상 변경

터미널 테마 색상을 변경합니다.

```
> /color
> /color reset
> /color default
> /color gray
> /color none
```

- 인자 없이 사용하면 색상 선택기가 나타납니다
- `reset`, `default`, `gray`, `none`으로 기본 색상으로 되돌릴 수 있습니다

### `/effort` — 노력 수준 변경

현재 모델의 노력 수준(effort level)을 직접 변경합니다.

```
> /effort
> /effort xhigh
> /effort high
> /effort medium
> /effort low
> /effort auto
```

- 인자 없이 사용하면 **인터랙티브 슬라이더**가 표시됩니다 (좌/우 화살표로 조절)
- `low`, `medium`, `high`, `xhigh`, `auto` 중 하나를 지정하여 즉시 변경합니다
- 시각적 표시: ○ low, ◐ medium, ● high, ⬤ xhigh
- **xhigh**는 Opus 4.7 전용으로 코딩 작업에 권장되는 수준입니다
- `auto`로 두면 작업에 따라 효율적인 수준이 자동 선택됩니다
- 모델 선택기의 좌/우 화살표와 동일한 효과입니다
- Claude가 응답 중에도 변경할 수 있습니다

### `/tui` — 풀스크린 TUI 토글

전체 화면(fullscreen) 인터페이스를 켜거나 끕니다.

```
> /tui
```

- `tui` 설정 키 또는 `--tui` 플래그로 시작 시점부터 활성화할 수 있습니다
- `autoScrollEnabled` 설정으로 자동 스크롤 동작을 제어합니다
- 풀스크린에서는 위쪽 출력으로 스크롤한 채 입력해도 화면이 점프하지 않습니다

### `/focus` — 포커스 모드

집중 모드에서 응답 영역만 표시합니다.

```
> /focus
```

- 이전에는 옵션이었던 동작이 별도 명령어로 분리되었습니다
- 포커스 모드 중에도 세션 리캡, 상태 표시줄이 보이도록 개선되었습니다

### `/statusline` — 상태 표시줄 설정

하단 상태 표시줄의 UI를 설정합니다.

```
> /statusline
```

---

## 프로젝트 및 작업

### `/init` — CLAUDE.md 생성

프로젝트 초기화 가이드를 실행하여 CLAUDE.md 파일을 생성합니다.

```
> /init
```

- Claude가 프로젝트를 분석하고 적절한 CLAUDE.md 초안을 제안합니다
- 빌드 명령어, 코딩 규칙, 디렉토리 구조 등을 포함합니다

> 자세한 내용은 [9장: CLAUDE.md 설정](../03-configuration/01-claude-md.md)에서 다룹니다.

### `/review` — PR 리뷰

현재 브랜치의 풀 리퀘스트를 리뷰합니다.

```
> /review
```

- Git diff를 분석하고 코드 리뷰를 수행합니다
- 버그, 보안 문제, 코드 품질 등을 검사합니다

### `/pr-comments` — PR 코멘트 가져오기

GitHub 풀 리퀘스트의 리뷰 코멘트를 가져옵니다.

```
> /pr-comments
```

- `gh` CLI가 설치되어 있어야 합니다

### `/add-dir` — 작업 디렉토리 추가

추가 작업 디렉토리를 등록합니다.

```
> /add-dir ../shared-lib
> /add-dir ~/other-project/src
```

- 여러 프로젝트를 동시에 참조해야 할 때 유용합니다
- CLI에서는 `claude --add-dir ../apps --add-dir ../lib`으로도 가능합니다

### `/plan` — Plan 모드 진입

Plan 모드로 전환합니다.

```
> /plan
> /plan fix the auth bug
```

- 읽기 전용 도구만 사용하여 코드베이스를 분석합니다
- 실제 변경 없이 계획을 수립할 때 사용합니다
- **설명 인자**를 전달하면 즉시 Plan 모드에 진입하여 해당 주제로 분석을 시작합니다
- Shift+Tab 두 번으로도 진입할 수 있습니다

---

## 정보 및 진단

### `/help` — 도움말

사용 가능한 모든 명령어와 키보드 단축키를 표시합니다.

```
> /help
```

### `/usage` — 사용량 + 비용 통합 뷰 (`/cost`, `/stats` 별칭)

세션 비용, 구독 사용량 한도(5시간/주), 일별 통계, 모델별 사용 빈도, 사용량 드라이버를 하나의 화면에 표시합니다.

```
> /usage
> /cost     # 별칭
> /stats    # 별칭
```

출력 항목:
- **세션 비용**: API 비용, 입출력 토큰, 코드 변경량
- **구독 사용량**: 5시간/주 단위 한도와 잔여량 (Pro/Max/Team/Enterprise)
- **사용 통계**: 일별 사용량, 세션 히스토리, 연속 사용일, 모델별 사용 빈도
- **사용량 드라이버**: 어떤 작업이 한도 소비를 주도했는지 (Claude 4.7 / Week 16부터)

> **변경 사항**: 2.1.118부터 `/cost`와 `/stats`가 `/usage`로 통합되었습니다. 두 별칭은 그대로 사용 가능합니다.

### `/less-permission-prompts` — 권한 프롬프트 자동화 가이드

세션의 트랜스크립트를 분석해, 자주 묻는 권한 프롬프트를 자동 승인 규칙(allowlist)으로 등록할지 추천합니다.

```
> /less-permission-prompts
```

- 같은 도구 호출이 반복되는 패턴을 식별
- 안전한 패턴은 `permissions.allow`에 추가할 수 있도록 제안
- "프롬프트 피로(prompt fatigue)"를 줄이고 싶을 때 유용

### `/status` — 세션 상태

현재 세션의 상태 정보를 표시합니다 (버전, 모델, 계정, 연결 상태).

```
> /status
```

### `/doctor` — 환경 진단

Claude Code 설치 환경의 건강 상태를 검사합니다.

```
> /doctor
> /doctor --performance
```

검사 항목:
- 설치 유형과 버전
- 자동 업데이트 상태
- ripgrep 가용성
- 설정 파일 유효성
- MCP 서버 상태
- 키바인딩 설정
- 컨텍스트 사용량 경고

### `/context` — 컨텍스트 시각화

현재 컨텍스트 사용량을 시각적 그리드로 보여줍니다.

```
> /context
```

- 컨텍스트 윈도우가 얼마나 사용되었는지 한눈에 파악할 수 있습니다
- 스킬 예산 초과 경고도 확인할 수 있습니다

### `/debug` — 디버그 로그

세션 디버그 로그를 읽어 문제를 진단합니다.

```
> /debug
> /debug 응답이 갑자기 끊겼어
```

- 선택적으로 문제 설명을 인자로 전달할 수 있습니다

---

## 유틸리티

### `/export` — 대화 내보내기

현재 대화를 파일이나 클립보드로 내보냅니다.

```
> /export
> /export conversation.md
```

### `/copy` — 응답 복사

Claude의 응답을 클립보드에 복사합니다.

```
> /copy
> /copy 3
```

- 인자 없이 사용하면 **마지막 응답**을 복사합니다
- 숫자 인덱스 `N`을 지정하면 **N번째 이전 응답**을 복사합니다

- 응답에 **코드 블록**이 있으면 인터랙티브 피커가 표시됩니다
- 개별 코드 블록을 선택하거나 전체 응답을 복사할 수 있습니다
- "Always copy full response" 옵션을 선택하면 이후 `/copy`에서 피커를 건너뜁니다
- **`w` 키**를 누르면 선택한 코드 블록을 파일에 직접 쓸 수 있습니다 (SSH 환경에서 클립보드 없이 유용)

### `/tasks` — 백그라운드 태스크

백그라운드에서 실행 중인 태스크를 나열하고 관리합니다.

```
> /tasks
```

### `/todos` — TODO 목록

현재 TODO 항목을 나열합니다.

```
> /todos
```

### `/memory` — 메모리 편집

CLAUDE.md 메모리 파일을 직접 편집합니다.

```
> /memory
```

- 프로젝트별 또는 전역 메모리를 수정할 수 있습니다

### `/mcp` — MCP 서버 관리

MCP 서버 연결과 OAuth 인증을 관리합니다.

```
> /mcp
```

> 자세한 내용은 [21장: MCP 서버 통합](../05-advanced/03-mcp-servers.md)에서 다룹니다.

---

## 음성 입력

### `/voice` — Voice Mode

음성으로 프롬프트를 입력하는 Voice Mode를 토글합니다.

```
> /voice
```

**사용 방법:**

1. `/voice`를 입력하여 Voice Mode 활성화
2. **스페이스바를 길게 누르고** 말하기 (push-to-talk)
3. 스페이스바를 놓으면 음성이 전사되어 입력창에 삽입

```
스페이스바 누름 → 말하기 → 스페이스바 놓음 → 텍스트 변환 → 입력창에 삽입
```

- 음성 전사(STT) 토큰은 **무료**입니다
- 키보드 입력과 병행할 수 있습니다 (음성이 커서 위치에 삽입)
- 항상 듣기(always-listening) 모드는 없습니다 — push-to-talk만 지원
- push-to-talk 키를 변경하려면 `~/.claude/keybindings.json`에서 `voice:pushToTalk`을 재설정합니다
- **20개 언어** 지원: 영어, 한국어, 일본어, 중국어, 스페인어, 프랑스어, 독일어, 포르투갈어, 이탈리아어, 힌디어, 러시아어, 폴란드어, 터키어, 네덜란드어, 우크라이나어, 그리스어, 체코어, 덴마크어, 스웨덴어, 노르웨이어
- Pro/Max/Team/Enterprise 구독자 사용 가능

> **참고**: Voice Mode는 2026년 3월부터 점진적으로 롤아웃되고 있습니다. 사용 가능 여부는 시작 화면에서 확인할 수 있습니다.

---

## 자동화

### `/loop` — 반복 프롬프트 실행 (`/proactive` 별칭)

프롬프트나 슬래시 커맨드를 정해진 간격으로 반복 실행합니다.

```
> /loop 5m check the deploy
> /loop 30m /review
> /loop cron "0 */2 * * *" check deploy status
> /loop cancel
```

- 기본 간격은 **10분**입니다
- `5m`, `30m`, `1h` 등 시간 단위를 지정할 수 있습니다 (`s` 초, `m` 분, `h` 시간, `d` 일)
- **Cron 스케줄링**: `cron` 키워드와 Cron 표현식으로 정밀한 스케줄 설정
- `cancel`로 실행 중인 반복을 취소합니다
- 백그라운드에서 실행되며, 세션이 유지되는 동안 동작합니다
- `CLAUDE_CODE_DISABLE_CRON` 환경 변수로 Cron 스케줄링을 비활성화할 수 있습니다

**일회성 리마인더**도 자연어로 설정할 수 있습니다:

```
> remind me at 3pm to push the release branch
> in 45 minutes, check whether the integration tests passed
```

**주의사항:**

- 반복 태스크는 생성 후 **3일 뒤 자동 만료**됩니다
- 세션당 최대 **50개** 스케줄 태스크를 등록할 수 있습니다
- 세션 종료 시 모든 태스크가 사라집니다 (세션 범위)
- Claude가 응답 중이면 예약된 프롬프트가 현재 턴이 끝난 후 실행됩니다
- 내부적으로 `CronCreate`, `CronList`, `CronDelete` 도구를 사용합니다

---

## 번들 슬래시 커맨드

Anthropic이 유지보수하며 매 릴리스에 업데이트되는 **번들 커맨드**입니다.

### `/simplify` — 코드 품질 개선

최근 변경한 파일을 3개 병렬 에이전트로 리뷰한 후 자동 수정합니다.

```
> /simplify
> /simplify focus on memory efficiency
```

리뷰 에이전트 3개가 병렬로 실행됩니다:

| 에이전트 | 검사 항목 |
|----------|----------|
| **코드 재사용** | 중복 코드, 기존 유틸리티 활용 |
| **코드 품질** | 가독성, 일관성, 베스트 프랙티스 |
| **효율성** | 성능, 메모리, 불필요한 연산 |

- 선택적으로 포커스 지침을 전달하여 특정 관점에 집중할 수 있습니다
- 기능 구현이나 버그 수정 후 **마무리 단계**에서 사용하기 좋습니다

### `/batch` — 대규모 병렬 변경

코드베이스 전체에 걸친 대규모 변경을 병렬로 수행합니다.

```
> /batch 모든 API 엔드포인트에 rate limiting 추가
```

**실행 과정:**

```
1. 코드베이스 분석
2. 작업을 5~30개 독립 단위로 분해
3. 계획을 사용자에게 제시 → 승인
4. 단위별 에이전트를 독립 worktree에서 병렬 실행
5. 각 에이전트가 구현 → 테스트 → PR 생성
```

- 각 에이전트는 **격리된 Git worktree**에서 작업하므로 서로 간섭하지 않습니다
- 대규모 마이그레이션, 일괄 리팩토링, API 변경 등에 적합합니다

### `/ultrareview` — 클라우드 멀티에이전트 코드 리뷰

현재 브랜치(또는 지정한 PR)를 Anthropic 클라우드의 다중 에이전트 함대가 병렬로 리뷰합니다.

```
> /ultrareview
> /ultrareview 1234            # GitHub PR 번호
> /ultrareview --target main   # 비교 대상 브랜치
```

- **공개 연구 프리뷰** (Week 17, 2026-04 출시), 사용자 트리거에 따라 별도 과금
- 로컬 브랜치를 번들링하여 클라우드에서 실행 (Git 저장소 필요)
- 비대화형으로 호출하려면 `claude ultrareview [target]` CLI를 사용
- 동일한 영역에 여러 검사를 **병렬 실행**해 결과를 합성

### `/ultraplan` — 클라우드 자동 환경 설계

복잡한 기능 또는 마이그레이션을 위한 단계별 계획과 함께 클라우드 워크스페이스를 자동 구성합니다.

```
> /ultraplan 결제 플로우 OAuth로 마이그레이션
```

- 분석 → 계획 수립 → 격리된 클라우드 환경에서 검증 단계까지 자동화
- 결과를 받아 "Refine with Ultraplan"으로 정제할 수 있습니다

### `/team-onboarding` — 팀 온보딩 가이드

로컬 Claude Code 사용 이력을 기반으로 팀원 온보딩 가이드를 생성합니다.

```
> /team-onboarding
```

- 프로젝트의 워크플로우, 규칙, 패턴을 분석하여 가이드 작성
- 새 팀원이 Claude Code를 빠르게 익힐 수 있도록 지원

### `/recap` — 세션 요약

현재 세션의 컨텍스트를 요약합니다.

```
> /recap
```

- 오래 자리를 비운 후 돌아왔을 때 유용합니다
- `/config`에서 자동 요약(Session Recap)을 활성화하면 75분 이상 비활성 후 자동 표시

### `/release-notes` — 릴리스 노트

Claude Code의 최신 릴리스 노트를 표시합니다.

```
> /release-notes
```

- 인터랙티브 버전 선택기로 특정 버전의 변경 내역을 확인

### `/powerup` — 기능 튜토리얼

Claude Code 기능의 인터랙티브 튜토리얼을 실행합니다.

```
> /powerup
```

- 애니메이션 데모와 함께 기능을 학습

---

## 인증

### `/login` — 로그인

Claude 계정으로 인증합니다.

```
> /login
```

- 브라우저가 열리며 로그인 페이지로 이동합니다

### `/logout` — 로그아웃

현재 인증을 해제합니다.

```
> /logout
```

---

## 빌트인 커맨드 요약 테이블

| 분류 | 명령어 | 인자 | 설명 |
|------|--------|------|------|
| **세션** | `/clear` | — | 대화 초기화 |
| | `/compact` | `[지침]` | 컨텍스트 압축 |
| | `/resume` | `[세션명]` | 이전 세션 재개 |
| | `/rename` | `<이름>` | 세션 이름 변경 |
| | `/rewind` | — | 대화 되돌리기 (`/undo` 별칭) |
| | `/branch` | — | 세션 분기 (`/fork` 별칭) |
| | `/teleport` | — | 원격 세션 가져오기 |
| **설정** | `/config` | — | 설정 화면 |
| | `/model` | `[모델명\|auto]` | 모델 전환 |
| | `/permissions` | — | 권한 관리 |
| | `/vim` | — | Vim 모드 토글 (visual `v`/`V` 지원) |
| | `/terminal-setup` | — | 터미널 최적화 |
| | `/theme` | `[create <name>]` | 테마 선택/생성 (커스텀 테마 지원) |
| | `/color` | `[reset\|default\|gray\|none]` | 색상 변경/리셋 |
| | `/effort` | `[low\|medium\|high\|xhigh\|auto]` | 노력 수준 변경 (슬라이더 UI) |
| | `/statusline` | — | 상태 표시줄 설정 |
| | `/tui` | — | 풀스크린 TUI 토글 |
| | `/focus` | — | 포커스 모드 |
| **작업** | `/init` | — | CLAUDE.md 생성 |
| | `/review` | — | PR 리뷰 |
| | `/pr-comments` | — | PR 코멘트 가져오기 |
| | `/add-dir` | `<경로>` | 작업 디렉토리 추가 |
| | `/plan` | `[설명]` | Plan 모드 진입 |
| **정보** | `/help` | — | 도움말 |
| | `/usage` | — | 비용+사용량+통계 통합 (`/cost`, `/stats` 별칭) |
| | `/status` | — | 세션 상태 |
| | `/doctor` | `[--performance]` | 환경 진단 |
| | `/context` | — | 컨텍스트 시각화 |
| | `/debug` | `[설명]` | 디버그 로그 |
| | `/less-permission-prompts` | — | 권한 프롬프트 자동화 가이드 |
| **유틸리티** | `/export` | `[파일명]` | 대화 내보내기 |
| | `/copy` | `[N]` | 응답 복사 (코드 블록 피커) |
| | `/tasks` | — | 백그라운드 태스크 |
| | `/todos` | — | TODO 목록 |
| | `/memory` | — | 메모리 편집 |
| | `/mcp` | — | MCP 서버 관리 |
| **자동화** | `/loop` | `[간격] <프롬프트>` | 반복 프롬프트 실행 (`/proactive` 별칭) |
| **음성** | `/voice` | — | Voice Mode 토글 |
| **번들** | `/simplify` | `[포커스]` | 코드 품질 리뷰 + 자동 수정 |
| | `/batch` | `<설명>` | 대규모 병렬 변경 |
| | `/ultrareview` | `[PR번호\|--target br]` | 클라우드 멀티에이전트 코드 리뷰 |
| | `/ultraplan` | `<설명>` | 클라우드 자동 계획+환경 구성 |
| | `/team-onboarding` | — | 팀 온보딩 가이드 생성 |
| | `/recap` | — | 세션 컨텍스트 요약 |
| | `/release-notes` | — | 릴리스 노트 표시 |
| | `/powerup` | — | 기능 튜토리얼 |
| **인증** | `/login` | — | 로그인 |
| | `/logout` | — | 로그아웃 |
| **종료** | `/exit` | — | Claude Code 종료 |

---

## 커스텀 슬래시 커맨드 (Skills)

빌트인 커맨드 외에 자신만의 슬래시 커맨드를 만들 수 있습니다. 이것이 **Skills 시스템**입니다.

### 스킬 생성하기

스킬은 `SKILL.md` 파일로 정의합니다:

**개인 스킬** (모든 프로젝트에서 사용):
```
~/.claude/skills/<skill-name>/SKILL.md
```

**프로젝트 스킬** (해당 프로젝트에서만):
```
<project>/.claude/skills/<skill-name>/SKILL.md
```

### SKILL.md 구조

```yaml
---
name: review-code
description: 코드를 리뷰하고 버그와 품질 이슈를 찾습니다
---

코드를 리뷰해주세요:
1. 버그와 로직 에러
2. 보안 취약점
3. 코드 품질 이슈
4. 베스트 프랙티스 준수 여부
```

이 스킬은 `/review-code`로 호출됩니다.

### 프론트매터 필드

| 필드 | 필수 | 설명 |
|------|:----:|------|
| `name` | 아니오 | 커맨드 이름 (소문자, 숫자, 하이픈만 가능, 최대 64자). 생략 시 디렉토리명 사용 |
| `description` | 권장 | 스킬 설명. Claude가 자동 호출 여부를 결정할 때 참조 |
| `disable-model-invocation` | 아니오 | `true`이면 Claude가 자동으로 호출하지 않음. 기본: `false` |
| `user-invocable` | 아니오 | `false`이면 `/` 메뉴에서 숨김. 기본: `true` |
| `allowed-tools` | 아니오 | 스킬 활성 시 승인 없이 사용 가능한 도구 |
| `argument-hint` | 아니오 | 자동완성에 표시될 인자 힌트. 예: `[issue-number]` |
| `model` | 아니오 | 스킬 실행 시 사용할 모델 |
| `context` | 아니오 | `fork`로 설정하면 격리된 서브에이전트에서 실행 |
| `agent` | 아니오 | `context: fork` 시 사용할 에이전트 유형 |
| `hooks` | 아니오 | 스킬 라이프사이클에 한정된 훅 |
| `effort` | 아니오 | 스킬 실행 시 노력 수준 (`low`, `medium`, `high`) |

### 인자 전달

스킬에 인자를 전달할 수 있습니다:

```yaml
---
name: fix-issue
description: GitHub 이슈를 수정합니다
disable-model-invocation: true
---

GitHub 이슈 $ARGUMENTS를 코딩 규칙에 따라 수정해주세요.

1. 이슈 내용을 읽고 요구사항 파악
2. 수정 구현
3. 테스트 작성
4. 커밋 생성
```

```
> /fix-issue 123
```

Claude는 `$ARGUMENTS`를 `123`으로 치환하여 실행합니다.

개별 인자에 접근하려면 `$ARGUMENTS[0]` 또는 `$0`, `$1`, `$2` 형식을 사용합니다:

```yaml
---
name: migrate-component
description: 컴포넌트를 한 프레임워크에서 다른 프레임워크로 마이그레이션
---

$0 컴포넌트를 $1에서 $2로 마이그레이션해주세요.
기존 동작과 테스트를 모두 보존하세요.
```

```
> /migrate-component SearchBar React Vue
```

### 호출 모드 제어

| 설정 | 사용자 호출 | Claude 자동 호출 | 용도 |
|------|:----------:|:---------------:|------|
| 기본값 | O | O | 범용 커맨드 |
| `disable-model-invocation: true` | O | X | 배포, 커밋 등 부작용이 있는 작업 |
| `user-invocable: false` | X | O | 참조 지식용 (배경 정보) |

### 동적 컨텍스트 주입

`` !`command` `` 문법으로 셸 명령어 출력을 스킬에 주입할 수 있습니다:

```yaml
---
name: pr-summary
description: PR 변경 사항을 요약합니다
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## PR 컨텍스트
- PR diff: !`gh pr diff`
- PR 코멘트: !`gh pr view --comments`
- 변경 파일: !`gh pr diff --name-only`

## 작업
이 PR을 요약해주세요...
```

명령어는 Claude가 프롬프트를 받기 전에 실행되며, 출력이 해당 위치에 삽입됩니다.

### 서브에이전트에서 스킬 실행

`context: fork`를 추가하면 격리된 서브에이전트에서 스킬이 실행됩니다:

```yaml
---
name: deep-research
description: 주제를 심층 조사합니다
context: fork
agent: Explore
---

$ARGUMENTS를 심층 조사해주세요:

1. Glob과 Grep으로 관련 파일 찾기
2. 코드 분석
3. 파일 참조와 함께 결과 요약
```

**실행 흐름:**

```
사용자: /deep-research 인증 시스템

→ Claude가 격리된 서브에이전트 생성
→ 시스템 프롬프트: agent 필드의 에이전트 유형(Explore)이 정의하는 기본 프롬프트
→ 태스크(사용자 메시지): SKILL.md의 본문 ("$ARGUMENTS를 심층 조사해주세요...")
→ $ARGUMENTS가 "인증 시스템"으로 치환됨
→ CLAUDE.md가 추가 컨텍스트로 로드됨
→ 서브에이전트가 독립적으로 작업 수행 후 결과 반환
```

`context: fork` 스킬은 **SKILL.md 자체가 서브에이전트의 작업 지시서**가 됩니다.

서브에이전트의 `skills` 필드로 스킬을 프리로드하는 방식도 있습니다. 이 경우 서브에이전트의 마크다운 본문이 시스템 프롬프트가 되고, Claude가 서브에이전트에 위임하는 메시지가 태스크가 됩니다:

```
# .claude/agents/analyzer.md
---
skills:
  - deep-research
  - code-review
---

코드 분석 전문 에이전트입니다.
분석 요청을 받으면 프리로드된 스킬을 활용하여...
```

```
사용자: "이 모듈을 분석해줘"

→ Claude가 analyzer 서브에이전트에 위임
→ 시스템 프롬프트: analyzer.md의 본문 ("코드 분석 전문 에이전트입니다...")
→ 태스크(사용자 메시지): Claude가 작성한 위임 메시지 ("이 모듈을 분석해달라는 요청입니다...")
→ 프리로드된 스킬(deep-research, code-review) + CLAUDE.md가 추가 컨텍스트로 로드됨
```

**두 접근 방식 비교:**

| | `context: fork` 스킬 | 스킬을 프리로드한 서브에이전트 |
|---|---|---|
| **시스템 프롬프트** | `agent` 필드의 에이전트 유형이 제공 | 서브에이전트 마크다운(.md) 본문 |
| **태스크** | SKILL.md 본문 내용 | Claude의 위임 메시지 |
| **추가 컨텍스트** | CLAUDE.md | 프리로드된 스킬 + CLAUDE.md |
| **호출 방식** | `/skill-name` 슬래시 커맨드 | Claude가 자동으로 위임 |
| **적합한 용도** | 사용자가 직접 실행하는 단일 작업 | 복합 작업에서 스킬을 조합하는 에이전트 |

### 스킬 배포 범위

| 범위 | 위치 | 공유 방법 |
|------|------|-----------|
| **프로젝트** | `.claude/skills/` | 버전 관리에 커밋 |
| **플러그인** | 플러그인 내 `skills/` 디렉토리 | [플러그인으로 배포](../05-advanced/07-plugins.md) |
| **관리자 배포** | managed settings 경로 | 조직 전체에 배포 |

### 스킬 접근 제어

스킬 접근 제어는 Claude Code의 **권한 시스템** (`/permissions` 명령어 또는 `settings.json`의 `permissions`)에서 설정합니다. `Bash()`, `Read()` 등 다른 도구 권한과 동일한 문법을 사용합니다.

**허용 규칙 (allow):**

```
Skill(commit)         # "commit" 스킬만 정확히 허용
Skill(review-pr *)    # "review-pr"로 시작하는 모든 스킬 허용
                      # (review-pr, review-pr-comments 등)
```

**차단 규칙 (deny):**

```
Skill(deploy *)       # "deploy"로 시작하는 스킬 차단
Skill                 # 모든 스킬 실행 차단
```

**설정 예시 (settings.json):**

```json
{
  "permissions": {
    "allow": [
      "Skill(commit)",
      "Skill(review-pr *)"
    ],
    "deny": [
      "Skill(deploy *)"
    ]
  }
}
```

**문법 규칙:**

| 패턴 | 의미 | 예시 |
|------|------|------|
| `Skill(name)` | 정확히 해당 이름의 스킬만 매칭 | `Skill(commit)` → `commit`만 |
| `Skill(name *)` | 해당 접두사로 시작하는 모든 스킬 매칭 | `Skill(review *)` → `review`, `review-pr` 등 |
| `Skill` | 모든 스킬 매칭 (deny에 넣으면 전체 차단) | — |

> **참고**: 이 문법은 `Bash(npm *)`, `Read(src/*)` 같은 다른 도구 권한 규칙과 동일한 패턴입니다. 자세한 내용은 [10장: 권한 모드와 보안](../03-configuration/02-permissions.md)을 참조하세요.

---

## 실전 스킬 예제: 코드베이스 시각화

스킬은 Claude의 프롬프트뿐만 아니라 스크립트도 포함할 수 있습니다:

```
~/.claude/skills/codebase-visualizer/
├── SKILL.md
└── scripts/
    └── visualize.py
```

````yaml
# SKILL.md
---
name: codebase-visualizer
description: 코드베이스의 인터랙티브 트리 시각화를 생성합니다
allowed-tools: Bash(python *)
---

# Codebase Visualizer

프로젝트 루트에서 시각화 스크립트를 실행하세요:

```bash
python ~/.claude/skills/codebase-visualizer/scripts/visualize.py .
```

`codebase-map.html`이 생성되어 브라우저에서 열립니다.
````

이 패턴으로 의존성 그래프, 테스트 커버리지 보고서, API 문서, 데이터베이스 스키마 시각화 등 다양한 시각적 출력을 만들 수 있습니다.

---

## 스킬 트러블슈팅

### 스킬이 트리거되지 않음

1. `description`에 사용자가 자연스럽게 말할 키워드가 포함되어 있는지 확인
2. "어떤 스킬이 있어?" 라고 물어서 Claude가 인식하는지 확인
3. `/skill-name`으로 직접 호출 시도
4. 스킬 수가 많으면 컨텍스트 예산을 초과할 수 있음 — `/context`로 확인

### 스킬이 너무 자주 트리거됨

1. `description`을 더 구체적으로 작성
2. 수동 호출만 원한다면 `disable-model-invocation: true` 추가

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **빌트인 커맨드** | `/clear`, `/compact`, `/model`, `/config`, `/cost` 등 30개 이상 |
| **목록 표시** | `/` 입력 후 필터링 |
| **커스텀 커맨드** | `.claude/skills/<name>/SKILL.md`로 생성 |
| **인자 전달** | `$ARGUMENTS`, `$0`, `$1` 등 |
| **호출 제어** | `disable-model-invocation`, `user-invocable` |
| **서브에이전트** | `context: fork`로 격리 실행 |
| **배포** | 프로젝트, 플러그인, 관리자 설정으로 공유 |

---

## 다음 챕터

[6장: 도구(Tools) 시스템 이해하기](02-tools.md)에서 Claude Code가 사용하는 내장 도구의 동작 방식과 권한 체계를 배웁니다.
