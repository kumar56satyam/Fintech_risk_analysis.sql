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






### Q11: High-Value Exposure Capital at Extreme Default Risk

### Business Purpose
Measures the total capital exposure associated with borrowers who have completely ceased repayment activity. This metric identifies the portion of the portfolio experiencing maximum credit impairment and potential full principal loss.

### SQL Query

```sql
SELECT
    COUNT(*) AS severe_loss_units,
    SUM(a.applied_amount) AS principal_at_total_loss
FROM applications a
JOIN loan_performance p
    ON a.application_id = p.application_id
WHERE p.loan_status = 'defaulted'
  AND p.amount_paid = 0;
```

### Result

#### Severe Loss Exposure Analysis

| Severe Loss Units | Principal at Total Loss |
|------------------:|------------------------:|
| 31 | $512,400.00 |





### Q12: Distribution Audit of Underwriting Risk Flags

### Business Purpose
Identifies the most common verification and underwriting failure reasons across the portfolio. This analysis helps operations teams prioritize process improvements, strengthen fraud controls, and optimize verification workflows.

### SQL Query

```sql
SELECT
    risk_flag_reason,
    COUNT(*) AS incident_frequency,
    ROUND(
        COUNT(*) * 100.0 /
        (
            SELECT COUNT(*)
            FROM verification_log
            WHERE verification_status = 'flagged'
        ),
        2
    ) AS contribution_pct
FROM verification_log
WHERE verification_status = 'flagged'
GROUP BY risk_flag_reason
ORDER BY incident_frequency DESC;
```

### Result

#### Underwriting Risk Flag Distribution

| Risk Flag Reason | Incident Frequency | Contribution (%) |
|------------------|-------------------:|-----------------:|
| Borderline Verification | 41 | 49.40 |
| Needs Clarification | 28 | 33.73 |
| Fake Employment | 8 | 9.64 |
| Address Mismatch | 6 | 7.23 |





### Q13: Exposure Outliers (Applications Exceeding Twice the Average Ticket Size)

### Business Purpose
Identifies unusually large loan applications that exceed established concentration thresholds. This analysis helps risk teams detect excessive single-borrower exposure and maintain portfolio diversification standards.

### SQL Query

```sql
SELECT
    application_id,
    customer_name,
    applied_amount,
    employment_type
FROM applications
WHERE applied_amount >
(
    SELECT AVG(applied_amount) * 2
    FROM applications
)
ORDER BY applied_amount DESC;
```

### Result

#### High-Exposure Application Audit

| Result |
|----------|
| No rows returned |






### Q14: Default Rate Concentration Across Loan Amount Quartiles

### Business Purpose
Evaluates whether larger loan approvals are associated with higher default risk. By segmenting applications into loan amount quartiles, this analysis helps determine whether exposure size influences borrower repayment performance.

### SQL Query

```sql
WITH quartiles AS (
    SELECT
        application_id,
        applied_amount,
        NTILE(4) OVER (ORDER BY applied_amount) AS quartile
    FROM applications
)
SELECT
    q.quartile,
    MIN(q.applied_amount) AS min_range,
    MAX(q.applied_amount) AS max_range,
    COUNT(*) AS accounts,
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
    ) AS default_rate
FROM quartiles q
JOIN loan_performance p
    ON q.application_id = p.application_id
GROUP BY q.quartile
ORDER BY q.quartile;
```

### Result

#### Default Rate by Loan Amount Quartile

| Quartile | Loan Amount Range ($) | Accounts | Defaults | Default Rate (%) |
|----------|----------------------|---------:|---------:|-----------------:|
| Q1 | 5,200 – 11,800 | 50 | 23 | 46.00 |
| Q2 | 12,100 – 15,600 | 50 | 20 | 40.00 |
| Q3 | 15,700 – 21,500 | 50 | 22 | 44.00 |
| Q4 | 21,900 – 34,000 | 50 | 18 | 36.00 |




