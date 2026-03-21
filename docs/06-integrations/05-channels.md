<!-- last_updated: 2026-03-21 -->

# 30. Channels — 외부 플랫폼 연동

> Telegram, Discord 등 외부 메시징 플랫폼에서 실행 중인 Claude Code 세션으로 이벤트를 푸시하는 Channels 기능을 다룹니다.

---

## Channels란?

Channel은 **외부 플랫폼의 이벤트를 실행 중인 Claude Code 세션으로 푸시하는 MCP 서버**입니다. 기존 MCP 서버가 Claude의 요청에 응답하는 방식이라면, Channel은 반대로 외부에서 세션에 메시지를 밀어넣습니다.

```
Telegram / Discord  →  Channel (MCP 서버)  →  Claude Code 세션
                    ←  Claude 응답 전송     ←
```

- **양방향 통신**: 외부에서 메시지를 보내면 Claude가 읽고, 같은 채널을 통해 응답합니다
- **세션 기반**: 이벤트는 현재 열려 있는 세션에만 도착합니다 (상시 실행은 백그라운드 프로세스 필요)
- 플러그인으로 설치하고, 세션마다 `--channels` 플래그로 활성화합니다

> **참고**: Channels는 **research preview** 상태입니다 (v2.1.80+). `--channels` 플래그 문법과 프로토콜이 변경될 수 있습니다.

---

## 요구사항

| 항목 | 요구 사항 |
|------|-----------|
| **Claude Code 버전** | v2.1.80 이상 |
| **런타임** | [Bun](https://bun.sh) 설치 필요 (`bun --version`으로 확인) |
| **인증** | claude.ai 로그인 필수 (Console/API 키 인증 미지원) |
| **Team/Enterprise** | 관리자가 `channelsEnabled`를 명시적으로 활성화해야 함 |

---

## Telegram 연동

### 1단계: Telegram 봇 생성

1. Telegram에서 [BotFather](https://t.me/BotFather)를 열고 `/newbot` 전송
2. 봇 이름과 고유 사용자명(끝에 `bot` 필수)을 입력
3. BotFather가 반환하는 **토큰을 복사**

### 2단계: 플러그인 설치

```
> /plugin install telegram@claude-plugins-official
```

플러그인을 찾을 수 없다면 먼저 마켓플레이스를 추가합니다:

```
> /plugin marketplace add anthropics/claude-plugins-official
```

### 3단계: 토큰 설정

```
> /telegram:configure <봇_토큰>
```

토큰이 `~/.claude/channels/telegram/.env`에 저장됩니다. 또는 셸 환경 변수 `TELEGRAM_BOT_TOKEN`을 설정해도 됩니다.

### 4단계: 채널 활성화 후 재시작

Claude Code를 종료하고 `--channels` 플래그로 재시작합니다:

```bash
claude --channels plugin:telegram@claude-plugins-official
```

### 5단계: 페어링

1. Telegram에서 생성한 봇에게 아무 메시지를 전송
2. 봇이 **페어링 코드**를 응답
3. Claude Code에서 코드를 입력하여 페어링:

```
> /telegram:access pair <코드>
```

4. 보안을 위해 허용 목록(allowlist)을 활성화:

```
> /telegram:access policy allowlist
```

이제 Telegram에서 봇에게 메시지를 보내면 Claude Code 세션에 전달됩니다.

---

## Discord 연동

### 1단계: Discord 봇 생성

1. [Discord Developer Portal](https://discord.com/developers/applications)에서 **New Application** 클릭
2. **Bot** 섹션에서 토큰 생성 후 복사
3. **Privileged Gateway Intents**에서 **Message Content Intent** 활성화

### 2단계: 봇을 서버에 초대

**OAuth2 > URL Generator**에서 `bot` 스코프를 선택하고 다음 권한을 부여합니다:

- View Channels, Send Messages, Send Messages in Threads
- Read Message History, Attach Files, Add Reactions

생성된 URL로 봇을 서버에 추가합니다.

### 3단계: 플러그인 설치 및 설정

```
> /plugin install discord@claude-plugins-official
> /discord:configure <봇_토큰>
```

### 4단계: 채널 활성화 후 재시작

```bash
claude --channels plugin:discord@claude-plugins-official
```

### 5단계: 페어링

Discord에서 봇에게 DM → 페어링 코드 수신 → Claude Code에서 승인:

```
> /discord:access pair <코드>
> /discord:access policy allowlist
```

---

## 여러 채널 동시 사용

`--channels`에 공백으로 구분하여 여러 플러그인을 전달할 수 있습니다:

```bash
claude --channels plugin:telegram@claude-plugins-official plugin:discord@claude-plugins-official
```

---

## 보안 모델

| 보안 계층 | 설명 |
|-----------|------|
| **발신자 허용 목록** | 페어링된 계정만 메시지 전송 가능, 나머지는 무시 |
| **페어링 코드** | 최초 연결 시 일회성 코드로 인증 |
| **세션별 활성화** | `--channels` 플래그를 전달한 세션에서만 동작 |
| **플러그인 허용 목록** | research preview 중 Anthropic 승인 플러그인만 사용 가능 |

---

## 엔터프라이즈 관리

| 플랜 | 기본 동작 |
|------|-----------|
| **Pro / Max** (개인) | 사용 가능, `--channels`로 선택적 활성화 |
| **Team / Enterprise** | 기본 비활성화, 관리자가 명시적으로 활성화 필요 |

관리자는 **claude.ai > Admin settings > Claude Code > Channels** 또는 managed settings에서 `channelsEnabled: true`로 설정합니다.

---

## 다른 원격 기능과 비교

| 기능 | 동작 방식 | 적합한 용도 |
|------|-----------|-------------|
| **Channels** | 외부 이벤트를 세션에 푸시 | 모바일에서 질문, CI 웹훅 수신 |
| **Remote Control** | claude.ai/모바일에서 세션 조작 | 진행 중인 세션을 원격으로 조작 |
| **Claude Code on Web** | 클라우드 VM에서 실행 | 독립적인 비동기 작업 위임 |
| **MCP 서버** | Claude가 쿼리 시 응답 | 외부 시스템 읽기/쿼리 |

---

## 제한사항

- **Research preview**: `--channels` 문법과 프로토콜이 변경될 수 있습니다
- **세션 실행 중에만 동작**: Claude Code를 종료하면 채널도 중단됩니다
- **권한 승인 대기**: Claude가 권한 프롬프트에서 멈추면 로컬에서 승인해야 합니다
- **Anthropic 허용 플러그인만**: 커스텀 채널은 `--dangerously-load-development-channels`로 테스트
- **Telegram 제한**: Bot API는 메시지 이력과 검색을 제공하지 않음 — 봇은 실시간 수신만 가능

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **개요** | 외부 플랫폼에서 세션으로 이벤트를 푸시하는 MCP 서버 |
| **지원 플랫폼** | Telegram, Discord (research preview) |
| **설치** | `/plugin install telegram@claude-plugins-official` |
| **활성화** | `claude --channels plugin:telegram@...` |
| **보안** | 페어링 코드 + 발신자 허용 목록 |
| **엔터프라이즈** | `channelsEnabled` 관리 설정으로 제어 |

---

## 다음 파트

Part VII: 레시피에서 [31장: CLAUDE.md 템플릿](../07-recipes/01-claude-md-templates.md)을 통해 다양한 프로젝트 유형에 맞는 설정 예제를 배웁니다.
