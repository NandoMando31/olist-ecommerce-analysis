USE olist;

WITH delivered AS (
    SELECT order_id,
           DATEDIFF(DATE(order_delivered_customer_date),
                    order_estimated_delivery_date) AS delay_days
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
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
SELECT d.delay_days,
       COUNT(*)                       AS reviewed_orders,
       ROUND(AVG(r.review_score), 2)  AS avg_score
FROM delivered d
INNER JOIN one_review r ON d.order_id = r.order_id
WHERE d.delay_days BETWEEN 0 AND 15
GROUP BY d.delay_days
ORDER BY d.delay_days;