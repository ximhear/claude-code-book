<!-- last_updated: 2026-02-11 -->

# 28. 엔터프라이즈 설정과 팀 관리

> 조직 단위의 Claude Code 배포와 관리를 다룹니다.

---

## 관리자 설정 (managed-settings.json)

### 배포 경로

| 플랫폼 | 경로 |
|--------|------|
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux/WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

관리자 설정은 **사용자가 덮어쓸 수 없습니다**.

### 배포 방법

MDM (macOS), Group Policy (Windows), Ansible/Chef/Puppet (Linux)을 통해 배포합니다.

---

## 조직 전체 정책

### 권한 잠금

```json
{
  "allowManagedPermissionRulesOnly": true,
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Bash(npm test)",
      "Read(src/**)"
    ],
    "deny": [
      "Bash(curl *)",
      "Bash(wget *)",
      "Read(.env*)",
      "Read(secrets/**)",
      "WebFetch"
    ]
  }
}
```

`allowManagedPermissionRulesOnly: true`이면 관리자가 정의한 권한 규칙만 적용됩니다.

### 훅 제어

```json
{
  "allowManagedHooksOnly": true,
  "hooks": [
    {
      "event": "PreToolUse",
      "matcher": "Bash",
      "type": "command",
      "command": "/opt/claude-hooks/validate.sh"
    }
  ]
}
```

### 위험한 모드 차단

```json
{
  "disableBypassPermissionsMode": "disable"
}
```

---

## 서버 관리형 설정

Anthropic 서버에서 직접 설정을 전달하는 방식입니다 (공개 베타):

- MDM 인프라 없이 설정 배포 가능
- 시작 시 서버에서 가져오고, 1시간마다 폴링
- 오프라인 시 캐시된 설정 사용
- 민감한 설정은 사용자 승인 필요

---

## SSO (Single Sign-On)

### 지원 프로토콜

- SAML 2.0
- OIDC (OpenID Connect)

### 설정 과정

1. 도메인 소유권 확인 (DNS TXT 레코드)
2. Admin Console에서 IdP 메타데이터 업로드
3. Okta, Azure AD, Auth0 등 IdP 연동

### 프로비저닝

- **JIT (Just-In-Time) 프로비저닝**: 사용자가 첫 로그인 시 자동으로 계정 생성
- **SCIM 2.0 자동 프로비저닝**: IdP에서 사용자/그룹을 동기화

### SCIM 상세 설정

SCIM (System for Cross-domain Identity Management)으로 사용자 라이프사이클을 자동화합니다:

- **사용자 생성**: IdP에서 할당 시 Claude 계정 자동 생성
- **사용자 비활성화**: IdP에서 제거 시 접근 권한 즉시 해제
- **그룹 동기화**: IdP 그룹을 Claude 팀/역할에 매핑
- **속성 매핑**: 이름, 이메일, 부서 등 사용자 속성 동기화

> Admin Console → Settings → SCIM Configuration에서 SCIM 엔드포인트 URL과 Bearer 토큰을 생성하여 IdP에 등록합니다.

---

## 플러그인 마켓플레이스 운영

### 승인된 소스만 허용

```json
{
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "company/approved-plugins" },
    { "source": "npm", "scope": "@company" }
  ]
}
```

비인가 플러그인 소스의 설치를 차단합니다.

---

## 감사와 모니터링

### OpenTelemetry

Claude Code는 OpenTelemetry 트레이스를 지원합니다:

- 도구 사용 추적
- 세션 활동 로깅
- 비용 모니터링

### 트랜스크립트 보존

- 기본 7~14일 보존
- 관리자가 보존 기간 설정 가능
- 감사 API로 접근

### Compliance API

- 감사 로그 접근
- 규제 요구사항 충족 (SOC 2, GDPR 등)

---

## 비용 관리 전략

### 팀 단위 제어

| 전략 | 방법 |
|------|------|
| **모델 제한** | 기본 모델을 Sonnet으로 설정 |
| **예산 한도** | `--max-budget-usd` 강제 |
| **도구 제한** | 필요한 도구만 allow |
| **캐싱** | 프롬프트 캐싱으로 90% 절감 |

### 비용 추적

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  }
}
```

---

## 관리자 전용 키 요약

| 키 | 용도 |
|----|------|
| `disableBypassPermissionsMode` | bypassPermissions 모드 차단 |
| `allowManagedPermissionRulesOnly` | 관리자 권한만 적용 |
| `allowManagedHooksOnly` | 관리자 훅만 실행 |
| `disableAllHooks` | 모든 훅 비활성화 |
| `strictKnownMarketplaces` | 승인된 플러그인 소스만 |

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **관리자 설정** | `managed-settings.json`, 사용자 덮어쓰기 불가 |
| **정책 강제** | 권한 잠금, 훅 제어, 모드 차단 |
| **서버 관리** | MDM 없이 서버에서 직접 배포 (베타) |
| **SSO** | SAML 2.0, OIDC, JIT/SCIM 프로비저닝 |
| **플러그인** | `strictKnownMarketplaces`로 소스 제한 |
| **감사** | OpenTelemetry, 트랜스크립트, Compliance API |
| **비용** | 모델 제한, 예산 한도, 캐싱 |

---

## 다음 챕터

Part VII: 레시피에서 [29장: CLAUDE.md 템플릿](../07-recipes/01-claude-md-templates.md)을 통해 다양한 프로젝트 유형에 맞는 설정 예제를 배웁니다.
