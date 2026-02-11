<!-- last_updated: 2026-02-11 -->

# 33. 실전 사례: Claude Code로 이 책을 만든 과정

> 이 책 자체가 Claude Code로 만들어졌습니다. 10,000줄 이상의 기술 서적을 만들며 사용한 실제 기법을 공개합니다.

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| **결과물** | 32장 + 부록 5개, 38개 마크다운 파일, 10,537줄 |
| **작업 방식** | Claude Code 대화형 세션 (Opus 4.6) |
| **핵심 기법** | 병렬 리서치 에이전트, 반복 빌드 검증, 세션 연속성 |
| **총 세션** | 3회 (컨텍스트 소진으로 세션 전환) |

---

## 기법 1: 프로젝트 스캐폴딩 — 구조 먼저, 내용 나중에

### 왜 이렇게 했나

10,000줄이 넘는 콘텐츠를 한 번에 쓸 수 없습니다. 먼저 전체 구조를 확정하고, 각 챕터는 스켈레톤(제목 + 섹션 헤더)만 배치한 후, 하나씩 채워 나갔습니다.

### 실제 과정

```bash
# 1단계: 디렉토리 구조 생성
mkdir -p docs/{01-getting-started,02-core-features,...,08-appendix}

# 2단계: 스켈레톤 파일 생성 (제목과 섹션 헤더만)
# 각 파일에 챕터 번호, 제목, 주요 섹션 헤더만 배치

# 3단계: 빌드 스크립트 생성
cat scripts/build.sh  # 전체 병합 + 줄 수 확인

# 4단계: CLAUDE.md에 프로젝트 규칙 정의
```

### 핵심 교훈

> **"빈 파일 38개 > 완성된 파일 1개"**
>
> 전체 구조가 먼저 있으면, Claude Code가 각 챕터의 맥락(앞뒤 챕터, 전체 흐름)을 이해하고 일관된 내용을 작성할 수 있습니다.

### CLAUDE.md 설정

```markdown
# 프로젝트 지침

## 규칙
- 한국어로 작성
- last_updated 메타데이터 포함
- 각 챕터 끝에 "다음 챕터" 링크 추가
- 코드 예제는 실행 가능하게 작성

## 빌드
- bash scripts/build.sh

## 구조
- docs/01-getting-started/ ~ docs/08-appendix/
```

---

## 기법 2: 병렬 리서치 에이전트 — 조사와 집필 분리

### 왜 이렇게 했나

각 챕터를 쓰기 전에 최신 공식 문서를 정확히 파악해야 합니다. 리서치를 순차적으로 하면 시간이 오래 걸리므로, **여러 서브에이전트를 동시에 실행**하여 병렬로 조사했습니다.

### 서브에이전트의 작동 원리

사용자가 직접 에이전트를 하나씩 띄우는 것이 아닙니다. **Claude Code가 내부적으로 `Task` 도구를 사용**하여 서브에이전트를 생성합니다.

```
사용자 프롬프트:
> "Part V (챕터 19-24)의 내용을 작성하기 위해 리서치를 진행해줘"

Claude Code의 내부 처리 (하나의 응답에서 동시 호출):
┌─ Task(subagent_type="Explore", prompt="Research Skills system...")
├─ Task(subagent_type="Explore", prompt="Research Hooks system...")
├─ Task(subagent_type="general-purpose", prompt="Research MCP...")
└─ Task(subagent_type="Explore", prompt="Research Subagents...")
    ↓ 4개가 동시에 실행됨
    ↓ 각 에이전트의 결과가 메인 세션에 요약 반환
```

핵심 포인트:

- **자동 판단**: Claude Code가 작업 성격을 분석하여 적절한 에이전트 타입을 선택
- **동시 실행**: 한 응답에서 여러 `Task`를 호출하면 병렬로 실행됨
- **격리된 컨텍스트**: 각 에이전트는 별도 컨텍스트에서 작업하므로 메인 세션을 오염시키지 않음
- **결과 요약**: 에이전트가 반환한 결과만 메인 세션에 반영됨

