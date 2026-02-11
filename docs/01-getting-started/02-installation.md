<!-- last_updated: 2026-02-11 -->

# 2. 설치 및 초기 설정

> Claude Code를 설치하고, 인증을 완료하고, 개발 환경을 점검합니다.

---

## 시스템 요구사항

| 항목 | 요구사항 |
|------|----------|
| **운영체제** | macOS 13.0+, Ubuntu 20.04+ / Debian 10+, Alpine 3.19+, Windows 10 1809+ |
| **RAM** | 최소 4GB |
| **네트워크** | 인터넷 연결 필수 ([지원 국가](https://www.anthropic.com/supported-countries) 확인) |
| **셸** | Bash 또는 Zsh 권장. Windows는 Git Bash 필요 |
| **Node.js** | 18+ (npm 설치 시에만 필요, 네이티브 설치는 불필요) |

---

## 설치 방법

### 방법 1: 네이티브 설치 (권장)

자동 업데이트를 지원하며, Node.js가 필요하지 않습니다.

**macOS / Linux / WSL:**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://claude.ai/install.ps1 | iex
```

**Windows (CMD):**

```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

설치 경로:
- macOS/Linux: `~/.local/bin/claude`
- Windows: `%USERPROFILE%\.local\bin\claude.exe`

**안정 버전 또는 특정 버전 설치:**

```bash
# 안정 버전 (최신보다 1주 뒤)
curl -fsSL https://claude.ai/install.sh | bash -s stable

# 특정 버전
curl -fsSL https://claude.ai/install.sh | bash -s 2.1.30
```

### 방법 2: Homebrew (macOS)

```bash
brew install --cask claude-code
```

> **주의**: Homebrew 설치는 자동 업데이트를 지원하지 않습니다. `brew upgrade claude-code`로 수동 업데이트해야 합니다.

### 방법 3: WinGet (Windows)

```powershell
winget install Anthropic.ClaudeCode
```

> **주의**: WinGet 설치도 자동 업데이트를 지원하지 않습니다. `winget upgrade Anthropic.ClaudeCode`로 수동 업데이트합니다.

### 방법 4: npm (지원 중단 예정)

```bash
npm install -g @anthropic-ai/claude-code
```

> **경고**: npm 설치는 **deprecated** 상태입니다. 네이티브 설치로 마이그레이션하세요:
> ```bash
> claude install   # 기존 npm 설치에서 네이티브로 전환
> ```
> `sudo npm install -g`는 **절대 사용하지 마세요** — 권한 문제와 보안 위험이 있습니다.

### 설치 확인

```bash
claude --version
# 출력 예: Claude Code version 2.1.39
```

### 자동 업데이트

네이티브 설치는 시작 시 자동으로 업데이트를 확인하고 백그라운드에서 업데이트합니다. 자동 업데이트를 끄려면:

```bash
export DISABLE_AUTOUPDATER=1
```

| 설치 방법 | 자동 업데이트 | 수동 업데이트 |
|-----------|:------------:|--------------|
| 네이티브 | ✅ | `claude update` |
| Homebrew | ❌ | `brew upgrade claude-code` |
| WinGet | ❌ | `winget upgrade Anthropic.ClaudeCode` |
| npm | ❌ | `npm update -g @anthropic-ai/claude-code` |

### 바이너리 무결성 검증

네이티브 설치 바이너리는 코드 서명이 되어 있습니다:
- **macOS**: "Anthropic PBC" 서명, Apple 공증(notarized) 완료
- **Windows**: "Anthropic, PBC" 서명

---

## 인증 설정

Claude Code를 사용하려면 인증이 필요합니다.

### 개인 사용자

**방법 1: Claude Pro / Max 구독 (권장)**

```bash
claude
# 첫 실행 시 인증 화면이 나타남
# 또는 세션 안에서:
/login
```

브라우저가 열리며 Claude.ai 로그인 페이지로 이동합니다. 브라우저가 자동으로 열리지 않으면 `c`를 눌러 URL을 복사한 뒤 브라우저에 붙여넣으세요.

인증 후 자격 증명은 안전하게 저장됩니다:
- **macOS**: 암호화된 Keychain
- **기타 플랫폼**: 보안 자격 증명 저장소

**방법 2: API 키 (종량제)**

[Anthropic Console](https://console.anthropic.com/)에서 API 키를 발급받습니다:

```bash
# 환경 변수로 설정
export ANTHROPIC_API_KEY="sk-ant-xxxxx"

# 셸 프로파일에 영구 추가
echo 'export ANTHROPIC_API_KEY="sk-ant-xxxxx"' >> ~/.zshrc
source ~/.zshrc
```

> **참고**: 인터랙티브 모드에서는 환경 변수보다 `/login` 명령어를 권장합니다.

### 팀 / 조직

| 옵션 | 설명 |
|------|------|
| **Claude for Teams** | 셀프 서비스 플랜 ($25~30/인/월) |
| **Claude for Enterprise** | SSO, 도메인 캡처, RBAC, 컴플라이언스 API |
| **Console 조직** | 공유 Console 조직에서 팀 관리 |

### 서드파티 클라우드 프로바이더

**Amazon Bedrock:**

```bash
export CLAUDE_CODE_USE_BEDROCK=1
aws configure   # AWS 자격 증명 설정
```

**Google Vertex AI:**

```bash
export CLAUDE_CODE_USE_VERTEX=1
gcloud auth application-default login
```

**Microsoft Foundry:**

```bash
export ANTHROPIC_FOUNDRY_API_KEY="your-key"
export ANTHROPIC_FOUNDRY_RESOURCE="my-resource"
```

---

## 인증 환경 변수 레퍼런스

| 변수 | 용도 |
|------|------|
| `ANTHROPIC_API_KEY` | Anthropic API 키 (SDK/headless용) |
| `ANTHROPIC_AUTH_TOKEN` | 커스텀 Authorization 헤더 (자동 `Bearer` 접두사) |
| `ANTHROPIC_CUSTOM_HEADERS` | 커스텀 HTTP 헤더 (`Name: Value`, 줄바꿈 구분) |
| `CLAUDE_CODE_USE_BEDROCK` | Amazon Bedrock 활성화 |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API 키 |
| `CLAUDE_CODE_USE_VERTEX` | Google Vertex AI 활성화 |
| `ANTHROPIC_FOUNDRY_API_KEY` | Microsoft Foundry API 키 |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Foundry 리소스명 |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | API 키 헬퍼 갱신 간격 (기본: 5분) |

### 고급 인증

**API 키 헬퍼 스크립트** — 동적으로 키를 생성:

```json
{
  "apiKeyHelper": "/bin/generate_temp_api_key.sh"
}
```

**mTLS 인증** — 상호 TLS:

```bash
export CLAUDE_CODE_CLIENT_CERT="/path/to/cert.pem"
export CLAUDE_CODE_CLIENT_KEY="/path/to/key.pem"
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="passphrase"
```

**로그인 방법 강제 지정** — 조직 관리용 (managed settings):

```json
{
  "forceLoginMethod": "claudeai",
  "forceLoginOrgUUID": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

---

## 환경 점검

### `/doctor` — 종합 진단

```
> /doctor
```

검사 항목:
- 설치 유형과 버전
- 자동 업데이트 상태
- 검색 기능 (ripgrep 가용성)
- 설정 파일 유효성 (잘못된 JSON, 타입 오류)
- MCP 서버 설정 오류
- 키바인딩 설정 검증
- 컨텍스트 사용량 경고 (과도한 CLAUDE.md, MCP 토큰 사용)
- 도달 불가능한 권한 규칙 경고
- 플러그인/에이전트 로딩 오류

```
> /doctor --performance   # 성능 관련 진단
```

> **팁**: 이슈 리포트 시 `/doctor`와 `/status`의 출력을 함께 포함하세요.

### `/terminal-setup` — 터미널 최적화

```
> /terminal-setup
```

Shift+Enter 멀티라인 입력, 키 바인딩 최적화, 셸별 호환성을 설정합니다.

---

## 설정 파일 위치

```
~/.claude/                     # 사용자 전역 설정
├── settings.json              # 전역 설정 (권한, 훅 등)
├── CLAUDE.md                  # 전역 메모리/지침
├── rules/                     # 전역 규칙
├── skills/                    # 사용자 스킬
├── keybindings.json           # 키 바인딩
└── projects/                  # 프로젝트별 자동 메모리
    └── <hash>/memory/MEMORY.md

~/.claude.json                 # 글로벌 상태 (테마, OAuth, MCP)

<project>/.claude/             # 프로젝트 설정
├── settings.json              # 팀 공유 (git 추적)
├── settings.local.json        # 개인용 (git 미추적)
└── ...

<project>/.mcp.json            # 프로젝트 MCP 서버

# 관리자 설정 (managed settings)
# macOS:   /Library/Application Support/ClaudeCode/
# Linux:   /etc/claude-code/
# Windows: C:\Program Files\ClaudeCode\
```

---

## 첫 실행 체크리스트

```bash
# 1. 버전 확인
claude --version

# 2. 첫 실행 (인증 포함)
claude

# 3. 환경 점검 (세션 안에서)
/doctor

# 4. 터미널 설정 (세션 안에서)
/terminal-setup

# 5. 도움말 확인
/help
```

---

## 자주 발생하는 설치 문제

### Windows: "Git Bash를 찾을 수 없음"

Git이 설치되어 있지 않거나 경로가 감지되지 않는 경우:

```powershell
# Git 설치 확인
git --version

# Git Bash 경로 명시적 설정
$env:CLAUDE_CODE_GIT_BASH_PATH="C:\Program Files\Git\bin\bash.exe"
```

### Windows: claude 명령어를 찾을 수 없음

PATH에 수동 추가가 필요합니다:

1. `Win+R` → `sysdm.cpl` → 고급 → 환경 변수
2. 사용자 변수에서 `Path` 선택 → 편집
3. 새로 만들기: `%USERPROFILE%\.local\bin`
4. 터미널 재시작

### WSL: 검색이 동작하지 않음

ripgrep이 설치되지 않은 경우:

```bash
# Ubuntu/Debian
sudo apt install ripgrep

# Alpine
apk add ripgrep
export USE_BUILTIN_RIPGREP=0
```

### WSL: Windows Node.js가 감지됨

WSL에서 Windows의 Node.js를 사용 중일 수 있습니다:

```bash
which node    # /mnt/c/... → 문제!
              # /usr/... → 정상

# Linux Node.js 설치
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
```

### WSL2: 샌드박싱 오류

```bash
sudo apt-get install bubblewrap socat
```

> **참고**: WSL1은 샌드박싱을 지원하지 않습니다. WSL2를 사용하세요.

### 인증 실패

```bash
/logout
# Claude Code 종료 후 재시작
claude
# 인증 과정 다시 진행
```

---

## 다음 챕터

[3장: 첫 번째 세션](03-first-session.md)에서 Claude Code를 실제로 실행하고 기본적인 상호작용을 체험합니다.
