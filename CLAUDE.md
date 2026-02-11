# Claude Code Book Project

## 프로젝트 개요
Claude Code(Anthropic CLI 도구)의 최신 사용법을 담은 전문가 수준의 한국어 가이드북 프로젝트.

## 프로젝트 구조
```
docs/
├── 01-getting-started/   # 설치, 초기 설정, 기본 사용법
├── 02-core-features/     # 핵심 기능 (명령어, 도구, 슬래시 커맨드)
├── 03-configuration/     # 설정 (settings.json, CLAUDE.md, 권한, 모델)
├── 04-workflows/         # 워크플로우 (Git, 코드리뷰, 디버깅, 리팩토링)
├── 05-advanced/          # 고급 기능 (MCP, Hooks, SDK, 서브에이전트)
├── 06-integrations/      # 통합 (IDE, GitHub Actions, CI/CD)
├── 07-recipes/           # 실전 레시피 및 패턴
└── 08-appendix/          # 부록 (단축키, 트러블슈팅, 용어집)
scripts/                  # 빌드/업데이트 스크립트
assets/                   # 이미지, 다이어그램
```

## 작성 규칙
- 모든 문서는 한국어로 작성
- 마크다운 형식 사용
- 각 문서는 실용적인 예제 포함
- 코드 블록에는 언어 태그 필수 지정
- 각 챕터는 초급 → 중급 → 고급 흐름으로 구성
- 최신 Claude Code 버전 기준으로 작성 (2025-2026)

## 업데이트 정책
- CHANGELOG.md에 업데이트 이력 기록
- VERSION 파일로 책 버전 관리
- 각 문서 상단에 `last_updated` 날짜 표기

## 빌드
- `scripts/build.sh`: 전체 문서를 하나의 파일로 병합
- `scripts/check-links.sh`: 내부 링크 검증
