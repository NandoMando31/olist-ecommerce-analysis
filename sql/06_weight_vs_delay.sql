-- Predictions: not recorded before running this query (oversight).
-- The refutation thresholds were fixed beforehand (see docs/hypotheses.md,
-- H3 and Amendment 2), so the hypothesis test itself is not affected.

USE olist;


WITH delivered AS (
    SELECT order_id,
           DATEDIFF(DATE(order_delivered_customer_date),
                    order_estimated_delivery_date) AS delay_days
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
),
order_weight AS (
    SELECT oi.order_id,
           SUM(p.product_weight_g) AS total_weight_g,
           SUM(p.product_weight_g IS NULL OR p.product_weight_g = 0) AS items_missing_weight
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY oi.order_id
),
grouped AS (
    SELECT d.order_id, d.delay_days, w.total_weight_g,
           CASE WHEN w.total_weight_g <= 1000  THEN 'light'
                WHEN w.total_weight_g <= 10000 THEN 'medium'
                WHEN w.total_weight_g <= 20000 THEN 'heavy'
                ELSE 'super_heavy' END AS weight_group
    FROM delivered d
    JOIN order_weight w ON w.order_id = d.order_id
    WHERE w.items_missing_weight = 0
)
SELECT weight_group,
       COUNT(*) AS orders
       -- , ROUND(100 * AVG(delay_days > 0), 2) AS late_pct
FROM grouped
GROUP BY weight_group
ORDER BY MIN(total_weight_g);