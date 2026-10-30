# Data Quality Rules
# Data Quality Rules

| # | Check | Finding | Decision |
|---|---|---|---|
| 1 | Delivery analysis scope | 96,478 of 99,441 orders are `delivered` | Delay metrics use only `delivered` orders |
| 2 | Delivered orders without delivery date | 8 orders | Excluded from delay metrics (cannot be computed) |
| 3 | Orders with more than one review | 547 orders (543 with 2, 4 with 3) | Keep the most recent review per order (ROW_NUMBER); avoids duplicating orders in joins |
| 4 | Delivered before purchase | 0 orders | No action |
| 5 | Estimated date with time component | 0 orders (all at midnight) | Compare dates: DATE(delivered) vs estimated date |
| 6 | Orders with no review | ~768 | Excluded from review analyses, kept in delivery analyses |
| 7 | Delivered orders missing approval or carrier date | 14 missing approval, 2 missing carrier (of 96,478) | Excluded from H1 segment analysis only; kept in delay analysis |
| 8 | Canceled orders with a delivery date | 6 orders | Excluded by the `order_status = 'delivered'` filter; documented as inconsistency |
| 9 | Delivered orders without a review | 768 orders overall (per-bucket share checked) | INNER JOIN for review metrics (only reviewed orders); no_review_pct reported per bucket to check for bias |
| 10 | Delivered orders with carrier pickup date before approval date | 1,350 | Excluded from H1 segment analysis (negative handling time); cause unknown |
| 11 | Delivered orders with customer delivery before carrier pickup | 23 | Excluded from H1 segment analysis (negative transit time) |
| 12 | Products with missing weight / zero weight | 2 / 4 products | Orders containing them are excluded from H3 (total weight cannot be computed reliably) |