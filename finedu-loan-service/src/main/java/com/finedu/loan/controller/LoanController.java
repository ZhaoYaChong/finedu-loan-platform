package com.finedu.loan.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/loan")
public class LoanController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/students")
    public List<Map<String, Object>> getStudents() {
        return jdbcTemplate.queryForList("SELECT id, student_no, real_name, university, credit_score FROM student");
    }

    @GetMapping("/overview")
    public List<Map<String, Object>> getLoanOverview() {
        String sql = "SELECT s.real_name, la.apply_no, la.amount, la.status " +
                     "FROM student s JOIN loan_application la ON s.id = la.student_id";
        return jdbcTemplate.queryForList(sql);
    }
}
