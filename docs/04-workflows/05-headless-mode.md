<!-- last_updated: 2026-02-11 -->

# 18. Headless 모드와 자동화

> 비대화형 모드로 스크립트와 CI/CD에서 활용하는 방법을 다룹니다.

---

## `-p` / `--print` 플래그

### 기본 사용법

`-p` 플래그는 Claude를 **비대화형 모드**로 실행합니다. 결과를 출력하고 즉시 종료합니다:

```bash
# 간단한 질문
claude -p "이 프로젝트를 설명해줘"

# 파이프 입력
cat error.log | claude -p "이 에러의 원인을 분석해줘"

# JSON 출력
claude -p "모든 API 엔드포인트를 나열해줘" --output-format json
```

### 주요 CLI 플래그

| 플래그 | 용도 | 예시 |
|--------|------|------|
| `-p`, `--print` | 비대화형 출력 | `claude -p "분석해줘"` |
| `--output-format` | 출력 형식 | `--output-format json` |
| `--input-format` | 입력 형식 | `--input-format stream-json` |
| `-c`, `--continue` | 이전 세션 이어가기 | `claude -c -p "확인해줘"` |
| `-r`, `--resume` | 특정 세션 재개 | `claude -r "task" -p "완료해줘"` |
| `--permission-mode` | 권한 모드 설정 | `--permission-mode plan` |
| `--no-session-persistence` | 세션 저장 안 함 | 임시 작업에 사용 |
| `--max-turns` | 최대 턴 수 | `--max-turns 5` |
| `--max-budget-usd` | 비용 한도 | `--max-budget-usd 0.50` |
| `--append-system-prompt` | 시스템 프롬프트 추가 | `--append-system-prompt "간결하게"` |
| `--model` | 모델 지정 | `--model haiku` |

---

## 출력 형식

### text (기본값)

```bash
claude -p "프로젝트 구조를 설명해줘"
# 일반 텍스트 출력
```

### json

```bash
claude -p "API 엔드포인트를 나열해줘" --output-format json
```

출력 구조:

```json
[
  {
    "type": "user",
    "content": "API 엔드포인트를 나열해줘",
    "timestamp": "2026-02-11T12:00:00Z"
  },
  {
    "type": "assistant",
    "content": "다음은 API 엔드포인트 목록입니다...",
    "toolUses": [...],
    "stopReason": "endTurn"
  },
  {
    "metadata": {
      "cost": { "inputTokens": 1500, "outputTokens": 800 },
      "duration": 2.5,
      "modelUsed": "claude-opus-4-6"
    }
  }
]
```

### stream-json

```bash
claude -p "코드를 분석해줘" --output-format stream-json
```

줄 단위로 JSON 객체가 실시간 출력됩니다. 스트리밍 처리에 유용합니다.

---

## Unix 파이프라인 통합

### 기본 패턴

```bash
cat 파일 | claude -p "지시사항"
```

### 실전 예시

```bash
# 에러 로그 분석
cat error.log | claude -p "에러의 근본 원인을 찾아줘"

# 코드 리뷰
cat src/auth.ts | claude -p "보안 취약점을 확인해줘"

# Git diff 리뷰
git diff | claude -p "이 변경 사항을 리뷰해줘"

# 테스트 실패 분석
npm test 2>&1 | claude -p "실패 원인을 분석해줘"

# JSON 데이터 분석
cat data.json | claude -p "데이터 구조를 요약해줘"

# 커밋 이력 분석
git log --oneline -20 | claude -p "최근 변경 사항을 요약해줘"
```

### 명령어 체이닝

```bash
# 분석 결과를 파일로 저장
git diff origin/main | \
  claude -p "보안 관점에서 리뷰해줘" \
  > review.md

# JSON 출력을 jq로 처리
claude -p "API 목록을 알려줘" --output-format json | \
  jq -r '.[] | select(.type=="assistant") | .content'

# 비용 정보 추출
claude -p "분석해줘" --output-format json | \
  jq '.[] | select(.metadata) | .metadata.cost'
```

---

## `--json-schema`를 활용한 구조화된 출력

Claude의 응답을 **특정 JSON 스키마**에 맞춰 출력할 수 있습니다:

```bash
claude -p "이 프로젝트의 의존성을 분석해줘" \
  --output-format json \
  --json-schema '{
    "type": "object",
    "properties": {
      "dependencies": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "name": { "type": "string" },
            "version": { "type": "string" },
            "purpose": { "type": "string" }
          }
        }
      }
    }
  }'
```

스크립트에서 구조화된 데이터가 필요할 때 유용합니다.

---

## `--max-turns`와 `--max-budget-usd`

### 턴 수 제한

```bash
# 최대 3턴으로 제한
claude -p "코드를 분석하고 수정해줘" --max-turns 3
```

턴 수를 제한하면 Claude가 무한히 반복하는 것을 방지합니다.

### 비용 한도

```bash
# 최대 $0.50로 제한
claude -p "로그를 분석해줘" --max-budget-usd 0.50
```

CI/CD 환경에서 예상치 못한 비용 증가를 방지합니다.

