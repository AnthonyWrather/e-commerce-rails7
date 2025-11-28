---
description: 'Create feature implementation plan'
mode: 'agent'
---

# Feature Implementation Plan Generator

Create a detailed implementation plan for a feature based on the parent Epic's architecture and requirements.

## Prerequisites

Before generating this plan, ensure:

- ✅ Epic architecture document exists: `/docs/ways-of-work/plan/{epic}/arch.md`
- ✅ Epic PRD exists: `/docs/ways-of-work/plan/{epic}/epic.md`
- ✅ Feature PRD exists: `/docs/ways-of-work/plan/{epic}/{feature}/prd.md`

## Process

### 1. Context Gathering

Use `#codebase` to read:

- Epic architecture: `/docs/ways-of-work/plan/{epic}/arch.md`
- Epic PRD: `/docs/ways-of-work/plan/{epic}/epic.md`
- Feature PRD: `/docs/ways-of-work/plan/{epic}/{feature}/prd.md`

### 2. Repository Analysis

Use `#search` and `#codebase` to:

- Identify relevant existing components
- Locate similar implementations for patterns
- Find integration points
- Review current architecture

### 3. Plan Generation

Create `/docs/ways-of-work/plan/{epic}/{feature}/implementation-plan.md` with:

## Implementation Plan: {Feature Name}

### Overview

Brief description of the feature and its place in the Epic.

### Architecture Alignment

How this feature integrates with the Epic's system architecture (reference diagrams from Epic arch.md).

### Technology Stack

List specific technologies, libraries, and frameworks to be used based on Epic decisions:

- **Frontend**: Framework, state management, UI library
- **Backend**: Framework, database, caching
- **Infrastructure**: Deployment, monitoring, CI/CD
- **External Services**: APIs, third-party integrations

### Component Breakdown

For each component identified in the Feature PRD:

#### Component: {Name}

- **Purpose**: What this component does
- **Responsibilities**: Specific functions
- **Dependencies**: Other components or services
- **Data Model**: Entities and relationships
- **API Surface**: Endpoints or interfaces

### Implementation Phases

Break down implementation into sequential phases with clear deliverables:

#### Phase 1: {Phase Name}

**Goal**: What will be achieved

**Tasks**:

- TASK-001: Specific task description
- TASK-002: Another task

**Deliverables**:

- Working feature X
- Tests for feature X
- Documentation update

**Dependencies**: Any prerequisites

**Estimated Effort**: T-shirt size (S/M/L/XL)

#### Phase 2: {Next Phase}

...continue for each phase

### Data Flow

Describe how data moves through the system for key user journeys:

```
User Action → Frontend Component → API Call → Backend Service → Database
```

### Integration Points

List all integration points with:

- **Integration with**: Component/service name
- **Method**: REST API, Event, Direct call
- **Data Contract**: What data is exchanged
- **Error Handling**: How failures are handled

### Security Considerations

Based on Feature PRD security requirements:

- Authentication/Authorization approach
- Data encryption needs
- Input validation strategy
- Security testing plan

### Testing Strategy

- **Unit Tests**: What to cover
- **Integration Tests**: Key scenarios
- **E2E Tests**: Critical user journeys
- **Performance Tests**: Load/stress testing needs

### Deployment Plan

- **Database Migrations**: Schema changes required
- **Feature Flags**: Gradual rollout strategy
- **Rollback Plan**: How to revert if needed
- **Monitoring**: Metrics and alerts to add

### Technical Risks

List potential challenges and mitigation strategies:

| Risk                 | Impact | Likelihood | Mitigation                 |
| -------------------- | ------ | ---------- | -------------------------- |
| Third-party API down | High   | Medium     | Implement circuit breaker  |
| Complex migration    | Medium | High       | Thorough testing, rollback |

### Dependencies

External dependencies that could affect implementation:

- **Internal**: Other teams or features
- **External**: Third-party services or libraries
- **Infrastructure**: Platform or tooling updates

### Success Criteria

How we know the implementation is complete:

- [ ] All acceptance criteria from Feature PRD met
- [ ] Code coverage > 80%
- [ ] Performance benchmarks achieved
- [ ] Security review passed
- [ ] Documentation complete

---

**References**:

- Epic Architecture: `/docs/ways-of-work/plan/{epic}/arch.md`
- Epic PRD: `/docs/ways-of-work/plan/{epic}/epic.md`
- Feature PRD: `/docs/ways-of-work/plan/{epic}/{feature}/prd.md`

### 4. Validation

Ensure the plan:

- ✅ Aligns with Epic architecture
- ✅ Addresses all Feature PRD requirements
- ✅ Includes realistic effort estimates
- ✅ Identifies technical risks
- ✅ Has clear success criteria

## Monorepo Considerations

If working in a monorepo, include:

- **Affected Packages**: List which packages will change
- **Shared Components**: Identify reusable code opportunities
- **Build Dependencies**: Update order and caching strategy
- **Deployment Coordination**: How packages are released together

## Invocation

```
@workspace #breakdown-feature-implementation

Context:
- Epic: {epic-name}
- Feature: {feature-name}
- PRD Location: /docs/ways-of-work/plan/{epic}/{feature}/prd.md
```

## Output

Creates `/docs/ways-of-work/plan/{epic}/{feature}/implementation-plan.md` with a comprehensive technical implementation plan ready for engineering teams to execute.
