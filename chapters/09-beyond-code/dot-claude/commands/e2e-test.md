---
description: Run end-to-end tests on the TaskFlow frontend
---
<!-- Chapter 9 (ch09:63-81). The book gives this command no file name; e2e-test is ours. Step 1 differs from the print: it takes the app URL from $ARGUMENTS and falls back to the printed http://localhost:3000. -->

Test the TaskFlow application:

1. Open the app at $ARGUMENTS (if empty, http://localhost:3000)
2. Register a new test user with a unique email
3. Log in with the test user credentials
4. Create a new task with title "E2E Test Task"
5. Verify the task appears in the task list
6. Add a tag "testing" to the task
7. Verify the tag appears on the task
8. Delete the task
9. Verify the task is no longer in the list
10. Log out and verify redirect to login page
11. Report results: PASS/FAIL for each step
