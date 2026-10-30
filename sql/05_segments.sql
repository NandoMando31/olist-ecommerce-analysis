-- Predictions (written before running):
--   approval:         20 %
--   seller_handling:  35 %
--   carrier_transit:  45 %

USE olist;

SELECT
  SUM(order_delivered_carrier_date < order_approved_at)            AS carrier_before_approval,
  SUM(order_delivered_customer_date < order_delivered_carrier_date) AS customer_before_carrier
FROM orders
WHERE order_status = 'delivered'
  AND order_approved_at IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;

  WITH base AS (
    SELECT order_id,
           TIMESTAMPDIFF(SECOND, order_purchase_timestamp, order_approved_at) / 86400 AS approval_days,
           TIMESTAMPDIFF(SECOND, order_approved_at, order_delivered_carrier_date) / 86400 AS handling_days,
           TIMESTAMPDIFF(SECOND, order_delivered_carrier_date, order_delivered_customer_date) / 86400 AS transit_days,
           TIMESTAMPDIFF(SECOND, order_purchase_timestamp, order_delivered_customer_date) / 86400 AS total_days
    FROM orders
    WHERE order_status = 'delivered'
      AND order_approved_at IS NOT NULL
      AND order_delivered_carrier_date IS NOT NULL
      AND order_delivered_customer_date IS NOT NULL
),
shares AS (
    SELECT order_id,
           approval_days / total_days AS approval_share,
           handling_days / total_days AS handling_share,
           transit_days  / total_days AS transit_share
    FROM base
    WHERE total_days > 0
      AND approval_days >= 0 AND handling_days >= 0 AND transit_days >= 0
),
long_format AS (
    SELECT 'approval' AS segment, approval_share AS share FROM shares
    UNION ALL
    SELECT 'seller_handling', handling_share FROM shares
    UNION ALL
    SELECT 'carrier_transit', transit_share FROM shares
),
ranked AS (
    SELECT segment, share,
           ROW_NUMBER() OVER (PARTITION BY segment ORDER BY share) AS rn,
           COUNT(*)     OVER (PARTITION BY segment)                AS cnt
    FROM long_format
)
SELECT segment,
       MAX(cnt) AS orders,
       ROUND(100 * AVG(share), 2) AS median_share_pct
FROM ranked
WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
GROUP BY segment
ORDER BY median_share_pct DESC;