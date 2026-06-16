# Portfolio SQL Queries and Execution Results

This document contains the complete analytical suite used to audit our fintech loan portfolio. The queries are organized by business priority, beginning with high-level financial KPIs, moving through credit risk analysis, operational tracking, and concluding with systemic data integrity audits.

---

## 📈 Section 1: Financial KPIs & Portfolio Exposure

### Q1: Total Active Asset Exposure and Top-of-Funnel Count
* **Business Purpose:** Generates macro-level volume metrics for executive liquidity and balance-sheet reporting.

```sql
SELECT 
    COUNT(application_id) AS total_onboarded_applications,
    SUM(applied_amount) AS total_portfolio_capital_demanded,
    ROUND(AVG(applied_amount), 2) AS average_ticket_size
FROM applications;

```

### Result

| Metric | Value |
|---------|---------|
| Total Onboarded Applications | 200 |
| Total Portfolio Capital Demanded | $3,355,730.00 |
| Average Ticket Size | $16,778.65 |



### Q2: Master Portfolio Default Rate (Asset Quality Mix)
* **Business Purpose:** Directly measures bottom-line portfolio impairment and historical credit risk.

```sql
SELECT 
    loan_status,
    COUNT(*) AS total_accounts,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_performance), 2) AS portfolio_percentage
FROM loan_performance
GROUP BY loan_status
ORDER BY total_accounts DESC;

```

### Result

### Loan Status Breakdown

| Loan Status | Total Accounts | Portfolio Percentage |
| :--- | :---: | :---: |
| Defaulted | 83 | 41.50% |
| Paid Off | 59 | 29.50% |
| Current | 58 | 29.00% |




### Q3 Structural Verification Funnel Pass vs. Leakage Rate
* **Business Purpose:** Evaluates the conversion drop-off driven by credit risk filtering rules.

```sql
SELECT 
    verification_status,
    COUNT(*) AS absolute_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM verification_log), 2) AS conversion_rate
FROM verification_log
GROUP BY verification_status;

```

### Result

### Verification Status Breakdown

| Verification Status | Absolute Count | Conversion Rate |
| :--- | :---: | :---: |
| Approved | 117 | 58.50% |
| Flagged | 83 | 41.50% |

### Q4 Capital Allocation Flow by Employment Demographics
* **Business Purpose:** Informs targeted user-acquisition costs and customized limit assignments.

```sql
SELECT 
    employment_type,
    COUNT(*) AS application_count,
    SUM(applied_amount) AS allocated_capital,
    ROUND(AVG(applied_amount), 2) AS avg_demanded_amount
FROM applications
GROUP BY employment_type;
```
### Result

### Employment Type Analysis

| Employment Type | Application Count | Allocated Capital | Avg. Demanded Amount |
| :--- | :---: | :---: | :---: |
| Salaried | 114 | $1,941,230.00 | $17,028.33 |
| Self Employed | 86 | $1,414,500.00 | $16,447.67 |


