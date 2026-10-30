# Hypotheses

> Written before exploring the data (October 22, 2026).

## Metrics used for satisfaction
- Primary: average `review_score`
- Secondary: share of low reviews (`review_score` of 1 or 2)
- Why: The mode stays at 5 even when the share of 1-star reviews more than
  triples, so it hides dissatisfaction. The average captures the whole
  distribution, and the share of low reviews expresses the problem in terms
  a manager understands.

## Method rule
Bucket thresholds for late orders will be set on Day 2 using only the
distribution of `delivery_delay_days`, before looking at review scores.

## H1: Where is delivery time lost?
**Segments:**
- Approval: `order_purchase_timestamp` to `order_approved_at`
- Seller handling: `order_approved_at` to `order_delivered_carrier_date`
- Carrier transit: `order_delivered_carrier_date` to `order_delivered_customer_date`

**Expectation:** The Carrier transit segment will account for the largest
median share of total delivery time, above 45%.

**Reasoning:** Brazil is a very large country, so parcels often travel long
distances between seller and customer, and transit depends on carrier
networks that the seller does not control. The other two segments happen
inside a single seller's or payment system's operation, so I expect them to
be shorter.

**Why 45%:** If the three segments weighed the same, each would be about 33%.
A 45% share is roughly 35% above an equal split, which makes the segment
clearly dominant without requiring it to be a majority (50%).

**Would be wrong if:** the median share of Carrier transit is 45% or lower,
OR the median share of another segment is higher than that of Carrier transit.

## H2: Does delay hurt satisfaction?
**Groups (`delay_bucket`):** early, on_time, late_1, late_2, late_3
(on_time is the control group; early is kept separate on purpose.)

**Expectation:** As delay_bucket worsens (on_time, late_1, late_2, late_3),
the average `review_score` will decrease. Early orders will have a higher
average `review_score` than on_time orders.

**Reasoning:** The estimated delivery date creates an expectation in the
customer, who waits until that specific date. After that date, uncertainty
appears about whether something went wrong, and that uncertainty grows with
each additional day of waiting. I expect early deliveries to exceed the
promise, which may make customers perceive the platform as reliable or as
prioritizing their order. This is a possible explanation, not something the
data can prove directly. An alternative is that early orders differ in
product category or customer location, which will be checked in the analysis.

**Would be wrong if:** (1) late_2 has an average `review_score` higher than
late_1 by more than 0.2 points, or late_3 higher than late_2 by more than
0.2 points, OR (2) the gap between on_time and late_3 is smaller than 1.0
point, OR (3) the average `review_score` of early orders is not higher than
that of on_time orders by at least 0.1 points.

**Why these thresholds:**
- 0.2 points: on a 1-5 scale, differences smaller than this between adjacent
  buckets could be noise, so only a larger reversal would contradict the
  expected order.
- 1.0 point: late_3 is the most severe bucket, so I expect a large gap. A
  smaller gap would suggest delay is not the main driver of low scores.
  
- 0.1 points (early vs on_time): the expected effect is smaller than the
  late-delivery effect, since both groups met the promise, so I accept a
  smaller gap. It may be revisited on Day 2 after checking group sizes (not
  review scores).
## H3: Are heavier orders delivered late more often?
**Groups (`weight_group`, based on total order weight in grams, the sum of
`product_weight_g` of all items):** light (0–1,000), medium (1,000–10,000),
heavy (10,000–20,000), super_heavy (over 20,000).
Group sizes will be checked on Day 2 using only the weight distribution,
before looking at delays.

**Expectation:** The share of late orders (`delivery_delay_days` > 0) will
increase with weight: light < medium < heavy < super_heavy.

**Reasoning:** Heavier or bulkier packages are harder for sellers and
carriers to handle and ship, which should add delays.

**Would be wrong if:**(1) the late share of heavy and super_heavy orders 
combined is not at least 2 percentage points higher than that of light and
medium orders combined, OR (2) the late share of any heavier group is lower
than that of the previous one by more than 1 percentage point.

**Why these thresholds:**
- 2 points (heavy and super_heavy vs light and medium): The overall late rate is
  only 6.77%, so a 3-point gap would require a ~44% relative increase and could
  reject a real but moderate effect (false negative). 2 points is still large
  enough to matter operationally. Group sizes will be reported to judge noise
  (false positive risk).
- 1 point (between adjacent groups): tolerates small fluctuations between
  neighboring weight groups.

## Open question for the business problem
If early deliveries are common, the estimated delivery date may be too
conservative. This will be checked in the analysis.

## Potential confounders (to check in the analysis)
- Product perishability: perishable products may ship faster (more likely
  early) but may also arrive damaged, which lowers the review score
  independently of delivery time. To check: count orders by product
  category and compare `review_score` across delay buckets within each
  category.
- Customer location and product category (see H2): early orders may differ
  from on_time orders in distance or category

## Amendment 1 (2026-10-28, delay buckets; group sizes only, no review scores)
- Delay distribution of 96,470 delivered orders: 91.89% early, 1.34% on_time,
  6.77% late.
- on_time has only 1,292 orders, so it is a small control group and early is
  the real baseline. The H2 early vs on_time comparison will be interpreted
  with caution.
- Late buckets, set from the delay distribution only: late_1 = 1-4 days
  (2,323 orders), late_2 = 5-10 days (2,119), late_3 = more than 10 days (2,092).

## Amendment 2 (2026-10-28, H3 threshold)
- Changed the H3 gap threshold from 3 to 2 percentage points after learning the
  overall late rate (6.77%), and before looking at any results by weight group.

  ## Results

### H2: Does delay hurt satisfaction?
| Bucket | Reviewed orders | Avg review_score | Low reviews (1-2 stars) |
|---|---|---|---|
| early | 88,163 | 4.29 | 9.22% |
| on_time | 1,280 | 4.03 | 12.42% |
| late_1 | 2,288 | 3.14 | 36.67% |
| late_2 | 2,068 | 1.86 | 74.76% |
| late_3 | 2,025 | 1.71 | 78.86% |

**Verdict: supported.** None of the three refutation conditions was met:
(1) the average score never rose between consecutive late buckets (late_1 to
late_2: -1.28; late_2 to late_3: -0.15); (2) the gap between on_time and
late_3 is 2.32 points, above the 1.0 threshold; (3) early orders scored
0.26 points above on_time, above the 0.1 threshold.

**Reading:** The average review score decreases as delay increases, but the
pattern has three levels, not five: early and on_time (about 4), late_1
(about 3.1) and late_2/late_3 (about 1.8). Dissatisfaction rises sharply once
orders are 5 or more days late. After that the average barely moves, which
is consistent with a floor effect: most customers already give 1 star.

**Limitations:** This is an association, not proof of causation. The on_time
group is small (1,280 orders). Orders without a review are 0.5%-3.2% of each
bucket, and the share grows with delay; a worst-case check did not change
the conclusions. A review score is an opinion, not a direct operational
measure.