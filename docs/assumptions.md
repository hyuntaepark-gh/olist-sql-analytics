# Assumptions & Definitions

This document describes the key assumptions, definitions, and calculation logic used in this SQL analytics project.
The goal is to ensure that the analysis is **consistent, reproducible, and interpretable**.

---

## 1) Dataset Scope

This project uses the **Olist Brazilian E-commerce dataset**.

Main tables used (raw → staging):
- `orders`
- `order_items`
- `order_payments`
- `order_reviews`
- `customers`
- `products`
- `sellers`
- `geolocation`

---

## 2) Order Status Filtering

Depending on the analysis goal, orders may be filtered by status.

### Delivered Orders (Primary Business Analysis)
For customer satisfaction, delivery performance, and retention analysis, the primary focus is:

- `order_status = 'delivered'`

### All Orders (Operational / Funnel Coverage)
For lifecycle coverage checks and funnel analysis, orders may include all statuses:

- `delivered`
- `shipped`
- `invoiced`
- `processing`
- `canceled`
- `unavailable`

> The filtering condition is explicitly stated in each query file when applied.

---

## 3) Date & Time Reference

Different business questions require different date fields.

### Purchase Date (Default)
Used for cohort and sales timeline analysis:

- `order_purchase_timestamp`

### Delivery Dates
Used for delivery performance and delay analysis:
- `order_delivered_customer_date`
- `order_estimated_delivery_date`

> If a delivery date is missing, delay-related metrics may exclude those orders to avoid invalid calculations.

---

## 4) KPI Definitions

### 4.1 Order Count
- **Order Count** = number of unique `order_id`

### 4.2 Customer Count
- **Customer Count** = number of unique `customer_unique_id`

> `customer_unique_id` is used to track repeat customers across multiple orders.

### 4.3 Revenue (Sales)
Revenue is calculated using payments.

- **Revenue** = `SUM(payment_value)`

Notes:
- Revenue is aggregated at the order level when needed.
- If an order has multiple payment records, all are included in the total.

### 4.4 Average Order Value (AOV)
- **AOV** = Revenue / Order Count

---

## 5) Funnel / Order Lifecycle Definitions

Order lifecycle stages are interpreted using available timestamps:

Common lifecycle fields:
- `order_purchase_timestamp`
- `order_approved_at`
- `order_delivered_carrier_date`
- `order_delivered_customer_date`

Funnel logic examples:
- Purchase → Approved → Shipped → Delivered

> Funnel analysis focuses on whether orders contain the expected lifecycle events and whether any steps are missing.

---

## 6) Cohort & Retention Definitions

### 6.1 Cohort Month
Cohorts are defined by the customer's **first purchase month**.

- **First Purchase Date** = MIN(`order_purchase_timestamp`) per `customer_unique_id`
- **Cohort Month** = month of First Purchase Date

### 6.2 Retention
Retention is measured as whether a customer places an order in later months after the cohort month.

- **Retention Month Index** = (Order Month - Cohort Month)
- **Retained Customer** = customer has ≥ 1 order in that month

> Retention is expressed as a cohort matrix showing repeat purchase behavior over time.

---

## 7) Delivery Delay Definitions

Delivery delay compares actual delivery vs estimated delivery.

### 7.1 Delay Days
- **Delay Days** = `order_delivered_customer_date` - `order_estimated_delivery_date`

Interpretation:
- Delay Days > 0  → delivered late
- Delay Days = 0  → delivered on time
- Delay Days < 0  → delivered early

> Orders without both delivery dates are excluded from delay calculations.

### 7.2 Delay Buckets
Delay buckets are used to simplify analysis and improve interpretability.

Example bucket logic:
- Early / On-time (Delay Days ≤ 0)
- 1–3 days late
- 4–7 days late
- 8+ days late

> Exact bucket thresholds may vary by query and are defined inside the relevant SQL script.

---

## 8) Review Score Handling

Review data is used to measure customer satisfaction.

- Review Score field: `review_score` (typically 1 to 5)

Notes:
- Orders without a review may be excluded from review-score comparisons.
- Review scores are aggregated by delay bucket to evaluate delivery impact.

---

## 9) Data Quality Checks

Basic validation checks may include:
- Duplicate order IDs in intermediate joins
- Missing lifecycle timestamps
- Missing customer identifiers
- Payment totals exceeding expected ranges

These checks are included to ensure analysis reliability.

---

## 10) Notes & Limitations

- This dataset represents historical e-commerce transactions and may not fully reflect real-time operations.
- Revenue is based on payment records and does not account for refunds unless explicitly represented in the dataset.
- Some orders may have incomplete lifecycle timestamps, which can impact funnel completeness metrics.

---

## 📌 Summary

This project emphasizes:
- clear KPI definitions
- consistent cohort logic
- explainable funnel and delay metrics
- transparent filtering rules

These assumptions ensure the SQL analysis is reproducible and aligned with real business analytics practices.