---

## 셸 스크립트에서의 활용

### CI 린트 스크립트

```bash
#!/bin/bash
# ci-lint.sh

git diff origin/main | \
  claude -p "보안 및 코드 품질 이슈를 확인해줘" \
  --output-format json \
  --max-budget-usd 0.50 \
  > lint-output.json

# 이슈 확인
if jq -e '.[] | select(.type=="assistant")' lint-output.json > /dev/null; then
  echo "리뷰 결과가 생성되었습니다"
  cat lint-output.json | jq -r '.[] | select(.type=="assistant") | .content'
fi
```

### Pre-commit 훅

```bash
#!/bin/bash
# .git/hooks/pre-commit

files=$(git diff --cached --name-only --diff-filter=ACM | grep "\.py$")

for file in $files; do
  result=$(cat "$file" | claude -p \
    "보안 취약점이 있으면 알려줘. 없으면 OK만 출력해줘" \
    --max-turns 1)
  if [ "$result" != "OK" ]; then
    echo "보안 이슈 발견: $file"
    echo "$result"
    exit 1
  fi
done
```

### 빌드 분석 스크립트

```bash
#!/bin/bash
# build-analyze.sh

npm run build 2>&1 | \
  claude -p "빌드 에러를 분석하고 수정 방법을 제안해줘" \
  --output-format text \
  > build-analysis.md

echo "빌드 분석이 build-analysis.md에 저장되었습니다"
```

### 에러 처리

```bash
#!/bin/bash

claude -p "코드를 분석해줘" > output.txt
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo "Claude Code 실행 실패 (종료 코드: $exit_code)"
  exit 1
fi
```

---

## CI/CD 통합

### GitHub Actions

```yaml
name: Claude Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Claude Code 리뷰
        run: |
          git diff origin/main > changes.diff
          claude -p "이 변경을 보안, 성능, 모범 사례 관점에서 리뷰해줘" \
            < changes.diff \
            --max-budget-usd 1.00 \
            > review.md
      - name: PR에 코멘트
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

### Claude Code Action

GitHub Actions에서 더 쉽게 사용할 수 있는 공식 액션:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    prompt: "이 PR을 리뷰해줘"
    max-budget-usd: 1.00
```

### Makefile 통합

```makefile
.PHONY: lint review

lint:
	@git diff origin/main | \
		claude -p "코드 이슈를 확인해줘" \
		--max-turns 3

review:
	@git diff origin/main | \
		claude -p "코드 리뷰해줘" \
		--output-format json > review-output.json
```

---

## 환경 변수로 동작 제어

CI/CD 환경에서 환경 변수로 Claude의 동작을 제어합니다:

```bash
# 읽기 전용 모드
export CLAUDE_CODE_PERMISSION_MODE=plan

# 모델 지정
export ANTHROPIC_MODEL=claude-haiku-4-5-20251001

# 백그라운드 태스크 비활성화
export CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1

# 자동 업데이트 비활성화
export DISABLE_AUTOUPDATER=1

# 실행
claude -p "분석해줘"
```

---

## 실전 자동화 패턴

### 일일 코드 품질 리포트

```bash
#!/bin/bash
# daily-report.sh

claude -p "$(cat <<'EOF'
다음 항목을 확인하고 리포트를 작성해줘:
1. TODO 주석 개수와 위치
2. 사용되지 않는 import
3. 테스트 커버리지가 낮은 파일
4. 잠재적 보안 이슈
EOF
)" --output-format text > daily-report.md
```

### 자동 문서 생성

```bash
#!/bin/bash
# generate-docs.sh

for file in src/api/*.ts; do
  claude -p "이 파일의 API 문서를 마크다운으로 생성해줘" \
    < "$file" \
    >> api-docs.md
done
```

### 마이그레이션 검증

```bash
#!/bin/bash
# validate-migration.sh

claude -p "$(cat <<'EOF'
이 데이터베이스 마이그레이션을 검증해줘:
- 롤백 가능한지
- 데이터 손실 위험이 있는지
- 인덱스가 적절한지
- 대용량 테이블에서 성능 이슈가 있는지
EOF
)" < migrations/latest.sql \
  --max-budget-usd 0.50
```

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **`-p` 플래그** | 비대화형 모드, 결과 출력 후 종료 |
| **출력 형식** | text (기본), json, stream-json |
| **파이프라인** | `cat file \| claude -p "분석"` 패턴 |
| **`--json-schema`** | 구조화된 JSON 출력 강제 |
| **제한** | `--max-turns`, `--max-budget-usd`로 제어 |
| **CI/CD** | GitHub Actions, GitLab CI, Makefile 통합 |
| **환경 변수** | 권한, 모델, 동작을 환경 변수로 제어 |
| **자동화 패턴** | 린트, 리뷰, 문서 생성, 마이그레이션 검증 |

---

## 다음 챕터

Part V: 고급 기능에서 [19장: Skills 개발](../05-advanced/01-skills.md)을 통해 커스텀 명령어를 만드는 방법을 배웁니다.
