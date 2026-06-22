import 'dart:convert';

class QrPaymentPayload {
  const QrPaymentPayload({
    required this.type,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.walletId,
    required this.upiId,
  });

  final String type;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String walletId;
  final String upiId;

  Map<String, dynamic> toJson() => {
        'type': type,
        'userId': userId,
        'name': name,
        'phone': phone,
        'email': email,
        'walletId': walletId,
        'upiId': upiId,
      };

  String encode() => jsonEncode(toJson());

  factory QrPaymentPayload.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'flowpay_user';
    final userId = json['userId'] as String? ?? json['uid'] as String? ?? '';
    final name = json['name'] as String? ?? 'FlowPay User';
    final phone = json['phone'] as String? ?? '';
    final email = json['email'] as String? ?? '';
    final walletId = json['walletId'] as String? ?? json['uid'] as String? ?? '';
    final upiId = json['upiId'] as String? ?? '';

    if (userId.isEmpty) {
      throw const FormatException('Invalid QR payload: missing userId.');
    }

    return QrPaymentPayload(
      type: type,
      userId: userId,
      name: name,
      phone: phone,
      email: email,
      walletId: walletId,
      upiId: upiId,
    );
  }

  static QrPaymentPayload? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw.trim());
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return QrPaymentPayload.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}

