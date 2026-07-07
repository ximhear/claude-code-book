---
name: book-style-guide
description: "claude-code-book 가이드북의 문체·표 형식·챕터 매핑·버전 표기 규칙. doc-updater가 검증된 변경을 문서에 반영할 때 사용한다. 한국어 작성 규칙, 코드 블록 태그, last_updated 헤더, 기능별 챕터 배치, 도입 버전 병기 방식을 다룬다."
---

# Book Style Guide — 가이드북 반영 규칙

이 가이드북에 새 내용을 반영할 때 지켜야 할 문체·구조·배치 규칙. 기존 문서와 이질감 없이 편입하는 것이 목표다.

## 작성 규칙 (프로젝트 CLAUDE.md 기준)

- **한국어로 작성**한다. 영문 용어는 첫 등장 시 병기 가능 (예: 프롬프트 캐싱(prompt caching))
- **마크다운 형식**, 명령형 서술 ("~한다", "~하라")
- **코드 블록에 언어 태그 필수**: ` ```bash `, ` ```json `, ` ```markdown ` 등
- **초급 → 중급 → 고급 흐름** 유지 — 고급 기능을 초급 절에 끼워 넣지 않는다
- **실용 예제 포함** — 개념만 서술하지 말고 실제 사용 예를 곁들인다

## last_updated 헤더

모든 문서 상단 1행:

```markdown
<!-- last_updated: YYYY-MM-DD -->
```

- 문서를 수정하면 이 날짜를 **이번 반영 날짜**로 갱신한다
- 한 번의 반영에서 수정한 모든 문서는 **동일 날짜**로 통일한다

## 도입 버전 병기

새 릴리스에서 도입/변경된 기능은 도입 CLI 버전을 병기한다:

- 본문: "`/workflows`로 실행 목록을 확인한다 (2.1.154)"
- 표 행: `| /workflows | ... | 동적 워크플로 오케스트레이션 (2.1.154) |`
- 폐지: "~는 폐지되었다 (2026-06-01 제거)" 처럼 폐지·제거 시점 명기

## 기능별 챕터 매핑

| 변경 유형 | 대상 문서 |
|----------|----------|
| 슬래시 커맨드 | `docs/02-core-features/01-slash-commands.md` |
| 모델·노력 수준·Fast 모드 | `docs/02-core-features/04-model-selection.md` |
| settings.json·환경 변수·관리형 설정 | `docs/03-configuration/02-settings.md` |
| CLAUDE.md·메모리·Rules | `docs/03-configuration/01-claude-md.md`, `04-rules.md`, `05-memory.md` |
| 권한 | `docs/03-configuration/03-permissions.md` |
| 스킬 | `docs/05-advanced/01-skills.md` |
| 훅 | `docs/05-advanced/02-hooks.md` |
| 플러그인 | `docs/05-advanced/07-plugins.md` |
| 키보드 단축키 | `docs/08-appendix/a-keyboard-shortcuts.md` |
| CLI 플래그·서브커맨드 | `docs/08-appendix/b-cli-reference.md` |
| 신규 용어 | `docs/08-appendix/d-glossary.md` |

> 한 기능이 여러 장에 걸치면(예: 새 모델은 8장·부록 D·부록 B 모두), **각 장에 일관되게** 반영한다. consistency-reviewer가 이 교차 반영을 검증한다.

## 반영 방식

| 변경 성격 | 반영 방식 |
|----------|----------|
| 신규 기능 | 해당 문서에 새 섹션 또는 표 행 추가 + 각 장 하단 **요약 표**도 함께 갱신 |
| 기존 동작 변경 | 기존 서술을 수정 (도입 버전 병기), 필요 시 "이전에는 ~였다" 주석 |
| 폐지·제거 | deprecated 표기, 대체 방법 안내 |
| 사실 정정 | fact-verifier 판정 근거로 기존 오류를 바로잡는다 |

**요약 표를 잊지 않는다.** 본문만 고치고 장 하단 요약 표를 방치하면 정합성 결함이 된다 — 둘을 함께 갱신한다.

## 용어집 등재

새 개념·기능·모델을 반영하면 `docs/08-appendix/d-glossary.md`에 용어 항목을 **알파벳/가나다 순서**에 맞게 추가한다. 본문 용어는 용어집 표기와 일치시킨다.

## 버전 정책 연동

- 책 버전은 `VERSION` 파일, 이력은 `CHANGELOG.md`가 관리한다 (version-keeper 담당)
- doc-updater는 문서 본문의 도입 버전 병기와 last_updated만 책임진다. VERSION/CHANGELOG는 건드리지 않는다

## 단일출처 항목 처리

fact-verifier가 `단일출처`로 표시한 항목은:
- 단정적 서술을 피하고 도입 버전을 명기한다
- `_workspace/03_doc_changes.md`의 "미반영·보류"에 신중 반영 사실을 기록한다
