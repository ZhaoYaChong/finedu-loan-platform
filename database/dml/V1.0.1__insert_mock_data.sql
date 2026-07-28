USE finedu_loan;

-- 1. 插入学生基本数据
INSERT INTO student (id, student_no, real_name, id_card, phone, university, major, credit_score) VALUES
(1, 'STU2026001', '张伟', '110101200301011234', '13800138001', '清华大学', '计算机科学与技术', 750),
(2, 'STU2026002', '李娜', '310101200302022345', '13800138002', '复旦大学', '金融学', 720);

-- 2. 插入贷款申请 (张伟申请 12,000 元，分 12 期)
INSERT INTO loan_application (id, apply_no, student_id, amount, term_months, purpose, status) VALUES
(1, 'APP202607270001', 1, 12000.00, 12, '购买实验设备与专业书籍', 'APPROVED');

-- 3. 插入审批记录 (风控通过)
INSERT INTO loan_approval (id, apply_id, approver, approved_amount, approval_status, remark) VALUES
(1, 1, 'AUDITOR_007', 12000.00, 'PASS', '学生信用良好，学业表现优秀，予以审批通过');

-- 4. 插入贷款合同
INSERT INTO loan_contract (id, contract_no, apply_id, total_amount, annual_rate, start_date, end_date, status) VALUES
(1, 'CTR202607270001', 1, 12000.00, 0.0435, '2026-08-01', '2027-08-01', 'ACTIVE');

-- 5. 插入放款流水
INSERT INTO loan_disbursement (id, disburse_no, contract_id, amount, disburse_time, status) VALUES
(1, 'PAY202608010001', 1, 12000.00, '2026-08-01 10:00:00', 'SUCCESS');

-- 6. 插入还款计划 (生成前 3 期)
INSERT INTO repayment_plan (id, contract_id, period_num, due_date, principal, interest, status) VALUES
(1, 1, 1, '2026-09-01', 1000.00, 43.50, 'PAID'),
(2, 1, 2, '2026-10-01', 1000.00, 43.50, 'OVERDUE'),
(3, 1, 3, '2026-11-01', 1000.00, 43.50, 'UNPAID');

-- 7. 插入第 1 期还款流水 (通过支付宝成功还款)
INSERT INTO repayment_record (id, pay_no, plan_id, pay_amount, pay_time, pay_channel) VALUES
(1, 'ALI202609018888', 1, 1043.50, '2026-09-01 14:20:00', 'ALIPAY');

-- 8. 插入第 2 期逾期催收记录
INSERT INTO collection_record (id, plan_id, collector, contact_type, result) VALUES
(1, 2, 'COLLECTOR_01', 'PHONE', '已电话联系学生本人，承诺于本周内完成补缴');
