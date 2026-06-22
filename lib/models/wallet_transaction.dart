import 'package:cloud_firestore/cloud_firestore.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
    this.status = 'success',
    this.direction = 'credit',
    this.paymentMode,
    this.razorpayPaymentId,
  });

  final String id;
  final double amount;
  final String type;
  final String description;
  final DateTime? createdAt;
  final String status;
  final String direction;
  final String? paymentMode;
  final String? razorpayPaymentId;

  bool get isCredit => direction == 'credit' || type == 'credit' || type == 'add_money';

  bool get isAddMoney => type == 'add_money' || (type == 'credit' && description == 'Added money');

  bool get isPaymentSent => direction == 'debit' || type == 'debit';

  bool get isPaymentReceived => isCredit && !isAddMoney;

  String get typeLabel {
    switch (type) {
      case 'add_money':
        return 'Add Money';
      case 'wallet_transfer':
        return 'Wallet Transfer';
      case 'offline_transfer':
        return 'Offline Transfer';
      case 'withdrawal':
        return 'Withdrawal Request';
      default:
        if (description.toLowerCase().contains('added') || description.toLowerCase().contains('add from bank')) {
          return 'Add Money';
        } else if (description.toLowerCase().contains('transfer to bank')) {
          return 'Withdrawal Request';
        } else if (description.toLowerCase().contains('offline')) {
          return 'Offline Transfer';
        } else {
          return 'Wallet Transfer';
        }
    }
  }

  factory WalletTransaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawType = data['type'] as String? ?? 'credit';
    
    // Determine direction
    String dir = 'credit';
    if (rawType == 'debit' || rawType == 'withdrawal') {
      dir = 'debit';
    } else if (rawType == 'credit' || rawType == 'add_money') {
      dir = 'credit';
    } else {
      dir = data['direction'] as String? ?? 'credit';
    }

    return WalletTransaction(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: rawType,
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'success',
      direction: dir,
      paymentMode: data['paymentMode'] as String?,
      razorpayPaymentId: data['razorpayPaymentId'] as String?,
    );
  }
}

