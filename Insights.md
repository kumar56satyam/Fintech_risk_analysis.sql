# Business Insights and Findings

## Executive Summary

This project analyzes **200 consumer loan applications**, verification records, and loan repayment performance.

The main objectives of the analysis were to:

- Understand the applicant and loan portfolio.
- Evaluate the verification process.
- Identify major credit and fraud risk factors.
- Analyze loan repayment and default patterns.
- Identify operational issues affecting verification and collections.

The analysis shows that traditional credit scores have limited variation in this portfolio. Verification results and repayment behavior provide stronger indicators of risk.

---

## 1. Application Insights

- **Total Applications:** 200
- **Average Loan Amount:** ₹16,778.65
- **Salaried Applicants:** 114 (57%)
- **Self-Employed Applicants:** 86 (43%)

Salaried applicants represent the larger share of applications, accounting for **57%** of the portfolio. Self-employed applicants account for the remaining **43%**.

Loan demand is mainly concentrated around the middle range of loan amounts, indicating the need for consistent risk assessment across both employment segments.

---

## 2. Verification Insights

### Verification Results

- **Approved Applications:** 117 (58.5%)
- **Rejected / Risk-Flagged Applications:** 83 (41.5%)
- **Average Verification TAT:** 35.5 hours

A significant **41.5% of applications were either rejected or flagged during verification**, making the verification process an important part of overall portfolio risk management.

### Verification Turnaround Time

The verification turnaround time varies depending on the type of issue identified.

Applications with clear issues such as **Fake Employment** were generally identified quickly, with verification taking approximately **11–15 hours**.

However, applications marked as **Needs Clarification** or **Borderline Verification** required considerably more time, with turnaround times reaching approximately **55–60 hours**.

This indicates that cases requiring manual investigation are a major source of verification delays.

---

## 3. Credit Risk Insights

### Credit Score Distribution

- **Average Credit Score:** 754
- **Minimum Credit Score:** 709
- **Maximum Credit Score:** 798

The applicant credit scores fall within a relatively narrow range of **709–798**.

Because the credit scores are concentrated within a limited range, credit score alone does not provide enough differentiation between lower- and higher-risk applicants in this dataset.

### Major Risk Factors

The verification process provides stronger risk signals than credit score variation.

| Risk Flag | Frequency | Main Segment |
|---|---|---|
| Borderline Verification | High | Self-Employed |
| Needs Clarification | Medium | Salaried & Self-Employed |
| Address Mismatch | Medium | Applicants with location differences |
| Fake Employment | Low but High Risk | Salaried |

**Borderline Verification** is particularly common among self-employed applicants, while **Fake Employment** is less frequent but represents a serious verification risk.

---

## 4. Loan Performance Insights

### Portfolio Status

| Loan Status | Accounts | Percentage |
|---|---:|---:|
| Paid Off | 59 | 29.5% |
| Current | 58 | 29.0% |
| Defaulted | 83 | 41.5% |

The portfolio contains **83 defaulted accounts**, representing **41.5% of the total accounts**.

At the same time, 58 accounts remain current and 59 accounts have been successfully paid off.

### Missed Payment Analysis

The analysis identifies a strong relationship between the number of missed payments and eventual loan performance.

Borrowers with **1–2 missed payments** frequently returned to a current repayment status, indicating a relatively high self-cure tendency.

However, once missed payments reached **6 or more**, the accounts in this dataset showed a **100% default rate**.

This makes repeated missed payments an important early warning indicator for potential default.

---

## 5. Operational Insights

### Verification Bottlenecks

Manual verification creates significant differences in turnaround time.

Self-employed applications generally require more investigation and verification, which can increase processing time compared with more standardized salaried profiles.

The highest delays are observed in cases requiring clarification or additional verification.

### Collection Performance

Defaulted accounts showed very low recovery amounts compared with the outstanding loan amounts.

This suggests that collection efforts are more effective when started **before the account reaches severe delinquency**, rather than relying mainly on recovery actions after default.

---

## 6. Strategic Recommendations

### 1. Introduce Early Warning Collection Actions

Accounts with **1–2 missed payments** show signs of self-correction in the dataset. However, repeated missed payments indicate increasing default risk.

Collection teams should prioritize accounts approaching the higher-risk delinquency stage and initiate proactive communication before the account becomes severely delinquent.

### 2. Improve Employment Verification

The significant turnaround time for **Needs Clarification** cases indicates an opportunity to reduce manual verification dependency.

Automated employment and income verification can help reduce processing time and improve the consistency of verification decisions.

### 3. Strengthen Address Verification

Address mismatches should receive additional verification because they can indicate differences between the applicant's reported information and available records.

Additional address validation can help reduce potential fraud and improve the quality of loan approvals.

### 4. Use Multiple Risk Indicators

Because credit scores are concentrated within a relatively narrow range, relying only on bureau scores may not provide sufficient risk differentiation.

Loan decisions should consider multiple factors, including:

- Credit score
- Employment verification
- Address verification
- Verification status
- Missed payment history
- Previous repayment behavior

---

## 7. Key Business Takeaways

1. **41.5% of applications were rejected or risk-flagged during verification.**
2. **41.5% of loan accounts were ultimately classified as defaulted.**
3. **Self-employed applicants represent 43% of the application portfolio and show a higher concentration of borderline verification cases.**
4. **Verification cases requiring clarification can take approximately 55–60 hours, creating a major operational bottleneck.**
5. **Credit scores have limited variation in this dataset, reducing their ability to independently differentiate risk.**
6. **Repeated missed payments are a strong indicator of future default, with accounts reaching 6+ missed payments showing a 100% default rate in this dataset.**
7. **Early collection intervention and stronger verification processes can help reduce credit and operational risk.**

---

## Conclusion

The analysis shows that **portfolio risk is influenced not only by credit scores but also by verification quality and repayment behavior**.

The narrow credit score range makes verification results and payment behavior particularly important for identifying risk.

The findings highlight three key areas for risk management:

- **Improve verification efficiency**
- **Strengthen fraud and address validation**
- **Act early on delinquent accounts**

Overall, the analysis demonstrates how SQL-based data analysis can be used to identify **credit risk patterns, operational bottlenecks, and actionable business insights** from a loan portfolio.
