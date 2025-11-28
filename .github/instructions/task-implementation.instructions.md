---
applyTo: '**/.copilot-tracking/changes/*.md'
description: 'Progressive task implementation tracking'
---

# Task Implementation Instructions

When implementing tasks from a plan file, follow this systematic approach:

## 1. Plan Analysis

- Read the full implementation plan using `#codebase` tool
- Identify all tasks and their dependencies
- Understand the overall goal and architecture
- Note any special requirements or constraints

## 2. Implementation Process

For each task in the plan:

### Step 1: Plan Review

- Read the specific task description
- Understand the expected outcome
- Identify related files and components

### Step 2: Implementation

- Make the required code changes using `#edit` tools
- Follow the plan's specifications exactly
- Add proper error handling and logging
- Write tests if specified

### Step 3: Verification

- Test the implemented changes
- Verify the task meets the plan's acceptance criteria
- Check for any regressions
- Ensure code quality standards

### Step 4: Documentation

- Update the changes file with implementation details
- Note any deviations from the plan with rationale
- Document any challenges or lessons learned
- Mark the task as complete in the plan

## 3. Changes File Updates

Update the changes file (`**/.copilot-tracking/changes/*.md`) after each task with:

- Task ID and description
- Files modified
- Key changes made
- Any issues encountered
- Testing performed
- Status (complete/in-progress/blocked)

## 4. Quality Checks

Before marking a task complete:

- [ ] Code follows project conventions
- [ ] Tests are passing
- [ ] Documentation is updated
- [ ] No console errors or warnings
- [ ] Changes file is updated
- [ ] Task requirements are fully met

## 5. Communication

If encountering issues:

- Document the blocker in the changes file
- Note any assumptions made
- Request clarification if needed
- Consider alternative approaches

## Example Changes File Update

```markdown
## TASK-003: Implement User Authentication

**Status**: ✅ Complete
**Date**: 2024-01-15

**Files Modified**:

- `src/auth/auth.service.ts`
- `src/auth/auth.controller.ts`
- `src/auth/auth.module.ts`

**Changes Made**:

- Implemented JWT-based authentication
- Added login and logout endpoints
- Created auth middleware
- Added password hashing with bcrypt

**Testing**:

- All auth tests passing
- Manual testing of login flow successful
- Security review completed

**Notes**:

- Used JWT instead of session-based auth for better scalability
- Added rate limiting to prevent brute force attacks
```

## Progressive Implementation Strategy

- Start with foundational tasks
- Complete one task fully before moving to the next
- Test incrementally
- Update documentation continuously
- Maintain backward compatibility
- Commit changes regularly