### 에이전트는 어디에 등록되어 있나?

| 종류 | 위치 | 예시 |
|------|------|------|
| **내장 에이전트** | Claude Code에 포함 | `Explore`, `code-reviewer`, `Plan`, `Bash`, `code-architect`, `code-explorer`, `code-simplifier`, `general-purpose` |
| **프로젝트 커스텀** | `.claude/agents/*.md` | 보안 감사, 성능 분석 등 팀 전용 에이전트 |
| **사용자 커스텀** | `~/.claude/agents/*.md` | 개인 스타일에 맞춘 리뷰어 등 |

내장 에이전트는 별도 설정 없이 바로 사용 가능합니다. `/agents` 명령어로 사용 가능한 에이전트 목록을 확인할 수 있습니다.

### 병렬 실행을 유도하는 방법

사용자가 직접 에이전트를 지정할 필요는 없지만, **프롬프트 구조가 병렬 실행 여부에 영향**을 줍니다:

```
# ❌ 병렬 실행이 어려운 프롬프트 (하나의 연속 작업)
> Skills 시스템을 조사하고 그 결과를 바탕으로 챕터를 써줘

# ✅ 병렬 실행을 유도하는 프롬프트 (독립적인 항목 나열)
> 서브에이전트를 사용해서 동시에 조사해줘:
> 1. Skills 시스템
> 2. Hooks 시스템
> 3. MCP 서버 연동
> 4. 서브에이전트와 에이전트 팀

# ✅ 명시적으로 에이전트 타입 지정도 가능
> code-reviewer 에이전트로 보안 분석을 해줘
> Explore 에이전트로 API 구조를 파악해줘
```

**병렬 실행의 조건**:
- 각 항목이 **독립적**이어야 함 (서로의 결과에 의존하지 않음)
- **목록 형태**로 제시하면 Claude Code가 병렬 가능성을 인식
- "동시에", "병렬로" 같은 키워드가 도움이 됨

### 실제 사용 패턴

이 책에서 실제로 실행된 리서치 에이전트의 예:

```
[Task] Research Skills system          → Explore 에이전트
[Task] Research Hooks system           → Explore 에이전트
[Task] Research MCP integration        → general-purpose 에이전트
[Task] Research Subagents/Agent Teams  → Explore 에이전트
```

각 에이전트가 독립적으로:
1. 공식 문서 웹 페이지를 `WebFetch`로 수집
2. 관련 GitHub 저장소 탐색
3. 커뮤니티 가이드와 블로그 확인
4. 상세 리서치 보고서 반환

### 핵심 교훈

> **"4개 에이전트 × 2분 = 2분" (순차적이면 8분)**
>
> 독립적인 조사 작업은 반드시 병렬로 실행합니다. Claude Code는 한 응답에서 여러 `Task`를 호출하여 동시에 실행합니다.

### 효율 비교

```
순차 실행:  [A]────[B]────[C]────[D]────  ≈ 8분
병렬 실행:  [A]────┐
            [B]────┤
            [C]────┤  ≈ 2분
            [D]────┘
```

### 서브에이전트에게 좋은 프롬프트 주기

```
Research Claude Code's Skills system for a Korean-language book.
Cover:
1. SKILL.md structure and YAML frontmatter fields
2. Argument passing ($ARGUMENTS, $0, $1...)
3. Context modes (fork vs inherit)
4. Agent types available
5. Practical examples

Fetch official docs from code.claude.com.
Return a detailed report with specific examples.
```

핵심: **구체적인 항목을 나열**하고, **출처를 명시**하고, **상세 보고서 형태로 반환**을 요청합니다.

---

## 기법 3: 반복 빌드 검증 — 쓸 때마다 빌드

### 왜 이렇게 했나

38개 파일을 쓰면서 빌드가 깨지는지 즉시 확인해야 합니다. 각 파트 완료 후 빌드 스크립트를 실행하여 전체 줄 수와 오류를 확인했습니다.

