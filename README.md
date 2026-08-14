# Fintech Loan Analytics SQL Project

## Project Overview

This project analyzes the end-to-end lifecycle of consumer loan applications, from application and verification to repayment and default.

The project uses a relational SQL database to analyze:

- Loan application patterns
- Applicant credit profiles
- Verification outcomes
- Verification turnaround time (TAT)
- Credit and fraud risk indicators
- Loan repayment performance
- Missed payment and default patterns

The goal is to use SQL-based analysis to identify **credit risk patterns, operational bottlenecks, and actionable business insights**.

---

## Business Problem

Fintech lenders process a large number of loan applications and need to balance loan approval with credit risk.

This project addresses key business questions such as:

- What percentage of applications are approved, rejected, or flagged?
- What are the major reasons for verification failures?
- How does verification turnaround time vary across different risk categories?
- Which employment segments show higher verification risk?
- How are missed payments related to loan defaults?
- Can early warning indicators be identified before an account reaches severe delinquency?
- What factors can help improve verification and collection strategies?

---

## Database Schema

The database consists of three related tables:

```text
                    ┌──────────────────────┐
                    │     applications     │
                    │──────────────────────│
                    │ application_id (PK)  │
                    │ customer_name        │
                    │ applied_amount       │
                    │ application_date     │
                    │ credit_score         │
                    │ employment_type      │
                    └──────────┬───────────┘
                               │
                    ┌──────────┴───────────┐
                    │                      │
                    ▼                      ▼
          ┌──────────────────┐   ┌──────────────────┐
          │ verification_log │   │ loan_performance │
          │──────────────────│   │──────────────────│
          │ verification_id  │   │ loan_id          │
          │ application_id   │   │ application_id   │
          │ assigned_agent   │   │ loan_status      │
          │ verification_    │   │ amount_paid      │
          │ status           │   │ missed_payments  │
          │ turnaround_time  │   └──────────────────┘
          │ risk_flag_reason │
          └──────────────────┘
