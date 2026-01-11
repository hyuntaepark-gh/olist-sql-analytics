# Olist SQL Analytics Project

End-to-end SQL analytics project using the **Olist Brazilian E-commerce dataset**.  
This project focuses on **business KPI analysis, cohort retention, and order lifecycle funnel analysis** using SQL.

---

## 📌 Project Overview

The goal of this project is to demonstrate **advanced SQL analytics skills** by transforming raw transactional data into meaningful business insights.

Key objectives:
- Design a relational data model from raw e-commerce data
- Build analysis-ready tables using SQL (CTEs & window functions)
- Analyze customer behavior through KPIs, cohorts, and funnels
- Translate query results into actionable business insights

This project is designed as a **portfolio project for data analyst / analytics roles**, with an emphasis on SQL as the primary analytical tool.

---

## 🗂️ Data Source

- **Dataset**: Brazilian E-Commerce Public Dataset by Olist  
- **Platform**: Kaggle  
- **Period**: 2016 – 2018  
- **Size**: ~100k orders

🔗 Dataset link:  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

> Raw CSV files are not included in this repository.  
> Please download the dataset directly from Kaggle if you want to reproduce the analysis.

---

## 🧱 Data Model (ERD)

The dataset follows a normalized relational structure, centered around orders and customers.

Main tables used:
- `orders`
- `order_items`
- `order_payments`
- `customers`
- `products`
- `order_reviews`
- `product_category_name_translation`

📌 An ERD diagram will be added in `docs/erd.png`.

---

## 🛠️ Tech Stack

- **SQL** (PostgreSQL syntax)
- **Git / GitHub**
- Markdown for documentation

---

## 📊 Analysis Scope

### 1. Core Business KPIs
- Total revenue
- Number of orders
- Number of unique customers
- Average Order Value (AOV)
- Revenue per customer
- Repeat purchase rate

📁 SQL: `sql/10_kpi.sql`

---

### 2. Order Lifecycle Funnel Analysis
Since clickstream event data is not available, a **order-based funnel** is constructed using order timestamps.

Funnel steps:
1. Order placed
2. Payment approved
3. Order shipped
4. Order delivered

Key metrics:
- Step-to-step conversion rate
- Drop-off rate
- Time between steps (lead time analysis)

📁 SQL: `sql/20_funnel_orders.sql`

---

### 3. Cohort Retention Analysis
Customer retention is analyzed using **monthly cohorts based on first purchase date**.

- Cohort month: customer’s first purchase month
- Retention measured by repeat orders in subsequent months
- Output formatted as a cohort retention matrix

📁 SQL: `sql/30_cohort_retention.sql`

---

## 🧠 Key SQL Techniques Used

- Common Table Expressions (CTEs)
- Window functions (`ROW_NUMBER`, `LAG`, `SUM OVER`)
- Multi-table joins
- Date & time transformations
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
   - Analysis scripts (`10_*.sql`, `20_*.sql`, `30_*.sql`)
4. Review results and insights in `docs/results.md`

---

## 🚀 Future Improvements

- Add customer lifetime value (LTV) analysis
- Segment analysis by product category and region
- Performance optimization with indexing
- Visualization layer (BI tool)

---

## 📎 Disclaimer

This project is for **educational and portfolio purposes only**.  
All data belongs to Olist and its original providers.
