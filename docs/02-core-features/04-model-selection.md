<!-- last_updated: 2026-02-11 -->

# 8. 모델 선택과 전환

> 상황에 맞는 모델 선택 전략과 전환 방법, 프롬프트 캐싱, 클라우드 프로바이더 설정을 다룹니다.

---

## 사용 가능한 모델

Claude Code는 세 가지 모델을 지원합니다.

### Claude Opus 4.6 — 최강의 추론

| 항목 | 내용 |
|------|------|
| **모델 ID** | `claude-opus-4-6` |
| **별칭** | `opus` |
| **컨텍스트 윈도우** | 200K (기본) / 1M (베타) |
| **최대 출력** | 128K 토큰 |
| **적응형 추론** | 지원 (Low/Medium/High) |
| **가격** | $5 / 1M 입력, $25 / 1M 출력 |
| **지식 기준일** | 2025년 5월 (신뢰), 2025년 8월 (훈련) |
| **적합한 용도** | 아키텍처 결정, 복잡한 디버깅, 대규모 리팩토링, 멀티스텝 계획 |

### Claude Sonnet 4.5 — 속도와 품질의 균형

| 항목 | 내용 |
|------|------|
| **모델 ID** | `claude-sonnet-4-5-20250929` |
| **별칭** | `sonnet` |
| **컨텍스트 윈도우** | 200K (기본) / 1M (베타) |
| **최대 출력** | 64K 토큰 |
| **가격** | $3 / 1M 입력, $15 / 1M 출력 |
| **지식 기준일** | 2025년 1월 (신뢰), 2025년 7월 (훈련) |
| **적합한 용도** | 일상적 코딩, 기능 구현, 버그 수정, 코드 리뷰 |

### Claude Haiku 4.5 — 빠르고 효율적

| 항목 | 내용 |
|------|------|
| **모델 ID** | `claude-haiku-4-5-20251001` |
| **별칭** | `haiku` |
| **컨텍스트 윈도우** | 200K |
| **최대 출력** | 64K 토큰 |
| **가격** | $1 / 1M 입력, $5 / 1M 출력 |
| **지식 기준일** | 2025년 2월 (훈련) |
| **적합한 용도** | 간단한 질문, 빠른 검색, 서브에이전트 백그라운드 처리 |

---

## 모델 별칭

별칭을 사용하면 항상 최신 버전의 모델을 가리킵니다.

| 별칭 | 대상 | 설명 |
|------|------|------|
| `default` | 계정 유형에 따라 다름 | Max/Teams: Opus, Pro: Opus |
| `opus` | Claude Opus 4.6 | 최신 Opus |
| `sonnet` | Claude Sonnet 4.5 | 최신 Sonnet |
| `haiku` | Claude Haiku 4.5 | 최신 Haiku |
| `opusplan` | Opus + Sonnet | 하이브리드 모드 (아래 설명) |
| `opus[1m]` | Opus 4.6 (1M 컨텍스트) | 100만 토큰 컨텍스트 |
| `sonnet[1m]` | Sonnet 4.5 (1M 컨텍스트) | 100만 토큰 컨텍스트 |

