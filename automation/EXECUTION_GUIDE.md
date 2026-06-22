# FlowPay Automation — Local & CI Execution Guide
> Phase 7: Complete CI/CD + Live E2E Testing

---

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Selenium E2E Tests (Local)](#selenium-e2e-tests-local)
4. [Appium Mobile Tests (Local)](#appium-mobile-tests-local)
5. [k6 Load Tests](#k6-load-tests)
6. [CI/CD Pipeline Reference](#cicd-pipeline-reference)
7. [Test Reports](#test-reports)
8. [Troubleshooting](#troubleshooting)

---

## Quick Start

```bash
# 1. Install Python dependencies
cd automation/selenium
pip install -r requirements.txt

# 2. Run all Selenium tests against live GitHub Pages
pytest tests/ --html=../../Test_Results/HTML/report.html -v

# 3. Run k6 baseline load test
k6 run -e BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ \
    automation/security/k6-load-test.js

# 4. Generate Excel reports
python automation/reports/generate_excel_report.py \
    --output-dir Test_Results/Excel

# 5. Generate HTML reports
python automation/reports/generate_html_report.py \
    --output-dir Test_Results/HTML
```

---

## Prerequisites

### For Selenium Tests
| Tool | Version | Install |
|------|---------|---------|
| Python | 3.11+ | [python.org](https://python.org) |
| Chrome | Latest | [google.com/chrome](https://google.com/chrome) |
| ChromeDriver | Auto-managed | Via `webdriver-manager` |
| pip packages | See requirements.txt | `pip install -r requirements.txt` |

### For Appium Tests
| Tool | Version | Install |
|------|---------|---------|
| Java JDK | 17+ | [adoptium.net](https://adoptium.net) |
| Maven | 3.9+ | [maven.apache.org](https://maven.apache.org) |
| Node.js | 18+ | [nodejs.org](https://nodejs.org) |
| Appium | 2.x | `npm install -g appium` |
| Android SDK | API 33 | Android Studio |
| Appium UiAutomator2 | Latest | `appium driver install uiautomator2` |

### For k6 Load Tests
```bash
# Windows (choco)
choco install k6

# macOS (brew)
brew install k6

# Linux
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg \
  --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | \
  sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update && sudo apt-get install k6
```

---

## Selenium E2E Tests (Local)

### Step 1: Install Dependencies
```bash
cd automation/selenium
pip install -r requirements.txt
```

### Step 2: Configure BASE_URL
```bash
# Windows
set BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/

# Linux/macOS
export BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/
```

### Step 3: Run Tests

#### Run All 480 Tests
```bash
cd automation/selenium
pytest tests/ \
  --html=../../Test_Results/HTML/report.html \
  --self-contained-html \
  -v --tb=short
```

#### Run Specific Module
```bash
# Authentication only (40 tests)
pytest tests/test_authentication.py -v

# Authorization only (40 tests)
pytest tests/test_authorization.py -v

# Regression only (50 tests)
pytest tests/test_regression.py -v

# Quick smoke (subset)
pytest tests/test_regression.py -k "reg_001 or reg_002 or reg_005" -v
```

#### Run by Marker
```bash
# All high priority
pytest tests/ -m "authentication or authorization" -v

# All UI tests
pytest tests/ -m "ui" -v

# Performance tests only
pytest tests/ -m "performance" -v

# Skip slow tests
pytest tests/ -m "not performance" -v
```

#### Run in Parallel
```bash
pip install pytest-xdist
pytest tests/ -n 4 --dist=worksteal -v
```

#### Run Against Different Environment
```bash
# Staging
BASE_URL=https://staging.flowpay.app pytest tests/ -v

# Local (not recommended for Selenium — use Pages)
BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ pytest tests/ -v
```

#### Run with Different Browsers
```bash
# Chrome (default)
BROWSER=chrome pytest tests/ -v

# Firefox
BROWSER=firefox pytest tests/ -v

# Edge
BROWSER=edge pytest tests/ -v
```

---

## Appium Mobile Tests (Local)

### Step 1: Start Android Emulator
```bash
# List available AVDs
emulator -list-avds

# Start emulator
emulator -avd Pixel_5_API_33 -no-snapshot-load

# Verify device connected
adb devices
```

### Step 2: Build Debug APK
```bash
cd flowpay_app
flutter build apk --debug
# APK: build/app/outputs/flutter-apk/app-debug.apk
```

### Step 3: Install APK
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Step 4: Start Appium Server
```bash
appium --base-path /wd/hub --port 4723 --log-level info
```

### Step 5: Run Tests
```bash
cd automation/appium
mvn test -Dtest=AuthenticationTests
mvn test                    # All test suites
mvn test -Dtest=AuthenticationTests,NavigationTests
```

### Appium Inspector Configuration
```json
{
  "platformName": "Android",
  "appium:deviceName": "Pixel_5_API_33",
  "appium:platformVersion": "13",
  "appium:appPackage": "com.example.flowpay_app",
  "appium:appActivity": "com.example.flowpay_app.MainActivity",
  "appium:automationName": "UiAutomator2",
  "appium:noReset": true
}
```

---

## k6 Load Tests

### Baseline Load Test (100 VUs × 1 minute)
```bash
k6 run \
  -e BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ \
  -e TEST_TYPE=baseline \
  automation/security/k6-load-test.js

# With HTML output
k6 run \
  -e BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ \
  --out json=Performance_Results/baseline-results.json \
  automation/security/k6-load-test.js
```

### Stress Test (200 → 1000 VUs)
```bash
k6 run \
  -e BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ \
  -e TEST_TYPE=stress \
  automation/security/k6-load-test.js
```

### Spike Test (50 → 500 VUs sudden)
```bash
k6 run \
  -e TEST_TYPE=spike \
  -e BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ \
  automation/security/k6-load-test.js
```

### Endurance Test (100 VUs × 30 minutes)
```bash
k6 run \
  -e TEST_TYPE=endurance \
  -e BASE_URL=https://jananibsse.github.io/janani_pdd_flowpay/ \
  automation/security/k6-load-test.js
```

### Expected Results (Baseline)
```
✅ WHAT YOU WILL SEE:

Requests per second (RPS):
    120 req/sec

Response Time:
    Average: 250ms
    Min:      50ms
    Max:    1500ms

Error Rate:
    < 5% (threshold)
```

---

## CI/CD Pipeline Reference

### Trigger Conditions
| Event | Pipelines Triggered |
|-------|-------------------|
| Push to `main` | `deploy-and-test.yml` |
| Push to any branch | `security-review.yml` |
| Pull Request to `main` | All pipelines |
| Manual dispatch | All pipelines (manual) |

### Pipeline Stages
```
deploy-and-test.yml:
 1 → Checkout
 2 → Install Flutter
 3 → Flutter Analyze
 4 → Flutter Unit Tests
 5 → Build Web (Release)
 6 → Deploy to GitHub Pages
 7 → Verify Deployment
 8 → Run Selenium Tests (13 modules)
 9 → Generate HTML Reports
10 → Generate Excel Reports
11 → Upload All Artifacts
12 → Post Notification (Slack/Discord)
13 → Job Summary

security-review.yml:
 1 → Checkout + SAST (flutter analyze)
 2 → Dependency Audit (pub audit)
 3 → Secrets Scan (gitleaks)
 4 → k6 Load Test (100VUs × 1min)
 5 → Generate Performance Reports
 6 → Upload Security Artifacts

android-e2e.yml:
 1  → Setup Android SDK
 2  → Build Debug APK
 3  → Create AVD (API 33)
 4  → Start Emulator
 5  → Install APK
 6  → Start Appium Server
 7  → Run Auth Tests
 8  → Run Nav Tests
 9  → Run CRUD Tests
10  → Run Input Validation
11  → Run Regression
12  → Generate HTML Report (ExtentReports)
13  → Generate Excel Report
14  → Upload Screenshots
15  → Upload APK + Reports
```

### Failure Policy
The workflow fails ONLY if:
1. **Flutter build fails** → Critical blocker
2. **GitHub Pages deployment fails** → Cannot test
3. **> 5% critical tests fail** → Quality threshold breached

Minor test failures (≤ 5%) produce warnings but don't block deployment.

---

## Test Reports

### HTML Reports
Generated in: `Test_Results/HTML/`
- `execution-report.html` — Full test report with module breakdown
- `dashboard.html` — Compact summary dashboard

### Excel Reports
Generated in: `Test_Results/Excel/`
| File | Description |
|------|-------------|
| `Automation_Test_Report.xlsx` | Full report (7 sheets) |
| `Passed_Test_Cases.xlsx` | All passing tests |
| `Failed_Test_Cases.xlsx` | All failing tests with reasons |
| `Summary_Report.xlsx` | Executive summary |

### JSON Results
Generated in: `Test_Results/JSON/`
- `execution-results.json` — Machine-readable results

### CI/CD Artifacts (GitHub Actions)
All artifacts retained for **30 days** in GitHub Actions.

---

## Troubleshooting

### Problem: ChromeDriver version mismatch
```bash
# webdriver-manager auto-manages ChromeDriver
pip install webdriver-manager --upgrade
```

### Problem: Headless Chrome issues
```bash
# Force non-headless for debugging
HEADLESS=false pytest tests/test_authentication.py -v
```

### Problem: Flutter app not loading
```bash
# Increase timeout
MAX_PAGE_LOAD_MS=10000 pytest tests/ -v
```

### Problem: Appium server not starting
```bash
# Check port
netstat -an | grep 4723
# Kill existing Appium
pkill -f appium
# Restart
appium --base-path /wd/hub --port 4723
```

### Problem: Emulator too slow
```bash
# Use snapshot for faster boot
emulator -avd Pixel_5_API_33 -snapshot default_boot
```

### Problem: k6 rate limit errors
```bash
# Reduce VUs for GitHub Pages (static hosting)
k6 run -e BASE_URL=<URL> --vus 20 --duration 60s automation/security/k6-load-test.js
```

---

## Test Count Summary

| Category | Selenium (Web) | Appium (Android) | Total |
|----------|---------------|-----------------|-------|
| Authentication | 40 | 40 | 80 |
| Authorization | 40 | 30 | 70 |
| Navigation | 30 | 30 | 60 |
| UI Validation | 50 | - | 50 |
| Forms | 50 | 40 | 90 |
| CRUD Operations | 50 | 40 | 90 |
| Input Validation | 40 | 40 | 80 |
| Error Handling | 20 | - | 20 |
| Session Mgmt | 20 | - | 20 |
| Accessibility | 20 | - | 20 |
| Responsive | 20 | - | 20 |
| Performance | 40 | 20 | 60 |
| Regression | 50 | 50 | 100 |
| **TOTAL** | **480** | **290** | **760+** |

---

*FlowPay Automation Framework | Phase 7 Complete*
