---
description: Analyze recent production logs for patterns
---
<!-- Chapter 9 (ch09:104-121). The book gives this command no file name; log-analysis is ours. Step 1 differs from the print: it takes the log path from $ARGUMENTS and falls back to the printed logs/production.log. -->

Analyze production logs:

1. Read the last 1000 lines of $ARGUMENTS (if empty, logs/production.log)
2. Count occurrences of each HTTP status code
3. Identify the 5 most common error messages
4. Find any request that took longer than 2 seconds
5. Check for any repeated errors from the same IP address
6. Write a summary to reports/log-analysis.md with:
   - Status code distribution
   - Top errors with first occurrence timestamps
   - Slow requests with endpoint and duration
   - Suspicious IP patterns (if any)
