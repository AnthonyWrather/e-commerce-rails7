---
mode: 'agent'
description: 'Create time-boxed technical spike documents for researching and resolving critical development decisions before implementation.'
tools: ['runCommands', 'runTasks', 'edit', 'search', 'extensions', 'usages', 'vscodeAPI', 'think', 'problems', 'changes', 'testFailure', 'openSimpleBrowser', 'fetch', 'githubRepo', 'todos', 'Microsoft Docs', 'search']
---

# Create Technical Spike Document

Create time-boxed technical spike documents for researching critical questions that must be answered before development can proceed. Each spike focuses on a specific technical decision with clear deliverables and timelines.

## Document Structure

Create individual files in `${input:FolderPath|docs/spikes}` directory. Name each file using the pattern: `[category]-[short-description]-spike.md` (e.g., `api-copilot-integration-spike.md`, `performance-realtime-audio-spike.md`).

```md
---
title: "${input:SpikeTitle}"
category: "${input:Category|Technical}"
status: "🔴 Not Started"
priority: "${input:Priority|High}"
timebox: "${input:Timebox|1 week}"
created: [YYYY-MM-DD]
updated: [YYYY-MM-DD]
owner: "${input:Owner}"
tags: ["technical-spike", "${input:Category|technical}", "research"]
---

# ${input:SpikeTitle}

## Summary

**Spike Objective:** [Clear, specific question or decision that needs resolution]

**Why This Matters:** [Impact on development/architecture decisions]

**Timebox:** [How much time allocated to this spike]

**Decision Deadline:** [When this must be resolved to avoid blocking development]

## Background

### Current Situation

[What we know now and why this spike is needed]

### Critical Questions

1. [Question that must be answered]
2. [Question that must be answered]
3. [Question that must be answered]

### Success Criteria

[Clear definition of what "done" looks like for this spike]

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Research Plan

### Investigation Areas

1. **[Area 1]**
   - Research approach
   - Tools/methods to use
   - Expected outcomes

2. **[Area 2]**
   - Research approach
   - Tools/methods to use
   - Expected outcomes

### Validation Method

[How will we test/validate findings?]

## Investigation Results

### [Finding 1]

**What we learned:** [Description]

**Evidence:** [Links, code samples, benchmark results]

**Implications:** [Impact on implementation]

### [Finding 2]

**What we learned:** [Description]

**Evidence:** [Links, code samples, benchmark results]

**Implications:** [Impact on implementation]

## Technical Constraints

[Discovered limitations or requirements]

- **Constraint 1**: [Description]
- **Constraint 2**: [Description]

## Prototype/Testing Notes

[Results from any prototypes, spikes, or technical experiments]

### External Resources

- [Link to relevant documentation]
- [Link to API references]
- [Link to community discussions]
- [Link to examples/tutorials]

## Decision

### Recommendation

[Clear recommendation based on research findings]

### Rationale

[Why this approach was chosen over alternatives]

### Implementation Notes

[Key considerations for implementation]

### Follow-up Actions

- [ ] [Action item 1]
- [ ] [Action item 2]
- [ ] [Update architecture documents]
- [ ] [Create implementation tasks]

## Status History

| Date   | Status         | Notes                      |
| ------ | -------------- | -------------------------- |
| [Date] | 🔴 Not Started | Spike created and scoped   |
| [Date] | 🟡 In Progress | Research commenced         |
| [Date] | 🟢 Complete    | [Resolution summary]       |

---

_Last updated: [Date] by [Name]_
```

## Categories for Technical Spikes

- **API/Integration**: Third-party API exploration, service integration feasibility
- **Performance**: Load testing, optimization strategies, benchmarking
- **Architecture**: System design decisions, patterns, infrastructure choices
- **Security**: Authentication/authorization approaches, compliance requirements
- **Data**: Database design, migration strategies, data modeling
- **DevOps**: CI/CD pipeline decisions, deployment strategies
- **UX/UI**: Accessibility requirements, responsive design approaches
- **Testing**: Test framework selection, testing strategies

## File Naming Conventions

Use descriptive, kebab-case names that indicate the category and specific unknown:

**API/Integration Examples:**

- `api-copilot-chat-integration-spike.md`
- `api-azure-speech-realtime-spike.md`
- `api-vscode-extension-capabilities-spike.md`

**Performance Examples:**

- `performance-audio-processing-latency-spike.md`
- `performance-extension-host-limitations-spike.md`
- `performance-webrtc-reliability-spike.md`

**Architecture Examples:**

- `architecture-voice-pipeline-design-spike.md`
- `architecture-state-management-spike.md`
- `architecture-error-handling-strategy-spike.md`

## Best Practices for AI Agents

1. **Start with Clear Questions**: Define exactly what needs to be answered
2. **Set Timebox Limits**: Research can be endless - set hard time limits
3. **Document Progressively**: Update findings as research progresses
4. **Include Evidence**: Link to sources, include code samples, add benchmarks
5. **Make Clear Recommendations**: End with actionable decisions
6. **Create Follow-up Tasks**: Break implementation into discrete tasks

## Research Strategy

### Phase 1: Information Gathering

1. **Search existing documentation** using search/fetch tools
2. **Analyze codebase** for existing patterns and constraints
3. **Research external resources** (APIs, libraries, examples)

### Phase 2: Validation & Testing

1. **Create focused prototypes** to test specific hypotheses
2. **Run targeted experiments** to validate assumptions
3. **Document test results** with supporting evidence

### Phase 3: Decision & Documentation

1. **Synthesize findings** into clear recommendations
2. **Document implementation guidance** for development team
3. **Create follow-up tasks** for implementation

## Tools Usage

- **search/searchResults:** Research existing solutions and documentation
- **fetch/githubRepo:** Analyze external APIs, libraries, and examples
- **codebase:** Understand existing system constraints and patterns
- **runTasks:** Execute prototypes and validation tests
- **editFiles:** Update research progress and findings
- **vscodeAPI:** Test VS Code extension capabilities and limitations

Focus on time-boxed research that resolves critical technical decisions and unblocks development progress.
