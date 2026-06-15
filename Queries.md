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



### **RESULT**

| Total Onboarded Applications | Total Portfolio Capital Demanded | Average Ticket Size |
| 200 | $3,355,730.00 | $16,778.65 |



### Q2 Master Portfolio Default Rate (Asset Quality Mix)
Business Purpose: Directly measures bottom-line portfolio impairment and historical credit risk.