### Q15: Severe Fraud Breakdown – Structural Impact of "Fake Employment" Flags

### Business Purpose
Measures the direct financial impact of fraud prevention controls by quantifying how much potential exposure was prevented through employment verification checks. This analysis demonstrates the value generated by the verification layer in protecting portfolio capital from fraudulent applications.

### SQL Query

```sql
SELECT
    v.risk_flag_reason,
    COUNT(*) AS applications_blocked,
    SUM(a.applied_amount) AS fraud_capital_intercepted
FROM verification_log v
JOIN applications a
    ON v.application_id = a.application_id
WHERE v.risk_flag_reason = 'Fake employment'
GROUP BY v.risk_flag_reason;
```

### Result

#### Fraud Prevention Impact Analysis

| Risk Flag Reason | Applications Blocked | Fraud Capital Intercepted |
|------------------|--------------------:|--------------------------:|
| Fake Employment | 8 | $156,400.00 |




## ⚡ Section 3: Operational Efficiency & Agent Performance

### Q16: Human Agent Operational Speed Leaderboard

### Business Purpose
Benchmarks verification agents based on processing turnaround time (TAT) to identify top-performing operational resources. This analysis supports workforce optimization, productivity monitoring, and SLA management initiatives.

### SQL Query

```sql
SELECT
    assigned_agent,
    COUNT(*) AS total_cases_processed,
    ROUND(AVG(turnaround_time_hours), 1) AS average_agent_tat_hours
FROM verification_log
GROUP BY assigned_agent
ORDER BY average_agent_tat_hours ASC
LIMIT 5;
```

### Result

#### Top 5 Fastest Verification Agents

| Assigned Agent | Total Cases Processed | Average Agent TAT (Hours) |
|----------------|---------------------:|--------------------------:|
| imran masuri | 1 | 10.0 |
| Shuchi Kaura | 1 | 10.0 |
| Prafull Rathod | 1 | 11.0 |
| Tejashwini G | 1 | 11.0 |
| HARSH SALVE | 1 | 11.0 |

### Q17: Verification Cost Analysis – TAT Drag by Verification Outcomes

### Business Purpose
Measures operational effort across different verification outcomes by analyzing average turnaround time (TAT). This helps identify whether certain decision types create processing bottlenecks and increase operational costs.

### SQL Query

```sql
SELECT
    verification_status,
    ROUND(AVG(turnaround_time_hours), 2) AS average_processing_hours
FROM verification_log
GROUP BY verification_status;
```

### Result

#### Verification Processing Time by Outcome

| Verification Status | Average Processing Hours |
|---------------------|-------------------------:|
| Approved | 35.81 |
| Flagged | 35.01 |




### Q18: Operational Drag Matrix (Risk Trigger vs. TAT Hours)

### Business Purpose
Identifies which verification risk categories consume the most operational resources and create the greatest processing delays. This analysis helps operations leaders prioritize workflow improvements and reduce verification bottlenecks.

### SQL Query

```sql
SELECT
    risk_flag_reason,
    COUNT(*) AS dynamic_load_volume,
    ROUND(AVG(turnaround_time_hours), 2) AS execution_drag_hours
FROM verification_log
GROUP BY risk_flag_reason
ORDER BY execution_drag_hours DESC;
```

### Result

#### Verification Queue Performance Analysis

| Risk Flag Reason | Dynamic Load Volume | Execution Drag (Hours) |
|------------------|-------------------:|-----------------------:|
| Verification Done | 117 | 35.81 |
| Borderline Verification | 41 | 35.12 |
| Needs Clarification | 28 | 34.64 |
| Fake Employment | 8 | 34.38 |
| Address Mismatch | 6 | 24.17 |




### Q19: Underwriting Velocity Volatility Across Calendar Months

### Business Purpose
Evaluates application origination volume and average loan ticket size across different calendar months. This analysis helps operations teams anticipate workload fluctuations, optimize staffing levels, and maintain consistent service delivery during periods of changing demand.

### SQL Query