### 실제 과정

```bash
# Part I (챕터 1-4) 완료 후
bash scripts/build.sh
# → Build complete: 2,847 lines

# Part II (챕터 5-8) 완료 후
bash scripts/build.sh
# → Build complete: 4,932 lines

# Part III (챕터 9-13) 완료 후
bash scripts/build.sh
# → Build complete: 6,105 lines

# ... 계속 증가 확인 ...

# 최종 빌드
bash scripts/build.sh
# → Build complete: 10,537 lines
```

### 핵심 교훈

> **"빌드를 자주 돌리면 문제를 일찍 잡는다"**
>
> 소프트웨어 개발의 CI와 같은 원칙입니다. Claude Code에서 `Bash` 도구로 빌드 스크립트를 자유롭게 실행할 수 있습니다.

---

## 기법 4: 컨텍스트 관리 — 세션 연속성 전략

### 왜 이렇게 했나

200K 토큰 컨텍스트 윈도우는 무한하지 않습니다. 이 프로젝트에서는 3번의 세션 전환이 발생했습니다:

```
세션 1: Part I-III (챕터 1-13) 작성 → 컨텍스트 소진
세션 2: Part IV-VIII (챕터 14-32, 부록) 작성 → 컨텍스트 소진
세션 3: 리뷰 및 최종 점검
```

### 세션 전환 시 컨텍스트 보존

컨텍스트가 소진되면 자동 압축(compaction)이 발생합니다. 이때 핵심 정보가 유지되도록 다음을 실천했습니다:

1. **CLAUDE.md에 프로젝트 상태 기록**: 어디까지 완료했는지 기록
2. **세션 요약이 상세하게 생성됨**: 자동 압축 시 파일 경로, 완료 상태, 다음 작업이 보존
3. **빌드 결과로 진행 상황 확인**: 줄 수로 객관적 진행 상태 파악

### 핵심 교훈

> **"큰 프로젝트는 세션 전환을 계획에 포함하라"**
>
> 각 세션에서 달성할 목표를 미리 정하고, 세션 끝에서 상태를 정리합니다.

### 세션 전환 전 체크리스트

```
1. 빌드 실행하여 현재 상태 확인
2. 완료된 챕터 목록 정리
3. 다음 세션에서 할 작업 명시
4. CLAUDE.md 업데이트
```

---

## 기법 5: Glob/Grep으로 빠른 파일 탐색

### 왜 이렇게 했나

38개 파일의 이름이 가끔 예상과 다를 때가 있었습니다. 예를 들어 `03-mcp.md`를 찾으려 했지만 실제 파일명은 `03-mcp-servers.md`였습니다.

### 실제 사용 패턴

```
# 파일명을 정확히 모를 때
Glob: docs/05-advanced/*.md
→ 01-skills.md, 02-hooks.md, 03-mcp-servers.md, ...

# 특정 키워드가 어느 파일에 있는지 찾을 때
Grep: "Agent Teams" → docs/05-advanced/05-agent-teams.md
```

### 핵심 교훈

> **"추측하지 말고, 검색하라"**
>
> 파일명이나 내용이 기억과 다를 수 있습니다. `Glob`과 `Grep`으로 확인 후 작업하면 실수를 방지합니다.

---

## 기법 6: 파트별 일괄 작성 — 배치 패턴

### 왜 이렇게 했나

하나의 파트에 속한 챕터들은 서로 참조하고 연결됩니다. 한 챕터씩 개별 작성하면 교차 참조가 어긋날 수 있으므로, **같은 파트의 챕터를 한 번에 작성**했습니다.

### 실제 과정

```
1. 리서치 에이전트로 파트 전체 조사 (병렬)
2. 파트의 모든 스켈레톤 파일 읽기 (병렬)
3. 챕터 순서대로 작성 (순차)
4. 파트 완료 후 빌드 검증
```

### 챕터 간 연결 관리

