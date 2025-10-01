---
description: Validate current changes against master.json rules
---

Read master.json and check recent changes against:

1. **governance.approval** - Did I need approval for these changes?
2. **principles** - DRY violations? Complexity > 10? Unused code?
3. **standards** - Code style compliance for affected languages?
4. **validation.gates** - Are tests passing? Security issues?

Provide a checklist of passes/fails with file:line references.