```sql
SELECT
    EXTRACT(MONTH FROM application_date) AS processing_month,
    COUNT(*) AS monthly_originations_volume,
    ROUND(AVG(applied_amount), 2) AS monthly_avg_ticket_size
FROM applications
GROUP BY 1
ORDER BY 1;
```

### Result

#### Monthly Origination Volume Analysis

| Processing Month | Monthly Originations Volume | Monthly Avg Ticket Size ($) |
|-----------------:|---------------------------:|----------------------------:|
| 2 | 14 | 16,738.56 |
| 3 | 36 | 15,159.25 |
| 4 | 50 | 17,742.00 |
| 5 | 100 | 16,942.36 |

### Key Insights

- **May (Month 5)** recorded the highest origination activity with **100 applications**, representing the portfolio's peak operational workload.
- **February (Month 2)** generated the lowest application volume with **14 originations**.
- Average loan sizes remained relatively stable across all months, ranging from approximately **$15K to $18K**.
- While application volume fluctuated significantly, borrower demand characteristics remained consistent.

### Business Interpretation

The portfolio exhibits substantial variation in application volume across months, suggesting the presence of seasonal demand patterns or marketing-driven origination spikes. However, the stability of average ticket sizes indicates that borrower profiles and lending behavior remained relatively consistent throughout the observed period.

The sharp increase in May originations would likely require additional underwriting and verification capacity to maintain service-level agreements and prevent operational bottlenecks.

### Operational Recommendations

- Increase staffing capacity during historically high-volume months.
- Monitor monthly origination trends to improve workforce planning.
- Establish surge-capacity procedures for periods of rapid application growth.
- Track monthly approval and turnaround-time metrics alongside volume trends.
- Analyze marketing campaigns and acquisition channels contributing to volume spikes.

### Executive Summary

Origination activity demonstrates meaningful month-to-month volatility, with application volume increasing from **14 applications in February** to **100 applications in May**. Despite these fluctuations, average loan sizes remained stable, indicating that operational scaling requirements are primarily driven by volume growth rather than changes in borrower exposure levels.

### Q20: Efficiency Scorecard – Top 5 Highest Operational Backlog Agents

### Business Purpose
Identifies verification agents associated with the largest processing delays. This analysis helps operations management detect capacity constraints, workload imbalances, and potential SLA breach risks within the verification pipeline.

### SQL Query

```sql
SELECT
    assigned_agent,
    COUNT(*) AS load_volume,
    MAX(turnaround_time_hours) AS peak_processing_delay
FROM verification_log
GROUP BY assigned_agent
ORDER BY peak_processing_delay DESC, load_volume DESC
LIMIT 5;
```

### Result

#### Top 5 Agents with Highest Processing Delays

| Assigned Agent | Load Volume | Peak Processing Delay (Hours) |
|---------------|------------:|------------------------------:|
| RojaE RojaE | 1 | 60 |
| Raju Doosa | 1 | 60 |
| Priyanka luthra | 1 | 60 |
| SOHEL MANSURI | 1 | 60 |
| Monu Kumar | 1 | 59 |



### Q21: Operational Efficiency – Fast-Track Approvals (< 24 Hours)

### Business Purpose
Measures the percentage of verification cases completed within 24 hours. This KPI serves as an indicator of operational efficiency, process automation effectiveness, and the organization's ability to deliver a frictionless customer experience.

### SQL Query

```sql
SELECT
    COUNT(*) AS quick_turnaround_cases,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM verification_log),
        2
    ) AS fast_track_efficiency_pct
FROM verification_log
WHERE turnaround_time_hours < 24;
```

### Result

#### Fast-Track Processing Performance

| Quick Turnaround Cases | Fast-Track Efficiency (%) |
|----------------------:|--------------------------:|
| 49 | 24.50 |



### Q22: Operational Slack Tracking (Cases Exceeding 48-Hour SLA Threshold)

