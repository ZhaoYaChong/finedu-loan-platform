-- ====================================================================
-- FinEdu Loan Platform Core Database Schema (V1.0.0)
-- Target Database: MySQL 8.0+
-- Standard: Financial Precision, Standard Audit Columns, Flyway Ready
-- ====================================================================

USE finedu_loan;

-- 1. 学生信息表 (student)
CREATE TABLE IF NOT EXISTS student (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    student_no VARCHAR(32) NOT NULL COMMENT '学号',
    real_name VARCHAR(64) NOT NULL COMMENT '真实姓名',
    id_card VARCHAR(18) NOT NULL COMMENT '身份证号码',
    phone VARCHAR(11) NOT NULL COMMENT '手机号码',
    university VARCHAR(128) NOT NULL COMMENT '就读高校',
    major VARCHAR(128) NOT NULL COMMENT '专业名称',
    credit_score INT NOT NULL DEFAULT 600 COMMENT '信用评分 (300-850)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_student_no (student_no),
    UNIQUE KEY uk_id_card (id_card),
    KEY idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生信息表';

-- 2. 贷款申请表 (loan_application)
CREATE TABLE IF NOT EXISTS loan_application (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    apply_no VARCHAR(64) NOT NULL COMMENT '申请单号 (唯一业务流水号)',
    student_id BIGINT NOT NULL COMMENT '关联学生ID',
    amount DECIMAL(12, 2) NOT NULL COMMENT '申请金额 (元)',
    term_months INT NOT NULL COMMENT '申请期限 (月)',
    purpose VARCHAR(255) NOT NULL COMMENT '贷款用途',
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING(待审核)/APPROVED(通过)/REJECTED(拒绝)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_apply_no (apply_no),
    KEY idx_student_id (student_id),
    KEY idx_status (status),
    CONSTRAINT fk_app_student FOREIGN KEY (student_id) REFERENCES student(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='贷款申请表';

-- 3. 审批记录表 (loan_approval)
CREATE TABLE IF NOT EXISTS loan_approval (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    apply_id BIGINT NOT NULL COMMENT '关联申请ID',
    approver VARCHAR(64) NOT NULL COMMENT '审批人账号/工号',
    approved_amount DECIMAL(12, 2) NOT NULL COMMENT '审批通过金额 (元)',
    approval_status VARCHAR(32) NOT NULL COMMENT '审批状态: PASS(通过)/REJECT(拒绝)',
    remark VARCHAR(255) DEFAULT NULL COMMENT '审批意见/拒绝原因',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审批时间',
    UNIQUE KEY uk_apply_id (apply_id),
    CONSTRAINT fk_approval_app FOREIGN KEY (apply_id) REFERENCES loan_application(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审批记录表';

-- 4. 贷款合同表 (loan_contract)
CREATE TABLE IF NOT EXISTS loan_contract (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    contract_no VARCHAR(64) NOT NULL COMMENT '合同编号',
    apply_id BIGINT NOT NULL COMMENT '关联申请ID',
    total_amount DECIMAL(12, 2) NOT NULL COMMENT '合同总金额 (元)',
    annual_rate DECIMAL(6, 4) NOT NULL COMMENT '年化利率 (如 0.0435 代表 4.35%)',
    start_date DATE NOT NULL COMMENT '合同起止日期',
    end_date DATE NOT NULL COMMENT '合同到期日期',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT '合同状态: ACTIVE(履约中)/FINISHED(结清)/TERMINATED(违约终止)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_contract_no (contract_no),
    UNIQUE KEY uk_contract_apply_id (apply_id),
    CONSTRAINT fk_contract_app FOREIGN KEY (apply_id) REFERENCES loan_application(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='贷款合同表';

-- 5. 放款记录表 (loan_disbursement)
CREATE TABLE IF NOT EXISTS loan_disbursement (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    disburse_no VARCHAR(64) NOT NULL COMMENT '放款交易流水号',
    contract_id BIGINT NOT NULL COMMENT '关联合同ID',
    amount DECIMAL(12, 2) NOT NULL COMMENT '实际放款金额 (元)',
    disburse_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '实际放款时间',
    status VARCHAR(32) NOT NULL DEFAULT 'SUCCESS' COMMENT '放款状态: SUCCESS(成功)/FAILED(失败)',
    UNIQUE KEY uk_disburse_no (disburse_no),
    KEY idx_contract_id (contract_id),
    CONSTRAINT fk_disburse_contract FOREIGN KEY (contract_id) REFERENCES loan_contract(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='放款记录表';

-- 6. 还款计划表 (repayment_plan)
CREATE TABLE IF NOT EXISTS repayment_plan (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    contract_id BIGINT NOT NULL COMMENT '关联合同ID',
    period_num INT NOT NULL COMMENT '还款期数 (如第 1 期)',
    due_date DATE NOT NULL COMMENT '应还日期',
    principal DECIMAL(12, 2) NOT NULL COMMENT '本期应还本金 (元)',
    interest DECIMAL(12, 2) NOT NULL COMMENT '本期应还利息 (元)',
    status VARCHAR(32) NOT NULL DEFAULT 'UNPAID' COMMENT '还款状态: UNPAID(未还)/PAID(已还)/OVERDUE(逾期)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_contract_period (contract_id, period_num),
    KEY idx_due_date (due_date),
    KEY idx_status (status),
    CONSTRAINT fk_plan_contract FOREIGN KEY (contract_id) REFERENCES loan_contract(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='还款计划表';

-- 7. 还款流水表 (repayment_record)
CREATE TABLE IF NOT EXISTS repayment_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    pay_no VARCHAR(64) NOT NULL COMMENT '支付平台交易流水号',
    plan_id BIGINT NOT NULL COMMENT '关联还款计划ID',
    pay_amount DECIMAL(12, 2) NOT NULL COMMENT '本次实还金额 (元)',
    pay_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '支付时间',
    pay_channel VARCHAR(32) NOT NULL COMMENT '支付渠道: ALIPAY/WECHAT/BANK_TRANSFER',
    UNIQUE KEY uk_pay_no (pay_no),
    KEY idx_plan_id (plan_id),
    CONSTRAINT fk_record_plan FOREIGN KEY (plan_id) REFERENCES repayment_plan(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='还款流水表';

-- 8. 催收记录表 (collection_record)
CREATE TABLE IF NOT EXISTS collection_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    plan_id BIGINT NOT NULL COMMENT '关联逾期还款计划ID',
    collector VARCHAR(64) NOT NULL COMMENT '催收专员账号',
    contact_type VARCHAR(32) NOT NULL COMMENT '联系渠道: PHONE(电话)/SMS(短信)/EMAIL(邮件)',
    result VARCHAR(255) NOT NULL COMMENT '催收结果说明',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '催收记录时间',
    KEY idx_plan_id (plan_id),
    CONSTRAINT fk_collection_plan FOREIGN KEY (plan_id) REFERENCES repayment_plan(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='催收记录表';