```markdown
<!-- 챕터 끝에 항상 다음 챕터 링크 -->
## 다음 챕터

[15장: Plan 모드](02-plan-mode.md)에서 읽기 전용 분석의 힘을 알아봅니다.
```

교차 참조 시 정확한 파일명을 사용하기 위해 `Glob`으로 실제 파일명을 확인합니다.

### 핵심 교훈

> **"관련 작업은 묶어서 처리하라"**
>
> 챕터 1개가 아닌 파트 단위로 작업하면 일관성이 높아집니다.

---

## 기법 7: 리뷰 에이전트로 품질 검증

### 왜 이렇게 했나

10,000줄을 사람이 한 줄씩 검토하기는 어렵습니다. 전체 책을 파트별로 나누어 **4개의 리뷰 에이전트가 동시에 검토**하도록 했습니다.

### 리뷰 에이전트 호출의 실제 메커니즘

리서치 에이전트(기법 2)와 마찬가지로, 사용자가 직접 에이전트를 4개 띄우는 것이 아닙니다:

```
사용자 프롬프트:
> "빌드된 책 전체를 훑어보고 빠진 내용이나 개선할 점 알려줘"

Claude Code의 내부 처리:
┌─ Task(subagent_type="code-reviewer",
│       prompt="Review Part I-II (Ch 1-8). Check completeness, accuracy...")
├─ Task(subagent_type="code-reviewer",
│       prompt="Review Part III-IV (Ch 9-18). Check completeness, accuracy...")
├─ Task(subagent_type="code-reviewer",
│       prompt="Review Part V-VI (Ch 19-28). Check completeness, accuracy...")
└─ Task(subagent_type="code-reviewer",
        prompt="Review Part VII-VIII (Ch 29+). Check completeness, accuracy...")
    ↓ 4개가 동시에 실행됨 (각각 독립된 컨텍스트)
    ↓ 각 에이전트가 담당 범위의 파일을 읽고 리뷰 보고서 반환
    ↓ 메인 세션에서 4개 보고서를 종합
```

**리서치(Explore)와 리뷰(code-reviewer)의 차이**:

| 구분 | 리서치 에이전트 | 리뷰 에이전트 |
|------|:-------------:|:------------:|
| **타입** | `Explore` 또는 `general-purpose` | `code-reviewer` |
| **주 도구** | WebFetch, WebSearch, Grep | Read, Grep, Glob |
| **목적** | 외부 정보 수집 | 기존 코드/문서 품질 검증 |
| **출력** | 조사 보고서 | 이슈 목록 (심각도별) |

### 실제 사용 패턴

```
[code-reviewer] Part I-II (Ch 1-8)     → 에이전트 A
[code-reviewer] Part III-IV (Ch 9-18)  → 에이전트 B
[code-reviewer] Part V-VI (Ch 19-28)   → 에이전트 C
[code-reviewer] Part VII-VIII (Ch 29+) → 에이전트 D
```

각 에이전트에게 구체적인 검증 기준을 부여했습니다:

```
For each chapter, analyze:
1. Completeness: Is anything important missing?
2. Accuracy: Are there factual errors?
3. Structure: Is the flow logical?
4. Examples: Are code examples correct?
5. Cross-references: Do links work?
```

### 리뷰 결과 종합

4개 에이전트가 반환한 리포트를 종합하여 우선순위별 이슈 목록을 만들었습니다:

| 우선순위 | 건수 | 예시 |
|----------|------|------|
| Critical | 4건 | 계층 순서 오류, 깨진 링크 |
| Important | 8건 | 누락 용어, 가격 검증 필요 |
| Moderate | 10건 | 상세 설명 보강, 예제 추가 |
| Minor | 5건 | 번역 용어 통일 |

### 핵심 교훈

> **"AI가 쓴 것은 AI가 리뷰할 수 있다"**
>
> `code-reviewer` 에이전트는 정확성, 완성도, 교차 참조를 체계적으로 검증합니다. 사람이 놓치기 쉬운 깨진 링크와 용어 불일치도 잡아냅니다.

