# Fintech Loan Analytics SQL Project

## Project Overview
This project simulates an enterprise fintech loan origination and portfolio performance monitoring system using SQL. The objective is to analyze the end-to-end lifecycle of a loan application—from initial submission and operational verification to final repayment or default classification. 

By querying this relational database, we generate actionable business intelligence to optimize credit risk parameters, identify operational verification bottlenecks, and improve bottom-line portfolio recovery strategies.

---

## Business Problem
Fintech lenders process vast volumes of high-velocity digital loan applications monthly. Maintaining automated profitability while keeping credit losses (Loss Given Default) low requires continuous portfolio auditing. This project addresses the core operational and risk management questions:
* What is the structural leakage/rejection rate at the verification funnel?
* How does operational verification Turnaround Time (TAT) impact conversion metrics?
* Which specific occupational risk segments display an accelerated velocity toward default?
* Can early warning signals (EWS) be isolated using missed payment trends before an account transitions into a non-performing asset (NPA)?

---

## Database Schema & Architecture

The database architecture consists of three highly synchronized tables structured to maintain absolute referential integrity:




[applications] 
   ├── (1:1) ──> [verification_log]
   └── (1:1) ──> [loan_performance]




### 1. Applications Table
Stores top-of-funnel consumer profiling data upon loan origination.
* `application_id` (INT, Primary Key)
* `customer_name` (VARCHAR)
* `applied_amount` (DECIMAL)
* `application_date` (DATE)
* `credit_score` (INT)
* `employment_type` (VARCHAR) — *Enforced via CHECK constraint (`'salaried'`, `'self employed'`)*

### 2. Verification Log Table
Tracks the operational risk management layer and manual agent processing metrics.
* `verification_id` (INT, Primary Key)
* `application_id` (INT, Foreign Key referencing `applications`)
* `assigned_agent` (VARCHAR)
* `verification_status` (VARCHAR) — *Enforced via CHECK constraint (`'approved'`, `'flagged'`)*
* `turnaround_time_hours` (INT)
* `risk_flag_reason` (VARCHAR)

### 3. Loan Performance Table
Monitors continuous post-disbursal repayment behavior and delinquency aging.
* `loan_id` (INT, Primary Key)
* `application_id` (INT, Foreign Key referencing `applications`)
* `loan_status` (VARCHAR) — *Enforced via CHECK constraint (`'current'`, `'defaulted'`, `'paid off'`)*
* `amount_paid` (DECIMAL)
* `missed_payments` (INT)

---

## SQL Concepts Demonstrated
This project avoids basic `SELECT *` scripts and showcases advanced data analytics structures:
* **Data Definition Language (DDL):** Building schemas with data-guard constraints (`NOT NULL`, `CHECK`, `DEFAULT`).
* **Deep Multi-Table JOINs:** Linking operational funnels with downstream credit performance.
* **Conditional Aggregations:** Utilizing complex `CASE WHEN` clauses inside aggregate functions to isolate specific attributes dynamically.
* **Common Table Expressions (CTEs) & Subqueries:** Structuring highly readable, layered queries for complex portfolio segmentation.
* **Window Functions:** Running analytical ranking and performance benchmarks across variables (e.g., tracking verification agent efficiency via `AVG() OVER()`).

---

## Core Core Key Performance Indicators (KPIs) Derived
The analysis scripts calculate standard institutional lending metrics, including:
* **Funnel Approval & Rejection Rates:** Measures structural credit policy strictness.
* **Portfolio Default Rate:** The absolute percentage of booked asset accounts trending into charge-off status.
* **Operational Verification Velocity (TAT):** Average processing hours evaluated across agents and risk categories.
* **Delinquency Velocity:** Granular correlation tracking between the count of `missed_payments` and final loan default realization.

---

## Project Structure & Files
* **`schema.sql`**: Production-grade database table initialization scripts containing explicit data integrity guardrails.
* **`data.sql`**: Comprehensive transactional dataset featuring 200 distinct application rows meticulously mapped to track performance logic.
* **`queries.sql`**: Advanced analytical SQL scripts executing the core KPI calculations and business trend extraction.
* **`insights.md`**: Deep-dive executive overview detailing key portfolio findings, operational bottleneck identifications, and strategic mitigation workflows.

---

## Tools & Environment
* **Database Engine:** PostgreSQL / MySQL compatible standard ANSI SQL
* **Documentation & Styling:** Markdown, Git
* **Analytics Strategy Framework:** Fintech Credit Risk Management (CRM) Principles

---

## Future Enhancements
* **Power BI Dashboard Integration:** Transforming the analytical SQL outputs into dynamic interactive risk-matrix visuals.
* **Advanced Cohort Segmentation:** Analyzing month-on-month vintage default rates to measure historical credit deterioration curves.
* **Predictive Risk Modeling:** Moving from retroactive SQL reporting to predictive machine learning algorithms for automated credit limit adjustments.
   
