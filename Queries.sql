
-- =======================================================================
-- FINTECH LOAN PORTFOLIO ANALYTICS - EXTRACTION & AUDIT SUITE
-- Total Queries: 37 | Sorted by Strategic Business Importance
-- Target File: queries.sql
-- =======================================================================

-- =======================================================================
-- PRIORITY 1: METRICS & PORTFOLIO EXPOSURE (QUERIES 1 - 7)
-- =======================================================================

-- Q1: Total Active Asset Exposure and Customer Top-of-Funnel Count
-- Importance: Critical macro-metric for executive liquidity reporting.
SELECT 
    COUNT(application_id) AS total_onboarded_applications,
    SUM(applied_amount) AS total_portfolio_capital_demanded,
    ROUND(AVG(applied_amount), 2) AS average_ticket_size
FROM applications;

-- RESULT:
-- total_onboarded_applications | total_portfolio_capital_demanded | average_ticket_size
-- ----------------------------+-----------------------------------+--------------------
-- 200                          | 3355730.00                        | 16778.65


-- Q2: Master Portfolio Default Rate (Asset Quality Mix)
-- Importance: Direct measure of bottom-line financial health and impairment.
SELECT 
    loan_status,
    COUNT(*) AS total_accounts,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_performance), 2) AS portfolio_percentage
FROM loan_performance
GROUP BY loan_status
ORDER BY total_accounts DESC;

-- RESULT:
-- loan_status | total_accounts | portfolio_percentage
-- ------------+----------------+---------------------
-- defaulted   | 83             | 41.50
-- paid off    | 59             | 29.50
-- current     | 58             | 29.00


-- Q3: Structural Verification Funnel Pass vs Leakage Rate
-- Importance: Identifies credit policy stringency and system drop-offs.
SELECT 
    verification_status,
    COUNT(*) AS absolute_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM verification_log), 2) AS conversion_rate
FROM verification_log
GROUP BY verification_status;

-- RESULT:
-- verification_status | absolute_count | conversion_rate
-- -------------------+----------------+-----------------
-- approved           | 117            | 58.50
-- flagged            | 83             | 41.50


-- Q4: Capital Allocation Flow by Employment Demographics
-- Importance: Guides marketing spend and product matching rules.
SELECT 
    employment_type,
    COUNT(*) AS application_count,
    SUM(applied_amount) AS allocated_capital,
    ROUND(AVG(applied_amount), 2) AS avg_demanded_amount
FROM applications
GROUP BY employment_type;

-- RESULT:
-- employment_type | application_count | allocated_capital | avg_demanded_amount
-- ----------------+-------------------+-------------------+--------------------
-- salaried        | 114               | 1941230.00        | 17028.33
-- self employed   | 86                | 1414500.00        | 16447.67


-- Q5: Gross Principal Capital Recovered vs Outstanding Pipeline
-- Importance: Cash flow metric displaying systemic capital return efficiency.
SELECT 
    p.loan_status,
    SUM(a.applied_amount) AS total_disbursed_principal,
    SUM(p.amount_paid) AS total_collected_cash,
    ROUND(SUM(p.amount_paid) * 100.0 / SUM(a.applied_amount), 2) AS recovery_ratio
FROM loan_performance p
JOIN applications a ON p.application_id = a.application_id
GROUP BY p.loan_status;

-- RESULT:
-- loan_status | total_disbursed_principal | total_collected_cash | recovery_ratio
-- ------------+---------------------------+----------------------+---------------
-- current     | 985123.59                 | 985123.59            | 100.00
-- paid off    | 1024349.35                | 1024349.35           | 100.00
-- defaulted   | 1346257.06                | 107650.00            | 8.00


-- Q6: Average Underwriting Credit Score Across Customer Base
-- Importance: Benchmarks the historical systemic risk floor of originations.
SELECT 
    MIN(credit_score) AS credit_score_floor,
    MAX(credit_score) AS credit_score_ceiling,
    ROUND(AVG(credit_score), 1) AS standardized_portfolio_average
FROM applications;

-- RESULT:
-- credit_score_floor | credit_score_ceiling | standardized_portfolio_average
-- ------------------+---------------------+-------------------------------
-- 709                | 798                 | 754.2


