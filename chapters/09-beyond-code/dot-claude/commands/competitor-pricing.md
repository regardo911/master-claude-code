---
description: Check competitor pricing pages for changes
---
<!-- Chapter 9 (ch09:224-239), verbatim from the book. The book gives this command no file name; competitor-pricing is ours. -->

Monitor competitor pricing:

1. Use Playwright to visit each URL in data/competitors.json
2. For each competitor:
   - Take a snapshot of their pricing page
   - Extract plan names and prices
   - Compare to the last recorded prices in data/pricing-history.json
3. If any price changed, write an alert to reports/pricing-alert.md
4. Update data/pricing-history.json with current prices
5. Take screenshots of any pages with changes
