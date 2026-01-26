-- =====================================================
-- 40_delivery_delay_analysis.sql
-- Delivery Delay Impact on Customer Reviews (PostgreSQL)
-- Purpose:
--   Quantify how delivery delays relate to review scores.
--
-- Definitions:
--   delay_days = delivered_customer_date - estimated_delivery_date
--     > 0  => delivered late
--     = 0  => on time
--     < 0  => delivered early
--
-- Outputs:
--   1) Summary stats for delay days
--   2) Delay bucket vs review score distribution (counts & share)
-- =====================================================

SET search_path TO olist;

-- -----------------------------------------------------
-- 1) Build analysis base (delivered orders with review + ETA + delivered date)
-- -----------------------------------------------------

WITH base AS (
    SELECT
        o.order_id,
        o.order_status,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        r.review_score,
        -- delay in full days
        (DATE(o.order_delivered_customer_date) - DATE(o.order_estimated_delivery_date)) AS delay_days
    FROM orders o
    JOIN order_reviews r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND r.review_score IS NOT NULL
)

SELECT
    COUNT(*) AS delivered_orders_with_reviews,
    ROUND(AVG(delay_days), 2) AS avg_delay_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delay_days) AS median_delay_days,
    MIN(delay_days) AS min_delay_days,
    MAX(delay_days) AS max_delay_days,
    SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) AS late_orders_cnt,
    ROUND(100.0 * SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_orders_pct
FROM base;

-- -----------------------------------------------------
-- 2) Delay bucket vs review score (COUNT)
-- -----------------------------------------------------

WITH base AS (
    SELECT
        o.order_id,
        r.review_score,
        (DATE(o.order_delivered_customer_date) - DATE(o.order_estimated_delivery_date)) AS delay_days
    FROM orders o
    JOIN order_reviews r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND r.review_score IS NOT NULL
),

bucketed AS (
    SELECT
        order_id,
        review_score,
        delay_days,
        CASE
            WHEN delay_days <= 0 THEN 'early_or_on_time'
            WHEN delay_days BETWEEN 1 AND 3 THEN 'late_1_3_days'
            WHEN delay_days BETWEEN 4 AND 7 THEN 'late_4_7_days'
            WHEN delay_days BETWEEN 8 AND 14 THEN 'late_8_14_days'
            ELSE 'late_15plus_days'
        END AS delay_bucket
    FROM base
)

SELECT
    delay_bucket,
    review_score,
    COUNT(*) AS cnt
FROM bucketed
GROUP BY 1,2
ORDER BY
    CASE delay_bucket
        WHEN 'early_or_on_time' THEN 1
        WHEN 'late_1_3_days' THEN 2
        WHEN 'late_4_7_days' THEN 3
        WHEN 'late_8_14_days' THEN 4
        WHEN 'late_15plus_days' THEN 5
        ELSE 99
    END,
    review_score;

-- -----------------------------------------------------
-- 3) Delay bucket vs review score (SHARE within bucket)
--     Helps interpret distribution changes per delay bucket.
-- -----------------------------------------------------

WITH base AS (
    SELECT
        o.order_id,
        r.review_score,
        (DATE(o.order_delivered_customer_date) - DATE(o.order_estimated_delivery_date)) AS delay_days
    FROM orders o
    JOIN order_reviews r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND r.review_score IS NOT NULL
),

bucketed AS (
    SELECT
        order_id,
        review_score,
        CASE
            WHEN delay_days <= 0 THEN 'early_or_on_time'
            WHEN delay_days BETWEEN 1 AND 3 THEN 'late_1_3_days'
            WHEN delay_days BETWEEN 4 AND 7 THEN 'late_4_7_days'
            WHEN delay_days BETWEEN 8 AND 14 THEN 'late_8_14_days'
            ELSE 'late_15plus_days'
        END AS delay_bucket
    FROM base
),

agg AS (
    SELECT
        delay_bucket,
        review_score,
        COUNT(*) AS cnt
    FROM bucketed
    GROUP BY 1,2
),

bucket_totals AS (
    SELECT
        delay_bucket,
        SUM(cnt) AS bucket_total
    FROM agg
    GROUP BY 1
)

SELECT
    a.delay_bucket,
    a.review_score,
    a.cnt,
    ROUND(100.0 * a.cnt / NULLIF(t.bucket_total, 0), 2) AS pct_within_bucket
FROM agg a
JOIN bucket_totals t
    ON a.delay_bucket = t.delay_bucket
ORDER BY
    CASE a.delay_bucket
        WHEN 'early_or_on_time' THEN 1
        WHEN 'late_1_3_days' THEN 2
        WHEN 'late_4_7_days' THEN 3
        WHEN 'late_8_14_days' THEN 4
        WHEN 'late_15plus_days' THEN 5
        ELSE 99
    END,
    a.review_score;
