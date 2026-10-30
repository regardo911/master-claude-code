<!-- Chapter 9 (ch09:125-154), verbatim from the book. The note under this line is ours. -->

> Sample output printed in the book for /log-analysis. This repo did not produce it, and your numbers will differ. The status table adds up to 1000 with no 429 or 404 row, while the error list has both; see BOOK-FIXES.md.

# Log Analysis: 2024-03-15

## Status Code Distribution (last 1000 requests)
| Status | Count | Percentage |
|--------|-------|------------|
| 200    | 847   | 84.7%      |
| 201    | 89    | 8.9%       |
| 400    | 31    | 3.1%       |
| 401    | 18    | 1.8%       |
| 500    | 15    | 1.5%       |

## Top 5 Errors
1. "Invalid token" (401) - 18 occurrences, first at 03:14:22
2. "Validation failed: title is required" (400) - 12 occurrences, first at 08:41:03
3. "Internal server error" (500) - 8 occurrences, first at 11:22:45
4. "Rate limit exceeded" (429) - 5 occurrences, first at 14:08:11
5. "Task not found" (404) - 4 occurrences, first at 09:55:30

## Slow Requests (>2s)
| Endpoint | Duration | Timestamp |
|----------|----------|-----------|
| GET /tasks?limit=500 | 4.2s | 11:22:44 |
| GET /tasks?limit=500 | 3.8s | 11:22:46 |
| POST /tasks (bulk) | 2.3s | 14:08:10 |

## Suspicious Patterns
IP 192.168.1.47 generated 18 consecutive 401 errors between
03:14:22 and 03:14:58 - possible brute-force attempt on login endpoint.
