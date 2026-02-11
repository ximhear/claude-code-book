<!-- last_updated: 2026-02-11 -->

# 21. MCP 서버 통합

> Model Context Protocol을 통한 외부 도구 연동 방법을 다룹니다.

---

## MCP란?

MCP (Model Context Protocol)는 AI 도구 통합을 위한 **오픈 소스 표준 프로토콜**입니다. Claude Code가 외부 도구, 데이터 소스, API에 안전하게 연결할 수 있게 해줍니다.

```
Claude Code ←MCP→ GitHub 서버
             ←MCP→ 데이터베이스 서버
             ←MCP→ Slack 서버
             ←MCP→ 커스텀 서버
```

내장 도구로 충분하지 않을 때, MCP를 통해 Claude의 능력을 확장합니다.

---

## 서버 설정

### settings.json에서 설정

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"],
      "transport": "stdio"
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### 설정 필드

| 필드 | 설명 |
|------|------|
| `command` | MCP 서버를 시작하는 명령어 |
| `args` | 명령어 인자 |
| `env` | 환경 변수 (`${VAR}` 확장 지원) |
| `transport` | 통신 방식 |

### 전송 방식 (Transport)

| 방식 | 설명 | 사용 시나리오 |
|------|------|-------------|
| **stdio** | 표준 입출력 | 로컬 프로세스 (가장 일반적) |
| **sse** | Server-Sent Events | HTTP 기반 원격 서버 (레거시) |
| **http** | 스트리밍 HTTP | 원격 서버 (권장, sse 대체) |

---

## CLI로 MCP 서버 관리

### 서버 추가

```bash
# stdio 서버 추가
claude mcp add filesystem npx -y @modelcontextprotocol/server-filesystem /path

# 환경 변수와 함께
claude mcp add github -e GITHUB_TOKEN=ghp_xxx npx -y @modelcontextprotocol/server-github
```

### 서버 관리

```bash
# 서버 목록
claude mcp list

# 서버 상세 정보
claude mcp get github

# 서버 제거
claude mcp remove filesystem
```

### `/mcp` 명령어

세션 중에 MCP 서버를 관리합니다:

```
> /mcp
```

- 설정된 MCP 서버와 상태 표시
- 개별 서버 활성화/비활성화
- 연결 테스트
- 각 서버의 제공 도구 확인

---

## MCP 도구 사용

### 도구 네이밍 규칙

MCP 도구는 `mcp__서버명__도구명` 형식으로 나타납니다:

```
mcp__github__create_pull_request
mcp__slack__send_message
mcp__puppeteer__puppeteer_navigate
```

### 권한 설정

```json
{
  "permissions": {
    "allow": [
      "mcp__github__*",
      "mcp__filesystem__read_file"
    ],
    "deny": [
      "mcp__filesystem__write_file"
    ]
  }
}
```

| 패턴 | 매칭 대상 |
|------|----------|
| `mcp__github__*` | GitHub 서버의 모든 도구 |
| `mcp__.*__read.*` | 모든 서버의 read 도구 |
| `mcp__puppeteer__puppeteer_navigate` | 특정 도구 |

### Tool Search와 Lazy Loading

MCP 도구가 많으면 컨텍스트 공간을 차지합니다. Claude Code는 **Tool Search**를 통해 필요한 도구만 동적으로 로드합니다:

- 도구 설명이 컨텍스트의 10%를 초과하면 자동 활성화
- 필요할 때만 도구를 검색하여 로드
- 불필요한 컨텍스트 소비 방지

---

## MCP 범위

| 범위 | 위치 | 공유 |
|------|------|:----:|
| **로컬** | `.claude/settings.local.json` | 개인 |
| **프로젝트** | `.claude/settings.json` | 팀 (git) |
| **사용자** | `~/.claude/settings.json` | 개인 |
| **관리자** | 시스템 경로 | 조직 |

---

## MCP 리소스 참조

`@` 구문으로 MCP 리소스를 직접 참조할 수 있습니다:

```
> @github:repo/issue/123 이 이슈를 분석해줘
> @database:users 테이블 구조를 보여줘
```

---

## 인기 MCP 서버

### 개발 도구

| 서버 | 기능 |
|------|------|
| **GitHub** | PR, 이슈, 커밋, 브랜치 관리 |
| **Git** | 로컬 저장소 작업 |
| **Filesystem** | 파일 읽기/쓰기/검색 |
| **Puppeteer** | 브라우저 자동화, 스크린샷 |

### 커뮤니케이션

| 서버 | 기능 |
|------|------|
| **Slack** | 메시지 전송, 채널 관리 |
| **Google Drive** | 문서/스프레드시트 접근 |

### 데이터베이스

| 서버 | 기능 |
|------|------|
| **PostgreSQL** | 쿼리 실행, 스키마 관리 |
| **MySQL** | 쿼리 실행, 데이터 조작 |
| **MongoDB** | 도큐먼트 조회/수정 |

---

## MCP vs 내장 도구

| 관점 | 내장 도구 | MCP 도구 |
|------|----------|---------|
| **설정** | 자동 | settings.json 필요 |
| **로딩** | 항상 로드됨 | 온디맨드 로딩 |
| **커스터마이즈** | 고정 기능 | 무한 확장 가능 |
| **외부 연동** | 제한적 | 광범위 |
| **컨텍스트 비용** | 일정 | 동적 |

---

## 커스텀 MCP 서버 구현

MCP 프로토콜 사양에 따라 자체 서버를 구현할 수 있습니다:

1. 서버 능력(capabilities)과 도구를 JSON 스키마로 정의
2. 선택한 전송 방식(stdio/sse/HTTP)으로 통신 구현
3. 도구 호출 처리와 결과 반환 구현
4. settings.json에 서버 등록

공식 레퍼런스 구현과 커뮤니티 예제가 GitHub에 다수 공개되어 있습니다.

---

## OAuth 인증

원격 MCP 서버가 OAuth를 요구하는 경우:

```json
{
  "mcpServers": {
    "my-server": {
      "url": "https://api.example.com/mcp",
      "transport": "streamable-http"
    }
  }
}
```

Claude Code는 OAuth 흐름을 자동으로 처리하며, 브라우저에서 인증 후 토큰을 안전하게 저장합니다.

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **MCP** | AI 도구 통합을 위한 오픈 소스 표준 |
| **설정** | `mcpServers` in settings.json |
| **전송** | stdio (로컬), sse/HTTP (원격) |
| **도구 이름** | `mcp__서버__도구` 형식 |
| **관리** | `claude mcp add/list/remove`, `/mcp` |
| **권한** | `mcp__서버__*` 패턴으로 제어 |
| **Lazy Loading** | 컨텍스트 10% 초과 시 자동 활성화 |
| **범위** | 로컬, 프로젝트, 사용자, 관리자 |

---

## 다음 챕터

[22장: 서브에이전트와 병렬 처리](04-subagents.md)에서 서브에이전트를 활용한 작업 위임과 병렬 처리를 배웁니다.
