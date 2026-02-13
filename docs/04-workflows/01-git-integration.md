<!-- last_updated: 2026-02-11 -->

# 14. Git 통합과 PR 워크플로우

> 커밋, 브랜치, PR 생성 등 Git 관련 기능을 다룹니다.

---

## 체크포인팅 — 안전한 변경의 기반

Claude Code는 파일을 수정하기 전에 **자동으로 체크포인트를 생성**합니다. Git의 스냅샷과 유사하지만, Claude 세션에 특화된 메커니즘입니다.

### 체크포인트 동작 방식

```
사용자 프롬프트 입력
  ↓
Claude가 현재 파일 상태 스냅샷 저장
  ↓
파일 수정 (Edit, Write 등)
  ↓
다음 프롬프트에서 새 체크포인트 생성
```

- 모든 사용자 프롬프트마다 새로운 체크포인트가 생성됩니다
- 체크포인트는 30일간 보존됩니다
- `Esc` + `Esc` 또는 `/rewind`로 이전 상태로 복원할 수 있습니다

### 되돌리기 옵션

| 옵션 | 동작 |
|------|------|
| **코드와 대화 모두 복원** | 파일과 채팅 이력 모두 이전 상태로 |
| **대화만 복원** | 현재 코드 유지, 채팅만 되돌림 |
| **코드만 복원** | 파일만 이전 상태로, 채팅 유지 |
| **여기서부터 요약** | 선택 시점 이후 메시지 압축 |

체크포인트는 Git 커밋과 독립적이므로, 커밋하지 않은 변경도 안전하게 되돌릴 수 있습니다.

---

## 커밋 생성

### 자동 커밋 메시지

Claude에게 커밋을 요청하면 변경 사항을 분석하여 적절한 메시지를 작성합니다:

```
> 변경 사항을 커밋해줘
```

Claude의 커밋 워크플로우:

1. `git status`로 변경된 파일 확인
2. `git diff`로 변경 내용 분석
3. `git log`로 기존 커밋 메시지 스타일 파악
4. 변경의 목적을 파악하여 커밋 메시지 작성
5. 관련 파일만 선택적으로 `git add`
6. 커밋 생성

### 커밋 어트리뷰션

Claude가 생성한 커밋에는 자동으로 Co-Authored-By 트레일러가 추가됩니다:

```
Fix authentication token refresh logic

Update the token refresh handler to properly check expiration
before attempting renewal, preventing unnecessary API calls.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

이를 통해 AI가 참여한 커밋을 Git 이력에서 추적할 수 있습니다.

### 커밋 규칙 설정

CLAUDE.md에 커밋 규칙을 명시하면 Claude가 따릅니다:

```markdown
## 커밋 규칙
- Conventional Commits 형식 사용 (feat:, fix:, refactor:, docs: 등)
- 커밋 메시지는 영어로 작성
- 제목은 50자 이내, 본문은 72자에서 줄바꿈
- 관련 이슈 번호 포함: "fix: resolve token expiry (#123)"
```

### 안전 원칙

Claude는 다음 Git 안전 원칙을 엄격히 따릅니다:

- 사용자가 명시적으로 요청하지 않으면 **커밋하지 않음**
- `--force`, `--no-verify` 등 위험한 플래그 사용 금지
- `git push`는 사용자 확인 후 실행
- `main`/`master` 브랜치에 force push 시 경고
- 기존 커밋을 `--amend`하는 대신 새 커밋 생성

---

## 브랜치 관리

### 브랜치 생성과 전환

```
> feature/user-auth 브랜치를 만들고 전환해줘
```

Claude는 `git checkout -b feature/user-auth`를 실행합니다.

### 브랜치 전략

Claude에게 브랜치 전략을 알려주면 일관되게 따릅니다:

```markdown
## 브랜치 규칙
- feature/*: 새 기능
- fix/*: 버그 수정
- refactor/*: 리팩토링
- docs/*: 문서 변경
- main에서 직접 커밋 금지
```

---

## PR 생성

### 기본 PR 워크플로우

```
> 이 변경 사항으로 PR을 만들어줘
```

Claude의 PR 생성 과정:

1. `git status`와 `git diff`로 변경 사항 파악
2. `git log`로 브랜치의 전체 커밋 이력 확인
3. 원격에 브랜치 push (`-u` 플래그)
4. `gh pr create`로 PR 생성

### PR 형식

```markdown
## Summary
- Add OAuth2 authentication flow
- Implement token refresh mechanism
- Add logout endpoint

## Test plan
- [ ] Verify login with Google OAuth
- [ ] Check token refresh after expiry
- [ ] Test logout clears all sessions

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### `--from-pr` — PR 세션 이어하기

`--from-pr`은 **특정 PR에 연결된 이전 세션을 복원**하는 기능입니다. `--resume`의 PR 특화 버전으로, 세션 ID 대신 PR 번호로 세션을 찾습니다.

```bash
# PR 번호로 세션 복원
claude --from-pr 123

# PR URL로 세션 복원
claude --from-pr https://github.com/org/repo/pull/123
```

> **주의**: `--from-pr`은 PR 브랜치를 체크아웃하거나 소스 코드를 변경하지 않습니다. 이전 세션의 대화 이력과 컨텍스트만 복원합니다. 필요하다면 브랜치 전환은 별도로 해야 합니다.

**세션과 PR의 연결 조건:**

세션이 PR에 연결되려면 **Claude Code 세션 안에서** `gh pr create`가 실행되어야 합니다:

```bash
# Claude에게 PR 생성을 요청 → 세션이 PR에 자동 연결됨 ✅
> PR을 만들어줘

# 세션 내 Bash 모드로 직접 실행 → 연결됨 ✅
> !gh pr create --title "feat: add auth"

# 별도 터미널에서 실행 (Claude Code 세션 밖) → 연결 안 됨 ❌
$ gh pr create --title "feat: add auth"
```

누가 실행하느냐(Claude vs 사용자)는 상관없고, Claude Code 세션 안에서 실행되었느냐가 핵심입니다.

**활용 시나리오:**

- PR을 만든 후 **리뷰 코멘트에 대응**할 때
- PR 작업을 중단했다가 **나중에 이어**할 때
- 여러 PR을 동시에 진행하면서 **특정 PR의 세션으로 전환**할 때

---

## 충돌 해결

병합 충돌이 발생하면 Claude에게 해결을 요청할 수 있습니다:

```
> 병합 충돌을 해결해줘
```

Claude의 충돌 해결 과정:

1. `git status`로 충돌 파일 식별
2. 충돌 마커(`<<<<<<<`, `=======`, `>>>>>>>`) 포함 파일 읽기
3. 양쪽 변경의 의도 파악
4. 적절히 병합하여 충돌 마커 제거
5. `git add`와 `git commit`으로 완료

---

## Git Worktree — 병렬 작업

### 개념

Git worktree는 하나의 저장소에서 **여러 작업 디렉토리를 동시에** 유지하는 Git 기능입니다. 각 worktree에서 독립적인 Claude 세션을 실행할 수 있습니다.

### 설정

```bash
# 기능 개발용 worktree 생성
git worktree add ../project-feature -b feature/new-ui

# 버그 수정용 worktree 생성
git worktree add ../project-bugfix -b fix/auth-bug
```

### 병렬 세션 실행

```bash
# 터미널 1: 기능 개발
cd ../project-feature
claude
> OAuth 로그인 기능 구현해줘

# 터미널 2: 버그 수정
cd ../project-bugfix
claude
> 인증 타임아웃 버그 수정해줘
```

### Worktree의 장점

| 장점 | 설명 |
|------|------|
| **완전한 파일 격리** | 각 worktree가 독립적인 작업 디렉토리 |
| **동일한 Git 히스토리** | 같은 저장소의 브랜치 |
| **독립적인 Claude 세션** | 각 worktree에서 별도 컨텍스트 |
| **병합이 쉬움** | 일반적인 Git merge/rebase |

### 정리

```bash
# worktree 삭제
git worktree remove ../project-feature

# 목록 확인
git worktree list
```

---

## 코드 리뷰

### 대화형 리뷰

```
> 최근 변경 사항을 리뷰해줘
> 보안 취약점 위주로 확인해줘
```

### PR 리뷰

```bash
# 특정 PR 리뷰
claude --from-pr 456
> 이 PR을 보안, 성능, 코드 품질 관점에서 리뷰해줘
```

### 커스텀 리뷰 스킬

`.claude/skills/review/SKILL.md`:

```markdown
---
name: review
description: "보안, 성능, 코드 품질 관점에서 코드를 리뷰합니다"
---

다음 코드를 리뷰해주세요:

$ARGUMENTS

확인 항목:
- 보안 취약점 (인젝션, XSS, 인증 결함)
- 성능 이슈
- 코드 스타일 준수 여부
- 에지 케이스와 에러 처리
```

---

## 실전 Git 워크플로우

### 기능 개발 전체 흐름

```
> feature/payment 브랜치를 만들어줘
> 결제 모듈을 구현해줘
> 테스트를 작성하고 실행해줘
> 변경 사항을 커밋해줘
> PR을 만들어줘
```

### 핫픽스 워크플로우

```
> main에서 fix/critical-bug 브랜치를 만들어줘
> 이 에러 로그를 분석하고 원인을 찾아줘
> 수정하고 테스트해줘
> 커밋하고 PR 만들어줘
```

### 리베이스 워크플로우

```
> main 브랜치의 최신 변경 사항을 가져와서 리베이스해줘
```

Claude는 충돌이 발생하면 자동으로 해결을 시도합니다.

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **체크포인트** | 프롬프트마다 자동 스냅샷, `Esc+Esc`로 복원 |
| **커밋** | 변경 분석 후 메시지 자동 생성, Co-Authored-By 트레일러 |
| **안전 원칙** | 명시적 요청 없이 커밋/푸시 금지, force 옵션 사용 금지 |
| **PR** | `gh pr create`로 생성, Summary/Test plan 형식 |
| **`--from-pr`** | PR에 연결된 이전 세션 복원 (세션 내 `gh pr create` 필요) |
| **Worktree** | 병렬 작업을 위한 독립적 작업 디렉토리 |
| **충돌 해결** | 충돌 마커 읽고 양쪽 의도 파악하여 병합 |
| **코드 리뷰** | 대화형 리뷰, PR 리뷰, 커스텀 스킬 |

---

## 다음 챕터

[15장: Plan 모드와 복잡한 작업](02-plan-mode.md)에서 읽기 전용 분석 모드를 활용한 체계적인 작업 진행 방법을 배웁니다.