---

## 기법 8: CLAUDE.md 활용 — 프로젝트 지식 누적

### 프로젝트 전용 CLAUDE.md

```markdown
# Claude Code 완벽 가이드

## 프로젝트 규칙
- 대상: Claude Code v2.1.x (2026년 2월)
- 언어: 한국어
- 모델: Opus 4.6, Sonnet 4.5, Haiku 4.5
- 각 챕터에 last_updated 메타데이터 포함
- 코드 예제는 실행 가능하게 작성
- 챕터 끝에 "다음 챕터" 링크 필수

## 빌드 명령어
bash scripts/build.sh

## 파일 구조
docs/01-getting-started/ (Part I: 시작하기)
docs/02-core-features/   (Part II: 핵심 기능)
...
```

### 핵심 교훈

> **"반복되는 지시는 CLAUDE.md에 넣어라"**
>
> "한국어로 써줘", "코드 예제를 넣어줘" 같은 반복 지시를 매번 프롬프트에 쓰지 않고 CLAUDE.md에 한 번만 정의합니다.

---

## 전체 워크플로우 다이어그램

```
[프로젝트 설정]
    ├─ CLAUDE.md 작성
    ├─ 디렉토리 구조 생성
    ├─ 빌드 스크립트 생성
    └─ 38개 스켈레톤 파일 배치
         │
         ▼
[파트별 반복] ×8
    ├─ 병렬 리서치 에이전트 실행
    │   ├─ WebFetch (공식 문서)
    │   ├─ WebSearch (커뮤니티)
    │   └─ 상세 보고서 반환
    │
    ├─ 스켈레톤 파일 읽기
    │
    ├─ 챕터 순차 작성
    │   ├─ Write 도구로 내용 작성
    │   └─ 교차 참조 링크 설정
    │
    └─ bash scripts/build.sh (빌드 검증)
         │
         ▼
[리뷰]
    ├─ 4개 리뷰 에이전트 병렬 실행
    ├─ 이슈 종합 및 우선순위 분류
    └─ 수정 작업
         │
         ▼
[완성] → 10,537줄
```

---

## 사용 기법 요약

| 기법 | 핵심 원칙 | 효과 |
|------|-----------|------|
| **스캐폴딩** | 구조 먼저, 내용 나중에 | 일관된 챕터 구성 |
| **병렬 리서치** | 독립 작업은 동시에 | 리서치 시간 75% 절감 |
| **반복 빌드** | 쓸 때마다 검증 | 문제 조기 발견 |
| **컨텍스트 관리** | 세션 전환을 계획에 포함 | 대규모 프로젝트 가능 |
| **Glob/Grep** | 추측하지 않고 검색 | 파일명 오류 방지 |
| **배치 작성** | 파트 단위로 작업 | 교차 참조 정확성 |
| **AI 리뷰** | AI가 쓴 것은 AI가 검증 | 체계적 품질 검증 |
| **CLAUDE.md** | 반복 지시는 파일에 | 프롬프트 간소화 |

---

## 이 기법이 적용 가능한 다른 프로젝트

| 프로젝트 유형 | 적용 기법 |
|---------------|-----------|
| **기술 문서** | 스캐폴딩 + 병렬 리서치 + 배치 작성 |
| **대규모 리팩토링** | 병렬 분석 + 반복 빌드 + 리뷰 에이전트 |
| **신규 프로젝트 생성** | 스캐폴딩 + CLAUDE.md + 컨텍스트 관리 |
| **레거시 코드 이해** | 병렬 리서치 + Glob/Grep |
| **테스트 스위트 작성** | 배치 작성 + 반복 빌드 검증 |
| **API 문서화** | 병렬 리서치 + 배치 작성 + AI 리뷰 |

---

## 다음 챕터

[부록 A: 단축키 모음](../08-appendix/a-keyboard-shortcuts.md)에서 모든 키보드 단축키를 한눈에 확인합니다.
