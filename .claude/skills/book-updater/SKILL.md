---
name: book-updater
description: "Claude Code 가이드북을 최신 릴리스에 맞춰 갱신하는 에이전트 팀 파이프라인. '업데이트 확인하고 적용해줘', 'Claude Code 최신 버전 반영', '변경사항 반영', '릴리스 반영', '책 업데이트', '신규 버전 조사', '다시 반영', '재실행', '이 부분만 다시 업데이트' 등 이 가이드북(claude-code-book)의 최신화 요청 전반에 이 스킬을 사용한다. 릴리스 추적 → 사실 교차검증 → 문서 반영 → 정합성 검증 → 버전/CHANGELOG/링크 관리를 팀이 협업하여 수행한다. 단순 개념 질문(예: '캐시 히트가 뭐야')은 직접 응답 가능하며, 새 챕터를 처음부터 집필하는 것은 이 스킬의 범위가 아니다."
---

# Book Updater — 가이드북 최신화 파이프라인

Claude Code(Anthropic CLI)의 신규 릴리스를 추적하여, 이 한국어 가이드북에 정확하게 반영하고 버전을 확정하는 에이전트 팀 워크플로우.

## 실행 모드

**에이전트 팀** — 5명이 SendMessage로 직접 통신하며 교차 검증한다. 릴리스 추적과 반영은 생성-검증(producer-reviewer) 성격이 강하므로, 검증자(fact-verifier, consistency-reviewer)가 생성자(release-tracker, doc-updater)와 실시간으로 조율한다.

## 에이전트 구성

| 에이전트 | 파일 | 역할 | 타입 |
|---------|------|------|------|
| release-tracker | `.claude/agents/release-tracker.md` | 신규 CLI 릴리스 델타 조사 | general-purpose |
| fact-verifier | `.claude/agents/fact-verifier.md` | 2-소스 교차검증, 환각 차단 | general-purpose |
| doc-updater | `.claude/agents/doc-updater.md` | 한국어 문서 반영, 챕터 배치 | general-purpose |
| consistency-reviewer | `.claude/agents/consistency-reviewer.md` | 교차 챕터 정합성 QA, 링크 검사 | general-purpose |
| version-keeper | `.claude/agents/version-keeper.md` | VERSION·CHANGELOG·빌드 확정 | general-purpose |

모든 Agent 호출은 `model: "opus"`로 실행한다.

## Phase 1: 컨텍스트 확인 (오케스트레이터 직접 수행)

먼저 실행 유형을 판별한다:

1. **기준선 파악**: `VERSION`과 `CHANGELOG.md` 최상단(`> Claude Code X ~ Y 반영`)을 읽어 책이 현재 커버하는 CLI 버전을 확인한다
2. **기존 산출물 확인**:
   - `_workspace/` 없음 → **초기 실행** (전체 파이프라인)
   - `_workspace/` 있음 + 사용자가 부분 수정 요청("이 부분만 다시") → **부분 재실행** (해당 에이전트만 재호출)
   - `_workspace/` 있음 + 새 조사 요청 → **새 실행** (기존 `_workspace/`를 `_workspace_prev/`로 이동 후 시작)
3. `_workspace/00_input.md`에 요청·기준선·실행 유형을 정리한다
4. 사용자 요청이 "확인만"인지 "확인하고 반영"인지 구분한다:
   - **확인만** → Phase 2까지 실행 후 델타·검증 결과 보고, 반영 여부를 사용자에게 확인
   - **확인하고 반영** → 전체 파이프라인 실행

## Phase 2: 릴리스 추적 및 검증 (생성-검증)

| 순서 | 작업 | 담당 | 의존 | 산출물 |
|------|------|------|------|--------|
| 1 | 릴리스 델타 조사 | release-tracker | 없음 | `_workspace/01_release_delta.md` |
| 2 | 사실 교차검증 | fact-verifier | 작업 1 | `_workspace/02_verification.md` |

- release-tracker가 델타를 완성하면 fact-verifier에게 전달한다
- fact-verifier가 `[확인 필요]`·환각 의심 항목을 발견하면 release-tracker에게 재조사를 요청한다 (최대 2회)
- **확정 목록**만 다음 Phase로 넘어간다

## Phase 3: 문서 반영 및 정합성 검증 (생성-검증, 점진적 QA)

| 순서 | 작업 | 담당 | 의존 | 산출물 |
|------|------|------|------|--------|
| 3 | 문서 반영 | doc-updater | 작업 2 | `docs/**/*.md` 편집 + `_workspace/03_doc_changes.md` |
| 4 | 정합성 검증 | consistency-reviewer | 작업 3 (점진적) | `_workspace/04_consistency_report.md` |

- doc-updater는 확정 목록만 반영한다. 기각 항목은 절대 넣지 않는다
- consistency-reviewer는 **모듈 완성 즉시** 교차 정합성을 검증한다 (전체 완료 후 1회가 아님)
- 🔴 필수 수정(모순·깨진 링크) 발견 시 doc-updater에게 즉시 수정 요청 → 재작업 → 재검증 (최대 2회)
- consistency-reviewer는 `scripts/check-links.sh`를 실제 실행하여 링크 무결성을 확인한다