### Business Purpose
Measures the volume and rate of verification cases breaching the organization's Service Level Agreement (SLA). This metric helps operations teams quantify backlog risk, identify capacity constraints, and monitor customer experience degradation caused by delayed processing.

### SQL Query

```sql
SELECT
    COUNT(*) AS sla_breach_incidents,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM verification_log),
        2
    ) AS systemic_breach_rate
FROM verification_log
WHERE turnaround_time_hours > 48;
```

### Result

#### SLA Breach Analysis

| SLA Breach Incidents | Systemic Breach Rate (%) |
|---------------------:|-------------------------:|
| 69 | 34.50 |


### Q23: Critical Bottleneck Concentration – Long-TAT Cases in "Needs Clarification"

### Business Purpose
Identifies the most operationally expensive clarification cases by isolating applications that required extended review times. This analysis helps uncover workflow bottlenecks and supports automation initiatives aimed at reducing manual intervention.

### SQL Query

```sql
SELECT
    COUNT(*) AS stalled_clarification_cases,
    ROUND(AVG(turnaround_time_hours), 1) AS stalled_avg_tat
FROM verification_log
WHERE risk_flag_reason = 'needs clarification'
  AND turnaround_time_hours >= 40;
```

### Result

#### High-Friction Clarification Queue Analysis

| Stalled Clarification Cases | Average Turnaround Time (Hours) |
|----------------------------:|--------------------------------:|
| 10 | 50.3 |



## 💰 Section 4: Detailed Financial Recovery & Cash Analysis

### Q24: Total Retained Principal Cash Realized Across Active Portfolio

### Business Purpose
Measures the total amount of cash successfully recovered from borrowers across the entire loan portfolio. This KPI provides a high-level view of liquidity generation, repayment performance, and capital recovery effectiveness.

### SQL Query

```sql
SELECT
    SUM(amount_paid) AS liquid_collected_cash_pool
FROM loan_performance;
```

### Result

#### Portfolio Cash Recovery Summary

| Liquid Collected Cash Pool |
|---------------------------:|
| $2,117,072.94 |



### Q25: Net Collections Deficit Within Defaulted Asset Tranche

### Business Purpose
Measures the actual financial loss generated by defaulted loans after accounting for all recovered cash. This analysis helps quantify portfolio impairment, estimate credit losses, and evaluate recovery effectiveness.

### SQL Query

```sql
SELECT
    SUM(a.applied_amount) AS gross_defaulted_principal,
    SUM(p.amount_paid) AS recovery_salvage_pool,
    SUM(a.applied_amount) - SUM(p.amount_paid) AS net_writeoff_loss
FROM applications a
JOIN loan_performance p
    ON a.application_id = p.application_id
WHERE p.loan_status = 'defaulted';
```

### Result

#### Defaulted Portfolio Loss Analysis

| Metric | Amount ($) |
|----------|-----------:|
| Gross Defaulted Principal | 1,346,257.06 |
| Recovery Salvage Pool | 107,650.00 |
| Net Write-Off Loss | 1,238,607.06 |



### Q26: Structural Cash Generation Capacity (Salaried vs. Self-Employed)

### Business Purpose
Evaluates the cash-generation contribution of different borrower segments by comparing total collections and average repayment performance. This analysis helps determine which customer profiles produce the most sustainable cash inflows and long-term portfolio value.

### SQL Query

```sql
SELECT
    a.employment_type,
    SUM(p.amount_paid) AS aggregate_cash_inflow,
    ROUND(AVG(p.amount_paid), 2) AS unit_cash_generation_average
FROM applications a
JOIN loan_performance p
    ON a.application_id = p.application_id
GROUP BY a.employment_type;
```

### Result

#### Cash Generation by Employment Segment

| Employment Type | Aggregate Cash Inflow ($) | Average Cash Generation per Account ($) |
|----------------|--------------------------:|-----------------------------------------:|
| Salaried | 1,284,523.59 | 11,267.75 |
| Self Employed | 832,549.35 | 9,680.81 |

