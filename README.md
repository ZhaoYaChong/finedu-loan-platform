# FinEdu Loan Platform

## 项目名称

金融助学贷款核心业务平台 DevOps 实战项目


## 项目背景

模拟银行助学贷款业务系统。

业务流程：

学生申请贷款
        ↓
贷款审核
        ↓
贷款发放
        ↓
学生还款
        ↓
逾期催收


## 技术栈

### 基础设施

- Ubuntu Server 22.04
- VMware
- Linux


### 自动化

- Git
- Ansible
- Jenkins


### 容器化

- Docker
- Kubernetes/K3s


### 监控

- Prometheus
- Grafana
- ELK


## 环境规划

|节点|IP|用途|
|-|-|-|
|bastion|192.168.31.100|堡垒机|
|app01|192.168.31.200|业务服务|
|db01|192.168.31.210|数据库|
|monitor01|192.168.31.220|监控|
