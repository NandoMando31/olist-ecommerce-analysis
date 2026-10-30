 H2: Does delay hurt satisfaction? Review score by delay bucket.
--
-- Predictions (written before running the query):
--   early avg_score:   4.3
--   late_3 avg_score:  3.5
--   Gap between on_time and late_3 above 1.0 point? YES
--
-- Actual results (added after running):
--   early avg_score:   4.29   (prediction: close)
--   late_3 avg_score:  1.71   (prediction: too high, effect was much stronger)
--   Gap on_time vs late_3: 2.32 points (YES, but larger than expected)
--
-- Method notes:
--   * One review per order (most recent, ties broken by review_id).
--   * LEFT JOIN keeps delivered orders without a review so no_review_pct can
--     be checked per bucket. AVG ignores NULLs, so avg_score and
--     low_review_pct equal those of an INNER JOIN.

USE olist;

WITH delivered AS (
    SELECT order_id,
           DATEDIFF(DATE(order_delivered_customer_date),
                    order_estimated_delivery_date) AS delivery_delay_days
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
),
bucketed AS (
    SELECT order_id, delivery_delay_days,
           CASE WHEN delivery_delay_days < 0  THEN 'early'
                WHEN delivery_delay_days = 0  THEN 'on_time'
                WHEN delivery_delay_days <= 4 THEN 'late_1'
                WHEN delivery_delay_days <= 10 THEN 'late_2'
                ELSE 'late_3' END AS delay_bucket
    FROM delivered
),
one_review AS (
    SELECT order_id, review_score
    FROM (
        SELECT order_id, review_score,
               ROW_NUMBER() OVER (
                   PARTITION BY order_id
                   ORDER BY review_creation_date DESC,
                            review_answer_timestamp DESC,
                            review_id
               ) AS rn
        FROM order_reviews
    ) ranked
    WHERE rn = 1
)
SELECT b.delay_bucket,
       COUNT(*) AS orders,
       ROUND(AVG(r.review_score), 2) AS avg_score,
       ROUND(100 * AVG(r.review_score <= 2), 2) AS low_review_pct
FROM bucketed b
INNER JOIN one_review r ON b.order_id = r.order_id
GROUP BY b.delay_bucket
ORDER BY MIN(b.delivery_delay_days);

SELECT b.delay_bucket,
       COUNT(*)                                           AS delivered_orders,
       COUNT(r.order_id)                                  AS reviewed_orders,
       ROUND(100 * (1 - COUNT(r.order_id) / COUNT(*)), 2) AS no_review_pct,
       ROUND(AVG(r.review_score), 2)                      AS avg_score,
       ROUND(100 * AVG(r.review_score <= 2), 2)           AS low_review_pct
FROM bucketed b
LEFT JOIN one_review r ON b.order_id = r.order_id
GROUP BY b.delay_bucket
ORDER BY MIN(b.delivery_delay_days);