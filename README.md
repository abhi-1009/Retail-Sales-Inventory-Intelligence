# 🛒 Retail Sales & Inventory Intelligence System

![Excel](https://img.shields.io/badge/Excel-Data%20Preprocessing-217346?style=flat&logo=microsoftexcel)
![MySQL](https://img.shields.io/badge/MySQL-Database%20%26%20Queries-orange?style=flat&logo=mysql)
![Power BI](https://img.shields.io/badge/Power%20BI-3%20Dashboards-F2C811?style=flat&logo=powerbi)
![Revenue](https://img.shields.io/badge/Revenue-$7.69M-green?style=flat)
![Orders](https://img.shields.io/badge/Orders-1%2C615-blue?style=flat)
![Internship](https://img.shields.io/badge/Internship-Labmentix-purple?style=flat)

A complete **3-phase retail analytics pipeline** — Excel preprocessing → MySQL database design → Power BI dashboards — built on a 9-table relational retail dataset covering 1,615 orders, $7.69M revenue, 1,445 customers, and 3 stores across NY, CA, and TX. Delivers 6 key business findings and 5 actionable recommendations.

## 📋 Table of Contents

- [Problem Statement](#problem-statement)
- [Dataset](#dataset)
- [Technologies Used](#technologies-used)
- [Phase 1 — Excel Preprocessing](#phase-1--excel-preprocessing)
- [Phase 2 — MySQL Database & SQL Queries](#phase-2--mysql-database--sql-queries)
- [Phase 3 — Power BI Dashboards](#phase-3--power-bi-dashboards)
- [Key Business Findings](#key-business-findings)
- [Business Recommendations](#business-recommendations)
- [Future Scope](#future-scope)

## 📌 Problem Statement

A retail company operating **3 stores across NY, CA, and TX** had no structured analytics system. Management could not identify top-selling products, understand customer behaviour, monitor staff performance, track inventory shortages, or analyse shipment delays. **All data sat in raw CSV files with zero visibility.**

### Business Use Cases Addressed

| # | Business Question |
| :---: | :--- |
| 1 | Identify top-selling brands by region and store |
| 2 | Track customer orders and fulfilment status |
| 3 | Evaluate staff performance by total sales handled |
| 4 | Identify most profitable product categories |
| 5 | Analyse stock levels across stores to optimise inventory |
| 6 | Monitor delayed shipments vs required delivery dates |
| 7 | Discover customer concentration and buying patterns |
| 8 | Understand order trends — daily, weekly, monthly |

## 📂 Dataset

**9 Relational Tables across 2 domains:**

### Sales Domain

| Table | Rows | Key Information |
| :--- | :---: | :--- |
| `orders` | 1,615 | Order transactions, status, dates, store, staff |
| `order_items` | 4,722 | Products per order, price, discount, revenue |
| `customers` | 1,445 | Contact details, city, state — NY / CA / TX |
| `staffs` | 10 | 6 active staff across 3 stores |
| `stores` | 3 | Santa Cruz CA · Baldwin NY · Rowlett TX |

### Production Domain

| Table | Rows | Key Information |
| :--- | :---: | :--- |
| `products` | 321 | Bike models, brand, category, price (2016–2018) |
| `brands` | 9 | Trek, Electra, Surly, Sun Bicycles, Haro... |
| `categories` | 7 | Mountain, Road, Cruisers, Electric, Cyclocross... |
| `stocks` | 939 | Inventory quantity per store per product |

## 🛠️ Technologies Used

| Technology | Version | Purpose |
| :--- | :---: | :--- |
| **Microsoft Excel** | Advanced | Data audit, null handling, calculated columns, date standardisation |
| **MySQL** | 8.0 | Schema design, 9 tables, 8 FK relationships, SQL queries, Views |
| **Microsoft Power BI** | Desktop | 3 dashboards, 32 DAX measures, 6 synced slicers |
| **SQL** | — | 9 analytical queries + 4 Views for BI integration |

## 🔄 Phase 1 — Excel Data Preprocessing

### Data Cleaning Steps

| Step | Action | Finding |
| :---: | :--- | :--- |
| **1. Data Audit** | Ran `COUNTBLANK()` and `COUNTIF()` on all 9 tables | Found 1,267 null phone values + 170 null shipped_dates |
| **2. Null Handling** | Phone → replaced NULLs with `'Not Provided'`; shipped_date blanks kept intentionally (represent unshipped orders) | — |
| **3. Duplicate Removal** | Identified 30 duplicate product names with different product_ids | Flagged as data quality observation; all 321 rows retained to preserve FK integrity |
| **4. Date Standardisation** | Converted order_date, required_date, shipped_date to `YYYY-MM-DD` using `=TEXT(D2,"YYYY-MM-DD")` | Prevents Excel from reformatting on save |
| **5. Calculated Columns** | Added `Revenue = quantity × list_price × (1 − discount)` and `Discount_Amount` in order_items | — |
| **6. Status Labels** | Added `Status_Label` and `Shipment_Flag` (Late / On Time / Not Shipped) in orders | — |
| **Output** | Saved `retail_cleaned.xlsx` with all 9 cleaned sheets + individual `clean_*.csv` files for SQL import | — |

### Key Findings from Excel Phase

| Metric | Value |
| :--- | :---: |
| Total Revenue | **$7,689,116** |
| Total Discounts Given | **$889,872** |
| Late Shipments Identified | **458 orders** |
| Unshipped Orders Flagged | **170 orders** |

## 🗄️ Phase 2 — MySQL Database & SQL Queries

### Database Schema

**9 Tables | 8 Foreign Key Relationships | All FK checks passed ✓**
brands          → brand_id PK, brand_name
categories      → category_id PK, category_name
stores          → store_id PK, store_name, city, state
customers       → customer_id PK, name, email, state
staffs          → staff_id PK, name, store_id FK, manager_id
products        → product_id PK, name, brand_id FK, category_id FK
orders          → order_id PK, customer_id FK, store_id FK, staff_id FK
order_items     → order_id FK + item_id PK, product_id FK, qty, price
stocks          → store_id FK + product_id FK (composite PK), qty

### SQL Queries Written (9 Queries)

| Query | Result |
| :--- | :--- |
| **Total Sales Summary** | Revenue, orders, customers, discounts in one query |
| **Revenue by Store & State** | Baldwin NY: $5.22M (67.8%) · Santa Cruz CA · Rowlett TX |
| **Revenue by Brand** | Trek: $4.60M (59.9%) · Electra: $1.21M · Surly: $0.95M |
| **Revenue by Category** | Mountain Bikes: 35.3% · Road Bikes: 21.7% |
| **Staff Performance** | Boyer: $2.62M · Daniel: $2.59M — top 2 handle 68% of revenue |
| **Late Shipment Analysis** | 31.7% shipped late — Santa Cruz worst at 36.6% |
| **Customer Loyalty** | 91% one-time buyers — only 9% repeat customers |
| **Year-over-Year Trend** | 2016: $2.43M → 2017: $3.45M (+42%) → 2018: partial |
| **Inventory Alerts** | 25 out-of-stock · 141 low-stock items flagged |

### SQL Views Created for Power BI (4 Views)

| View | Purpose |
| :--- | :--- |
| `vw_sales_master` | Joined orders + customers + stores + staff + products |
| `vw_stock_summary` | Inventory levels per store per product with alert flags |
| `vw_staff_performance` | Total revenue and order count per staff member |
| `vw_customer_ltv` | Customer lifetime value aggregation with repeat flag |

## 📊 Phase 3 — Power BI Dashboards

### Dashboard Summary

| Metric | Value |
| :--- | :---: |
| Total Dashboards | **3** |
| DAX Measures | **32** |
| Synced Slicers | **6** |
| Executive Summary Page | **1** |
| Data Source | MySQL Views (4 Views) |

### Dashboard 1 — Executive Summary

| KPI Card | Value |
| :--- | :---: |
| Total Revenue | $7.69M |
| Total Orders | 1,615 |
| Total Customers | 1,445 |
| YoY Growth (2017) | +42% |
| Late Shipment Rate | 31.7% |

### Dashboard 2 — Sales Performance

- Revenue by store, brand, category, staff
- Year-over-year revenue trend (2016–2018)
- Top 5 products by revenue
- Staff performance ranking

### Dashboard 3 — Inventory & Customer Intelligence

- Stock levels per store — out-of-stock and low-stock alerts
- Customer LTV distribution
- Repeat vs one-time buyer breakdown
- Shipment status by store

## 🔍 Key Business Findings

| # | Finding | Evidence |
| :---: | :--- | :--- |
| 1 | **Store Concentration Risk** | Baldwin NY generates 67.8% of all revenue ($5.22M of $7.69M) — single-store dependency |
| 2 | **Trek Brand Dominance** | Trek accounts for 59.9% of revenue ($4.60M) — top product: Trek Slash 8 27.5 at $555,559 |
| 3 | **Mountain Bikes Lead Revenue** | Mountain Bikes $2.72M (35.3%) + Road Bikes $1.67M (21.7%) = 57% of all revenue |
| 4 | **Critical Late Shipment Problem** | 31.7% of shipped orders (458 of 1,445) arrived late — Santa Cruz worst at 36.6% |
| 5 | **Customer Retention Crisis** | 91% of 1,445 customers placed only 1 order — only 131 (9%) are repeat buyers |
| 6 | **Strong 2017 Growth** | Revenue grew from $2.43M (2016) to $3.45M (2017) — **+42% year-over-year growth** |

## 💡 Business Recommendations

| # | Recommendation | Current State | Target Action |
| :---: | :--- | :--- | :--- |
| R1 | **Fix Late Shipments Urgently** | 31.7% late rate | Set KPI: below 10% late within 6 months; audit Santa Cruz first (36.6%) |
| R2 | **Launch Customer Retention Programme** | 91% never return | Post-purchase email + loyalty scheme; 5% conversion = +$430K annual revenue |
| R3 | **Reduce Store & Brand Dependency** | Baldwin 67.8%, Trek 59.9% | Invest in CA and TX stores; negotiate with 2–3 additional brands |
| R4 | **Automate Inventory Reorder Alerts** | 25 out-of-stock, 141 low-stock | Auto reorder at 10-unit threshold; prioritise Trek Mountain and Road Bikes |
| R5 | **Optimise Discount Strategy** | $889,872 discounts (10.5% avg) | Audit 20% discount tier on 1,203 orders; test reducing to 15% |

## 🔮 Future Scope

| # | Enhancement | Description |
| :---: | :--- | :--- |
| 1 | **ML Demand Forecasting** | Scikit-learn model to predict high-demand products by month — train on 2016–2017, validate 2018 |
| 2 | **Customer RFM Segmentation** | K-Means clustering of 1,445 customers into Champion, Loyal, At-Risk, Lost segments |
| 3 | **Real-time ETL Pipeline** | Replace manual CSV import with Apache Airflow or Azure Data Factory for daily Power BI refresh |
| 4 | **Churn Prediction Model** | Binary classifier (Logistic Regression / Random Forest) to identify customers likely not to return |
| 5 | **Supplier & Shipment Intelligence** | Track supplier lead times and carrier performance to fix the 31.7% late shipment root cause |
| 6 | **Mobile-First Dashboard** | Publish to Power BI Service with mobile-optimised layouts for store managers |

## 👤 Author

**Abhijit Sinha**
- GitHub: [@abhi-1009](https://github.com/abhi-1009)
- LinkedIn: [abhijit-sinha-053b159a](https://linkedin.com/in/abhijit-sinha-053b159a)
- Email: sinhaabhijit12@yahoo.com
- Internship: Data Analytics Intern — Labmentix, Bengaluru (May 2026)

