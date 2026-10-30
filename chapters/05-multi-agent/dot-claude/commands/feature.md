---
description: Build a new feature using research-plan-build pipeline
---
<!-- Chapter 5 (ch05:124-152), verbatim from the book. Run it as /feature add due dates to tasks. -->

Build the following feature for TaskFlow: $ARGUMENTS

Follow this process:

1. First, use a read-only research subagent to scan the codebase and identify:
   - Existing patterns relevant to this feature
   - Files that will need to be modified
   - Test patterns used in similar features

2. Based on the research results, use a Plan agent to design
   the implementation approach. The plan should include:
   - Which files to create or modify
   - The data model changes (if any)
   - The API endpoints to add
   - The test cases to write

3. Review the plan. If it looks correct, proceed with implementation.
   Build the feature following the plan, using the existing patterns
   found during the research step.

4. After building, run the test suite. Fix any failures.

5. Run /review on the changes.
