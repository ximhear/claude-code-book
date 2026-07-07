---
name: doc-consistency-checks
description: "가이드북의 교차 챕터 정합성 규칙과 링크·빌드 스크립트 실행법, 버전 정책. consistency-reviewer가 문서 간 모순을 검증하고, version-keeper가 VERSION·CHANGELOG를 확정할 때 사용한다. check-links.sh/build.sh 실행, last_updated 통일, SemVer 규칙을 다룬다."
---

# Doc Consistency Checks — 정합성·버전 검증

여러 문서에 걸친 정합성을 교차 검증하고, 링크·빌드 무결성을 확인하며, 버전 메타데이터를 확정하는 방법.

## 왜 교차 검증인가

단일 문서의 사실 정확성은 fact-verifier가 이미 보장했다. 이 책에서 가장 흔한 결함은 **같은 사실이 여러 장에서 다르게 서술되는 것**이다. 예: 새 모델이 8장에는 "기본 노력 high", 부록 D 용어집에는 "기본 노력 medium"으로 적히는 식. 따라서 검증의 핵심은 "존재 확인"이 아니라 **경계면 교차 비교**다.

## 교차 챕터 정합성 절차 (consistency-reviewer)

1. **등장 위치 수집**: 이번에 반영된 각 기능·모델·용어를 `grep -rn "키워드" docs/`로 검색하여 등장하는 **모든** 문서를 나열한다
2. **다중 등장 대조**: 두 문서 이상에 나오면, 다음이 일치하는지 대조한다
   - 이름·철자 (모델 ID, 커맨드명, 설정 키)
   - 도입 버전 표기 `(2.1.x)`
   - 핵심 동작·기본값 서술
3. **불일치 = 🔴 필수 수정**: 어느 쪽이 맞는지 fact-verifier 판정을 확인한 뒤 doc-updater에 수정 요청 (임의 판단 금지)

## 용어·표기 일관성

- 신규 용어가 `docs/08-appendix/d-glossary.md`에 등재됐는가
- 본문 용어가 용어집 표기와 일치하는가
- 장 하단 **요약 표**가 본문과 일치하는가 (본문만 고치고 요약 표를 방치하는 실수가 잦다)

## last_updated 통일

이번 반영에서 수정한 **모든** 문서의 헤더가 동일 날짜인지 확인한다:

```bash
grep -rL "last_updated" docs/ | grep '\.md$'   # 헤더 누락 문서
grep -rn "last_updated" docs/ | sort            # 날짜 분포 확인
```

불일치 시 통일 날짜를 정하고 doc-updater에 일괄 갱신을 요청한다.

## 스크립트 실행 (읽기만으로 판단하지 않는다)

### 링크 검사 — 반드시 실행
```bash
bash scripts/check-links.sh
```
- `All links OK`가 아니면 🔴 필수 수정. 깨진 링크의 파일·대상을 명시하여 doc-updater에 반려한다

### 병합 빌드 — version-keeper가 최종 확정 시 실행
```bash
bash scripts/build.sh
```
- 실패 시 원인(누락 파일·문법)을 파악하여 해당 에이전트에 반려한다

## 버전 정책 (version-keeper)

프로젝트 규약: **VERSION 파일 + CHANGELOG.md + last_updated 헤더** 3종을 함께 관리한다.

### SemVer 규칙
| 반영 규모 | 버전 증가 | 예 |
|----------|----------|-----|
| 새 CLI 릴리스 반영 (기능 추가·변경) | minor | 0.10.0 → 0.11.0 |
| 오탈자·소규모 정정만 | patch | 0.11.0 → 0.11.1 |
| 대규모 구조 개편 | major | 0.x → 1.0.0 |

### CHANGELOG 항목 (최상단에 추가)
```markdown
## [0.11.0] - 2026-05-30
> Claude Code 2.1.149 ~ 2.1.157 반영

### Added
- ...
### Changed
- ...
### Deprecated
- ...
```

`> Claude Code X ~ Y 반영` 줄은 **다음 릴리스 추적의 기준선**이 되므로 반드시 CLI 버전 범위를 정확히 적는다.

## 확정 전제 조건

version-keeper는 다음이 모두 참일 때만 버전을 확정한다:
- [ ] consistency-reviewer 정합성 통과 (🟢, 또는 🟡 수정 반영 완료)
- [ ] `check-links.sh` → All links OK
- [ ] `build.sh` → 성공
- [ ] 수정 문서 last_updated 통일 완료
- [ ] VERSION↑, CHANGELOG 항목 추가 완료

하나라도 실패하면 버전을 올리지 않고 해당 에이전트에 반려한다.

## 커밋 정책

- 커밋·푸시는 **사용자가 명시적으로 요청할 때만** 수행한다 (자동 금지)
- 스테이징 시 `.claude/settings.local.json` 등 로컬 설정은 제외한다
