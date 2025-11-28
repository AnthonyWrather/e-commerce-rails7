---
description: 'Create Epic PRD'
mode: 'agent'
---

# Epic PRD Generator

Generate a comprehensive Product Requirements Document (PRD) for an Epic - a large initiative that delivers significant business value and may span multiple features.

## Prerequisites

Before generating this PRD, ensure:

- ✅ Clear business problem or opportunity identified
- ✅ User research or market analysis available
- ✅ Stakeholder alignment on Epic scope
- ✅ Success metrics defined

## Process

### 1. Discovery

Use available tools to gather context:

- `#codebase` - Review existing documentation
- `#search` - Find related discussions or requirements
- `#fetch` - Gather external research or competitive analysis

### 2. PRD Generation

Create `/docs/ways-of-work/plan/{epic}/epic.md` with:

## Product Requirements Document: {Epic Name}

### Executive Summary

**Epic Overview**: 2-3 sentence description of this Epic and its business value.

**Target Users**: Primary user personas who will benefit.

**Business Value**: Quantifiable value this Epic delivers (revenue, cost savings, user satisfaction).

**Success Metrics**: Key metrics to measure Epic success.

**Timeline**: Estimated duration and key milestones.

---

### 1. Background

#### Business Context

Describe the business problem or opportunity:

- Current market situation
- Competitive landscape
- Strategic importance
- Alignment with company goals

#### Problem Statement

Clearly articulate the problem this Epic solves:

- **Who** experiences the problem
- **What** the problem is
- **Where** it occurs
- **When** it happens
- **Why** it matters

#### User Research

Summarize relevant user research findings:

- User interviews and quotes
- Survey results
- Usage data and analytics
- Competitive analysis
- Market trends

---

### 2. Goals & Success Criteria

#### Epic Goals

High-level objectives:

1. **Goal 1**: Increase user engagement by 30%
2. **Goal 2**: Reduce support tickets by 50%
3. **Goal 3**: Enable new revenue stream worth $XM

#### Success Metrics

Quantifiable metrics to measure success:

| Metric                     | Baseline | Target | Measurement Method     |
| -------------------------- | -------- | ------ | ---------------------- |
| Monthly Active Users       | 100K     | 150K   | Analytics dashboard    |
| Task Completion Rate       | 60%      | 85%    | User session tracking  |
| Net Promoter Score         | 20       | 40     | Quarterly survey       |
| Revenue per User           | $50      | $75    | Financial reporting    |

#### Out of Scope

Explicitly state what this Epic will NOT include:

- Feature X (deferred to future Epic)
- Use case Y (not a priority)
- Integration Z (separate initiative)

---

### 3. User Personas

#### Persona 1: {Name}

**Role**: {Job title or role description}

**Demographics**:

- Age range, location, education, tech savviness

**Goals**:

- What they want to achieve
- Their motivations

**Pain Points**:

- Current frustrations
- Blockers to success

**Behaviors**:

- How they currently work
- Tools they use
- Frequency of tasks

**Quote**: "In their own words..."

#### Persona 2: {Name}

...continue for each persona

---

### 4. User Journeys

Map key user flows this Epic enables or improves:

#### Journey 1: {Journey Name}

**Current State** (Before Epic):

```
[Discover Need] → [Manual Process] → [Workaround] → [Frustration] → [Partial Success]
```

**Future State** (After Epic):

```
[Discover Need] → [Guided Flow] → [Automated Step] → [Confirmation] → [Complete Success]
```

**Key Improvements**:

- Reduced steps from 10 to 3
- Eliminated manual data entry
- Real-time feedback
- 80% faster completion time

#### Journey 2: {Journey Name}

...continue for each journey

---

### 5. High-Level Requirements

Group requirements by theme or capability:

#### Theme 1: {Capability Name}

| ID     | Requirement                                 | Priority  | Dependencies |
| ------ | ------------------------------------------- | --------- | ------------ |
| REQ-001| Users must be able to...                   | Must Have | None         |
| REQ-002| System shall automatically...              | Must Have | REQ-001      |
| REQ-003| Users should receive notifications when... | Should    | REQ-002      |
| REQ-004| System could integrate with...             | Could     | None         |

#### Theme 2: {Capability Name}

...continue for each theme

---

### 6. Non-Functional Requirements

#### Performance

- **Response Time**: API calls <500ms p95
- **Page Load**: Initial load <2s, subsequent <1s
- **Throughput**: Support 10,000 concurrent users
- **Scalability**: Handle 5x traffic spike

#### Security

- **Authentication**: OAuth 2.0 / SAML integration
- **Authorization**: Role-based access control
- **Data Protection**: GDPR, SOC 2 compliance
- **Encryption**: TLS 1.3 in transit, AES-256 at rest

#### Usability

- **Accessibility**: WCAG 2.1 AA compliance
- **Internationalization**: Support 5 languages
- **Mobile**: Responsive design for iOS and Android
- **Browser**: Support latest 2 versions of major browsers

#### Reliability

- **Uptime**: 99.9% availability
- **Disaster Recovery**: RTO 4 hours, RPO 15 minutes
- **Data Backup**: Automated daily backups
- **Error Handling**: Graceful degradation

---

### 7. Feature Breakdown

List the features that comprise this Epic:

#### Feature 1: {Feature Name}

**Description**: 2-3 sentence summary

**User Value**: What users gain

**Priority**: Must Have / Should Have / Could Have

**Estimated Effort**: T-shirt size (S/M/L/XL)