> **특정 버전 고정**: 버전을 고정하려면 전체 모델 ID를 사용하세요 (예: `claude-sonnet-4-5-20250929`). 별칭은 업데이트 시 자동으로 최신 버전을 가리킵니다. 모델 ID의 날짜 접미사(예: `20250929`)는 새 버전 출시 시 변경될 수 있으므로, 최신 ID는 [Anthropic 공식 문서](https://docs.anthropic.com/en/docs/about-claude/models)에서 확인하세요.

---

## 모델 전환 방법

5가지 방법이 있으며, **우선순위가 높은 순서**로 나열합니다:

### 1. `/model` 커맨드 (최우선)

세션 중 즉시 전환합니다:

```
> /model opus
> /model sonnet
> /model haiku
> /model opusplan
> /model sonnet[1m]
```

- 현재 응답 생성 중에도 전환할 수 있습니다
- Opus 4.6 선택 시 **좌/우 화살표**로 노력 수준을 조절합니다
- 인자 없이 `/model`을 입력하면 선택 화면이 나타납니다

### 2. `--model` CLI 플래그 (두 번째)

Claude Code 시작 시 모델을 지정합니다:

```bash
claude --model opus
claude --model sonnet[1m]
claude --model claude-opus-4-6     # 전체 모델 ID
```

### 3. `ANTHROPIC_MODEL` 환경 변수 (세 번째)

```bash
export ANTHROPIC_MODEL=opus
export ANTHROPIC_MODEL=sonnet[1m]
export ANTHROPIC_MODEL=claude-sonnet-4-5-20250929

# 셸 프로파일에 영구 설정
echo 'export ANTHROPIC_MODEL=opus' >> ~/.zshrc
```

### 4. Settings 파일 (네 번째)

```json
// .claude/settings.json (프로젝트별)
// 또는 ~/.claude/settings.json (전역)
{
  "model": "opus"
}
```

### 5. Option+P / Alt+P 단축키

세션 중 빠르게 모델을 전환합니다:

| 플랫폼 | 단축키 |
|--------|--------|
| **macOS** | Option+P |
| **Windows/Linux** | Alt+P |

- 현재 입력 중인 프롬프트는 유지됩니다
- `/terminal-setup` 실행 후 사용할 수 있습니다

---

## Opusplan 하이브리드 모드

`opusplan`은 두 모델의 장점을 결합하는 특별한 별칭입니다:

```
Plan 모드 (코드 분석, 계획 수립) → Opus 4.6 사용
실행 모드 (코드 작성, 구현)     → Sonnet 4.5 사용
```

### 왜 Opusplan을 사용하는가?

| 단계 | 필요한 능력 | 적합한 모델 |
|------|------------|-------------|
| 아키텍처 설계 | 깊은 추론 | Opus |
| 요구사항 분석 | 맥락 파악 | Opus |
| 코드 구현 | 빠른 생성 | Sonnet |
| 테스트 작성 | 패턴 따르기 | Sonnet |
| 리팩토링 계획 | 전략적 판단 | Opus |

### 활성화 방법

```bash
# CLI 시작 시
claude --model opusplan

# 세션 중
> /model opusplan

# 환경 변수
export ANTHROPIC_MODEL=opusplan
```

### 비용 효과

Opusplan은 전체를 Opus로 사용하는 것보다 비용이 절감됩니다:

```
전체 Opus:    계획(Opus $5/$25) + 구현(Opus $5/$25) = 높은 비용
Opusplan:     계획(Opus $5/$25) + 구현(Sonnet $3/$15) = 절감된 비용
```

복잡한 프로젝트에서 계획에는 전체 토큰의 20~30%만 사용되므로, 나머지 70~80%의 실행 비용이 크게 줄어듭니다.

---

## 1M 토큰 확장 컨텍스트

### `[1m]` 접미사

모델 별칭에 `[1m]`을 붙이면 100만 토큰 컨텍스트로 전환됩니다:

```bash
claude --model opus[1m]
claude --model sonnet[1m]

# 세션 중
> /model sonnet[1m]
```

### 지원 모델

| 모델 | 1M 컨텍스트 | 기본 컨텍스트 |
|------|:-----------:|:------------:|
| Opus 4.6 | 지원 (베타) | 200K |
| Sonnet 4.5 | 지원 (베타) | 200K |
| Haiku 4.5 | 미지원 | 200K |

### 언제 1M 컨텍스트가 필요한가

- **대규모 코드베이스 분석**: 수백 개의 파일을 한 번에 이해해야 할 때
- **긴 세션**: 여러 시간에 걸친 복잡한 작업에서 컨텍스트 손실을 줄이고 싶을 때
- **대용량 파일**: 매우 긴 로그 파일이나 데이터 파일을 분석할 때

### 주의사항

- 200K 토큰을 초과하는 요청에는 **장문 컨텍스트 가격**이 적용됩니다
- 현재 **베타** 상태이며, 일부 플랜에서는 사용할 수 없을 수 있습니다
- 컨텍스트가 커질수록 응답 시간이 길어질 수 있습니다

---

## Fast 모드

Opus 4.6에서 더 빠른 응답을 위한 모드입니다.

### 활성화

```
> /fast
```

- 활성화되면 상태 표시줄에 `↯` 아이콘이 나타납니다
- 동일한 Opus 4.6 모델을 사용하지만 출력 속도가 빠릅니다
- 다시 `/fast`를 입력하면 비활성화됩니다

### Fast 모드 동작

```
일반 모드:  Opus 4.6 → 표준 속도
Fast 모드:  Opus 4.6 → 빠른 출력 (동일 모델)
```

### 레이트 리밋 시 동작

Fast 모드에서 레이트 리밋에 도달하면:

1. **자동으로 표준 Opus 4.6으로 폴백**
2. `↯` 아이콘이 회색으로 변하여 쿨다운 상태를 표시
3. 작업은 계속 진행됩니다 (중단되지 않음)
4. 쿨다운이 끝나면 **자동으로 Fast 모드가 재활성화**

---

## 프롬프트 캐싱

### 자동 캐싱

Claude Code는 **프롬프트 캐싱을 자동으로 활성화**합니다. 별도의 설정이 필요 없습니다.

캐싱이 적용되는 대상:
- **CLAUDE.md 파일** — 매 요청마다 포함되므로 캐싱 효과가 큼
- **반복되는 파일 컨텍스트** — 같은 파일을 여러 번 참조할 때
- **대화 히스토리** — 이전 턴의 내용이 캐시됨
- **시스템 프롬프트** — 도구 정의 등

캐싱으로 입력 토큰 비용이 상당히 절감됩니다.

### 캐싱 비활성화

특수한 상황에서 캐싱을 끌 수 있습니다:

```bash
# 전역 비활성화
export DISABLE_PROMPT_CACHING=1

# 모델별 비활성화
export DISABLE_PROMPT_CACHING_HAIKU=1
export DISABLE_PROMPT_CACHING_SONNET=1
export DISABLE_PROMPT_CACHING_OPUS=1
```

> **참고**: `DISABLE_PROMPT_CACHING` (전역)이 모델별 설정보다 우선합니다.

---

## 클라우드 프로바이더별 설정

Anthropic API 외에 세 가지 클라우드 프로바이더를 통해 Claude Code를 사용할 수 있습니다.

### Amazon Bedrock

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1

# 기본 모델 변경
export ANTHROPIC_MODEL='global.anthropic.claude-sonnet-4-5-20250929-v1:0'
```

Bedrock에서의 모델 ID 형식:
- `global.anthropic.claude-sonnet-4-5-20250929-v1:0`
- `us.anthropic.claude-haiku-4-5-20251001-v1:0`
- 추론 프로파일 ID 또는 애플리케이션 추론 프로파일 ARN 사용 가능

### Google Vertex AI

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
```

Vertex AI에서의 모델 ID 형식:
- `claude-sonnet-4-5@20250929`
- `claude-haiku-4-5@20251001`
- `claude-opus-4-6`

1M 컨텍스트: `context-1m-2025-08-07` 베타 헤더로 지원 (Sonnet 4.5, Opus 4.6).

### Microsoft Foundry

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE={resource}
# 또는
export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic

# 기본 모델 지정
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-5'
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-6'
```

인증 방법:
- API 키: `ANTHROPIC_FOUNDRY_API_KEY`
- Microsoft Entra ID: Azure SDK 자격 증명 체인

---

## 모델 선택 전략

### 상황별 추천

| 상황 | 추천 모델 | 이유 |
|------|-----------|------|
| 아키텍처 설계 | `opus` | 깊은 추론으로 최적의 설계 |
| 일상적 코딩 | `sonnet` | 속도와 품질의 균형 |
| 간단한 질문/검색 | `haiku` | 빠르고 저렴 |
| 복잡한 프로젝트 | `opusplan` | 계획은 Opus, 실행은 Sonnet |
| 대규모 코드 분석 | `sonnet[1m]` | 넓은 컨텍스트 |
| 긴급한 작업 | `opus` + `/fast` | 최대 속도 |
| CI/CD 자동화 | `haiku` 또는 `sonnet` | 비용 효율적 |

### 비용 최적화 원칙

```
1. 대부분의 작업은 sonnet으로 시작
2. 복잡한 문제가 나타나면 opus로 전환
3. 단순 반복 작업은 haiku로 전환
4. 계획+실행이 필요한 프로젝트는 opusplan 활용
5. /cost로 비용을 주기적으로 모니터링
```

### 레이트 리밋 시 자동 폴백

Claude Code는 레이트 리밋 상황에서 자동으로 모델을 전환합니다:

- Fast 모드: 표준 Opus 4.6으로 자동 폴백
- Opus 사용량 초과: Sonnet으로 자동 전환 가능
- 폴백은 투명하게 이루어지며 작업이 중단되지 않습니다

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **모델** | Opus 4.6 (최강), Sonnet 4.5 (균형), Haiku 4.5 (빠름) |
| **별칭** | `opus`, `sonnet`, `haiku`, `opusplan`, `sonnet[1m]`, `opus[1m]` |
| **전환 방법** | `/model`, `--model`, `ANTHROPIC_MODEL`, settings.json, Option+P |
| **우선순위** | `/model` > `--model` > 환경 변수 > settings 파일 |
| **Opusplan** | 계획은 Opus, 실행은 Sonnet — 비용 효율적 |
| **1M 컨텍스트** | `[1m]` 접미사, 대규모 코드베이스 분석에 유용 |
| **Fast 모드** | `/fast`로 토글, 레이트 리밋 시 자동 폴백 |
| **캐싱** | 자동 활성화, `DISABLE_PROMPT_CACHING`으로 비활성화 |
| **클라우드** | Bedrock, Vertex AI, Foundry 지원 |

---

## 다음 파트

Part II의 핵심 기능을 모두 배웠습니다. [Part III: 설정 심화](../03-configuration/01-claude-md.md)에서 CLAUDE.md, 권한 시스템, Rules, 메모리 관리 등 Claude Code를 프로젝트에 최적화하는 방법을 다룹니다.
