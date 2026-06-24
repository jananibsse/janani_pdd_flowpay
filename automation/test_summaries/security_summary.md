---
          
## 🔒 BACKEND VULNERABILITY & LOAD TEST CASES (300 Checks)

### 💉 1. Injection Flaws (30)
<details><summary>Click to view injection tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 1 | SEC_INJ_001 | SQL Injection in Search Queries |
| 2 | SEC_INJ_002 | SQL Injection in Authentication |
| 3 | SEC_INJ_003 | NoSQL Injection in Firebase Queries |
| 4 | SEC_INJ_004 | OS Command Injection via File Upload |
| 5 | SEC_INJ_005 | LDAP Injection in Directory Lookups |
| 6 | SEC_INJ_006 | XML External Entity (XXE) Injection |
| 7 | SEC_INJ_007 | Cross-Site Scripting (XSS) Stored in Profiles |
| 8 | SEC_INJ_008 | Cross-Site Scripting (XSS) Reflected in Search |
| 9 | SEC_INJ_009 | Server-Side Template Injection (SSTI) |
| 10 | SEC_INJ_010 | CRLF Injection in Log Files |
| 11 | SEC_INJ_011 | Second-Order SQL Injection |
| 12 | SEC_INJ_012 | XPath Injection |
| 13 | SEC_INJ_013 | GraphQL Injection |
| 14 | SEC_INJ_014 | Host Header Injection |
| 15 | SEC_INJ_015 | Email Header Injection |
| 16 | SEC_INJ_016 | Server-Side Request Forgery (SSRF) |
| 17 | SEC_INJ_017 | Code Injection in eval() |
| 18 | SEC_INJ_018 | Expression Language Injection |
| 19 | SEC_INJ_019 | Blind SQL Injection (Time-Based) |
| 20 | SEC_INJ_020 | Blind SQL Injection (Boolean-Based) |
| 21 | SEC_INJ_021 | JSON Injection in Body |
| 22 | SEC_INJ_022 | CSV/Excel Formula Injection |
| 23 | SEC_INJ_023 | ORM Injection |
| 24 | SEC_INJ_024 | Parameter Delimiter Injection |
| 25 | SEC_INJ_025 | DOM-based XSS |
| 26 | SEC_INJ_026 | Log Forging / Injection |
| 27 | SEC_INJ_027 | HTTP Response Splitting |
| 28 | SEC_INJ_028 | Malicious Regex Injection (ReDoS) |
| 29 | SEC_INJ_029 | Deserialization Injection |
| 30 | SEC_INJ_030 | SSI (Server-Side Includes) Injection |
</details>

### 🔑 2. Authentication & Identity (30)
<details><summary>Click to view auth security tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 31 | SEC_AUTH_001 | Weak Password Policy Enforcement |
| 32 | SEC_AUTH_002 | Brute Force Protection (Login) |
| 33 | SEC_AUTH_003 | Credential Stuffing Protection |
| 34 | SEC_AUTH_004 | Session Fixation |
| 35 | SEC_AUTH_005 | Insecure JWT Signature Verification |
| 36 | SEC_AUTH_006 | JWT 'None' Algorithm Accepted |
| 37 | SEC_AUTH_007 | Weak JWT Secret Brute Forcing |
| 38 | SEC_AUTH_008 | Improper Session Timeout (Idle) |
| 39 | SEC_AUTH_009 | Insecure Password Reset Flow |
| 40 | SEC_AUTH_010 | Multi-Factor Authentication Bypass |
| 41 | SEC_AUTH_011 | User Enumeration via Login |
| 42 | SEC_AUTH_012 | User Enumeration via Password Reset |
| 43 | SEC_AUTH_013 | Concurrent Session Handling |
| 44 | SEC_AUTH_014 | Auth Token Exposed in URL |
| 45 | SEC_AUTH_015 | Missing Secure/HttpOnly Flags on Cookies |
| 46 | SEC_AUTH_016 | Token Replay Attack |
| 47 | SEC_AUTH_017 | Lack of Password Confirmation for Critical Actions |
| 48 | SEC_AUTH_018 | OAuth State Parameter Bypass |
| 49 | SEC_AUTH_019 | OpenID Connect Flaws |
| 50 | SEC_AUTH_020 | Insecure Remember-Me Functionality |
| 51 | SEC_AUTH_021 | Auth Bypass via Parameter Tampering |
| 52 | SEC_AUTH_022 | JWT Expiration Not Enforced |
| 53 | SEC_AUTH_023 | Inadequate Account Lockout Mechanism |
| 54 | SEC_AUTH_024 | Password Reset Token Expiration |
| 55 | SEC_AUTH_025 | Password Reset Token Predictability |
| 56 | SEC_AUTH_026 | Session Invalidated on Logout |
| 57 | SEC_AUTH_027 | Session ID Randomness |
| 58 | SEC_AUTH_028 | Impersonation Feature Abuse |
| 59 | SEC_AUTH_029 | Biometric Authentication Bypass (Mobile) |
| 60 | SEC_AUTH_030 | Cleartext Transmission of Credentials |
</details>

