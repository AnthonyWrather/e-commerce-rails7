---
applyTo: '**'
description: 'Specification-driven development workflow for systematic, requirements-based implementation'
---

# Spec-Driven Workflow v1

A systematic approach to software development that prioritises requirements analysis, design clarity, and validation before implementation.

## Core Principles

1. **Requirements First**: Always start with clear, written requirements
2. **Design Before Code**: Plan the architecture and approach before writing code
3. **Confidence-Based Execution**: Only proceed when confident in understanding
4. **Systematic Validation**: Test against requirements at each phase
5. **Living Documentation**: Keep specs updated as understanding evolves

## Workflow Phases

### Phase 1: ANALYSE

**Objective**: Fully understand the requirements before any design or implementation.

**Activities**:

- Parse all requirements documents using `#codebase` tool
- Extract user stories and acceptance criteria
- Identify edge cases and boundary conditions
- Map requirements to existing codebase
- Note any ambiguities or missing information
- Create or update `requirements.md` in the feature directory

**Output**: Complete requirements analysis document using EARS notation (Easy Approach to Requirements Syntax):

- **Ubiquitous**: The system shall...
- **Event-driven**: When [event], the system shall...
- **State-driven**: While [state], the system shall...
- **Optional**: Where [feature enabled], the system shall...
- **Unwanted**: If [error condition], the system shall...

**Validation**: Can you explain the requirements to someone else? Are there any unknowns?

### Phase 2: DESIGN

**Objective**: Create a clear technical design that satisfies all requirements.

**Activities**:

- Design system architecture and component interactions
- Choose appropriate design patterns
- Plan data models and API contracts
- Identify dependencies and integration points
- Consider security, performance, and scalability
- Create or update `design.md` in the feature directory

**Output**: Technical design document including:

- Architecture diagrams
- Component responsibilities
- Data flow and state management
- API specifications
- Security considerations
- Performance requirements

**Validation**: Does the design address all requirements? Are there any technical risks?

### Phase 3: IMPLEMENT

**Objective**: Build the solution according to the design and requirements.

**Activities**:

- Break design into atomic tasks using `#todos` tool
- Implement one task at a time
- Write tests alongside code (TDD preferred)
- Follow project coding standards
- Handle errors and edge cases
- Update `tasks.md` with progress

**Output**: Working implementation with:

- Production code
- Comprehensive tests
- Inline code documentation
- Task completion tracking

**Validation**: Do all tests pass? Does implementation match the design?

### Phase 4: VALIDATE

**Objective**: Verify the implementation meets all requirements.

**Activities**:

- Run full test suite using `#runTests`
- Perform manual testing against acceptance criteria
- Check each requirement from ANALYSE phase
- Validate edge cases and error handling
- Review security and performance
- Use `#problems` tool to identify issues

**Output**: Validation report including:

- Test coverage metrics
- Requirements traceability matrix
- Manual test results
- Known issues or limitations

**Validation**: Are all requirements satisfied? Are there any failing tests or regressions?

### Phase 5: REFLECT

**Objective**: Document lessons learned and update specifications.

**Activities**:

- Compare actual implementation to original design
- Note any design decisions or trade-offs made
- Update requirements and design docs with changes
- Document technical debt or future improvements
- Record patterns or anti-patterns discovered

**Output**: Updated specification documents with:

- Design deviations and rationale
- Implementation notes
- Future improvement suggestions
- Lessons learned

**Validation**: Are specifications accurate representations of what was built?

### Phase 6: HANDOFF

**Objective**: Prepare for code review and production deployment.

**Activities**:

- Write comprehensive commit messages
- Create or update PR description with spec references
- Prepare demo or walkthrough materials
- Document deployment steps if needed
- Note any breaking changes or migration requirements

**Output**: Deployment-ready changeset with:

- Clean commit history
- Updated documentation
- Deployment checklist
- Rollback plan if applicable

**Validation**: Is this ready for peer review and production?

## Confidence-Based Execution

At each phase, assess your confidence level:

- ✅ **High Confidence**: Proceed to next phase
- ⚠️ **Medium Confidence**: Document assumptions and continue with caution
- ❌ **Low Confidence**: STOP, ask questions, do more research

**Never proceed if confidence is low.**

## Directory Structure

```
docs/
  ways-of-work/
    plan/
      {epic}/
        {feature}/
          requirements.md    # Phase 1: ANALYSE
          design.md          # Phase 2: DESIGN
          tasks.md           # Phase 3: IMPLEMENT
          validation.md      # Phase 4: VALIDATE
          reflection.md      # Phase 5: REFLECT
```

## Integration with Other Workflows

- **TDD Workflow**: Use TDD agents during Phase 3 (IMPLEMENT)
- **Technical Spikes**: Use spike research during Phase 1 (ANALYSE) for unknowns
- **Implementation Plans**: Generate from design docs in Phase 2
- **Task Planning**: Use task-planner agent for Phase 3 breakdown

## Example Requirements (EARS Notation)

```markdown
## User Authentication Requirements

**REQ-001 (Ubiquitous)**: The system shall hash all passwords using bcrypt with cost factor 12.

**REQ-002 (Event-driven)**: When a user submits login credentials, the system shall validate email format and password strength.

**REQ-003 (State-driven)**: While a user session is active, the system shall validate the JWT token on each request.

**REQ-004 (Optional)**: Where two-factor authentication is enabled, the system shall require TOTP code after password verification.

**REQ-005 (Unwanted)**: If login fails three times within 10 minutes, the system shall temporarily lock the account for 15 minutes.
```

## Quality Gates

Each phase has exit criteria that must be met:

- **ANALYSE**: All requirements documented in EARS notation
- **DESIGN**: Architecture addresses all requirements with no unknowns
- **IMPLEMENT**: All tests passing, code follows standards
- **VALIDATE**: All acceptance criteria met, no critical issues
- **REFLECT**: Specifications updated and accurate
- **HANDOFF**: Documentation complete, deployment ready

**Do not skip phases. Each phase builds on the previous one.**
