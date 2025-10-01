---
description: Refactor code following master.json principles
---

Follow the refactor workflow from master.json:

1. **Analyze** (from master.json execution.phases.analyze):
   - Find assumptions, estimate cost, identify risks
   - Questions: hidden_assumptions? maintenance_burden?

2. **Design** (from execution.phases.design):
   - Generate 3-5 approaches
   - Select minimum viable complexity
   - Questions: where does this break? simpler alternative?

3. **Implement** (from execution.phases.implement):
   - Write tests first
   - Apply standards.languages rules
   - Questions: single responsibility? testable?

4. **Validate** (from execution.phases.validate):
   - Check complexity < 10
   - No duplication
   - Tests pass

Target: files or pattern specified by user.
