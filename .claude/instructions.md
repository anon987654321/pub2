# Project Governance

When working on this codebase:

1. **Read master.json first** - It contains project philosophy and standards
2. **Follow governance.approval rules**:
   - Auto-proceed: syntax fixes, formatting, dead code removal, typos
   - Ask approval: logic changes, deletions, new features, security, migrations, schemas
3. **Apply standards.languages** rules for the file type you're editing
4. **Use execution.phases** for complex features:
   - discover → analyze → ideate → design → implement → validate → deliver → learn

## Quick Checks Before Committing

- [ ] Complexity < 10 (cyclomatic)
- [ ] No code duplication (DRY)
- [ ] Tests exist and pass
- [ ] No new code smells

## Workflow Selection

- **new_feature**: Full 8-phase cycle
- **bug_fix**: analyze → implement → validate → deliver
- **refactor**: analyze → design → implement → validate
- **security_fix**: Fast-track with security gates
