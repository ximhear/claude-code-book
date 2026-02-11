<!-- last_updated: 2026-02-11 -->

# 11. 권한(Permissions) 시스템

> 도구 실행 권한을 세밀하게 제어하는 방법을 다룹니다.

---

## 권한 모드

Claude Code는 6가지 권한 모드를 지원합니다. Shift+Tab으로 순환하거나 설정에서 지정합니다.

| 모드 | 동작 | 사용 시나리오 |
|------|------|---------------|
| **default** | 도구 사용 시마다 승인 요청 | 가장 안전, 일반적인 사용 |
| **acceptEdits** | 파일 편집 자동 승인, Bash는 승인 필요 | 신뢰할 수 있는 프로젝트 |
| **plan** | 읽기 전용 도구만 사용 | 코드 분석, 계획 수립 |
| **delegate** | 에이전트 팀 관리 도구만 사용 | 에이전트 팀 리더 |
| **dontAsk** | 사전 허용된 도구만 실행, 나머지 자동 거부 | 자동화 파이프라인 |
| **bypassPermissions** | 모든 승인 건너뜀 | 격리된 컨테이너만 (위험) |

### 모드 설정 방법

```bash
# CLI 시작 시
claude --permission-mode plan

# 설정 파일
# .claude/settings.json
{
  "defaultMode": "acceptEdits"
}

# 세션 중
# Shift+Tab으로 순환
```

> **경고**: `bypassPermissions`는 인터넷이 없는 격리된 VM/컨테이너에서만 사용하세요. 관리자 설정으로 비활성화할 수 있습니다.

---

## 권한 규칙 구조

### Allow / Deny / Ask

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)"],
    "deny": ["Bash(rm -rf *)"],
    "ask": ["Edit(src/**/*.ts)"]
  }
}
```

| 규칙 | 동작 |
|------|------|
| **allow** | 승인 없이 자동 실행 |
| **deny** | 항상 차단 |
| **ask** | 사용자에게 승인 요청 (기본 동작) |

### 평가 순서: Deny > Ask > Allow

```
도구 호출 발생
  ↓
1. deny 규칙 검사 → 매칭되면 차단
  ↓
2. ask 규칙 검사 → 매칭되면 승인 요청
  ↓
3. allow 규칙 검사 → 매칭되면 자동 실행
  ↓
