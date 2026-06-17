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

## 📈 Q5: Gross Principal Capital Recovered vs. Outstanding Pipeline

### Business Purpose
Disbursal cash flow tracking to evaluate baseline asset performance and measure how much of the loan principal has been recovered across different loan statuses.

### SQL Query

```sql
SELECT 
    p.loan_status,
    SUM(a.applied_amount) AS total_disbursed_principal,
    SUM(p.amount_paid) AS total_collected_cash,
    ROUND(
        SUM(p.amount_paid) * 100.0 / SUM(a.applied_amount),
        2
    ) AS recovery_ratio
FROM loan_performance p
JOIN applications a
    ON p.application_id = a.application_id
GROUP BY p.loan_status;
```

### Result

#### Portfolio Performance by Loan Status

| Loan Status | Total Disbursed Principal | Total Collected Cash | Recovery Ratio |
|------------|--------------------------:|---------------------:|---------------:|
| Current | $985,123.59 | $985,123.59 | 100.00% |
| Paid Off | $1,024,349.35 | $1,024,349.35 | 100.00% |
| Defaulted | $1,346,257.06 | $107,650.00 | 8.00% |




## 📊 Q6: Average Underwriting Credit Score Across Customer Base

### Business Purpose
Establishes the historical credit profile foundation of applicants entering the lending system. This metric helps assess the overall credit quality of the applicant pool and supports risk-based lending decisions.

### SQL Query

```sql
SELECT
    MIN(credit_score) AS credit_score_floor,
    MAX(credit_score) AS credit_score_ceiling,
    ROUND(AVG(credit_score), 1) AS standardized_portfolio_average
FROM applications;
```

### Result

#### Portfolio Credit Score Distribution

| Credit Score Floor | Credit Score Ceiling | Standardized Portfolio Average |
|-------------------:|---------------------:|--------------------------------:|
| 709 | 798 | 754.2 |




## ⚡ Q7: Global System Processing Efficiency (Operational TAT Baseline)

### Business Purpose
Establishes organizational Service Level Agreement (SLA) speed benchmarks by measuring the efficiency of the verification workflow. These metrics help identify operational bottlenecks and evaluate processing performance across the lending pipeline.

### SQL Query

```sql
SELECT
    ROUND(AVG(turnaround_time_hours), 2) AS system_wide_avg_tat_hours,
    MIN(turnaround_time_hours) AS fastest_triage_hours,
    MAX(turnaround_time_hours) AS slowest_escalation_hours
FROM verification_log;
```

### Result

#### Verification Processing Performance

| System-Wide Avg TAT (Hours) | Fastest Triage (Hours) | Slowest Escalation (Hours) |
|----------------------------:|-----------------------:|---------------------------:|
| 35.48 | 10 | 60 |




## 🛠️ Section 2: Credit Risk Infrastructure & Cohort Drills

### Q8: Occupational Risk Matrix (Employment Type vs. Default Propensity)

### Business Purpose
Identifies high-risk borrower segments based on employment classification. This analysis helps credit risk teams implement targeted underwriting controls, optimize approval policies, and reduce future portfolio losses.

### SQL Query

```sql
SELECT
    a.employment_type,
    COUNT(*) AS total_booked_loans,
    SUM(
        CASE
            WHEN p.loan_status = 'defaulted' THEN 1
            ELSE 0
        END
    ) AS default_volume,
    ROUND(
        SUM(
            CASE
                WHEN p.loan_status = 'defaulted' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS segment_default_rate
FROM applications a
JOIN loan_performance p
    ON a.application_id = p.application_id
GROUP BY a.employment_type;
```

### Result

#### Employment Segment Risk Analysis

| Employment Type | Total Booked Loans | Default Volume | Segment Default Rate (%) |
|----------------|-------------------:|---------------:|-------------------------:|
| Self Employed | 86 | 49 | 56.98 |
| Salaried | 114 | 34 | 29.82 |




### Q9: Early Warning Signal (EWS) – Missed Payments Velocity Cliff

### Business Purpose
Identifies the critical delinquency threshold at which borrowers transition from manageable repayment delays into high-probability default events. This analysis supports Early Warning Systems (EWS), collection prioritization, and proactive portfolio risk management.

### SQL Query

```sql
SELECT
    CASE
        WHEN missed_payments = 0 THEN '0: Perfect Standings'
        WHEN missed_payments BETWEEN 1 AND 2 THEN '1-2: Minor Delinquency'
        WHEN missed_payments BETWEEN 3 AND 5 THEN '3-5: Warning Cohort'
        ELSE '6+: Severe Write-Off Impairment'
    END AS delinquency_lifecycle_tier,
    COUNT(*) AS total_accounts,
    SUM(
        CASE
            WHEN loan_status = 'defaulted' THEN 1
            ELSE 0
        END
    ) AS hard_defaults,
    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'defaulted' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS conversion_to_default_pct
FROM loan_performance
GROUP BY 1
ORDER BY 1;
```

### Result

#### Delinquency Lifecycle Analysis

| Delinquency Lifecycle Tier | Total Accounts | Hard Defaults | Conversion to Default (%) |
|----------------------------|---------------:|--------------:|--------------------------:|
| 0: Perfect Standings | 109 | 0 | 0.00 |
| 1-2: Minor Delinquency | 80 | 0 | 0.00 |
| 6+: Severe Write-Off Impairment | 11 | 11 | 100.00 |


### Q10: Underwriting Disconnect (Credit Score vs. Default Rates)

### Business Purpose
Evaluates whether borrower credit scores effectively predict default behavior within the portfolio. This analysis helps validate underwriting quality and determine whether bureau scores remain a reliable risk assessment tool.

### SQL Query

```sql
SELECT
    CASE
        WHEN credit_score < 730 THEN '700-729: Low-Tier Bureau'
        WHEN credit_score BETWEEN 730 AND 760 THEN '730-760: Mid-Tier Bureau'
        ELSE '761+: Premium-Tier Bureau'
    END AS score_bracket,
    COUNT(*) AS total_allocated,
    SUM(
        CASE
            WHEN p.loan_status = 'defaulted' THEN 1
            ELSE 0
        END
    ) AS defaults,
    ROUND(
        SUM(
            CASE
                WHEN p.loan_status = 'defaulted' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS default_ratio
FROM applications a
JOIN loan_performance p
    ON a.application_id = p.application_id
GROUP BY 1
ORDER BY 1;
```

### Result

#### Credit Score Risk Segmentation Analysis

| Score Bracket | Total Allocated | Defaults | Default Ratio (%) |
|--------------|----------------:|----------:|------------------:|
| 700-729: Low-Tier Bureau | 44 | 19 | 43.18 |
| 730-760: Mid-Tier Bureau | 70 | 30 | 42.86 |
| 761+: Premium-Tier Bureau | 86 | 34 | 39.53 |

