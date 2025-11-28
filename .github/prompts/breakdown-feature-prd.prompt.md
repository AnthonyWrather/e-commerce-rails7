---
description: 'Create a Feature PRD from Epic context'
mode: 'agent'
---

# Feature PRD Generator

Generate a detailed Product Requirements Document (PRD) for a specific feature within an Epic.

## Prerequisites

Before generating this PRD, ensure:

- ✅ Epic PRD exists: `/docs/ways-of-work/plan/{epic}/epic.md`
- ✅ Epic architecture exists (optional): `/docs/ways-of-work/plan/{epic}/arch.md`
- ✅ Feature scope is clear and distinct from Epic

## Process

### 1. Epic Context

Use `#codebase` to read:

- Epic PRD: `/docs/ways-of-work/plan/{epic}/epic.md`
- Epic architecture (if exists): `/docs/ways-of-work/plan/{epic}/arch.md`

Understand:

- Epic goals and success metrics
- User personas and pain points
- Overall business context
- Technical constraints from Epic

### 2. Feature Scope Definition

Based on Epic breakdown, define:

- What specific user problem this feature solves
- Which Epic requirements this feature addresses
- How this feature relates to other features in the Epic
- Clear boundaries of what is IN and OUT of scope

### 3. PRD Generation

Create `/docs/ways-of-work/plan/{epic}/{feature}/prd.md` with:

## Product Requirements Document: {Feature Name}

### Executive Summary

**Epic**: [{Epic Name}](/docs/ways-of-work/plan/{epic}/epic.md)

**Feature Overview**: 2-3 sentence description of this feature and its value.

**Target Users**: Which personas from the Epic will use this feature.

**Business Value**: Specific value this feature delivers toward Epic goals.

**Success Metrics**: Measurable outcomes for this feature.

---

### 1. Background

#### Epic Context

Brief summary of the parent Epic and how this feature fits into the larger initiative.

#### Problem Statement

What specific problem does this feature solve for users?

- **Current State**: How users currently handle this need
- **Pain Points**: Specific frustrations or inefficiencies
- **Opportunity**: How this feature improves the situation

#### User Research

Relevant findings from Epic user research that inform this feature:

- User quotes or feedback
- Usage data or analytics
- Competitive analysis insights

---

### 2. Goals & Success Criteria

#### Feature Goals

Specific objectives this feature aims to achieve:

1. **Goal 1**: Description
2. **Goal 2**: Description
3. **Goal 3**: Description

#### Success Metrics

How we measure if this feature is successful:

| Metric                | Target   | Measurement Method       |
| --------------------- | -------- | ------------------------ |
| User adoption         | 60%      | Analytics tracking       |
| Task completion time  | -30%     | User testing             |
| Error rate            | <2%      | Error monitoring         |
| User satisfaction     | 4.5/5    | In-app survey            |

#### Out of Scope

Explicitly state what this feature will NOT include:

- Feature X (will be addressed in separate feature)
- Use case Y (not part of Epic scope)
- Integration Z (deferred to future Epic)

---

### 3. User Stories

Describe key user journeys and acceptance criteria.

#### Story 1: {Title}

**As a** {persona from Epic}
**I want to** {capability}
**So that** {benefit}

**Acceptance Criteria**:

- ✅ Given {context}, when {action}, then {outcome}
- ✅ Given {context}, when {action}, then {outcome}
- ✅ {Additional criterion}

**Priority**: Must Have / Should Have / Could Have / Won't Have

**Estimated Effort**: S / M / L / XL

#### Story 2: {Title}

...continue for each user story

---

### 4. Functional Requirements

Detailed functional requirements organized by capability:

#### Capability 1: {Name}

| ID     | Requirement                                 | Priority  | Notes                  |
| ------ | ------------------------------------------- | --------- | ---------------------- |
| FR-001 | System shall allow users to...             | Must Have | References Epic REQ-05 |
| FR-002 | System shall validate...                   | Must Have |                        |
| FR-003 | System shall provide feedback when...      | Should    |                        |

