import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/email_config.dart';

/// EmailService sends transactional emails via the EmailJS REST API.
///
/// Uses only 2 templates (compatible with EmailJS free Spark plan):
///   • templateTransaction  → payment sent & payment received
///   • templateWithdrawal   → withdrawal submitted, approved & rejected
///
/// All message content is built in Dart and passed as template_params,
/// so both templates can use a simple universal body like:
///
///   <p>Hi {{to_name}},</p>
///   <p>{{title}}</p>
///   <p>{{message_body}}</p>
///   <p>{{extra_note}}</p>
///   <p>— FlowPay Team</p>
class EmailService {
  EmailService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;

  // ── Core: POST to EmailJS REST endpoint ───────────────────────────────────

  Future<void> _send({
    required String templateId,
    required Map<String, String> params,
  }) async {
    // Skip silently until credentials are configured.
    if (EmailConfig.publicKey == 'YOUR_EMAILJS_PUBLIC_KEY' ||
        EmailConfig.serviceId == 'YOUR_SERVICE_ID' ||
        templateId == 'YOUR_TRANSACTION_TEMPLATE_ID' ||
        templateId == 'YOUR_WITHDRAWAL_TEMPLATE_ID') {
      return;
    }

    final response = await _client.post(
      Uri.parse(EmailConfig.apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': EmailConfig.serviceId,
        'template_id': templateId,
        'user_id': EmailConfig.publicKey,
        'template_params': params,
      }),
    );

    if (response.statusCode != 200) {
      throw EmailServiceException(
        'EmailJS ${response.statusCode}: ${response.body}',
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  // ── Payment Emails (Template 1: templateTransaction) ─────────────────────

  Future<void> sendPaymentSentEmail({
    required String toEmail,
    required String userName,
    required String amount,
    required String receiverPhone,
    required String transactionId,
    required DateTime timestamp,
  }) async {
    await _send(
      templateId: EmailConfig.templateTransaction,
      params: {
        'to_email': toEmail,
        'to_name': userName,
        'subject': 'Payment Sent – Rs. $amount | FlowPay',
        'title': 'Your payment of Rs. $amount was sent successfully.',
        'message_body':
            'Sent to: $receiverPhone\n'
            'Transaction ID: $transactionId\n'
            'Date & Time: ${_fmt(timestamp)}',
        'extra_note':
            'If you did not authorize this, contact support immediately.',
      },
    );
  }

  Future<void> sendPaymentReceivedEmail({
    required String toEmail,
    required String userName,
    required String amount,
    required String senderPhone,
    required String transactionId,
    required DateTime timestamp,
  }) async {
    await _send(
      templateId: EmailConfig.templateTransaction,
      params: {
        'to_email': toEmail,
        'to_name': userName,
        'subject': 'Payment Received – Rs. $amount | FlowPay',
        'title': 'You received Rs. $amount into your FlowPay wallet.',
        'message_body':
            'Received from: $senderPhone\n'
            'Transaction ID: $transactionId\n'
            'Date & Time: ${_fmt(timestamp)}',
        'extra_note': 'This amount has been credited to your wallet.',
      },
    );
  }

  // ── Withdrawal Emails (Template 2: templateWithdrawal) ───────────────────

  Future<void> sendWithdrawalSubmittedEmail({
    required String toEmail,
    required String userName,
    required String amount,
    required String bankName,
    required String accountLast4,
    required String upiId,
    required String withdrawalId,
    required DateTime timestamp,
  }) async {
    await _send(
      templateId: EmailConfig.templateWithdrawal,
      params: {
        'to_email': toEmail,
        'to_name': userName,
        'subject': 'Withdrawal Submitted – Rs. $amount | FlowPay',
        'title': 'Your withdrawal request of Rs. $amount has been submitted.',
        'message_body':
            'Bank: $bankName\n'
            'Account: **** $accountLast4\n'
            'UPI ID: $upiId\n'
            'Reference ID: $withdrawalId\n'
            'Submitted On: ${_fmt(timestamp)}\n'
            'Status: Pending Review',
        'extra_note':
            'Your request is under review. You will be notified once approved or rejected (1–2 business days).',
      },
    );
  }

  Future<void> sendWithdrawalApprovedEmail({
    required String toEmail,
    required String userName,
    required String amount,
    required String bankName,
    required String accountLast4,
    required String upiId,
    required String withdrawalId,
  }) async {
    await _send(
      templateId: EmailConfig.templateWithdrawal,
      params: {
        'to_email': toEmail,
        'to_name': userName,
        'subject': 'Withdrawal Approved – Rs. $amount | FlowPay',
        'title': 'Great news! Your withdrawal of Rs. $amount has been APPROVED.',
        'message_body':
            'Bank: $bankName\n'
            'Account: **** $accountLast4\n'
            'UPI ID: $upiId\n'
            'Reference ID: $withdrawalId\n'
            'Status: Approved',
        'extra_note':
            'Funds will be credited to your bank account within 1–3 business days via NEFT/IMPS.',
      },
    );
  }

  Future<void> sendWithdrawalRejectedEmail({
    required String toEmail,
    required String userName,
    required String amount,
    required String bankName,
    required String accountLast4,
    required String withdrawalId,
  }) async {
    await _send(
      templateId: EmailConfig.templateWithdrawal,
      params: {
        'to_email': toEmail,
        'to_name': userName,
        'subject': 'Withdrawal Rejected – Rs. $amount Refunded | FlowPay',
        'title': 'Your withdrawal of Rs. $amount has been rejected.',
        'message_body':
            'Bank: $bankName\n'
            'Account: **** $accountLast4\n'
            'Reference ID: $withdrawalId\n'
            'Status: Rejected\n'
            'Refund: Rs. $amount returned to your FlowPay wallet.',
        'extra_note':
            'Contact support if you believe this was an error.',
      },
    );
  }
}

class EmailServiceException implements Exception {
  EmailServiceException(this.message);
  final String message;
  @override
  String toString() => 'EmailServiceException: $message';
}
