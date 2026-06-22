# FlowPay Enterprise Automation Suite

> **770+ Automated Test Cases** | **3 CI/CD Pipelines** | **Selenium + Appium + k6**

---

## 📋 Overview

Enterprise-grade QA automation framework for the FlowPay digital wallet application. Covers web E2E testing (Selenium), native Android testing (Appium), load/performance testing (k6/Artillery/JMeter), and security auditing.

---

## 🏗️ Architecture

```
automation/
├── selenium/      → Python Selenium E2E framework (480+ tests)
├── appium/        → Java Appium Android framework (290 tests)
├── reports/       → Python report generators (HTML, Excel, Summary)
├── security/      → Load tests + security audit documents
└── EXECUTION_GUIDE.md
```

---

## 🧪 Test Coverage

| Framework | Language | Tests | Modules |
|-----------|----------|:-----:|:-------:|
| Selenium (Web) | Python + pytest | 480+ | 13 |
| Appium (Android) | Java + TestNG | 290 | 8 |
| k6 (Load) | JavaScript | 4 scenarios | — |
| Artillery (Load) | YAML | 3 phases | — |
| JMeter (Load) | XML | 1 plan | — |
| **TOTAL** | — | **770+** | **21** |

### Test Categories

| Category | Selenium | Appium |
|----------|:--------:|:------:|
| Authentication | 40 | 40 |
| Authorization | 40 | 30 |
| Navigation | 30 | 30 |
| UI Validation | 50 | — |
| Forms | 50 | 40 |
| CRUD Operations | 50 | 40 |
| Input Validation | 40 | 40 |
| Error Handling | 40 | — |
| Session Management | ✓ | — |
| Accessibility | 20 | — |
| Responsive Design | 40 | — |
| Performance Smoke | 20 | 20 |
| Regression | 50 | 50 |

---

## 🚀 Quick Start

### Selenium (Web E2E)

```bash
cd automation/selenium
pip install -r requirements.txt
pytest tests/ -v --html=reports/report.html
```

### Appium (Android)

```bash
# Terminal 1: Start Appium server
appium --base-path /wd/hub --port 4723

# Terminal 2: Run tests
cd automation/appium
mvn test
```

### k6 Load Test

```bash
k6 run -e BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ \
    automation/security/k6-load-test.js
```

### Reports

```bash
python automation/reports/generate_html_report.py --output-dir Test_Results/HTML
python automation/reports/generate_excel_report.py --output-dir Test_Results/Excel
python automation/reports/generate_security_report.py --output-dir Test_Results/Security
```

---

## 🔧 CI/CD Pipelines

| Workflow | Trigger | Stages | Duration |
|----------|---------|:------:|:--------:|
| `deploy-and-test.yml` | Push to main | 13 | ~15 min |
| `security-review.yml` | Manual / Schedule | 12 | ~10 min |
| `android-e2e.yml` | Manual | 21 | ~25 min |

---

## 📊 Report Output

| Type | Format | Generator |
|------|--------|-----------|
| HTML Report | `.html` | `generate_html_report.py` |
| Excel Report | `.xlsx` (4 workbooks) | `generate_excel_report.py` |
| GitHub Summary | Markdown | `generate_summary.py` |
| Security Excel | `.xlsx` (5 sheets) | `generate_security_report.py` |
| Appium HTML | `.html` | ExtentReports (TestListener) |
| Appium Excel | `.xlsx` (4 workbooks) | `ExcelReportGenerator.java` |

---

## 🔐 Security Audit

- **10 findings** mapped to CWE + OWASP Top 10 (2021)
- **Score**: 72/100 (MEDIUM risk)
- **Details**: See [security-review.md](security/security-review.md)
- **Fixes**: See [remediation-guide.md](security/remediation-guide.md)

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| [EXECUTION_GUIDE.md](EXECUTION_GUIDE.md) | Full local + CI setup guide |
| [security-review.md](security/security-review.md) | Security findings |
| [performance-report.md](security/performance-report.md) | Load test results |
| [remediation-guide.md](security/remediation-guide.md) | Code-level fixes |
| [dependency-analysis.md](security/dependency-analysis.md) | Dependency audit |
| [backend-inventory.md](security/backend-inventory.md) | Firebase + API inventory |

---

## ⚙️ Requirements

### Selenium
- Python 3.9+
- Chrome / Firefox / Edge browser
- pip packages: `selenium`, `pytest`, `pytest-html`, `openpyxl`, `requests`

### Appium
- Java 17+
- Maven 3.8+
- Node.js 18+ (for Appium server)
- Appium 2.x (`npm install -g appium`)
- Android SDK (API 33+)
- Flutter debug APK

### Load Testing
- k6 (`brew install k6` / `choco install k6`)
- Artillery (`npm install -g artillery`)
- JMeter 5.6+ (optional)

---

## 📄 License

Internal — FlowPay QA Team
