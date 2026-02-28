<!-- last_updated: 2026-02-11 -->

# 28. 클라우드 프로바이더 (Bedrock, Vertex, Foundry)

> Amazon Bedrock, Google Vertex AI, Microsoft Foundry와의 연동을 다룹니다.

---

## 클라우드 프로바이더가 필요한 이유

개인 사용자라면 Anthropic 계정으로 Claude Code를 바로 사용하면 됩니다. 클라우드 프로바이더는 주로 **기업/조직 환경**에서 필요합니다.

### 개인 사용 vs 기업 사용

| | 개인 (Anthropic 직접) | 기업 (클라우드 프로바이더) |
|---|---|---|
| **계정** | 개인 Anthropic 계정 | 회사 AWS/GCP/Azure 계정 |
| **인증** | Anthropic 로그인 | IAM, Azure AD, Google Cloud 인증 |
| **비용** | 개인 카드 결제 | 회사 클라우드 빌링에 통합 |
| **데이터** | Anthropic 서버 경유 | 선택한 리전 내 처리 |
| **설정** | 없음 (바로 사용) | 환경 변수 설정 필요 |

### 프로바이더를 사용하는 구체적 시나리오

1. **회사가 Anthropic과 직접 계약이 없는 경우** — 이미 AWS/GCP/Azure 계약이 있으므로 해당 클라우드를 통해 Claude를 사용합니다
2. **개인 계정 사용이 금지된 경우** — 회사 보안 정책상 개인 Anthropic 계정으로 업무 코드를 처리할 수 없으므로, 회사 IAM/Azure AD로 접근을 통제합니다
3. **데이터가 특정 리전을 벗어나면 안 되는 경우** — 금융, 의료, 공공기관 등 규제 산업에서 데이터 레지던시 요구사항을 충족합니다
4. **비용을 부서별/프로젝트별로 추적해야 하는 경우** — 기존 클라우드 빌링 시스템(Cost Explorer, Cloud Billing 등)에 AI 비용을 통합합니다
5. **네트워크 격리가 필요한 경우** — 회사 VPC/VNet 내에서만 트래픽이 흐르도록 제한합니다

> **요약**: Claude Code의 기능 자체는 동일합니다. 프로바이더는 "어떤 경로로 Claude API를 호출하느냐"만 바꿉니다. 개인 사용자에게는 불필요하며, 기업 환경에서 인증, 빌링, 컴플라이언스 요구사항을 충족하기 위해 사용합니다.

---

## Amazon Bedrock

### 활성화

```bash
export CLAUDE_CODE_USE_BEDROCK=1
```

### 인증

IAM 기반 인증을 사용합니다:

```bash
# AWS CLI 프로필
export AWS_PROFILE=my-profile

# 또는 직접 키 지정
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_REGION=us-east-1
```

### 특징

| 항목 | 설명 |
|------|------|
| **인증** | IAM, SSO, 임시 자격증명 |
| **비용 추적** | AWS Cost Explorer에서 확인 |
| **모니터링** | CloudWatch 통합 |
| **모델** | Opus 4.6, Sonnet 4.6, Haiku 4.5 |

---

## Google Vertex AI

### 활성화

```bash
export CLAUDE_CODE_USE_VERTEX=1
export ANTHROPIC_VERTEX_PROJECT_ID=my-project-id
export CLOUD_ML_REGION=us-east5
```

### 인증

Google Cloud 인증을 사용합니다:

```bash
gcloud auth application-default login
```

### 특징

- **FedRAMP High** 인증
- Google Cloud의 보안 및 컴플라이언스 인프라 활용
- 데이터 레지던시 지원

---

## Microsoft Foundry

### 활성화

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=my-resource
export ANTHROPIC_FOUNDRY_API_KEY=...
```

### 인증

Azure AD (Microsoft Entra ID) 인증을 사용합니다:

```bash
# 방법 1: API 키 직접 사용
export ANTHROPIC_FOUNDRY_API_KEY=your-key

# 방법 2: Azure CLI 인증 (권장)
az login
# Azure 기본 자격증명이 자동으로 사용됨
```

- `/login`과 `/logout` 명령어는 비활성화됨 (Azure 자격증명 사용)
- 리소스명은 Azure Portal에서 확인: `ANTHROPIC_FOUNDRY_RESOURCE`
- 서비스 프린시펄을 사용한 비대화형 인증도 지원

### 특징

- Opus 4.6, Sonnet 4.6, Haiku 4.5 모델 지원
- Extended Thinking 포함 모든 Claude Code 기능 사용 가능
- Azure 인프라와 통합
- Azure RBAC (역할 기반 접근 제어) 연동

---

## API 프록시 (ANTHROPIC_BASE_URL)

커스텀 프록시 서버나 API 게이트웨이를 사용하려면:

```bash
export ANTHROPIC_BASE_URL=https://my-proxy.example.com/v1
```

### 용도

- 멀티 프로바이더 라우팅
- 속도 제한 관리
- 커스텀 로깅과 감사
- 네트워크 격리

---

## LiteLLM 게이트웨이

LiteLLM을 통해 여러 프로바이더를 통합 관리할 수 있습니다:

```bash
export ANTHROPIC_BASE_URL=http://localhost:4000
```

LiteLLM은 Bedrock, Vertex, Foundry, Anthropic API를 하나의 인터페이스로 통합합니다.

---

## 네트워크 설정

### mTLS 인증서

```bash
export CLAUDE_CODE_CLIENT_CERT=/path/to/cert.pem
export CLAUDE_CODE_CLIENT_KEY=/path/to/key.pem
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE=secret
```

### 프록시 설정

```bash
export HTTPS_PROXY=https://proxy.company.com:8443
```

---

## Devcontainers

Docker 기반 개발 환경에서 클라우드 프로바이더 인증을 전달합니다:

```json
{
  "containerEnv": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "us-east-1"
  },
  "mounts": [
    "source=${localEnv:HOME}/.aws,target=/root/.aws,type=bind,readonly"
  ]
}
```

---

## 프로바이더 비교

| 항목 | Bedrock | Vertex AI | Foundry |
|------|:-------:|:---------:|:-------:|
| **인증** | IAM | Google Cloud | Azure AD |
| **FedRAMP** | 해당 없음 | High | 해당 없음 |
| **비용 추적** | Cost Explorer | Cloud Billing | Azure Billing |
| **모니터링** | CloudWatch | Cloud Monitoring | Azure Monitor |
| **데이터 레지던시** | 리전별 | 리전별 | 리전별 |

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **Bedrock** | `CLAUDE_CODE_USE_BEDROCK=1`, IAM 인증 |
| **Vertex AI** | `CLAUDE_CODE_USE_VERTEX=1`, FedRAMP High |
| **Foundry** | `CLAUDE_CODE_USE_FOUNDRY=1`, Azure AD |
| **프록시** | `ANTHROPIC_BASE_URL`로 커스텀 엔드포인트 |
| **mTLS** | 클라이언트 인증서 지원 |
| **Devcontainers** | 컨테이너에 인증 전달 |

---

## 다음 챕터

[29장: 엔터프라이즈 설정과 팀 관리](04-enterprise.md)에서 조직 단위의 Claude Code 배포와 관리를 배웁니다.
