import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderPhone,
    required this.receiverPhone,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String senderPhone;
  final String receiverPhone;
  final double amount;
  final String status;
  final DateTime? createdAt;

  factory PaymentTransaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return PaymentTransaction(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      senderPhone: data['senderPhone'] as String? ?? '',
      receiverPhone: data['receiverPhone'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  bool isSentBy(String uid) => senderId == uid;
  bool isReceivedBy(String uid) => receiverId == uid;
}
