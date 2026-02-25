<!-- last_updated: 2026-02-11 -->

# 24. Agent SDK (프로그래밍 인터페이스)

> Claude Agent SDK를 활용한 프로그래밍 방식의 Claude Code 활용을 다룹니다.

---

## Agent SDK 개요

Agent SDK (구 Claude Code SDK)는 Claude Code의 기능을 **프로그래밍 방식으로 사용**할 수 있게 해주는 TypeScript/JavaScript 라이브러리입니다.

### 용도

- 커스텀 AI 에이전트 구축
- CI/CD 파이프라인에 Claude 통합
- 대화형 도구 개발
- 자동화된 코드 분석/수정 시스템

### `-p` 플래그와의 차이

| 방식 | 적합한 경우 |
|------|-----------|
| `claude -p` | 간단한 스크립트, 셸 자동화 |
| **Agent SDK** | 복잡한 프로그래밍 통합, 커스텀 에이전트 |

---

## 설치

**시스템 요구사항**: Node.js 18 이상

```bash
npm install @anthropic-ai/claude-agent-sdk
```

---

## 기본 사용법

### 간단한 질의

```typescript
import { Agent } from "@anthropic-ai/claude-agent-sdk";

const agent = new Agent({
  model: "claude-sonnet-4-5-20250929",
});

const result = await agent.run("이 프로젝트의 구조를 설명해줘");
console.log(result.text);
```

### 대화 세션

```typescript
const agent = new Agent({
  model: "claude-sonnet-4-5-20250929",
  systemPrompt: "당신은 TypeScript 전문가입니다.",
});

// 첫 번째 메시지
const result1 = await agent.run("auth 모듈을 분석해줘");

// 이전 컨텍스트를 유지한 후속 메시지
const result2 = await agent.run("보안 취약점이 있어?", {
  conversationId: result1.conversationId,
});
```

---

## 시스템 프롬프트 설정

```typescript
const agent = new Agent({
  model: "claude-opus-4-6",
  systemPrompt: `
    당신은 보안 전문가입니다.

    모든 코드를 OWASP Top 10 기준으로 분석하고,
    발견된 취약점은 심각도(Critical/High/Medium/Low)와 함께
    구체적인 수정 방법을 제시하세요.
  `,
});
```

---

## 도구 제한

사용 가능한 도구를 제한하여 에이전트의 행동을 통제합니다:

```typescript
const agent = new Agent({
  model: "claude-sonnet-4-5-20250929",
  tools: ["Read", "Glob", "Grep"],           // 허용 도구
  disallowedTools: ["Write", "Edit", "Bash"], // 차단 도구
  permissionMode: "plan",                     // 읽기 전용 모드
});
```

---

## 스트리밍 출력

실시간으로 응답을 스트리밍합니다:

```typescript
const agent = new Agent({
  model: "claude-sonnet-4-5-20250929",
});

for await (const event of agent.stream("코드를 분석해줘")) {
  if (event.type === "text") {
    process.stdout.write(event.text);
  } else if (event.type === "toolUse") {
    console.log(`도구 사용: ${event.toolName}`);
  }
}
```

---

## 실전 활용 예제

### CI 코드 리뷰 봇

```typescript
import { Agent } from "@anthropic-ai/claude-agent-sdk";
import { execSync } from "child_process";

async function reviewPR() {
  const diff = execSync("git diff origin/main").toString();

  const agent = new Agent({
    model: "claude-sonnet-4-5-20250929",
    systemPrompt: "코드 리뷰 전문가입니다. 보안, 성능, 품질을 검토합니다.",
    tools: ["Read", "Glob", "Grep"],
    maxTurns: 10,
  });

  const result = await agent.run(`다음 변경 사항을 리뷰해주세요:\n\n${diff}`);

  return {
    review: result.text,
    cost: result.metadata.cost,
  };
}
```

### 자동 문서 생성기

```typescript
async function generateDocs(directory: string) {
  const agent = new Agent({
    model: "claude-sonnet-4-5-20250929",
    systemPrompt: "API 문서 전문 작성자입니다.",
  });

  const result = await agent.run(
    `${directory} 디렉토리의 모든 API 엔드포인트에 대한 ` +
    `OpenAPI 스펙 문서를 생성해주세요.`
  );

  return result.text;
}
```

### 다중 에이전트 파이프라인

```typescript
async function analyzeAndFix(filePath: string) {
  // 1단계: 분석 에이전트
  const analyzer = new Agent({
    model: "claude-sonnet-4-5-20250929",
    tools: ["Read", "Grep"],
    systemPrompt: "코드 분석 전문가입니다.",
  });

  const analysis = await analyzer.run(`${filePath}를 분석해주세요`);

  // 2단계: 수정 에이전트
  const fixer = new Agent({
    model: "claude-opus-4-6",
    tools: ["Read", "Edit", "Write"],
    systemPrompt: "코드 수정 전문가입니다.",
  });

  const fix = await fixer.run(
    `다음 분석 결과를 바탕으로 수정해주세요:\n${analysis.text}`
  );

  return fix;
}
```

---

## 마이그레이션 가이드

이전 `claude-code` SDK에서 마이그레이션하는 경우:

| 이전 (claude-code) | 현재 (agent-sdk) |
|--------------------|--------------------|
| `import { Claude } from "claude-code"` | `import { Agent } from "@anthropic-ai/claude-agent-sdk"` |
| `new Claude()` | `new Agent({ model: "..." })` |
| `claude.ask("질문")` | `agent.run("질문")` |
| `claude.stream("질문")` | `agent.stream("질문")` |

---

## 요약

| 주제 | 핵심 포인트 |
|------|------------|
| **Agent SDK** | Claude Code의 프로그래밍 인터페이스 |
| **설치** | `npm install @anthropic-ai/claude-agent-sdk` |
| **기본 사용** | `new Agent()` → `agent.run()` |
| **시스템 프롬프트** | 에이전트 역할과 규칙 정의 |
| **도구 제한** | `tools`, `disallowedTools`, `permissionMode` |
| **스트리밍** | `agent.stream()`으로 실시간 출력 |
| **활용** | CI 봇, 문서 생성, 다중 에이전트 파이프라인 |

---

## 다음 챕터

[25장: 플러그인](07-plugins.md)에서 Skills, Hooks, MCP 서버를 하나의 패키지로 묶어 배포하는 플러그인 시스템을 배웁니다.