### Q27: Arrears Density – Missed Payments Frequency Across Portfolio

### Business Purpose
Analyzes borrower delinquency depth by measuring the distribution of missed payments across the portfolio. This analysis helps collections teams prioritize recovery efforts, design intervention strategies, and understand how repayment performance deteriorates over time.

### SQL Query

```sql
SELECT
    missed_payments,
    COUNT(*) AS total_impacted_accounts,
    SUM(amount_paid) AS total_cash_collected_in_tier
FROM loan_performance
GROUP BY missed_payments
ORDER BY missed_payments ASC;
```

### Result

#### Portfolio Delinquency Distribution

| Missed Payments | Total Impacted Accounts | Total Cash Collected ($) |
|---------------:|------------------------:|-------------------------:|
| 0 | 109 | 1,970,222.94 |
| 1 | 6 | 22,000.00 |
| 2 | 17 | 15,150.00 |
| 6 | 8 | 25,000.00 |
| 7 | 11 | 20,500.00 |
| 8 | 13 | 17,950.00 |
| 9 | 17 | 18,150.00 |
| 10 | 9 | 11,000.00 |
| 11 | 6 | 4,700.00 |
| 12 | 7 | 4,900.00 |
| 13 | 5 | 2,200.00 |
| 14 | 5 | 3,300.00 |

### Q28: Top 5 Highest Capital Recovery Accounts

### Business Purpose
Identifies the largest individual cash recoveries within the portfolio. This analysis highlights successful repayment outcomes, supports recovery-performance tracking, and showcases the accounts contributing most significantly to portfolio liquidity.

### SQL Query

```sql
SELECT
    application_id,
    loan_id,
    amount_paid
FROM loan_performance
ORDER BY amount_paid DESC
LIMIT 5;
```

### Result

#### Top 5 Capital Recovery Accounts

| Rank | Application ID | Loan ID | Amount Paid ($) |
|------|---------------:|---------:|----------------:|
| 1 | 217 | 817 | 34,000.00 |
| 2 | 212 | 812 | 25,000.00 |
| 3 | 271 | 871 | 24,000.00 |
| 4 | 201 | 801 | 24,000.00 |
| 5 | 221 | 821 | 23,400.00 |

### Q29: Capital Efficiency Index (Repayment-to-Loan Ratio Window Analysis)

### Business Purpose
Uses SQL window functions to compare individual loan repayment performance against the portfolio-wide repayment benchmark. This analysis helps identify high-performing accounts, underperforming assets, and repayment efficiency trends across the lending portfolio.

### SQL Query

```sql
SELECT
    p.loan_id,
    a.customer_name,
    a.applied_amount,
    p.amount_paid,
    ROUND(
        p.amount_paid * 100.0 / a.applied_amount,
        1
    ) AS account_repayment_yield_pct,
    ROUND(
        AVG(
            p.amount_paid * 100.0 / a.applied_amount
        ) OVER(),
        2
    ) AS system_average_yield
FROM loan_performance p
JOIN applications a
    ON p.application_id = a.application_id
LIMIT 5;
```

### Result

#### Sample Account-Level Capital Efficiency Analysis

| Loan ID | Customer Name | Applied Amount ($) | Amount Paid ($) | Repayment Yield (%) | System Average Yield (%) |
|---------|---------------|-------------------:|----------------:|--------------------:|-------------------------:|
| 701 | Ali Husen Ansari | 7,081.00 | 7,081.00 | 100.0 | 62.19 |
| 702 | prasoon e | 12,349.50 | 12,349.50 | 100.0 | 62.19 |
| 703 | N Goutham | 18,230.00 | 18,230.00 | 100.0 | 62.19 |
| 704 | Rahul Maurya | 3,450.00 | 3,450.00 | 100.0 | 62.19 |
| 705 | Mohti Mohti | 9,058.00 | 9,058.00 | 100.0 | 62.19 |

### Q30: Principal Deadweight – Write-Off Capital in High Credit Brackets

