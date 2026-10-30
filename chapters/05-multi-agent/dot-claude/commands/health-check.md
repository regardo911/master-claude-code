---
description: Check production API health and investigate errors
---
<!-- Chapter 5 (ch05:215-235). One line differs from the print: the printed command names no URL, so the first line takes it from $ARGUMENTS. Run it as /health-check https://your-app.example.com -->

Run a production health check for TaskFlow at $ARGUMENTS (the production base URL):

1. Use a general-purpose agent with Playwright MCP to:
   - Visit the production health endpoint
   - Check the response status and body
   - Visit the monitoring dashboard
   - Take a screenshot of the error graph

2. If errors are detected, use a read-only research subagent to:
   - Search the codebase for the error-producing endpoint
   - Read the route handler and service code
   - Identify potential causes

3. Report findings: health status, any errors detected,
   likely causes with file:line references, and suggested fixes.
