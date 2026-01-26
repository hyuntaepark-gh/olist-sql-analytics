-- =====================================================
-- 20_order_lifecycle_funnel.sql
-- Order Lifecycle Funnel (PostgreSQL)
-- Purpose:
--   Reconstruct a funnel using order lifecycle timestamps
--   (no clickstream available in Olist dataset).
--
-- Funnel Steps (order-based):
--   1) Order Placed
--   2) Payment Approved
--   3) Shipped (Carrier pickup)
--   4) Delivered to Customer
--
-- Outputs:
--   - Step volumes
--   - Step-to-step conversion rates
--   - Drop-off rates
--   - Avg days between steps (lead times)
-- =====================================================

SET search_path TO olist;

WITH base AS (
    SELECT
        o.order_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date
    FROM orders o
),

steps AS (
    SELECT
        '1_order_placed'::text AS step,
        COUNT(DISTINCT order_id) AS orders_cnt
    FROM base
    WHERE order_purchase_timestamp IS NOT NULL

    UNION ALL
    SELECT
        '2_payment_approved' AS step,
        COUNT(DISTINCT order_id) AS orders_cnt
    FROM base
    WHERE order_approved_at IS NOT NULL

    UNION ALL
    SELECT
        '3_shipped_to_carrier' AS step,
        COUNT(DISTINCT order_id) AS orders_cnt
    FROM base
    WHERE order_delivered_carrier_date IS NOT NULL

    UNION ALL
    SELECT
        '4_delivered_to_customer' AS step,
        COUNT(DISTINCT order_id) AS orders_cnt
    FROM base
    WHERE order_delivered_customer_date IS NOT NULL
),

funnel AS (
    SELECT
        step,
        orders_cnt,
        LAG(orders_cnt) OVER (ORDER BY step) AS prev_step_orders
    FROM steps
)

SELECT
    step,
    orders_cnt AS orders,
    prev_step_orders AS prev_orders,
    ROUND(100.0 * orders_cnt / NULLIF(prev_step_orders, 0), 2) AS step_conversion_rate_pct,
    ROUND(100.0 * (1 - (orders_cnt / NULLIF(prev_step_orders, 0)::numeric)), 2) AS step_dropoff_rate_pct
FROM funnel
ORDER BY step;

-- -----------------------------------------------------
-- Lead time analysis (avg days between steps)
-- Only for orders where both timestamps exist.
-- -----------------------------------------------------

WITH base AS (
    SELECT
        o.order_id,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date
    FROM orders o
),

lead_times AS (
    SELECT
        order_id,
        (order_approved_at - order_purchase_timestamp) AS placed_to_approved,
        (order_delivered_carrier_date - order_approved_at) AS approved_to_carrier,
        (order_delivered_customer_date - order_delivered_carrier_date) AS carrier_to_delivered,
        (order_delivered_customer_date - order_purchase_timestamp) AS placed_to_delivered
    FROM base
)

SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM placed_to_approved) / 86400.0), 2) AS avg_days_placed_to_approved,
    ROUND(AVG(EXTRACT(EPOCH FROM approved_to_carrier) / 86400.0), 2) AS avg_days_approved_to_carrier,
    ROUND(AVG(EXTRACT(EPOCH FROM carrier_to_delivered) / 86400.0), 2) AS avg_days_carrier_to_delivered,
    ROUND(AVG(EXTRACT(EPOCH FROM placed_to_delivered) / 86400.0), 2) AS avg_days_placed_to_delivered
FROM lead_times
WHERE placed_to_approved IS NOT NULL
  AND approved_to_carrier IS NOT NULL
  AND carrier_to_delivered IS NOT NULL
  AND placed_to_delivered IS NOT NULL;