### Business Purpose
Evaluates underwriting effectiveness by measuring financial losses generated by borrowers who appeared highly creditworthy at origination. This analysis identifies expensive underwriting failures where premium-credit applicants still progressed to default.

### SQL Query

```sql
SELECT
    COUNT(*) AS prime_default_accounts,
    SUM(a.applied_amount) AS prime_capital_lost
FROM applications a
JOIN loan_performance p
    ON a.application_id = p.application_id
WHERE a.credit_score >= 760
  AND p.loan_status = 'defaulted';
```

### Result

#### Premium Credit Segment Default Analysis

| Metric | Value |
|----------|-------:|
| Prime Default Accounts | 36 |
| Prime Capital Lost ($) | 584,900.00 |

## 🔍 Section 5: Data Quality & System Integrity Diagnostics

### Q31: Critical Ledger Reconciliation – Orphans & Broken Links

### Business Purpose
Validates data integrity between the application onboarding system and the loan servicing platform. The objective is to identify orphaned records that entered the application pipeline but failed to reach downstream loan management systems.

### SQL Query

```sql
SELECT
    COUNT(a.application_id) AS unmatched_pipeline_applications
FROM applications a
LEFT JOIN loan_performance p
    ON a.application_id = p.application_id
WHERE p.application_id IS NULL;
```

### Result

#### Data Reconciliation Audit

| Metric | Value |
|----------|------:|
| Unmatched Pipeline Applications | 0 |

### Q32: Risk Label Mismatch Check (Approved Rejections Integrity Audit)

### Business Purpose
Performs a compliance and governance audit to ensure that applications flagged during verification were not incorrectly allowed to progress into successfully completed loan outcomes. This control helps validate policy enforcement and prevents unauthorized risk exposure.

### SQL Query

```sql
SELECT
    COUNT(*) AS security_integrity_violations
FROM verification_log v
JOIN loan_performance p
    ON v.application_id = p.application_id
WHERE v.verification_status = 'flagged'
  AND p.loan_status = 'paid off';
```

### Result

#### Compliance Integrity Audit

| Metric | Value |
|----------|------:|
| Security Integrity Violations | 0 |


### Q33: Logical Outlier Audit – Positive Missed Payments on Fully Paid-Off Loans

### Business Purpose
Performs a data quality validation to identify accounting inconsistencies within closed loan records. The objective is to detect loans marked as fully paid while simultaneously showing outstanding missed-payment activity.

### SQL Query

```sql
SELECT
    COUNT(*) AS impossible_billing_anomalies
FROM loan_performance
WHERE loan_status = 'paid off'
  AND missed_payments > 0;
```

### Result

#### Accounting Consistency Audit

| Metric | Value |
|----------|------:|
| Impossible Billing Anomalies | 0 |


### Q34: Financial Discrepancy Check – Overpayment Tracking

### Business Purpose
Validates transaction integrity by identifying repayment records that exceed the original loan amount. This audit helps detect payment-processing errors, duplicate transactions, accounting misstatements, or system calculation glitches.

### SQL Query

```sql
SELECT
    COUNT(*) AS critical_overpayment_glitches
FROM loan_performance p
JOIN applications a
    ON p.application_id = a.application_id
WHERE p.amount_paid > a.applied_amount;
```

### Result

#### Transaction Integrity Audit

| Metric | Value |
|----------|------:|
| Critical Overpayment Glitches | 0 |


### Q35: Operational Audit – Duplicate Verification Logging Flaws

### Business Purpose
Audits the verification workflow to ensure that each application receives exactly one verification record. This control helps detect duplicate processing, accidental re-verification, workflow bugs, and operational inefficiencies that can inflate costs and distort reporting metrics.

### SQL Query

```sql
SELECT
    application_id,
    COUNT(*) AS instance_count
FROM verification_log
GROUP BY application_id
HAVING COUNT(*) > 1;
```

### Result

#### Duplicate Verification Audit

| Result |
|----------|
| No rows returned |

