---
description: Morning health check from monitoring dashboard
---
<!-- Chapter 9 (ch09:27-45), verbatim from the book. Needs DASHBOARD_URL and the dashboard login in your environment. -->

Run a morning health check:

1. Use Playwright to visit the monitoring dashboard at the URL
   in DASHBOARD_URL environment variable
2. Log in if needed (credentials in environment variables)
3. Take a snapshot of the main overview page
4. Read the key metrics: error rate, response time p99, active users
5. Take a screenshot for the record
6. Check the alerts page for any active alerts
7. Write a summary to reports/morning-check.md including:
   - Current metrics vs yesterday (if visible)
   - Any active alerts with severity
   - Screenshot path for reference
