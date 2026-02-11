<!-- last_updated: 2026-02-11 -->

# 부록 A: 단축키 모음

> 모든 키보드 단축키를 한눈에 정리합니다.

---

## 전역 단축키

| 단축키 | 동작 |
|--------|------|
| `Ctrl+C` | 인터럽트/취소 (변경 불가) |
| `Ctrl+D` | 종료 (변경 불가) |
| `Ctrl+L` | 화면 지우기 |
| `Ctrl+T` | 태스크 리스트 토글 |
| `Ctrl+O` | 트랜스크립트 (verbose) 토글 |

---

## 채팅 입력

| 단축키 | 동작 |
|--------|------|
| `Enter` | 메시지 전송 |
| `Escape` | 입력 취소 |
| `Shift+Tab` | 권한 모드 순환 (Default → Accept → Plan) |
| `Option/Alt+P` (`Meta+P`) | 모델 선택기 |
| `Option/Alt+T` (`Meta+T`) | Extended Thinking 토글 |
| `Ctrl+G` | 외부 에디터로 열기 |
| `Ctrl+V` | 이미지 붙여넣기 |
| `Ctrl+R` | 히스토리 검색 |
| `Ctrl+B` | 백그라운드 실행 |

---

## 승인 프롬프트

| 키 | 동작 |
|:--:|------|
| `Y` / `Enter` | 허용 |
| `N` / `Escape` | 거부 |
| `A` | 항상 허용 (설정에 저장) |
| `D` | 이 세션 동안 묻지 않음 |

---

## 자동완성

| 단축키 | 동작 |
|--------|------|
| `Tab` | 자동완성 수락 |
| `Escape` | 자동완성 무시 |

---

## 모델 선택기

| 단축키 | 동작 |
|--------|------|
| `←` | 노력 수준 감소 |
| `→` | 노력 수준 증가 |

---

## 되돌리기

| 단축키 | 동작 |
|--------|------|
| `Esc` + `Esc` | 되돌리기 메뉴 (= `/rewind`) |

---

## 태스크 뷰

| 단축키 | 동작 |
|--------|------|
| `Ctrl+B` | 태스크를 백그라운드로 |

---

## 세션 선택기 (`--resume`)

| 키 | 동작 |
|:--:|------|
| `↑` / `↓` | 세션 탐색 |
| `→` / `←` | 그룹 열기/닫기 |
| `Enter` | 세션 선택 |
| `P` | 내용 미리보기 |
| `R` | 세션 이름 변경 |
| `/` | 검색 |
| `A` | 모든 프로젝트 토글 |
| `B` | 브랜치 필터 |
| `Esc` | 닫기 |

---

## 키바인딩 커스터마이즈

`~/.claude/keybindings.json`에서 키 바인딩을 변경할 수 있습니다:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+enter": "chat:submit",
        "ctrl+e": "chat:externalEditor"
      }
    }
  ]
}
```

### 수정자 키

- `ctrl` / `control`
- `alt` / `opt` / `option`
- `shift`
- `meta` / `cmd` / `command`

### 특수 키

`escape`, `enter`, `tab`, `space`, `up`, `down`, `left`, `right`, `backspace`, `delete`

### 코드 (연속 입력)

```json
"ctrl+k ctrl+s": "some:action"
```

### 바인딩 해제

```json
"ctrl+u": null
```

### 전체 액션 목록

```
> /keybindings
```