**Dependencies**: Other features or Epics

**Success Criteria**:

- Measurable outcome 1
- Measurable outcome 2

#### Feature 2: {Feature Name}

...continue for each feature

---

### 8. Technical Considerations

#### Architecture Implications

- New services or components required
- Database schema changes
- API contracts
- Third-party integrations

#### Technical Constraints

- Must use existing auth system
- Limited to current tech stack
- Cannot exceed budget of $X
- Must launch by Q2

#### Technical Risks

| Risk                    | Impact | Likelihood | Mitigation Strategy        |
| ----------------------- | ------ | ---------- | -------------------------- |
| API latency under load  | High   | Medium     | Caching layer, load testing|
| Third-party dependency  | Medium | High       | Fallback mechanism         |
| Data migration issues   | High   | Low        | Phased rollout, testing    |

---

### 9. Go-to-Market Strategy

#### Launch Plan

- **Phase 1**: Internal beta with select users (Week 1-2)
- **Phase 2**: Limited release to early adopters (Week 3-4)
- **Phase 3**: General availability (Week 5+)

#### Marketing & Communications

- Product announcement blog post
- Email campaign to existing users
- In-app notifications and tutorials
- Sales enablement materials

#### Training & Support

- User documentation and FAQs
- Video tutorials
- Support team training
- Community forum setup

---

### 10. Dependencies & Assumptions

#### Internal Dependencies

- **Team Availability**: Frontend team available Q1
- **Platform Readiness**: Auth system upgrade by Jan 15
- **Data Access**: Analytics pipeline complete

#### External Dependencies

- **Third-party API**: Provider X launches API v2 in Feb
- **Regulatory**: Compliance approval by Mar 1
- **Partner Integration**: Partner Y provides integration by Apr

#### Assumptions

- User adoption will be 60% within 6 months
- No major architectural changes needed
- Existing infrastructure can handle traffic
- Current team size is sufficient

---

### 11. Risks & Mitigation

| Risk                        | Impact | Likelihood | Mitigation Strategy           | Owner    |
| --------------------------- | ------ | ---------- | ----------------------------- | -------- |
| Low user adoption           | High   | Medium     | User research, phased rollout | PM       |
| Technical debt accumulation | Medium | High       | Refactor sprints, code review | Eng Lead |
| Scope creep                 | High   | Medium     | Strict change control         | PM       |
| Resource constraints        | Medium | Low        | Prioritization, contractor    | EM       |

---

### 12. Timeline & Milestones

#### High-Level Timeline

| Milestone                | Date       | Deliverable                       |
| ------------------------ | ---------- | --------------------------------- |
| Kick-off                 | 2024-01-15 | Epic PRD approved                 |
| Architecture Complete    | 2024-02-01 | Architecture spec finalized       |
| Feature PRDs Complete    | 2024-02-15 | All feature PRDs written          |
| Alpha Release            | 2024-03-15 | Internal testing complete         |
| Beta Release             | 2024-04-01 | Limited user release              |
| General Availability     | 2024-05-01 | Full production launch            |

#### Sprint Planning

- Sprint 1-2: Feature A development
- Sprint 3-4: Feature B development
- Sprint 5: Integration and testing
- Sprint 6: Beta feedback and refinement
- Sprint 7: GA prep and launch

---

### 13. Success Measurement

#### Launch Metrics (Week 1)

- Active users: 10K
- Feature activation rate: 50%
- Error rate: <1%
- Average session time: 5 minutes

#### 30-Day Metrics

- Monthly active users: 50K
- Task completion rate: 75%
- User satisfaction score: 4.0/5
- Support ticket volume: <100

#### 90-Day Metrics (Full Success)

- Monthly active users: 150K
- Task completion rate: 85%
- Net Promoter Score: 40
- Revenue impact: +$500K

---

### 14. Open Questions

List unresolved questions that need answers:

- [ ] Question 1: Who will own ongoing maintenance?
- [ ] Question 2: What is the sunset plan for legacy feature X?
- [ ] Question 3: How will we handle international compliance?

---

### 15. Appendix

#### Related Documents

- Market research report: [Link]
- User research findings: [Link]
- Competitive analysis: [Link]
- Technical feasibility study: [Link]

#### Stakeholders

| Name       | Role              | Responsibility                |
| ---------- | ----------------- | ----------------------------- |
| Jane Doe   | Product Manager   | Epic owner and decision maker |
| John Smith | Engineering Lead  | Technical architecture        |
| Sarah Lee  | Design Lead       | User experience design        |
| Mike Chen  | Marketing Manager | Go-to-market strategy         |

---

**Revision History**:

| Version | Date       | Author   | Changes                        |
| ------- | ---------- | -------- | ------------------------------ |
| 1.0     | 2024-01-15 | Jane Doe | Initial draft                  |
| 1.1     | 2024-01-20 | Jane Doe | Updated based on feedback      |

### 3. Validation

Ensure the Epic PRD:

- ✅ Clearly articulates business value and user needs
- ✅ Includes measurable success metrics
- ✅ Defines scope boundaries (in/out of scope)
- ✅ Identifies risks and mitigation strategies
- ✅ Has stakeholder alignment

## Invocation

```
@workspace #breakdown-epic-pm

Context:
- Epic name: {epic-name}
- Business problem: {problem description}
- Target users: {user personas}
```

## Output

Creates `/docs/ways-of-work/plan/{epic}/epic.md` with a comprehensive Epic PRD ready for architecture design and feature breakdown.
