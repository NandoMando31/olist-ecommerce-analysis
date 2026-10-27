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