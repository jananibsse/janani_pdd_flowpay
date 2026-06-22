/// EmailJS Configuration
///
/// ─────────────────────────────────────────────────────────────────────────
/// FREE PLAN: Only 2 templates needed (one for payments, one for withdrawals)
/// ─────────────────────────────────────────────────────────────────────────
///
/// SETUP STEPS:
///
/// 1. Sign up at https://www.emailjs.com (free Spark plan: 200 emails/month)
///
/// 2. Add Gmail Email Service:
///    Dashboard → Email Services → Add New Service → Gmail
///    Copy the Service ID (e.g. service_xxxxxxx)
///
/// 3. Create Template 1 — "FlowPay Transaction"  (for payments sent/received)
///    Dashboard → Email Templates → Create New Template
///    → To Email:  {{to_email}}
///    → Subject:   {{subject}}
///    → Body (HTML):
///
///      <p>Hi {{to_name}},</p>
///      <p>{{title}}</p>
///      <p>{{message_body}}</p>
///      <p>{{extra_note}}</p>
///      <p>— FlowPay Team</p>
///
///    Copy its Template ID.
///
/// 4. Create Template 2 — "FlowPay Withdrawal"  (for all withdrawal events)
///    Same body as Template 1 is fine — or you can style it differently.
///    Copy its Template ID.
///
/// 5. Enable REST API:
///    Dashboard → Account → Security → REST API → Enable
///
/// 6. Get your Public Key:
///    Dashboard → Account → General → Public Key
///
/// 7. Fill in the values below.
/// ─────────────────────────────────────────────────────────────────────────
class EmailConfig {
  // ── Your EmailJS Public Key (NOT the private Access Token) ────────────────
  static const String publicKey = 'YOUR_EMAILJS_PUBLIC_KEY';

  // ── Email Service ID ──────────────────────────────────────────────────────
  static const String serviceId = 'YOUR_SERVICE_ID';

  // ── Template 1: used for payment sent & payment received ──────────────────
  static const String templateTransaction = 'YOUR_TRANSACTION_TEMPLATE_ID';

  // ── Template 2: used for withdrawal submitted, approved & rejected ────────
  static const String templateWithdrawal = 'YOUR_WITHDRAWAL_TEMPLATE_ID';

  // ── Sender display name ───────────────────────────────────────────────────
  static const String senderName = 'FlowPay';

  // ── EmailJS REST endpoint (do not change) ─────────────────────────────────
  static const String apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';
}
