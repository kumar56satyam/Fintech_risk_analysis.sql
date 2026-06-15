-- 1. Create Applications Table
CREATE TABLE applications (
    application_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    applied_amount DECIMAL(10, 2) NOT NULL,
    application_date DATE NOT NULL,
    credit_score INT NOT NULL,
    employment_type VARCHAR(50) NOT NULL,
    CONSTRAINT chk_employment_type CHECK (employment_type IN ('salaried', 'self employed'))
);

-- 2. Create Verification Log Table (Links to Applications)
CREATE TABLE verification_log (
    verification_id INT PRIMARY KEY,
    application_id INT NOT NULL,
    assigned_agent VARCHAR(100) NOT NULL,
    verification_status VARCHAR(50) NOT NULL, 
    turnaround_time_hours INT NOT NULL,
    risk_flag_reason VARCHAR(255),
    FOREIGN KEY (application_id) REFERENCES applications(application_id),
    CONSTRAINT chk_verification_status CHECK (verification_status IN ('approved', 'rejected', 'flagged'))
);

-- 3. Create Loan Performance Table (Links to Applications)
CREATE TABLE loan_performance (
    loan_id INT PRIMARY KEY,
    application_id INT NOT NULL,
    loan_status VARCHAR(50) NOT NULL, 
    amount_paid DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    missed_payments INT NOT NULL DEFAULT 0,
    FOREIGN KEY (application_id) REFERENCES applications(application_id),
    CONSTRAINT chk_loan_status CHECK (loan_status IN ('current', 'defaulted', 'paid off'))
);