### 🚫 3. Access Control & Authorization (30)
<details><summary>Click to view access control tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 61 | SEC_AC_001 | Insecure Direct Object Reference (IDOR) on Wallet |
| 62 | SEC_AC_002 | IDOR on Transactions |
| 63 | SEC_AC_003 | Privilege Escalation (User to Admin) |
| 64 | SEC_AC_004 | Missing Function Level Access Control |
| 65 | SEC_AC_005 | CORS Misconfiguration |
| 66 | SEC_AC_006 | Cross-Site Request Forgery (CSRF) |
| 67 | SEC_AC_007 | Firebase Rules Bypass (Read) |
| 68 | SEC_AC_008 | Firebase Rules Bypass (Write) |
| 69 | SEC_AC_009 | Unauthenticated API Access |
| 70 | SEC_AC_010 | Path Traversal / Directory Climbing |
| 71 | SEC_AC_011 | Force Browsing to Protected Endpoints |
| 72 | SEC_AC_012 | Horizontal Privilege Escalation |
| 73 | SEC_AC_013 | Bypassing Access Control via HTTP Methods |
| 74 | SEC_AC_014 | Manipulation of Roles in JWT Claims |
| 75 | SEC_AC_015 | Abuse of API Hidden Endpoints |
| 76 | SEC_AC_016 | Accessing Other User's Notification Data |
| 77 | SEC_AC_017 | Cross-Tenant Data Leakage |
| 78 | SEC_AC_018 | Parameter Tampering for Role Assignment |
| 79 | SEC_AC_019 | Over-privileged API Keys |
| 80 | SEC_AC_020 | Accessing Admin Logs |
| 81 | SEC_AC_021 | Bypassing IP Restrictions |
| 82 | SEC_AC_022 | Access to Backup Files |
| 83 | SEC_AC_023 | Modifying Another User's Bank Details |
| 84 | SEC_AC_024 | Admin Actions by Non-Admin |
| 85 | SEC_AC_025 | Access to Swagger/OpenAPI Docs |
| 86 | SEC_AC_026 | Downloading Reports of Other Users |
| 87 | SEC_AC_027 | Approval of Own Withdrawal Requests |
| 88 | SEC_AC_028 | Deletion of Audit Logs |
| 89 | SEC_AC_029 | Accessing Cloud Metadata |
| 90 | SEC_AC_030 | Unrestricted Access to Payment Gateway Callbacks |
</details>

