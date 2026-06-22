# FlowPay — Backend Inventory
> Last Updated: 2026-06-22 | Environment: Firebase (Google Cloud)

---

## Services Inventory

### 1. Firebase Authentication
| Attribute | Detail |
|-----------|--------|
| **Provider** | Firebase / Google Cloud |
| **Service** | Firebase Authentication v2 |
| **Methods** | Email/Password, (Google OAuth — optional) |
| **Session Tokens** | Firebase JWT (1-hour expiry, auto-refresh) |
| **MFA** | Not currently enabled |
| **Rate Limiting** | Firebase built-in (100 req/s per IP) |
| **Endpoint** | `https://identitytoolkit.googleapis.com` |

---

### 2. Cloud Firestore
| Attribute | Detail |
|-----------|--------|
| **Provider** | Firebase / Google Cloud |
| **Database Type** | NoSQL Document Store |
| **Region** | asia-south1 (Mumbai) / Default |
| **Security** | Firestore Security Rules v2 |
| **Real-time** | Yes — Firestore listeners |
| **Offline** | Yes — Local cache enabled |

#### Collections
| Collection | Purpose | Access |
|-----------|---------|--------|
| `users/{uid}` | User profiles | Auth-scoped |
| `wallets/{uid}` | Wallet balance + PIN hash | Auth-scoped |
| `transactions/{txId}` | Payment records | Sender/Receiver scoped |
| `notifications/{uid}/items/{id}` | In-app notifications | Auth-scoped |
| `withdrawals/{uid}/history/{id}` | Bank withdrawal requests | Auth-scoped |
| `banks/{uid}` | Linked bank accounts | Auth-scoped |
| `offline_transactions/{uid}` | Pending offline sync | Auth-scoped |
| `admin_data/{docId}` | Admin-only analytics | Admin-scoped |

---

### 3. Firebase Storage
| Attribute | Detail |
|-----------|--------|
| **Provider** | Firebase / Google Cloud |
| **Use** | Profile pictures, QR images |
| **Access** | Auth-scoped bucket rules |
| **Max File Size** | 5MB (enforced in rules) |
| **CORS** | Configured for app domains |

---

### 4. Razorpay Payment Gateway
| Attribute | Detail |
|-----------|--------|
| **Provider** | Razorpay |
| **Integration** | `razorpay_flutter` v1.3.x |
| **Payment Methods** | UPI, Cards, Net Banking, Wallets |
| **Currency** | INR |
| **Mode** | Test (to be switched to Live before launch) |
| **Webhook** | Not configured — RECOMMENDED |
| **Security Risk** | API key in client code — needs Cloud Functions |

---

### 5. Email Service
| Attribute | Detail |
|-----------|--------|
| **Provider** | Custom `EmailService` class |
| **Purpose** | Transaction confirmations |
| **Backend** | Firebase Cloud Functions (recommended) |
| **Current Implementation** | `lib/services/email_service.dart` |

---

## Application Screens Inventory (23 Screens)

| Screen | File | Route | Auth Required |
|--------|------|-------|--------------|
| Splash | `splash_screen.dart` | `/` | No |
| Login | `login_screen.dart` | `/login` | No |
| Register | `register_screen.dart` | `/register` | No |
| Home | `home_screen.dart` | `/home` | Yes |
| Send Money | `send_money_screen.dart` | `/send` | Yes |
| Transactions | `transactions_screen.dart` | `/transactions` | Yes |
| Notifications | `notifications_screen.dart` | `/notifications` | Yes |
| Profile | `profile_screen.dart` | `/profile` | Yes |
| Settings | `settings_screen.dart` | `/settings` | Yes |
| Security Center | `security_center_screen.dart` | `/security` | Yes |
| Help & Support | `help_support_screen.dart` | `/help` | Yes |
| Bank Link | `bank_account_link_screen.dart` | `/bank` | Yes |
| Withdrawal | `withdraw_to_bank_screen.dart` | `/withdraw` | Yes |
| Withdrawal History | `withdrawal_history_screen.dart` | `/withdrawals` | Yes |
| Scan QR | `scan_qr_screen.dart` | `/scan` | Yes |
| Personal QR | `personal_qr_screen.dart` | `/qr` | Yes |
| Analytics | `analytics_screen.dart` | `/analytics` | Admin |
| Offline TX | `offline_transactions_screen.dart` | `/offline` | Yes |
| Admin Dashboard | `admin_dashboard_screen.dart` | `/admin` | Admin |
| Set Wallet PIN | `set_wallet_pin_screen.dart` | `/pin/set` | Yes |
| PIN Verification | `wallet_pin_verification_screen.dart` | `/pin/verify` | Yes |
| Receiver Preview | `receiver_profile_preview_screen.dart` | `/receiver` | Yes |
| QR Payment | `qr_payment_screen.dart` | `/qr-pay` | Yes |

---

## Services Inventory (Dart)

| Service | File | Purpose |
|---------|------|---------|
| `AuthService` | `auth_service.dart` | Firebase Auth wrapper |
| `WalletService` | `wallet_service.dart` | Balance, transactions, PIN |
| `NotificationService` | `notification_service.dart` | In-app + push notifications |
| `EmailService` | `email_service.dart` | Email confirmations |
| `PaymentService` | `payment_service.dart` | Razorpay integration |
| `QrService` | (Planned) | QR code validation |

---

## Models Inventory

| Model | File | Purpose |
|-------|------|---------|
| `WalletUser` | `wallet_user.dart` | User profile |
| `WalletTransaction` | `wallet_transaction.dart` | Transaction record |
| `QrPaymentPayload` | `qr_payment_payload.dart` | QR scan payload |
| `FlowPayNotification` | `flowpay_notification.dart` | Notification data |

---

## Third-Party API Endpoints

| Service | Endpoint | Protocol | Auth |
|---------|----------|----------|------|
| Firebase Auth | `identitytoolkit.googleapis.com` | HTTPS | API Key |
| Firestore | `firestore.googleapis.com` | HTTPS | OAuth2 |
| Firebase Storage | `storage.googleapis.com` | HTTPS | OAuth2 |
| Razorpay API | `api.razorpay.com` | HTTPS | API Key |
| Google Fonts | `fonts.googleapis.com` | HTTPS | None |
