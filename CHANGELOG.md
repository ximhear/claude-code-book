# Changelog

## [0.4.0] - 2026-02-28
### Added
- 17장: Remote Control 섹션 추가 (모바일/웹 원격 제어, 보안 모델, 요구사항, 제한사항)
- 20장: HTTP 훅 타입 추가 (`type: "http"`, URL/헤더/환경변수 보간), 10개 신규 이벤트 추가 (총 17개)
- CLI 레퍼런스: `claude auth` 서브커맨드 (login/status/logout), `--worktree` 플래그
- 15장: `--worktree` CLI 플래그 사용법 추가
- 22장: 서브에이전트 Worktree 격리 (`isolation: worktree`) 섹션 추가
- 용어집: Remote Control 용어 추가
### Changed
- Sonnet 4.5 → Sonnet 4.6 전체 업데이트 (모델 ID, 별칭, 가격표, 클라우드 프로바이더 등 8개 파일)

## [0.3.0] - 2026-02-25
### Changed
- 25장 플러그인 챕터를 공식 문서 기반으로 전면 수정
  - `.claude-plugin/plugin.json` 매니페스트 구조, `name@marketplace` 설치 문법, `/plugin` 슬래시 커맨드
  - `marketplace.json` 스키마, 소스 유형, 공식 마켓플레이스(`claude-plugins-official`) 소개
  - `extraKnownMarketplaces`, `enabledPlugins` 맵 형식, `hostPattern` 엔터프라이즈 설정
- CLI 레퍼런스, 엔터프라이즈, settings.json, Rules, 용어집 교차 참조 동기화

## [0.2.0] - 2026-02-25
### Added
- 25장: 플러그인 챕터 신규 추가 (플러그인 구조, 설치/관리, 마켓플레이스, 엔터프라이즈 관리, 실전 예제)
- 플러그인 관련 교차 참조 추가 (Skills, CLI 레퍼런스, 엔터프라이즈, Rules, 슬래시 커맨드)
### Changed
- 챕터 번호 재정렬: 25장 삽입으로 기존 25~33장이 26~34장으로 변경
- README.md 목차 업데이트

## [0.1.0] - 2026-02-11
### Added
- 프로젝트 초기 구조 설정
- 목차 및 챕터 구성
