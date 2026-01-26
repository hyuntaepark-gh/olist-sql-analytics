-- =====================================================
-- 10_kpi.sql
-- Core Business KPI Summary
-- =====================================================

-- Ensure correct schema
SET search_path TO olist;

-- KPI Summary (Delivered Orders Only)
SELECT
    COUNT(DISTINCT o.order_id)                    AS total_orders,
    COUNT(DISTINCT c.customer_unique_id)          AS unique_customers,
    SUM(oi.price)                                 AS total_revenue,
    ROUND(SUM(oi.price) 
          / COUNT(DISTINCT o.order_id), 2)        AS aov,
    ROUND(SUM(oi.price) 
          / COUNT(DISTINCT c.customer_unique_id), 2)
                                                   AS revenue_per_customer
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';
