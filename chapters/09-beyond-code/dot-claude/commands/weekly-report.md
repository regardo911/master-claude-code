---
description: Generate weekly client report
---
<!-- Chapter 9 (ch09:273-305), verbatim from the book. The book gives this command no file name; weekly-report is ours. Run it as /weekly-report <client>. -->

Generate this week's client report for $ARGUMENTS:

1. Query the database for this week's usage statistics:
   - Total API calls
   - Unique active users
   - Error rate
   - New features deployed (from git log)

2. Use Playwright to visit the monitoring dashboard:
   - Go to the client's project view
   - Take a screenshot of the usage graph
   - Take a screenshot of the error graph
   - Check for any active incidents

3. Use Playwright to check the project management board:
   - Count completed tasks this week
   - List any open blockers
   - Note next week's priorities

4. Generate a report in reports/weekly/[client]-[date].md:
   - Usage summary with numbers and graphs
   - Incident report (or "No incidents this week")
   - Work completed (tasks with descriptions)
   - Next week priorities
   - Attach screenshots

5. Generate an email draft with the report highlights.