4. 아무것도 매칭 안 됨 → 모드별 기본 동작
```

Deny가 항상 최우선이므로, allow와 deny에 같은 패턴이 있으면 deny가 적용됩니다.

---

## 도구 지정자 (Tool Specifiers)

### Bash — 명령어 패턴

와일드카드 `*`로 패턴 매칭:

```json
"Bash(npm run build)"       // 정확한 명령어
"Bash(npm run *)"           // "npm run"으로 시작하는 모든 명령어
"Bash(* --version)"         // "--version"으로 끝나는 명령어
"Bash(git * main)"          // "git"과 "main" 사이 아무 텍스트
"Bash(*)"                   // 모든 Bash 명령어 (= "Bash")
```

**공백과 단어 경계**:

```json
"Bash(ls *)"    // "ls " 뒤에 인자가 오는 경우 (단어 경계)
"Bash(ls*)"     // "ls"로 시작하는 모든 것 (lsof 등 포함)
```

**주의사항**:
- 셸 연산자 (`&&`, `||`, `;`)를 인식하므로 `safe-cmd && dangerous-cmd`를 단순 접두사 규칙으로 허용하는 것은 불가능합니다
- URL 필터링에 Bash 패턴은 부적합합니다 — `WebFetch(domain:...)` + Bash deny를 조합하세요

### Read / Edit — 파일 경로 패턴

gitignore 스타일 패턴을 사용합니다:

```json
"/src/**/*.ts"              // 설정 파일 기준 상대 경로 (프로젝트 내)
"~/Documents/*.pdf"         // 홈 디렉토리 기준
"//Users/alice/secrets/**"  // 절대 경로 (슬래시 두 개)
"*.env"                     // 현재 디렉토리의 .env 파일
"src/**"                    // src/ 하위 모든 파일 (재귀)
```

**경로 접두사 규칙**:

| 접두사 | 의미 | 예시 |
|--------|------|------|
| `/` | 설정 파일 기준 상대 경로 | `/src/**/*.ts` |
| `~/` | 홈 디렉토리 | `~/Documents/*.pdf` |
| `//` | 파일시스템 절대 경로 | `//tmp/test` |
| 없음 | 현재 디렉토리 기준 | `*.env` |

### WebFetch — 도메인 필터

```json
"WebFetch(domain:docs.example.com)"   // 특정 도메인
"WebFetch"                             // 모든 웹 요청
```

### MCP — 서버 및 도구 패턴

```json
"mcp__puppeteer__puppeteer_navigate"   // 특정 도구
"mcp__puppeteer__*"                     // 서버의 모든 도구
"mcp__.*__write.*"                      // 모든 서버의 write 도구
```

### Task — 서브에이전트 지정

```json
"Task(Explore)"           // Explore 에이전트
"Task(Plan)"              // Plan 에이전트
"Task(my-custom-agent)"   // 커스텀 에이전트
```

### Skill — 스킬 지정

```json
"Skill(commit)"           // 정확한 스킬명
"Skill(review-pr *)"      // 접두사 매칭 + 인자
"Skill"                   // 모든 스킬
```

---

## 승인 프롬프트

Claude가 승인이 필요한 도구를 호출하면:

```
Claude wants to run: npm test

  Allow?
  [y] Yes  [n] No  [a] Always allow this  [d] Don't ask again for this session
```

| 키 | 동작 | 범위 |
|:--:|------|------|
| `y` | 이번만 허용 | 단발 |
| `n` | 거부 | 단발 |
| `a` | 항상 허용 (설정에 저장) | 영구 |
| `d` | 이 세션 동안 묻지 않음 | 세션 |

### 파일 편집 승인

```
Claude wants to edit: src/utils.ts

  - function validate(input) {
  + function validate(input: string): boolean {

  Allow?
  [y] Yes  [n] No  [a] Always allow edits
```

diff가 표시되므로 변경 내용을 확인한 후 승인할 수 있습니다.

---

## `/permissions` — 인터랙티브 관리

```
> /permissions
```

현재 적용 중인 모든 권한 규칙을 표시합니다:

- 각 규칙의 출처 (User, Project, Local, Managed)
- Allow / Deny 규칙 목록
- 규칙 추가/삭제 인터페이스

---

## 설정 파일별 권한

### 프로젝트 공유 (.claude/settings.json)

팀원 전체에 적용되는 규칙입니다. Git에 커밋합니다:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx prisma *)",
      "Bash(git add *)",
      "Bash(git commit *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(rm -rf *)",
      "Read(.env)",
      "Read(secrets/**)"
    ]
  }
}
```

### 개인 로컬 (.claude/settings.local.json)

개인적인 권한 오버라이드입니다. Git에 포함되지 않습니다:

```json
{
  "permissions": {
    "allow": [
      "Bash(docker compose *)"
    ]
  }
}
```

### 사용자 전역 (~/.claude/settings.json)

모든 프로젝트에 적용되는 개인 규칙입니다:

```json
{
  "permissions": {
    "allow": [
      "Bash(* --version)",
      "Bash(* --help)"
    ]
  }
}
```

### 관리자 (managed-settings.json)

조직 전체에 강제되는 규칙입니다. 사용자가 덮어쓸 수 없습니다:

```json
{
  "allowManagedPermissionRulesOnly": true,
  "permissions": {
    "deny": [
      "Bash(curl *)",
      "Bash(wget *)",
      "Read(.env*)",
      "WebFetch"
    ]
  }
}
```

---

## 보안 고려사항

### 권한 규칙의 한계

권한 규칙은 **Claude의 도구 호출을 제어**하지만, OS 수준의 보안을 대체하지 않습니다:

- 권한 규칙 → Claude가 시도하지 않도록 방지
- 샌드박싱 → OS 수준에서 실행 환경 격리
- 두 가지를 함께 사용하는 것이 **심층 방어 (defense in depth)** 원칙입니다

### URL 필터링은 Bash보다 WebFetch로

```json
// 부적합 (❌) — Bash 패턴으로 URL 필터링
"allow": ["Bash(curl https://api.example.com/*)"]
// curl -X GET, curl --silent 등 변형에 취약

// 적합 (✅) — WebFetch 도메인 + Bash deny
"allow": ["WebFetch(domain:api.example.com)"],
"deny": ["Bash(curl *)", "Bash(wget *)"]
```

### 민감한 파일 보호

```json
{
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(secrets/**)",
      "Read(~/.aws/**)",
      "Read(~/.ssh/**)"
    ]
  }
}
```

---

## 세션 범위 vs 영구 권한

| 유형 | 범위 | 설정 방법 |
|------|------|-----------|
| **단발 허용** (y) | 이번 호출만 | 승인 프롬프트에서 `y` |
| **세션 허용** (d) | 세션 종료까지 | 승인 프롬프트에서 `d` |
| **영구 허용** (a) | 설정 파일에 저장 | 승인 프롬프트에서 `a` |
| **규칙 기반** | 설정 파일에 저장 | `/permissions` 또는 직접 편집 |
| **관리자** | 항상 강제 | IT 배포 |

---

## 실전 예제

### 웹 개발 프로젝트

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx next *)",
      "Bash(npx prisma *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git checkout *)",
      "Read(src/**)",
      "Edit(src/**)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Read(.env*)",
      "Read(node_modules/**)"
    ]
  }
}
```

### CI/CD 파이프라인 (자동화)

```json
{
  "defaultMode": "dontAsk",
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Bash(npm test)",
      "Bash(npm run lint)",
      "Read(src/**)",
      "Edit(src/**)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(npm publish)",
      "WebFetch"
    ]
  }
}
```

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **모드** | default, acceptEdits, plan, delegate, dontAsk, bypassPermissions |
| **규칙** | allow / deny / ask — Deny가 최우선 |
| **Bash 패턴** | `*` 와일드카드, 공백으로 단어 경계 |
| **파일 패턴** | gitignore 스타일, `/`, `~/`, `//` 접두사 |
| **MCP 패턴** | `mcp__서버__도구` 형식 |
| **승인 옵션** | y (단발), n (거부), a (영구), d (세션) |
| **보안** | 권한 규칙 + 샌드박싱 = 심층 방어 |

---

## 다음 챕터

[12장: Rules — 모듈식 규칙 파일](04-rules.md)에서 `.claude/rules/` 디렉토리를 활용한 모듈식 지침 관리를 배웁니다.
