<!-- last_updated: 2026-02-11 -->

# 26. IDE 통합 (VS Code, JetBrains, Desktop)

> 각 IDE와 데스크톱 앱에서의 Claude Code 사용법을 다룹니다.

---

## VS Code 확장

### 설치

VS Code Marketplace에서 **Claude Code** 확장을 설치합니다.

### 주요 기능

| 기능 | 설명 |
|------|------|
| **채팅 패널** | 사이드바에서 Claude와 대화 |
| **인라인 Diff** | 파일 변경 사항을 diff 뷰어로 표시 |
| **@-멘션** | `@파일명:줄번호`로 특정 코드 참조 |
| **여러 대화 탭** | 동시에 여러 대화 관리 |
| **Plan 리뷰** | 계획을 검토한 후 승인 |
| **Auto-Accept** | 편집 자동 승인 모드 |
| **대화 이력** | 이전 대화 검색과 재개 |

### 사용법

1. 사이드바의 Claude 아이콘 클릭
2. 채팅 패널에 요청 입력
3. 파일 변경 시 diff 뷰어에서 확인/승인
4. `@`로 파일이나 심볼을 직접 참조

---

## JetBrains 플러그인

### 지원 IDE

IntelliJ IDEA, PyCharm, WebStorm, GoLand, PHPStorm, Rider 등 모든 JetBrains IDE를 지원합니다.

### 설치

JetBrains Marketplace에서 **Claude Code [Beta]** 플러그인을 설치합니다.

### 특징

- IDE의 통합 터미널 내에서 CLI 실행
- 파일 변경 사항을 IDE의 diff 뷰어로 표시
- IDE의 프로젝트 구조와 통합

---

## Desktop 앱과 웹 환경

> **Claude 제품 구분**: 혼동하기 쉬운 4가지 제품을 정리합니다.
>
> | 제품 | 형태 | 용도 |
> |------|------|------|
> | **Claude Code** | 터미널 CLI | 로컬에서 코드 작업 (이 책의 주제) |
> | **Claude Desktop** | 데스크톱 앱 | GUI로 여러 Claude Code 세션 관리 |
> | **Claude.ai** | 웹 채팅 | 범용 AI 대화 (코딩 특화 아님) |
> | **Claude Code on the Web** | 클라우드 VM | 브라우저에서 Claude Code 실행 |

### Claude Desktop (macOS, Windows)

독립 실행형 데스크톱 애플리케이션으로, Claude Code 세션을 시각적으로 관리합니다:

- 각 세션에 격리된 worktree 제공
- 다수의 인스턴스를 시각적으로 관리
- 로컬 머신에서 작동
- **Claude Code CLI가 내부적으로 실행됨** — 동일한 도구와 기능 사용

### Claude Code on the Web

Anthropic의 클라우드 인프라에서 Claude Code를 실행하는 웹 기반 환경:

- 격리된 VM에서 실행 (로컬 환경 불필요)
- 브라우저에서 접근
- 팀원과 협업 가능
- `/teleport`로 로컬 터미널과 연결하여 계속 작업 가능

---

## Vim/Neovim 통합

공식 플러그인은 없지만, 커뮤니티 솔루션이 활발합니다:

| 플러그인 | 특징 |
|---------|------|
| **claude-code.nvim** | Neovim 0.7.0+ 지원, 기본 통합 |
| **claudecode.nvim** | WebSocket MCP 통합 |
| **claude-inline.nvim** | Cursor 스타일 인라인 편집 |
| **avante.nvim** | 에이전트 모드 지원 |

### Ghostty 3-패널 설정

터미널 기반 개발자를 위한 대안:

```
┌──────────────┬──────────────┐
│              │              │
│   Neovim     │  Claude Code │
│   (편집기)   │   (터미널)   │
│              │              │
├──────────────┴──────────────┤
│        일반 터미널          │
└─────────────────────────────┘
```

---

## Chrome 통합

Puppeteer MCP 서버를 통해 브라우저 자동화가 가능합니다:

- 웹 페이지 탐색과 상호작용
- 스크린샷 캡처
- JavaScript 실행
- 폼 작성과 테스트

---

## Slack 통합

Slack MCP 서버를 설정하여 Claude Code에서 Slack과 연동합니다:

- 메시지 전송
- 채널 관리
- 대화 분석

---

## 터미널 멀티플렉서

### tmux 사용 시 주의

`Ctrl+B`가 tmux의 프리픽스 키이므로, 백그라운드 실행 시 `Ctrl+B`를 **두 번** 눌러야 합니다.

### 세션 상태 확인

```bash
claude --status <session-id>
```

---

## 요약

| 플랫폼 | 상태 | 특징 |
|--------|:----:|------|
| **VS Code** | 공식 | 채팅 패널, 인라인 diff, @-멘션 |
| **JetBrains** | 공식 (Beta) | 통합 터미널, diff 뷰어 |
| **Desktop** | 공식 | 시각적 세션 관리, worktree |
| **Web** | 공식 | 클라우드 VM, 팀 협업 |
| **Vim/Neovim** | 커뮤니티 | 다양한 플러그인, 3-패널 레이아웃 |

---

## 다음 챕터

[27장: GitHub Actions / CI·CD 통합](02-ci-cd.md)에서 CI/CD 파이프라인에서의 활용 방법을 배웁니다.
