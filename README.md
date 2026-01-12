# Olist SQL Analytics Project

End-to-end SQL analytics project using the **Olist Brazilian E-commerce dataset**.  
This project demonstrates **advanced SQL analytics skills** by transforming raw transactional data into **business-ready insights**.

Rather than focusing on simple queries, this project emphasizes **business-oriented analysis**, answering real-world questions such as:
- Where do customers drop off in the order lifecycle?
- How does delivery performance impact customer satisfaction?
- How well does the business retain customers over time?

---

## 📌 Project Overview

The goal of this project is to showcase **production-style SQL analytics** skills:

- Designing a relational data model from raw CSV files  
- Building analysis-ready tables using SQL (CTEs, joins, window functions)  
- Performing KPI, funnel, cohort, and operational impact analysis  
- Translating query results into **actionable business insights**

This repository is structured as a **portfolio project for Data Analyst / Business Analytics roles**, with SQL as the primary analytical tool.

---

## 🗂️ Data Source

- **Dataset**: Brazilian E-Commerce Public Dataset by Olist  
- **Platform**: Kaggle  
- **Period**: 2016 – 2018  
- **Scale**: ~100,000 orders

🔗 Dataset link:  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

> Raw CSV files are **not included** in this repository.  
> Please download the dataset directly from Kaggle to reproduce the analysis.

---

## 🧱 Data Model (ERD)

The dataset follows a normalized relational structure centered around customer orders.

Main tables:
- `customers`
- `orders`
- `order_items`
- `order_payments`
- `order_reviews`
- `products`
- `product_category_name_translation`

📌 ERD diagram: `docs/erd.png`

---

## 🛠️ Tech Stack

- **SQL (PostgreSQL syntax)**
- **Git / GitHub**
- Markdown for documentation

---

## 📊 Analysis Scope

### 1. Core Business KPIs

Key metrics calculated using SQL:
- Total number of orders
- Unique customers
- Average Order Value (AOV)
- Orders per customer
- Revenue-related aggregates

📁 SQL file: `sql/10_kpi.sql`

---

### 2. Order Lifecycle Funnel Analysis

Because clickstream data is not available, an **order-based funnel** is constructed
using order timestamps.

Funnel steps:
1. Order placed
2. Payment approved
3. Order shipped
4. Order delivered

Key insights:
- Step-to-step conversion rates
- Drop-off points across the order lifecycle
- Data coverage validation across related tables

📁 SQL file: `sql/20_funnel_orders.sql`

---

### 3. Cohort Retention Analysis

Customer retention is analyzed using **monthly cohorts** based on the first purchase date.

- Cohort month = customer’s first order month
- Retention measured by repeat purchases in subsequent months
- Output formatted as a cohort retention matrix

📁 SQL file: `sql/30_cohort_retention.sql`

---

### 4. Delivery Delay Impact on Customer Satisfaction ⭐

This analysis evaluates how **delivery delays affect customer review scores**.

Orders are grouped into delay buckets based on how late they were delivered
relative to the estimated delivery date.

Delay buckets:
- 0–3 days
- 4–7 days
- 8–14 days
- 15+ days

Key findings:
- Orders delayed **15+ days** show a strong concentration of **1–2 star reviews**
- Even moderate delays (4–7 days) correlate with lower customer satisfaction
- On-time or near-on-time deliveries maintain significantly higher review scores

This analysis highlights how **operational performance directly impacts customer experience**.

📁 SQL file: `sql/40_delivery_delay_reviews.sql`

---

## 🧠 Key SQL Techniques Used

- Common Table Expressions (CTEs)
- Window functions (`ROW_NUMBER`, `LAG`, `SUM OVER`)
- Multi-table joins
- Date and time interval calculations
- Aggregation and cohort modeling

---

## 📁 Repository Structure

```

olist-sql-analytics/
├─ README.md
├─ sql/
│ ├─ 00_setup.sql
│ ├─ 01_staging.sql
│ ├─ 02_marts.sql
│ ├─ 10_kpi.sql
│ ├─ 20_funnel_orders.sql
│ ├─ 30_cohort_retention.sql
│ ├─ 40_delivery_delay_reviews.sql
│ └─ 99_tests.sql
├─ docs/
│ ├─ erd.png
│ ├─ assumptions.md
│ └─ results.md

```

---

## ▶️ How to Run

1. Download the dataset from Kaggle  
2. Load CSV files into a PostgreSQL database  
3. Run SQL scripts in order:
   - `00_setup.sql`
   - `01_staging.sql`
   - `02_marts.sql`
   - Analysis scripts (`10_*.sql`, `20_*.sql`, `30_*.sql`, `40_*.sql`)
4. Review results and insights in `docs/results.md`

---

## 🚀 Future Improvements

- Customer Lifetime Value (LTV) analysis
- Regional and product category segmentation
- Performance optimization using indexing
- Visualization layer using a BI tool (Tableau / Power BI)

---

## 📎 Disclaimer

This project is for **educational and portfolio purposes only**.  
All data belongs to Olist and its original providers.