#### Capability 2: {Name}

...continue for each major capability

---

### 5. Non-Functional Requirements

#### Performance

- Page load time: <2s
- API response time: <500ms
- Concurrent users: Support 1000

#### Security

- Authentication: Inherit from Epic auth system
- Authorization: Role-based access control
- Data encryption: TLS 1.3 in transit, AES-256 at rest

#### Usability

- Accessibility: WCAG 2.1 AA compliance
- Mobile responsive: Support iOS 14+ and Android 10+
- Browser support: Chrome, Firefox, Safari, Edge (latest 2 versions)

#### Reliability

- Uptime: 99.9%
- Data backup: Daily with 30-day retention
- Error recovery: Graceful degradation with user notifications

---

### 6. User Experience

#### UI/UX Considerations

- Visual design principles from Epic style guide
- Key interaction patterns (modals, forms, navigation)
- Responsive breakpoints and mobile-first approach
- Accessibility requirements (keyboard nav, screen readers)

#### User Flow Diagrams

```
[Entry Point] → [Step 1] → [Decision Point] → [Success State]
                                ↓
                          [Error State]
```

#### Mockups/Wireframes

Link to design files or include low-fidelity wireframes.

---

### 7. Technical Considerations

#### Integration Points

This feature integrates with:

- **Service/Component A**: Purpose of integration
- **Service/Component B**: Purpose of integration
- **Third-party API C**: Purpose of integration

#### Data Requirements

- New database tables/collections needed
- Existing data to migrate or transform
- Data retention and archival policies

#### Dependencies

- **Internal**: Other features or services
- **External**: Third-party libraries or services
- **Infrastructure**: Platform or tooling requirements

#### Technical Constraints

Constraints inherited from Epic architecture:

- Must use Epic's chosen tech stack
- Must conform to Epic's API standards
- Must integrate with Epic's monitoring/logging

---

### 8. Launch Plan

#### Rollout Strategy

- **Phase 1**: Internal beta with 10% of users
- **Phase 2**: Limited release to early adopters
- **Phase 3**: General availability

#### Feature Flags

- Use feature flag system for gradual rollout
- Toggle capability for A/B testing
- Quick rollback if issues detected

#### Success Monitoring

- Dashboard with key metrics
- Alert thresholds for performance/errors
- User feedback collection mechanism

---

### 9. Risks & Mitigation

| Risk                        | Impact | Likelihood | Mitigation Strategy           |
| --------------------------- | ------ | ---------- | ----------------------------- |
| Third-party API unreliable  | High   | Medium     | Implement circuit breaker     |
| User adoption low           | High   | Low        | Onboarding tutorials and tips |
| Performance under load      | Medium | Medium     | Load testing before launch    |

---

### 10. Open Questions

List unresolved questions that need answers before implementation:

- [ ] Question 1: Who decides...?
- [ ] Question 2: How should we handle...?
- [ ] Question 3: What is the expected behavior when...?

---

**References**:

- Epic PRD: `/docs/ways-of-work/plan/{epic}/epic.md`
- Epic Architecture: `/docs/ways-of-work/plan/{epic}/arch.md`
- Design Files: [Link to Figma/Sketch]

---

**Revision History**:

| Version | Date       | Author | Changes                  |
| ------- | ---------- | ------ | ------------------------ |
| 1.0     | YYYY-MM-DD | Name   | Initial draft            |

### 4. Validation

Ensure the PRD:

- ✅ Aligns with Epic goals and requirements
- ✅ Has clear, testable acceptance criteria
- ✅ Includes all necessary functional and non-functional requirements
- ✅ Identifies risks and open questions
- ✅ Defines success metrics

## Invocation

```
@workspace #breakdown-feature-prd

Context:
- Epic: {epic-name}
- Feature: {feature-name}
- Epic PRD: /docs/ways-of-work/plan/{epic}/epic.md
```

## Output

Creates `/docs/ways-of-work/plan/{epic}/{feature}/prd.md` with a comprehensive Feature PRD ready for implementation planning and engineering execution.
