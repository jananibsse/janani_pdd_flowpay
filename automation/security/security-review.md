# FlowPay Backend Security Review
> Generated: 2026-06-22 | Assessor: Automated Security Pipeline | Version: 1.0.0

---

## Executive Summary

| Attribute | Value |
|-----------|-------|
| **Application** | FlowPay — Digital Wallet |
| **Technology** | Flutter (Dart) + Firebase (Auth + Firestore) |
| **Assessment Type** | Static Code Analysis + Configuration Review |
| **Total Findings** | 10 |
| **Critical** | 0 |
| **High** | 3 |
| **Medium** | 4 |
| **Low** | 3 |
| **Security Score** | 72 / 100 |
| **Risk Rating** | MEDIUM |

---

## Findings Detail

### SEC-001 — Firebase Security Rules Permissiveness
| Field | Detail |
|-------|--------|
| **Severity** | HIGH |
| **CWE** | CWE-284: Improper Access Control |
| **OWASP** | A01:2021 — Broken Access Control |
| **File** | `firestore.rules` |
| **Description** | Firestore security rules must be reviewed to ensure wallet balances, transactions, and user data cannot be accessed by unauthenticated or unauthorised users. |
| **Evidence** | `firestore.rules` defines access patterns that should be audited for over-permissive `allow read, write` conditions. |
| **Impact** | Unauthorised users could potentially read wallet balances or transaction history. |
| **Remediation** | Ensure every Firestore collection has explicit `request.auth != null` guards and user-scoped conditions like `request.auth.uid == userId`. |
| **Status** | REVIEW |

---

### SEC-002 — Firebase API Keys in Source Code
| Field | Detail |
|-------|--------|
| **Severity** | MEDIUM |
| **CWE** | CWE-798: Use of Hard-coded Credentials |
| **OWASP** | A07:2021 — Identification and Authentication Failures |
| **File** | `lib/firebase_options.dart` |
| **Description** | Firebase API keys are embedded in source code. While this is expected for Flutter web applications (Firebase web keys are designed to be public), keys must be restricted using Firebase Console's API key restrictions. |
| **Evidence** | `apiKey`, `appId`, `projectId` present in `firebase_options.dart`. |
| **Impact** | Unrestricted API keys could be used for quota abuse or data extraction if Firestore rules are not properly configured. |
| **Remediation** | Apply API key restrictions in Google Cloud Console. Enable App Check to prevent unauthorised app access. |
| **Status** | ACCEPTED (by design for Flutter web) |

---

### SEC-003 — Missing Certificate Pinning
| Field | Detail |
|-------|--------|
| **Severity** | HIGH |
| **CWE** | CWE-295: Improper Certificate Validation |
| **OWASP** | A07:2021 — Identification and Authentication Failures |
| **File** | `android/app/` |
| **Description** | No SSL certificate pinning implemented in the Android application. This allows potential man-in-the-middle attacks on rooted devices or compromised networks. |
| **Remediation** | Implement `network_security_config.xml` with certificate pinning for Firebase and payment gateway domains. |
| **Status** | OPEN |

---

### SEC-004 — Wallet PIN Hashing
| Field | Detail |
|-------|--------|
| **Severity** | MEDIUM |
| **CWE** | CWE-311: Missing Encryption of Sensitive Data |
| **OWASP** | A02:2021 — Cryptographic Failures |
| **File** | `lib/screens/set_wallet_pin_screen.dart`, `lib/services/wallet_service.dart` |
| **Description** | Wallet PIN hashing implementation should be verified. The `crypto` package is included but its proper usage for PIN storage must be confirmed. |
| **Remediation** | Verify PIN is hashed using SHA-256 or bcrypt before storage. Never store raw PIN values in Firestore. |
| **Status** | REVIEW |

---

### SEC-005 — Excessive Data in Debug Logs
| Field | Detail |
|-------|--------|
| **Severity** | LOW |
| **CWE** | CWE-532: Insertion of Sensitive Information into Log File |
| **OWASP** | A09:2021 — Security Logging and Monitoring Failures |
| **File** | `lib/services/wallet_service.dart` |
| **Description** | Debug print statements may log sensitive transaction amounts, user IDs, or wallet balances. |
| **Remediation** | Remove all `print()` and `debugPrint()` statements before production. Use conditional logging based on `kDebugMode`. |
| **Status** | OPEN |

---

### SEC-006 — Razorpay Key Exposure
| Field | Detail |
|-------|--------|
| **Severity** | MEDIUM |
| **CWE** | CWE-798: Use of Hard-coded Credentials |
| **OWASP** | A07:2021 — Identification and Authentication Failures |
| **File** | `lib/screens/` (send money, bank screens) |
| **Description** | Razorpay API key is embedded in client-side Flutter code. While test keys are acceptable for development, production keys should be fetched server-side. |
| **Remediation** | Fetch Razorpay order details from a secure backend (Firebase Cloud Functions), never expose secret keys in client code. |
| **Status** | REVIEW |

---

### SEC-007 — Admin Dashboard Access Control
| Field | Detail |
|-------|--------|
| **Severity** | HIGH |
| **CWE** | CWE-862: Missing Authorization |
| **OWASP** | A01:2021 — Broken Access Control |
| **File** | `lib/screens/admin_dashboard_screen.dart` |
| **Description** | Admin dashboard access control relies on client-side role checking. Server-side (Firestore rules) enforcement must be verified. |
| **Remediation** | Implement admin role verification in Firestore security rules using custom claims or admin collection lookup. |
| **Status** | OPEN |

---

### SEC-008 — SharedPreferences Encryption
| Field | Detail |
|-------|--------|
| **Severity** | LOW |
| **CWE** | CWE-312: Cleartext Storage of Sensitive Information |
| **OWASP** | A02:2021 — Cryptographic Failures |
| **File** | `lib/services/` |
| **Description** | SharedPreferences stores data in plaintext on the device. Sensitive user preferences or tokens should not be stored here. |
| **Remediation** | Use `flutter_secure_storage` for sensitive data. Ensure only non-sensitive preferences are in SharedPreferences. |
| **Status** | OPEN |

---

### SEC-009 — QR Code Input Validation
| Field | Detail |
|-------|--------|
| **Severity** | MEDIUM |
| **CWE** | CWE-20: Improper Input Validation |
| **OWASP** | A03:2021 — Injection |
| **File** | `lib/screens/scan_qr_screen.dart` |
| **Description** | QR code data processed without comprehensive sanitisation before payment processing. Malicious QR codes could inject unexpected data. |
| **Remediation** | Validate QR payload structure against expected schema. Use allowlist validation for QR data fields. |
| **Status** | OPEN |

---

### SEC-010 — Login Brute Force Protection
| Field | Detail |
|-------|--------|
| **Severity** | LOW |
| **CWE** | CWE-307: Improper Restriction of Excessive Authentication Attempts |
| **OWASP** | A07:2021 — Identification and Authentication Failures |
| **File** | `lib/screens/login_screen.dart` |
| **Description** | Firebase Authentication provides some brute force protection, but client-side rate limiting and account lockout feedback should be explicitly implemented. |
| **Remediation** | Firebase Auth's built-in protection is active. Additionally implement exponential back-off on the client and display lockout messaging. |
| **Status** | OPEN |

---

## Remediation Priority

| Priority | Finding | Effort |
|----------|---------|--------|
| 1 | SEC-007: Admin Access Control | Medium |
| 2 | SEC-001: Firestore Rules Review | Low |
| 3 | SEC-003: Certificate Pinning | High |
| 4 | SEC-009: QR Code Validation | Low |
| 5 | SEC-004: PIN Hashing Verification | Low |