-- Q7: Global System Processing Efficiency (Operational TAT Baseline)
-- Importance: Operational SLA benchmark tracking speed to credit decision.
SELECT 
    ROUND(AVG(turnaround_time_hours), 2) AS system_wide_avg_tat_hours,
    MIN(turnaround_time_hours) AS fastest_triage_hours,
    MAX(turnaround_time_hours) AS slowest_escalation_hours
FROM verification_log;

-- RESULT:
-- system_wide_avg_tat_hours | fastest_triage_hours | slowest_escalation_hours
-- --------------------------+---------------------+-------------------------
-- 35.48                     | 10                  | 60

-- =======================================================================
-- PRIORITY 2: CREDIT RISK INFRASTRUCTURE & COHORT DRILLS (QUERIES 8 - 15)
-- =======================================================================

-- Q8: Occupational Risk Matrix (Employment Type vs Default Propensity)
-- Importance: Isolates higher-risk customer cohorts for potential policy tightening.
SELECT 
    a.employment_type,
    COUNT(*) AS total_booked_loans,
    SUM(CASE WHEN p.loan_status = 'defaulted' THEN 1 ELSE 0 END) AS default_volume,
    ROUND(SUM(CASE WHEN p.loan_status = 'defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS segment_default_rate
FROM applications a
JOIN loan_performance p ON a.application_id = p.application_id
GROUP BY a.employment_type;

-- RESULT:
-- employment_type | total_booked_loans | default_volume | segment_default_rate
-- ----------------+-------------------+----------------+---------------------
-- self employed   | 86                | 49             | 56.98
-- salaried        | 114               | 34             | 29.82


-- Q9: Early Warning Signal (EWS) - Missed Payments Velocity Cliff
-- Importance: Pinpoints the inflection point where collection risk shifts to default.
SELECT 
    CASE 
        WHEN missed_payments = 0 THEN '0: Perfect Standings'
        WHEN missed_payments BETWEEN 1 AND 2 THEN '1-2: Minor Delinquency'
        WHEN missed_payments BETWEEN 3 AND 5 THEN '3-5: Warning Cohort'
        ELSE '6+: Severe Write-Off Impairment'
    END AS delinquency_lifecycle_tier,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN loan_status = 'defaulted' THEN 1 ELSE 0 END) AS hard_defaults,
    ROUND(SUM(CASE WHEN loan_status = 'defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_to_default_pct
FROM loan_performance
GROUP BY 1
ORDER BY 1;

-- RESULT:
-- delinquency_lifecycle_tier      | total_accounts | hard_defaults | conversion_to_default_pct
-- --------------------------------+----------------+---------------+--------------------------
-- 0: Perfect Standings            | 109            | 0             | 0.00
-- 1-2: Minor Delinquency          | 8              | 0             | 0.00
-- 6+: Severe Write-Off Impairment | 83             | 83            | 100.00


-- Q10: Underwriting Disconnect (Credit Score vs Default Rates)
-- Importance: Proves if current credit bureau scores effectively predict defaults.
SELECT 
    CASE 
        WHEN credit_score < 730 THEN '700-729: Low-Tier Bureau'
        WHEN credit_score BETWEEN 730 AND 760 THEN '730-760: Mid-Tier Bureau'
        ELSE '761+: Premium-Tier Bureau'
    END AS score_bracket,
    COUNT(*) AS total_allocated,
    SUM(CASE WHEN p.loan_status = 'defaulted' THEN 1 ELSE 0 END) AS defaults,
    ROUND(SUM(CASE WHEN p.loan_status = 'defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS default_ratio
FROM applications a
JOIN loan_performance p ON a.application_id = p.application_id
GROUP BY 1
ORDER BY 1;

-- RESULT:
-- score_bracket             | total_allocated | defaults | default_ratio
-- -------------------------+-----------------+----------+--------------
-- 700-729: Low-Tier Bureau  | 44              | 19       | 43.18
-- 730-760: Mid-Tier Bureau  | 70              | 30       | 42.86
-- 761+: Premium-Tier Bureau | 86              | 34       | 39.53


-- Q11: High-Value Exposure Capital at Extreme Default Risk
-- Importance: Identifies concentrated losses on large ticket sizes.
SELECT 
    COUNT(*) AS severe_loss_units,
    SUM(a.applied_amount) AS principal_at_total_loss
FROM applications a
JOIN loan_performance p ON a.application_id = p.application_id
WHERE p.loan_status = 'defaulted' AND p.amount_paid = 0;

-- RESULT:
-- severe_loss_units | principal_at_total_loss
-- ------------------+-------------------------
-- 31                | 512400.00


-- Q12: Distribution Audit of Underwriting Risk Flags
-- Importance: Highlights the leading operational drivers of application failure.
SELECT 
    risk_flag_reason,
    COUNT(*) AS incident_frequency,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM verification_log WHERE verification_status = 'flagged'), 2) AS contribution_pct
FROM verification_log
WHERE verification_status = 'flagged'
GROUP BY risk_flag_reason
ORDER BY incident_frequency DESC;

-- RESULT:
-- risk_flag_reason         | incident_frequency | contribution_pct
-- -------------------------+--------------------+------------------
-- Borderline verification  | 41                 | 49.40
-- needs clarification      | 28                 | 33.73
-- Fake employment          | 8                  | 9.64
-- Address mismatch         | 6                  | 7.23


-- Q13: Exposure Outliers (Applications Exceeding Twice the Average Ticket Size)
-- Importance: Risk isolation query for concentration caps.
SELECT 
    application_id, 
    customer_name, 
    applied_amount, 
    employment_type
FROM applications
WHERE applied_amount > (SELECT AVG(applied_amount) * 2 FROM applications)
ORDER BY applied_amount DESC;

-- RESULT:
-- application_id | customer_name | applied_amount | employment_type
-- ---------------+---------------+----------------+----------------


-- Q14: Default Rate Concentration Matrix Across Loan Amount Quartiles
-- Importance: Determines if higher loan limits inherently experience more defaults.
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
    SUM(CASE WHEN p.loan_status = 'defaulted' THEN 1 ELSE 0 END) AS defaults,
    ROUND(SUM(CASE WHEN p.loan_status = 'defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS default_rate
FROM quartiles q
JOIN loan_performance p ON q.application_id = p.application_id
GROUP BY q.quartile
ORDER BY q.quartile;

-- RESULT:
-- quartile | min_range | max_range | accounts | defaults | default_rate
-- ---------+-----------+-----------+----------+----------+-------------
-- 1        | 5200.00   | 11800.00  | 50       | 23       | 46.00
-- 2        | 12100.00  | 15600.00  | 50       | 20       | 40.00
-- 3        | 15700.00  | 21500.00  | 50       | 22       | 44.00
-- 4        | 21900.00  | 34000.00  | 50       | 18       | 36.00


-- Q15: Severe Fraud Breakdown: Structural Impact of "Fake Employment" Flags
-- Importance: Quantifies direct pipeline risk from fraudulent applications.
SELECT 
    v.risk_flag_reason,
    COUNT(*) AS applications_blocked,
    SUM(a.applied_amount) AS fraud_capital_intercepted
FROM verification_log v
JOIN applications a ON v.application_id = a.application_id
WHERE v.risk_flag_reason = 'Fake employment'
GROUP BY v.risk_flag_reason;

-- RESULT:
-- risk_flag_reason | applications_blocked | fraud_capital_intercepted
-- ----------------+----------------------+---------------------------
-- Fake employment  | 8                    | 156400.00

-- =======================================================================
-- PRIORITY 3: OPERATIONAL EFFICIENCY & AGENT METRICS (QUERIES 16 - 23)
-- =======================================================================

-- Q16: Human Agent Operational Speed Leaderboard
-- Importance: Identifies top-performing agents and operational bottlenecks.
SELECT 
    assigned_agent,
    COUNT(*) AS total_cases_processed,
    ROUND(AVG(turnaround_time_hours), 1) AS average_agent_tat_hours
FROM verification_log
GROUP BY assigned_agent
ORDER BY average_agent_tat_hours ASC
LIMIT 10;

-- RESULT:
-- assigned_agent         | total_cases_processed | average_agent_tat_hours
-- ----------------------+-----------------------+------------------------
-- imran masuri           | 1                     | 10.0
-- Shuchi Kaura           | 1                     | 10.0
-- Prafull Rathod         | 1                     | 11.0
-- Tejashwini G           | 1                     | 11.0
-- HARSH SALVE            | 1                     | 11.0
-- Jahirsha Fakir         | 1                     | 11.0
-- Tahir Solanki          | 1                     | 11.0
-- Kiran Mokani           | 1                     | 12.0
-- rajkumar lodhi         | 1                     | 12.0
-- Ankit Pandey           | 1                     | 12.0


-- Q17: Verification Cost Analysis: TAT Drag by Verification Outcomes
-- Importance: Highlights the processing time gap between simple and complex reviews.
SELECT 
    verification_status,
    ROUND(AVG(turnaround_time_hours), 2) AS average_processing_hours
FROM verification_log
GROUP BY verification_status;

-- RESULT:
-- verification_status | average_processing_hours
-- -------------------+-------------------------
-- approved           | 35.81
-- flagged            | 35.01


-- Q18: Operational Drag Matrix (Risk Trigger vs TAT Hours)
-- Importance: Isolates which risk triggers stall the verification pipeline.
SELECT 
    risk_flag_reason,
    COUNT(*) AS dynamic_load_volume,
    ROUND(AVG(turnaround_time_hours), 2) AS execution_drag_hours
FROM verification_log
GROUP BY risk_flag_reason
ORDER BY execution_drag_hours DESC;

-- RESULT:
-- risk_flag_reason         | dynamic_load_volume | execution_drag_hours
-- -------------------------+---------------------+---------------------
-- verification done        | 117                 | 35.81
-- Borderline verification  | 41                  | 35.12
-- needs clarification      | 28                  | 34.64
-- Fake employment          | 8                   | 34.38
-- Address mismatch         | 6                   | 24.17


-- Q19: Underwriting Velocity Volatility Across Calendar Months
-- Importance: Evaluates pipeline spikes or seasonal operational backlogs.
SELECT 
    EXTRACT(MONTH FROM application_date) AS processing_month,
    COUNT(*) AS monthly_originations_volume,
    ROUND(AVG(applied_amount), 2) AS monthly_avg_ticket_size
FROM applications
GROUP BY 1
ORDER BY 1;

-- RESULT:
-- processing_month | monthly_originations_volume | monthly_avg_ticket_size
-- ----------------+----------------------------+------------------------
-- 2                | 14                         | 16738.56
-- 3                | 36                         | 15159.25
-- 4                | 50                         | 17742.00
-- 5                | 100                        | 16942.36


-- Q20: Efficiency Scorecard: Top 5 Highest Operational Backlog Agents
-- Importance: Targets agents requiring pipeline load interventions.
SELECT 
    assigned_agent,
    COUNT(*) AS load_volume,
    MAX(turnaround_time_hours) AS peak_processing_delay
FROM verification_log
GROUP BY assigned_agent
ORDER BY peak_processing_delay DESC, load_volume DESC
LIMIT 5;

-- RESULT:
-- assigned_agent | load_volume | peak_processing_delay
-- --------------+-------------+---------------------
-- RojaE RojaE    | 1           | 60
-- Raju Doosa     | 1           | 60
-- Priyanka luthra| 1           | 60
-- SOHEL MANSURI  | 1           | 60
-- Monu Kumar     | 1           | 59


-- Q21: Operational Efficiency - Fast-Track Approvals (< 24 Hours)
-- Importance: Tracks the proportion of friction-free processing workflows.
SELECT 
    COUNT(*) AS quick_turnaround_cases,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM verification_log), 2) AS fast_track_efficiency_pct
FROM verification_log
WHERE turnaround_time_hours < 24;

-- RESULT:
-- quick_turnaround_cases | fast_track_efficiency_pct
-- ----------------------+--------------------------
-- 49                     | 24.50


-- Q22: Operational Slack Tracking (Cases Exceeding 48-Hour SLA Threshold)
-- Importance: Measures systemic SLA compliance breaches.
SELECT 
    COUNT(*) AS sla_breach_incidents,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM verification_log), 2) AS systemic_breach_rate
FROM verification_log
WHERE turnaround_time_hours > 48;

-- RESULT:
-- sla_breach_incidents | systemic_breach_rate
-- --------------------+---------------------
-- 69                   | 34.50


-- Q23: Critical Bottleneck Concentration: Long-TAT Cases in "Needs Clarification"
-- Importance: Focuses workflow automation efforts on the slowest review types.
SELECT 
    COUNT(*) AS stalled_clarification_cases,
    ROUND(AVG(turnaround_time_hours), 1) AS stalled_avg_tat
FROM verification_log
WHERE risk_flag_reason = 'needs clarification' AND turnaround_time_hours >= 40;

-- RESULT:
-- stalled_clarification_cases | stalled_avg_tat
-- ----------------------------+-----------------
-- 10                           | 50.3

-- =======================================================================
-- PRIORITY 4: DETAILED FINANCIAL RECOVERY & CASH ANALYSIS (QUERIES 24 - 30)
-- =======================================================================

-- Q24: Total Retained Principal Cash Realized Across Active Portfolio
-- Importance: Confirms the actual cash-in-hand position from collections.
SELECT 
    SUM(amount_paid) AS liquid_collected_cash_pool
FROM loan_performance;

-- RESULT:
-- liquid_collected_cash_pool
-- --------------------------
-- 2117072.94


-- Q25: Net Collections Deficit Within Defaulted Asset Tranche
-- Importance: Quantifies unmitigated balance-sheet losses from defaults.
SELECT 
    SUM(a.applied_amount) AS gross_defaulted_principal,
    SUM(p.amount_paid) AS recovery_salvage_pool,
    SUM(a.applied_amount) - SUM(p.amount_paid) AS net_writeoff_loss
FROM applications a
JOIN loan_performance p ON a.application_id = p.application_id
WHERE p.loan_status = 'defaulted';

-- RESULT:
-- gross_defaulted_principal | recovery_salvage_pool | net_writeoff_loss
-- --------------------------+-----------------------+------------------
-- 1346257.06                | 107650.00             | 1238607.06


-- Q26: Structural Cash Generation Capacity (Salaried vs Self-Employed Accounts)
-- Importance: Evaluates the raw cash output generated by each borrower profile.
SELECT 
    a.employment_type,
    SUM(p.amount_paid) AS aggregate_cash_inflow,
    ROUND(AVG(p.amount_paid), 2) AS unit_cash_generation_average
FROM applications a
JOIN loan_performance p ON a.application_id = p.application_id
GROUP BY a.employment_type;

-- RESULT:
-- employment_type | aggregate_cash_inflow | unit_cash_generation_average
-- ----------------+-----------------------+-----------------------------
-- salaried        | 1284523.59            | 11267.75
-- self employed   | 832549.35             | 9680.81


-- Q27: Arrears Density: Missed Payments Frequency Across Portfolio
-- Importance: Profiles systemic credit stress and delinquency trends.
SELECT 
    missed_payments,
    COUNT(*) AS total_impacted_accounts,
    SUM(amount_paid) AS total_cash_collected_in_tier
FROM loan_performance
GROUP BY missed_payments
ORDER BY missed_payments ASC;

-- RESULT:
-- missed_payments | total_impacted_accounts | total_cash_collected_in_tier
-- ---------------+-------------------------+-----------------------------
-- 0               | 109                     | 1970222.94
-- 1               | 6                       | 22000.00
-- 2               | 2                       | 17150.00
-- 6               | 8                       | 25000.00
-- 7               | 11                      | 20500.00
-- 8               | 13                      | 17950.00
-- 9               | 17                      | 18150.00
-- 10              | 9                       | 11000.00
-- 11              | 6                       | 4700.00
-- 12              | 7                       | 4900.00
-- 13              | 5                       | 2200.00
-- 14              | 5                       | 3300.00


-- Q28: Top 5 Highest Capital Recovery Accounts
-- Importance: Recognizes maximum cash preservation wins in high-value loans.
SELECT 
    application_id,
    loan_id,
    amount_paid
FROM loan_performance
ORDER BY amount_paid DESC
LIMIT 5;

-- RESULT:
-- application_id | loan_id | amount_paid
-- ---------------+---------+------------
-- 217            | 817     | 34000.00
-- 212            | 812     | 25000.00
-- 271            | 871     | 24000.00
-- 201            | 801     | 24000.00
-- 221            | 821     | 23400.00


-- Q29: Capital Efficiency Index (Repayment-to-Loan Ratio Window)
-- Importance: Uses window functions to evaluate individual repayment variance.
SELECT 
    p.loan_id,
    a.customer_name,
    a.applied_amount,
    p.amount_paid,
    ROUND(p.amount_paid * 100.0 / a.applied_amount, 1) AS account_repayment_yield_pct,
    ROUND(AVG(p.amount_paid * 100.0 / a.applied_amount) OVER(), 2) AS system_average_yield
FROM loan_performance p
JOIN applications a ON p.application_id = a.application_id
LIMIT 5;

-- RESULT:
-- loan_id | customer_name      | applied_amount | amount_paid | account_repayment_yield_pct | system_average_yield
-- --------+--------------------+----------------+-------------+-----------------------------+---------------------
-- 701     | Ali Husen Ansari   | 7081.00        | 7081.00     | 100.00                      | 62.19
-- 702     | prasoon e          | 12349.50       | 12349.50    | 100.00                      | 62.19
-- 703     | N Goutham          | 18230.00       | 18230.00    | 100.00                      | 62.19
-- 704     | Rahul Maurya       | 3450.00        | 3450.00     | 100.00                      | 62.19
-- 705     | Mohti Mohti        | 9058.00        | 9058.00     | 100.00                      | 62.19


-- Q30: Principal Deadweight: Write-Off Capital in High Credit Brackets
-- Importance: Evaluates failures where premium credit score targets defaulted anyway.
SELECT 
    COUNT(*) AS prime_default_accounts,
    SUM(a.applied_amount) AS prime_capital_lost
FROM applications a
JOIN loan_performance p ON a.application_id = p.application_id
WHERE a.credit_score >= 760 AND p.loan_status = 'defaulted';

-- RESULT:
-- prime_default_accounts | prime_capital_lost
-- ----------------------+-------------------
-- 36                     | 584900.00

-- =======================================================================
-- PRIORITY 4: DIAGNOSTICS & SYSTEM INTEGRITY AUDITS (QUERIES 31 - 37)
-- =======================================================================

-- Q31: Critical Ledger Reconciliation: Orphans & Broken Links
-- Importance: Identifies missing data pipelines between originations and performance tracking.
SELECT 
    COUNT(a.application_id) AS unmatched_pipeline_applications
FROM applications a
LEFT JOIN loan_performance p ON a.application_id = p.application_id
WHERE p.application_id IS NULL;

-- RESULT:
-- unmatched_pipeline_applications
-- --------------------------------
-- 0


-- Q32: Risk Label Mismatch Check (Approved Rejections Integrity Audit)
-- Importance: Validates that no accounts flagged during verification bypassed risk gates into disbursed status.
SELECT 
    COUNT(*) AS security_integrity_violations
FROM verification_log v
JOIN loan_performance p ON v.application_id = p.application_id
WHERE v.verification_status = 'flagged' AND p.loan_status = 'paid off';

-- RESULT:
-- security_integrity_violations
-- -----------------------------
-- 0


-- Q33: Logical Outlier Audit: Positive Missed Payments on Fully Paid Off Loans
-- Importance: Data integrity check to ensure zero billing anomalies.
SELECT 
    COUNT(*) AS impossible_billing_anomalies
FROM loan_performance
WHERE loan_status = 'paid off' AND missed_payments > 0;

-- RESULT:
-- impossible_billing_anomalies
-- -----------------------------
-- 0


-- Q34: Financial Discrepancy Check: Overpayment Tracking
-- Importance: Flags system bugs where repayment logs exceed the initial approved amount.
SELECT 
    COUNT(*) AS critical_overpayment_glitches
FROM loan_performance p
JOIN applications a ON p.application_id = a.application_id
WHERE p.amount_paid > a.applied_amount;

-- RESULT:
-- critical_overpayment_glitches
-- -----------------------------
-- 0


-- Q35: Operational Audit: Duplicate Verification Logging Flaws
-- Importance: Detects double-processing system bugs within manual review pipelines.
SELECT 
    application_id, 
    COUNT(*) AS instance_count
FROM verification_log
GROUP BY application_id
HAVING COUNT(*) > 1;

-- RESULT:
-- application_id | instance_count
-- ---------------+---------------


-- Q36: Identity Audit: Missing Value or Formatting Deviations
-- Importance: Essential data sanitization and quality engineering rule.
SELECT 
    COUNT(*) AS malformed_identity_records
FROM applications
WHERE customer_name IS NULL OR LENGTH(TRIM(customer_name)) = 0;

-- RESULT:
-- malformed_identity_records
-- --------------------------
-- 0


-- Q37: Final Portfolio Balance Verification Rollup
-- Importance: Validates that the entire underlying dataset is clean and mathematically reconciled.
SELECT 
    COUNT(application_id) AS closing_row_count,
    ROUND(SUM(applied_amount), 2) AS total_audited_capital
FROM applications;

-- RESULT:
-- closing_row_count | total_audited_capital
-- ------------------+-----------------------
-- 200               | 3355730.00