## Phase 4: 버전 확정 (오케스트레이터 + version-keeper)

정합성 통과(🟢, 또는 🟡 수정 반영) 후:

1. version-keeper가 `VERSION`을 올리고 `CHANGELOG.md`에 항목을 추가한다
2. 모든 수정 문서의 `last_updated`를 이번 반영 날짜로 통일 확정한다
3. `check-links.sh`, `build.sh`를 실행하여 최종 무결성을 확인한다
4. `_workspace/05_release_summary.md`에 릴리스 요약을 기록한다

## Phase 5: 보고 및 진화

1. 사용자에게 최종 요약을 보고한다:
   - 신규 CLI 버전 범위, 헤드라인 변경
   - 수정 문서 목록, 책 버전 변화, CHANGELOG 항목
   - check-links / build 결과
2. **커밋은 사용자가 명시적으로 요청할 때만** 수행한다. `.claude/settings.local.json` 등 로컬 설정은 스테이징에서 제외한다
3. 피드백을 요청한다 — 반영 누락·톤·챕터 배치에 개선점이 있는지 확인하고, 있으면 하네스에 반영한다

## 작업 규모별 모드

| 사용자 요청 패턴 | 실행 모드 | 투입 에이전트 |
|----------------|----------|-------------|
| "업데이트 확인하고 적용해줘" | **풀 파이프라인** | 5명 전원 |
| "신규 버전 있는지만 확인해줘" | **조사 모드** | release-tracker + fact-verifier |
| "이 델타 반영해줘" (검증 완료본 제공) | **반영 모드** | doc-updater + consistency-reviewer + version-keeper |
| "이 문서만 정합성 확인해줘" | **QA 모드** | consistency-reviewer 단독 |
| "버전만 올리고 CHANGELOG 정리해줘" | **버전 모드** | version-keeper 단독 |
| "지난번 반영에서 이 항목만 다시" | **부분 재실행** | 해당 에이전트만 |

## 데이터 전달 프로토콜

| 전략 | 방식 | 용도 |
|------|------|------|
| 파일 기반 | `_workspace/` 디렉토리 | 델타·검증·반영내역 등 주요 산출물 |
| 메시지 기반 | SendMessage | 재조사 요청, 🔴 수정 요청, 정정 공유 |
| 태스크 기반 | TaskCreate/TaskUpdate | Phase 의존 관계·진행상황 추적 |

파일명 컨벤션: `{순번}_{산출물}.md` (예: `01_release_delta.md`)
중간 산출물(`_workspace/`)은 보존한다 — 사후 검증·다음 릴리스 기준선 추적용.

## 에러 핸들링

| 에러 유형 | 전략 |
|----------|------|
| 출처 접근 불가 | 접근 가능 출처로 진행, 누락 명시 |
| 환각 의심 항목 | fact-verifier가 기각, 절대 반영하지 않음 |
| 단일출처 항목 | 신중 반영(버전 병기), 최종 보고서에 명시 |
| 교차 챕터 모순 | fact-verifier 판정 확인 후 수정, 임의 판단 금지 |
| check-links/build 실패 | 버전 확정 보류, doc-updater에 반려 |
| 에이전트 실패 | 1회 재시도 → 해당 산출물 없이 진행, 보고서에 누락 명시 |

## 테스트 시나리오

### 정상 흐름 (풀 파이프라인)
**프롬프트**: "업데이트 사항을 확인하고 적용해줘."
**기대 결과**:
- release-tracker: VERSION/CHANGELOG 기준선 이후 신규 CLI 버전 델타 조사
- fact-verifier: 2-소스 교차검증, 환각·중복 제거, 확정 목록 생성
- doc-updater: 확정 항목을 해당 챕터에 반영, last_updated 갱신
- consistency-reviewer: 교차 챕터 정합성 확인, check-links.sh 실행
- version-keeper: VERSION↑, CHANGELOG 항목 추가, 최종 요약
- 커밋은 사용자 요청 전까지 대기

### 조사 모드 흐름
**프롬프트**: "새로 나온 Claude Code 버전 있는지만 확인해줘."
**기대 결과**: release-tracker + fact-verifier만 투입, 델타·검증 결과 보고 후 반영 여부 질의

### 에러 흐름
**프롬프트**: "업데이트 반영해줘" (조사해 보니 신규 버전 없음)
**기대 결과**: release-tracker가 "기준선 이후 신규 릴리스 없음"을 보고, 파이프라인 조기 종료, 불필요한 반영 방지

## 에이전트별 확장 스킬

| 확장 스킬 | 경로 | 대상 에이전트 | 역할 |
|----------|------|-------------|------|
| changelog-research | `.claude/skills/changelog-research/SKILL.md` | release-tracker, fact-verifier | 공식 출처·2-소스 교차확인 방법 |
| book-style-guide | `.claude/skills/book-style-guide/SKILL.md` | doc-updater | 문체·표 형식·챕터 매핑·버전 표기 규칙 |
| doc-consistency-checks | `.claude/skills/doc-consistency-checks/SKILL.md` | consistency-reviewer, version-keeper | 교차 정합성 규칙·스크립트 실행·버전 정책 |
