SET search_path TO olist;

WITH base AS (
  SELECT
      c.customer_unique_id,
      DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
),
cohort AS (
  SELECT
      customer_unique_id,
      MIN(order_month) AS cohort_month
  FROM base
  GROUP BY 1
),
activity AS (
  SELECT
      b.customer_unique_id,
      c.cohort_month,
      b.order_month,
      (EXTRACT(YEAR FROM b.order_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
      + (EXTRACT(MONTH FROM b.order_month) - EXTRACT(MONTH FROM c.cohort_month)) AS month_index
  FROM base b
  JOIN cohort c USING (customer_unique_id)
),
cohort_size AS (
  SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS cohort_customers
  FROM cohort
  GROUP BY 1
),
ret AS (
  SELECT
      cohort_month,
      month_index,
      COUNT(DISTINCT customer_unique_id) AS active_customers
  FROM activity
  WHERE month_index BETWEEN 0 AND 6
  GROUP BY 1,2
)
SELECT
  r.cohort_month::date AS cohort_month,
  cs.cohort_customers,
  ROUND(100.0 * SUM(CASE WHEN month_index=0 THEN active_customers END) / cs.cohort_customers, 1) AS m0,
  ROUND(100.0 * SUM(CASE WHEN month_index=1 THEN active_customers END) / cs.cohort_customers, 1) AS m1,
  ROUND(100.0 * SUM(CASE WHEN month_index=2 THEN active_customers END) / cs.cohort_customers, 1) AS m2,
  ROUND(100.0 * SUM(CASE WHEN month_index=3 THEN active_customers END) / cs.cohort_customers, 1) AS m3,
  ROUND(100.0 * SUM(CASE WHEN month_index=4 THEN active_customers END) / cs.cohort_customers, 1) AS m4,
  ROUND(100.0 * SUM(CASE WHEN month_index=5 THEN active_customers END) / cs.cohort_customers, 1) AS m5,
  ROUND(100.0 * SUM(CASE WHEN month_index=6 THEN active_customers END) / cs.cohort_customers, 1) AS m6
FROM ret r
JOIN cohort_size cs USING (cohort_month)
GROUP BY 1,2
ORDER BY 1;