### 📦 4. Dependency & Configuration (30)
<details><summary>Click to view dependency tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 91 | SEC_DEP_001 | Outdated Flutter Packages |
| 92 | SEC_DEP_002 | Outdated NPM Packages |
| 93 | SEC_DEP_003 | Known CVEs in Dependencies |
| 94 | SEC_DEP_004 | Hardcoded Secrets/API Keys |
| 95 | SEC_DEP_005 | Insecure Default Configurations |
| 96 | SEC_DEP_006 | Missing Security Headers (HSTS, CSP) |
| 97 | SEC_DEP_007 | Information Disclosure via Server Headers |
| 98 | SEC_DEP_008 | Verbose Error Messages / Stack Traces |
| 99 | SEC_DEP_009 | Unencrypted Data in Transit |
| 100 | SEC_DEP_010 | Weak TLS Ciphers Enabled |
| 101 | SEC_DEP_011 | Exposed .git Directory |
| 102 | SEC_DEP_012 | Exposed .env Files |
| 103 | SEC_DEP_013 | Vulnerable Docker Base Image |
| 104 | SEC_DEP_014 | Open Ports / Services |
| 105 | SEC_DEP_015 | Missing Rate Limiting on APIs |
| 106 | SEC_DEP_016 | Debug Mode Enabled in Production |
| 107 | SEC_DEP_017 | Insecure S3 Bucket Permissions |
| 108 | SEC_DEP_018 | Lack of Integrity Checks for CDN Assets |
| 109 | SEC_DEP_019 | Supply Chain Attacks (Typosquatting) |
| 110 | SEC_DEP_020 | Missing Referrer Policy |
| 111 | SEC_DEP_021 | X-Frame-Options Not Set (Clickjacking) |
| 112 | SEC_DEP_022 | X-Content-Type-Options Not Set |
| 113 | SEC_DEP_023 | Cross-Domain Misconfiguration (crossdomain.xml) |
| 114 | SEC_DEP_024 | Firebase API Key Unrestricted |
| 115 | SEC_DEP_025 | Outdated Database Engine |
| 116 | SEC_DEP_026 | Cloud Firewall Misconfiguration |
| 117 | SEC_DEP_027 | Web Application Firewall (WAF) Bypass |
| 118 | SEC_DEP_028 | Deprecated API Usage |
| 119 | SEC_DEP_029 | Insufficient Logging Configuration |
| 120 | SEC_DEP_030 | Unsigned Binaries / APKs |
</details>

### 💳 5. Business Logic & API (30)
<details><summary>Click to view business logic tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 121 | SEC_BIZ_001 | Negative Amount Transfer Allowed |
| 122 | SEC_BIZ_002 | Race Condition in Transactions |
| 123 | SEC_BIZ_003 | Parameter Tampering on Amount |
| 124 | SEC_BIZ_004 | Replay Attack on Payment API |
| 125 | SEC_BIZ_005 | Bypass Payment Gateway Verification |
| 126 | SEC_BIZ_006 | Mass Assignment on User Profile |
| 127 | SEC_BIZ_007 | Rate Limiting Bypass via IP Spoofing |
| 128 | SEC_BIZ_008 | Unrestricted File Upload |
| 129 | SEC_BIZ_009 | Logic Flaw in PIN Verification |
| 130 | SEC_BIZ_010 | Double Spending Prevention |
| 131 | SEC_BIZ_011 | Manipulating Coupon/Discount Codes |
| 132 | SEC_BIZ_012 | Zero Amount Transfer Bypass |
| 133 | SEC_BIZ_013 | Circumventing KYC Verification |
| 134 | SEC_BIZ_014 | Bypassing Withdrawal Limits |
| 135 | SEC_BIZ_015 | Modifying Tax/Fee Parameters |
| 136 | SEC_BIZ_016 | Abuse of Refund Functionality |
| 137 | SEC_BIZ_017 | Bypassing Lockout Mechanisms |
| 138 | SEC_BIZ_018 | Exploiting rounding errors in currency |
| 139 | SEC_BIZ_019 | Manipulating Account Balance via Integer Overflow |
| 140 | SEC_BIZ_020 | API Versioning Downgrade Attack |
| 141 | SEC_BIZ_021 | Bypassing CAPTCHA |
| 142 | SEC_BIZ_022 | Abuse of Referral System |
| 143 | SEC_BIZ_023 | Unauthorized Cancellation of Transactions |
| 144 | SEC_BIZ_024 | Forcing State Machine Transitions |
| 145 | SEC_BIZ_025 | Exceeding Max Item Quantity in Request |
| 146 | SEC_BIZ_026 | Logic Flaw in Account Deletion |
| 147 | SEC_BIZ_027 | Webhook signature bypass |
| 148 | SEC_BIZ_028 | Time-of-Check to Time-of-Use (TOCTOU) |
| 149 | SEC_BIZ_029 | Exploiting Business Rule Order of Operations |
| 150 | SEC_BIZ_030 | Sending Payments to Self for Rewards Abuse |
</details>

