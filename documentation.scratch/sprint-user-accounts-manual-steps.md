# User Accounts Sprint - Manual Setup Steps

## Summary

✅ **COMPLETED**:
- Sprint plan document created: `documentation.scratch/sprint-plan-user-accounts.md`
- GitHub issues created for all 4 epics:
  - Issue #425: [EPIC] Database & Models for User Accounts (21 points)
  - Issue #426: [EPIC] Authentication & Registration (34 points)
  - Issue #427: [EPIC] User Dashboard & Profile (34 points)
  - Issue #428: [EPIC] Integration & Testing (21 points)

## ⚠️ Manual Steps Required

### 1. Add Issues to Kanban Board

Due to GitHub CLI authentication limitations in the devcontainer, you need to manually add the issues to the project board.

**Steps**:

1. Navigate to the Kanban board:
   - URL: https://github.com/users/AnthonyWrather/projects/3/views/2

2. Add each issue to the board:
   - Click "+ Add item" or drag issues from the sidebar
   - Issues to add:
     - #425: [EPIC] Database & Models for User Accounts
     - #426: [EPIC] Authentication & Registration
     - #427: [EPIC] User Dashboard & Profile
     - #428: [EPIC] Integration & Testing

3. Set the status column:
   - Recommended: Move all to "To Do" or "Backlog" column
   - These represent the full user accounts sprint

**Alternative CLI Method** (if you have project scope):

```bash
# Refresh GitHub CLI with project scopes
gh auth refresh -s read:project -s project

# Add issues to project
gh project item-add 3 --owner AnthonyWrather --url https://github.com/AnthonyWrather/e-commerce-rails7/issues/425
gh project item-add 3 --owner AnthonyWrather --url https://github.com/AnthonyWrather/e-commerce-rails7/issues/426
gh project item-add 3 --owner AnthonyWrather --url https://github.com/AnthonyWrather/e-commerce-rails7/issues/427
gh project item-add 3 --owner AnthonyWrather --url https://github.com/AnthonyWrather/e-commerce-rails7/issues/428
```

---

### 2. Create Custom Labels (Optional)

The issues currently only have the `enhancement` label. You may want to create custom labels for better organization:

**Recommended Labels**:

| Label | Color | Description |
|-------|-------|-------------|
| `user-accounts` | #0E8A16 (green) | User accounts feature |
| `sprint-user-accounts` | #1D76DB (blue) | Sprint-specific work |
| `high-priority` | #D93F0B (red) | High priority items |
| `epic` | #5319E7 (purple) | Epic-level issues |

**Steps to Create Labels**:

1. Navigate to: https://github.com/AnthonyWrather/e-commerce-rails7/labels
2. Click "New label"
3. Enter name, color, description
4. Click "Create label"

**Steps to Add Labels to Issues**:

1. Open each issue (#425, #426, #427, #428)
2. Click "Labels" in the right sidebar
3. Select the labels you want to add
4. Labels will be added automatically

**Alternative CLI Method**:

```bash
# Create labels
gh label create "user-accounts" --color "0E8A16" --description "User accounts feature" --repo AnthonyWrather/e-commerce-rails7
gh label create "sprint-user-accounts" --color "1D76DB" --description "Sprint-specific work" --repo AnthonyWrather/e-commerce-rails7
gh label create "high-priority" --color "D93F0B" --description "High priority items" --repo AnthonyWrather/e-commerce-rails7
gh label create "epic" --color "5319E7" --description "Epic-level issues" --repo AnthonyWrather/e-commerce-rails7

# Add labels to issues
gh issue edit 425 --add-label "user-accounts,sprint-user-accounts,high-priority,epic" --repo AnthonyWrather/e-commerce-rails7
gh issue edit 426 --add-label "user-accounts,sprint-user-accounts,high-priority,epic" --repo AnthonyWrather/e-commerce-rails7
gh issue edit 427 --add-label "user-accounts,sprint-user-accounts,epic" --repo AnthonyWrather/e-commerce-rails7
gh issue edit 428 --add-label "user-accounts,sprint-user-accounts,high-priority,epic" --repo AnthonyWrather/e-commerce-rails7
```

---

## Sprint Overview

| Epic | Story Points | Priority | Issues |
|------|-------------|----------|--------|
| Epic 1: Database & Models | 21 | HIGH | #425 |
| Epic 2: Authentication & Registration | 34 | HIGH | #426 |
| Epic 3: User Dashboard & Profile | 34 | MEDIUM | #427 |
| Epic 4: Integration & Testing | 21 | HIGH | #428 |
| **TOTAL** | **110** | | **4 epics** |

**Sprint Duration**: 3 weeks (15 working days)
**Estimated Effort**: 110 story points
**Target Start**: TBD
**Target End**: TBD

---

## Sprint Schedule Recommendation

### Week 1: Foundation (Epic 1 + Story 2.1)
- **Focus**: Database models and user registration
- **Deliverables**: User can register, email confirmation sent, guest cart transferred

### Week 2: Authentication & Dashboard (Epic 2 + Epic 3)
- **Focus**: Login/logout, password reset, user dashboard
- **Deliverables**: Users can log in, reset password, view/edit profile

### Week 3: Addresses, Orders & Integration (Epic 3 + Epic 4)
- **Focus**: Address book, order history, integration, testing
- **Deliverables**: Address book, order history, full integration, 80%+ test coverage

---

## Next Steps

1. ✅ Review sprint plan: `documentation.scratch/sprint-plan-user-accounts.md`
2. ⚠️ Add issues to Kanban board (manual step above)
3. ⚠️ Create custom labels (optional)
4. ⚠️ Assign sprint start/end dates
5. ⚠️ Review and approve epics
6. ⚠️ Break epics into individual story issues (if needed)
7. ✅ Begin Sprint 1 implementation

---

## Related Documents

- **Sprint Plan**: `documentation.scratch/sprint-plan-user-accounts.md`
- **Original Issue**: #186 - Add User accounts with a login and reset password screen
- **GitHub Issues**:
  - #425 - [EPIC] Database & Models for User Accounts
  - #426 - [EPIC] Authentication & Registration
  - #427 - [EPIC] User Dashboard & Profile
  - #428 - [EPIC] Integration & Testing
- **Kanban Board**: https://github.com/users/AnthonyWrather/projects/3/views/2

---

## Questions or Issues?

If you have questions about the sprint plan or need to adjust priorities, please comment on the relevant epic issue or reach out to the team.
