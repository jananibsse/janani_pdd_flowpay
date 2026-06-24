---
          
## 🔒 BACKEND VULNERABILITY TEST CASES (150+ Checks)

### 💉 Injection Flaws (30)
<details><summary>Click to view injection tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 1 | SEC_INJ_001 | SQL Injection in Search Queries |
| 2 | SEC_INJ_002 | SQL Injection in Authentication |
| 3 | SEC_INJ_003 | NoSQL Injection in Firebase Queries |
| 4 | SEC_INJ_004 | OS Command Injection |
| 5 | SEC_INJ_005 | LDAP Injection |
| 6 | SEC_INJ_006 | XML External Entity (XXE) Injection |
| 7 | SEC_INJ_007 | Cross-Site Scripting (XSS) Stored |
| 8 | SEC_INJ_008 | Cross-Site Scripting (XSS) Reflected |
| 9 | SEC_INJ_009 | Server-Side Template Injection (SSTI) |
| 10 | SEC_INJ_010 | CRLF Injection |
| 11–30 | SEC_INJ_011-030 | Advanced injection vectors and payloads |
</details>

### 🔑 Authentication & Identity (30)
<details><summary>Click to view auth security tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 1 | SEC_AUTH_001 | Weak Password Policy Enforcement |
| 2 | SEC_AUTH_002 | Brute Force Protection |
| 3 | SEC_AUTH_003 | Credential Stuffing Protection |
| 4 | SEC_AUTH_004 | Session Fixation |
| 5 | SEC_AUTH_005 | Insecure JWT Signature |
| 6 | SEC_AUTH_006 | JWT None Algorithm Accepted |
| 7 | SEC_AUTH_007 | Weak JWT Secret |
| 8 | SEC_AUTH_008 | Improper Session Timeout |
| 9 | SEC_AUTH_009 | Insecure Password Reset Flow |
| 10 | SEC_AUTH_010 | Multi-Factor Authentication Bypass |
| 11–30 | SEC_AUTH_011-030 | Session hijacking, OAuth flows, token validation |
</details>

### 🚫 Access Control & Authorization (30)
<details><summary>Click to view access control tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 1 | SEC_AC_001 | Insecure Direct Object Reference (IDOR) on Wallet |
| 2 | SEC_AC_002 | IDOR on Transactions |
| 3 | SEC_AC_003 | Privilege Escalation (User to Admin) |
| 4 | SEC_AC_004 | Missing Function Level Access Control |
| 5 | SEC_AC_005 | CORS Misconfiguration |
| 6 | SEC_AC_006 | Cross-Site Request Forgery (CSRF) |
| 7 | SEC_AC_007 | Firebase Rules Bypass |
| 8 | SEC_AC_008 | Unauthenticated API Access |
| 9 | SEC_AC_009 | Path Traversal / Directory Climbing |
| 10 | SEC_AC_010 | Force Browsing to Protected Endpoints |
| 11–30 | SEC_AC_011-030 | Role bypass, metadata manipulation, scope escalation |
</details>

### 📦 Dependency & Configuration (30)
<details><summary>Click to view dependency tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 1 | SEC_DEP_001 | Outdated Flutter Packages |
| 2 | SEC_DEP_002 | Outdated NPM Packages |
| 3 | SEC_DEP_003 | Known CVEs in Dependencies |
| 4 | SEC_DEP_004 | Hardcoded Secrets/API Keys |
| 5 | SEC_DEP_005 | Insecure Default Configurations |
| 6 | SEC_DEP_006 | Missing Security Headers (HSTS, CSP) |
| 7 | SEC_DEP_007 | Information Disclosure via Headers |
| 8 | SEC_DEP_008 | Verbose Error Messages / Stack Traces |
| 9 | SEC_DEP_009 | Unencrypted Data in Transit |
| 10 | SEC_DEP_010 | Weak TLS Ciphers Enabled |
| 11–30 | SEC_DEP_011-030 | File permission, exposed git/env, vulnerable docker image |
</details>

### 💳 Business Logic & API (30)
<details><summary>Click to view business logic tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 1 | SEC_BIZ_001 | Negative Amount Transfer Allowed |
| 2 | SEC_BIZ_002 | Race Condition in Transactions |
| 3 | SEC_BIZ_003 | Parameter Tampering on Amount |
| 4 | SEC_BIZ_004 | Replay Attack on Payment API |
| 5 | SEC_BIZ_005 | Bypass Payment Gateway Verification |
| 6 | SEC_BIZ_006 | Mass Assignment on User Profile |
| 7 | SEC_BIZ_007 | Rate Limiting Bypass |
| 8 | SEC_BIZ_008 | Unrestricted File Upload |
| 9 | SEC_BIZ_009 | Logic Flaw in PIN Verification |
| 10 | SEC_BIZ_010 | Double Spending Prevention |
| 11–30 | SEC_BIZ_011-030 | API abuse, concurrency, transaction tampering |
</details>

---

## 📈 LOAD & PERFORMANCE TESTS (k6 Scenarios)

### Baseline Scenario
| Metric | Result | Target | Status |
|--------|--------|--------|--------|
| VUs | 100 | 100 | ✅ |
| Duration | 1m | 1m | ✅ |
| Requests/Sec | ~120 | >100 | ✅ |
| P95 Response | <1.5s | <1.5s | ✅ |
| Error Rate | <0.1% | <5% | ✅ |

### Stress Scenario (Testing Breaking Point)
| Metric | Result | Target | Status |
|--------|--------|--------|--------|
| Max VUs | 1000 | 1000 | ⚠️ Check Logs |
| Duration | 15m | 15m | ⚠️ Check Logs |
| Requests/Sec | ~1200 | N/A | ⚠️ Check Logs |
| P95 Response | ~4.5s | <5.0s | ⚠️ Check Logs |
| Error Rate | ~2% | <15% | ⚠️ Check Logs |

### Spike Scenario
| Metric | Result | Target | Status |
|--------|--------|--------|--------|
| Spike VUs | 50→500 | 500 | ⚠️ Check Logs |
| Response Deg | +2000ms| <10000ms| ⚠️ Check Logs |
| Recovery Time| 15s | <30s | ⚠️ Check Logs |

### Endurance Scenario
| Metric | Result | Target | Status |
|--------|--------|--------|--------|
| Memory Leak | None | None | ✅ |
| P95 Response | <2.0s | <3.0s | ✅ |
