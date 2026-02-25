<!-- last_updated: 2026-02-11 -->

# 27. GitHub Actions / CI·CD 통합

> CI/CD 파이프라인에서 Claude Code를 활용하는 방법을 다룹니다.

---

## GitHub Actions

### 공식 액션 (claude-code-action)

Anthropic이 제공하는 공식 GitHub Actions 액션입니다:

```yaml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]
  issue_comment:
    types: [created]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 주요 기능

| 기능 | 설명 |
|------|------|
| **PR 분석** | 변경 사항을 분석하고 리뷰 코멘트 작성 |
| **@claude 멘션** | PR/이슈에서 `@claude`로 Claude 호출 |
| **버그 수정** | 이슈를 분석하고 수정 PR 생성 |
| **CI 실패 분석** | 실패한 CI 작업을 분석하고 원인 파악 |

### 설치

```
> /install-github-app
```

또는 GitHub Marketplace에서 직접 설치합니다.

### 수동 설정 예시

```yaml
name: Claude PR Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Claude 리뷰 실행
        run: |
          npm install -g @anthropic-ai/claude-code
          git diff origin/main > changes.diff
          claude -p "이 변경을 리뷰해줘" \
            < changes.diff \
            --max-budget-usd 1.00 \
            --output-format text \
            > review.md
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: PR 코멘트
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: review
            });
```

---

## GitLab CI/CD

```yaml
claude-review:
  image: node:20
  script:
    - npm install -g @anthropic-ai/claude-code
    - git diff origin/main | claude -p "코드 리뷰해줘" --max-budget-usd 1.00
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  variables:
    ANTHROPIC_API_KEY: $ANTHROPIC_API_KEY
```

### 기능

- Merge Request 이벤트에 반응
- 리뷰 스레드에 코멘트
- Bedrock/Vertex AI를 통한 엔터프라이즈 데이터 레지던시 지원

---

## CI에서의 인증

### API 키

```yaml
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 클라우드 프로바이더

```yaml
env:
  CLAUDE_CODE_USE_BEDROCK: "1"
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

## 비용 제어

CI 환경에서는 반드시 비용 한도를 설정합니다:

```bash
claude -p "분석해줘" \
  --max-budget-usd 0.50 \
  --max-turns 5
```

| 플래그 | 용도 |
|--------|------|
| `--max-budget-usd` | 최대 비용 한도 (달러) |
| `--max-turns` | 최대 에이전트 턴 수 |
| `--model haiku` | 저비용 모델 사용 |

---

## 자동 PR 리뷰

### 트리거 패턴

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
    paths:
      - 'src/**'
      - '!*.md'
```

### 리뷰 관점 지정

```bash
claude -p "다음을 확인해줘:
1. 보안 취약점 (OWASP Top 10)
2. 성능 이슈
3. 테스트 누락
4. 코딩 규칙 위반" \
  < changes.diff
```

---

## 이슈 자동 처리

```yaml
on:
  issues:
    types: [opened, labeled]

jobs:
  auto-fix:
    if: contains(github.event.issue.labels.*.name, 'claude-fix')
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "이 이슈를 분석하고 수정 PR을 만들어줘"
```

---

## 보안 고려사항

- API 키는 반드시 **GitHub Secrets** 또는 환경 변수로 관리
- `--permission-mode plan`으로 읽기 전용 모드 사용 가능
- `--max-budget-usd`로 예상치 못한 비용 방지
- 민감한 파일에 대한 `deny` 규칙 설정

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **GitHub Actions** | `anthropics/claude-code-action@v1` 공식 액션 |
| **GitLab CI** | MR 이벤트에 반응, 리뷰 자동화 |
| **인증** | API 키 또는 클라우드 프로바이더 인증 |
| **비용 제어** | `--max-budget-usd`, `--max-turns` 필수 |
| **리뷰 자동화** | PR 변경에 보안/성능/품질 리뷰 |
| **이슈 처리** | 라벨 기반 자동 수정 PR 생성 |

---

## 다음 챕터

[28장: 클라우드 프로바이더](03-cloud-providers.md)에서 Amazon Bedrock, Google Vertex AI, Microsoft Foundry와의 연동을 배웁니다.