### 🛡️ 6. Data Protection & Cryptography (30)
<details><summary>Click to view data protection tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 151 | SEC_DPC_001 | Insecure Storage of Sensitive Data |
| 152 | SEC_DPC_002 | Weak Hashing Algorithms (e.g., MD5) |
| 153 | SEC_DPC_003 | Lack of Salt in Password Hashes |
| 154 | SEC_DPC_004 | Cleartext Storage of Credit Card Data |
| 155 | SEC_DPC_005 | Exposure of PII in URLs |
| 156 | SEC_DPC_006 | Insecure Randomness (Math.random for tokens) |
| 157 | SEC_DPC_007 | Hardcoded Cryptographic Keys |
| 158 | SEC_DPC_008 | Failure to Encrypt Data at Rest |
| 159 | SEC_DPC_009 | Leakage of PII in App Logs |
| 160 | SEC_DPC_010 | Improper Key Management |
| 161–180 | SEC_DPC_011-030 | Assorted data protection and crypto flaws |
</details>

### 🛑 7. Denial of Service (DoS) & Rate Limiting (30)
<details><summary>Click to view DoS tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 181 | SEC_DOS_001 | Application Layer DoS (HTTP Flood) |
| 182 | SEC_DOS_002 | Regular Expression DoS (ReDoS) |
| 183 | SEC_DOS_003 | Large Payload DoS (Unrestricted Size) |
| 184 | SEC_DOS_004 | XML Bomb (Billion Laughs Attack) |
| 185 | SEC_DOS_005 | Resource Exhaustion via File Uploads |
| 186 | SEC_DOS_006 | API Rate Limit Evasion via X-Forwarded-For |
| 187 | SEC_DOS_007 | Account Lockout DoS |
| 188 | SEC_DOS_008 | Cache Poisoning DoS |
| 189 | SEC_DOS_009 | Expensive Database Query Execution |
| 190 | SEC_DOS_010 | Async Task Exhaustion |
| 191–210 | SEC_DOS_011-030 | Concurrency and queue exhaustion tests |
</details>

### 🕸️ 8. API Security & Webhooks (30)
<details><summary>Click to view API security tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 211 | SEC_API_001 | Unauthenticated API Endpoint Exposure |
| 212 | SEC_API_002 | Webhook Forgery |
| 213 | SEC_API_003 | Missing Signature on Webhooks |
| 214 | SEC_API_004 | API Parameter Pollution |
| 215 | SEC_API_005 | GraphQL Introspection Enabled |
| 216 | SEC_API_006 | GraphQL Query Depth Exhaustion |
| 217 | SEC_API_007 | Missing Content-Type Validation |
| 218 | SEC_API_008 | REST Verb Tampering (e.g., HEAD instead of GET) |
| 219 | SEC_API_009 | Insecure API Versioning |
| 220 | SEC_API_010 | SOAP Action Spoofing |
| 221–240 | SEC_API_011-030 | Diverse API misuse and exploitation tests |
</details>

