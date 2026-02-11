<!-- last_updated: 2026-02-11 -->

# 부록 C: 트러블슈팅

> 자주 발생하는 문제와 해결 방법을 정리합니다.

---

## `/doctor` — 자동 진단

```
> /doctor
```

Claude Code의 자동 진단 도구입니다. 설정 충돌, 컨텍스트 사용량, MCP 연결 등을 검사합니다.

---

## 설치 문제

### Node.js 버전 호환성

```
Error: Node.js version not supported
```

**해결**: Node.js 18 이상이 필요합니다.

```bash
node --version  # 18.0.0 이상 확인
```

### 네이티브 설치 권장

```bash
# 권장 방법 (curl)
curl -fsSL https://claude.ai/install.sh | sh

# npm은 더 이상 권장되지 않음
```

### 권한 오류

```
Error: EACCES permission denied
```

**해결**: 설치 디렉토리의 소유권을 확인합니다.

---

## 인증 오류

### API 키 문제

```
Error: Invalid API key
```

**해결**:
1. `ANTHROPIC_API_KEY` 환경 변수 확인
2. 키가 `sk-ant-`로 시작하는지 확인
3. 키 만료 여부 확인

### 클라우드 프로바이더 인증

```
Error: Failed to authenticate with Bedrock
```

**해결**:
1. AWS 자격증명 확인 (`aws sts get-caller-identity`)
2. 모델 접근 권한 확인
3. 리전 설정 확인

---

## 성능 문제

### 응답이 느림

- 컨텍스트가 가득 찼을 수 있음 → `/compact` 또는 `/clear`
- MCP 서버가 많으면 초기화 시간 증가 → 불필요한 서버 비활성화
- 네트워크 지연 → 프록시 설정 확인

### 컨텍스트 고갈

```
> /context  # 컨텍스트 사용량 확인
```

200K 토큰 윈도우가 가득 차면 성능이 저하됩니다:

- `/compact`로 대화 압축
- `/clear`로 세션 초기화
- 서브에이전트로 탐색 작업 위임

---

## IDE 연동 문제

### VS Code 확장이 연결 안 됨

1. Claude Code CLI가 설치되어 있는지 확인 (`claude --version`)
2. VS Code를 재시작
3. 확장을 재설치

### JetBrains 플러그인

1. 플러그인 호환 버전 확인
2. IDE를 재시작
3. 통합 터미널 설정 확인

---

## MCP 서버 문제

### 서버 연결 실패

```bash
# MCP 디버그 모드
claude --mcp-debug
```

```
> /mcp  # 서버 상태 확인
```

### 일반적인 원인

- 서버 명령어 경로가 잘못됨
- 환경 변수가 설정되지 않음
- 서버 프로세스가 비정상 종료

### 해결 순서

1. `claude mcp get <서버명>`으로 설정 확인
2. 명령어를 직접 실행하여 오류 확인
3. `--mcp-debug` 플래그로 상세 로그 확인

---

## Windows/WSL 이슈

### WSL 내에서 사용

Claude Code는 WSL 환경에서 네이티브로 작동합니다:

```bash
# WSL에서 설치
curl -fsSL https://claude.ai/install.sh | sh
```

### 경로 문제

Windows 경로(`C:\Users\...`)와 WSL 경로(`/mnt/c/Users/...`)가 혼동될 수 있습니다. WSL 내에서는 항상 Linux 경로를 사용합니다.

---

## 훅 문제

### 훅이 실행되지 않음

1. 스크립트에 실행 권한이 있는지 확인 (`chmod +x script.sh`)
2. 매처 패턴이 올바른지 확인
3. `--verbose` 모드로 훅 실행 로그 확인

### 훅이 무한 루프

타임아웃을 설정합니다:

```json
{
  "timeout": 10
}
```

---

## 프록시 및 방화벽 환경

### 기업 프록시 설정

```bash
# HTTP 프록시 설정
export HTTPS_PROXY=http://proxy.company.com:8080
export HTTP_PROXY=http://proxy.company.com:8080
export NO_PROXY=localhost,127.0.0.1

# 또는 Claude Code 전용 설정
export ANTHROPIC_BASE_URL=https://internal-proxy.company.com/v1
```

### 자체 서명 인증서

```bash
# Node.js가 자체 서명 인증서를 허용하도록 설정
export NODE_EXTRA_CA_CERTS=/path/to/company-ca.pem
```

### 방화벽 허용 목록

Claude Code가 접근해야 하는 도메인:
- `api.anthropic.com` — Anthropic API
- `statsig.anthropic.com` — 기능 플래그
- `sentry.io` — 에러 리포팅 (선택)

---

## 일반적인 해결 절차

1. `/doctor` 실행
2. `--verbose` 모드로 상세 로그 확인
3. `~/.claude/settings.json` 설정 확인
4. Claude Code 업데이트: `claude update`
5. 캐시 초기화: `claude config clear-cache`
6. 이슈 보고: [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues)