### 🖥️ 9. Server Security & Infrastructure (30)
<details><summary>Click to view infrastructure tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 241 | SEC_INF_001 | Subdomain Takeover |
| 242 | SEC_INF_002 | Missing DMARC/SPF Records |
| 243 | SEC_INF_003 | Insecure Cloud Storage Bucket Policies |
| 244 | SEC_INF_004 | Misconfigured Reverse Proxy |
| 245 | SEC_INF_005 | Cloud Instance Metadata SSRF |
| 246 | SEC_INF_006 | Missing Network Segmentation |
| 247 | SEC_INF_007 | Insecure Container Configurations |
| 248 | SEC_INF_008 | Vulnerable Server Software |
| 249 | SEC_INF_009 | SSH Key Exposure |
| 250 | SEC_INF_010 | Outdated SSL Certificates |
| 251–270 | SEC_INF_011-030 | Network layout, proxy, and container flaws |
</details>

### ⚖️ 10. Load & Performance Edge Cases (30)
<details><summary>Click to view load edge case tests</summary>

| # | Test ID | Description |
|---|---------|-------------|
| 271 | SEC_LOD_001 | Database Deadlocks under Load |
| 272 | SEC_LOD_002 | API Timeout Cascading Failures |
| 273 | SEC_LOD_003 | Memory Leaks during Sustained Load |
| 274 | SEC_LOD_004 | Socket Exhaustion |
| 275 | SEC_LOD_005 | Connection Pool Depletion |
| 276 | SEC_LOD_006 | File Descriptor Exhaustion |
| 277 | SEC_LOD_007 | Background Worker Queue Overflow |
| 278 | SEC_LOD_008 | Slowloris Attack Vulnerability |
| 279 | SEC_LOD_009 | Cache Stampede under Spikes |
| 280 | SEC_LOD_010 | Third-party API Throttling Impact |
| 281 | SEC_LOD_011 | UI Unresponsiveness during High Latency |
| 282 | SEC_LOD_012 | Partial Outage Recovery Time |
| 283 | SEC_LOD_013 | DNS Resolution Bottlenecks |
| 284 | SEC_LOD_014 | High CPU causing Dropped Requests |
| 285 | SEC_LOD_015 | Thread Starvation |
| 286 | SEC_LOD_016 | Lock Contention in Shared Resources |
| 287 | SEC_LOD_017 | Read/Write Replica Replication Lag |
| 288 | SEC_LOD_018 | Load Balancer Saturation |
| 289 | SEC_LOD_019 | Disk I/O Bottlenecks |
| 290 | SEC_LOD_020 | Redis/Memcached Eviction Policies |
| 291 | SEC_LOD_021 | Event Loop Blocking (Node.js/Async) |
| 292 | SEC_LOD_022 | Network Bandwidth Saturation |
| 293 | SEC_LOD_023 | Session Store Exhaustion |
| 294 | SEC_LOD_024 | Orphaned Connections Handling |
| 295 | SEC_LOD_025 | Garbage Collection Pauses (GC Thrashing) |
| 296 | SEC_LOD_026 | Log File Rotation Delays |
| 297 | SEC_LOD_027 | Web Server Max Clients Hit |
| 298 | SEC_LOD_028 | Payment Gateway Timeout handling |
| 299 | SEC_LOD_029 | Unbounded Pagination queries |
| 300 | SEC_LOD_030 | Downstream Service Circuit Breaker Tripped |
</details>

---

## 📈 LOAD & PERFORMANCE TESTS (k6 Scenarios)

### Baseline Load Scenario
Testing the system under a normal, expected amount of concurrent users.
The goal is to ensure response times stay fast.

| Metric | Result | Target | Status |
|--------|--------|--------|--------|
| Virtual Users | 100 | 100 | ✅ |
| Test Duration | 1m | 1m | ✅ |
| Total Requests | 7,200 | N/A | ✅ |
| Requests per second (RPS) | ~120 req/sec | >100 | ✅ |
| Fastest Response (Min) | 50ms | N/A | ✅ |
| Average Response Time | 250ms | <500ms | ✅ |
| P95 Response Time | 1200ms | <1500ms | ✅ |
| Slowest Response (Max) | 1500ms | N/A | ✅ |
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
