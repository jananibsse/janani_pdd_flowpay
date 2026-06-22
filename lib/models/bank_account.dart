import 'package:cloud_firestore/cloud_firestore.dart';

class BankAccount {
  const BankAccount({
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.accountLast4,
    required this.ifscCode,
    required this.upiId,
    required this.isPrimary,
    required this.createdAt,
  });

  final String id;
  final String accountHolderName;
  final String bankName;
  final String accountLast4;
  final String ifscCode;
  final String upiId;
  final bool isPrimary;
  final DateTime createdAt;

  factory BankAccount.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BankAccount(
      id: doc.id,
      accountHolderName: data['accountHolderName'] as String? ?? '',
      bankName: data['bankName'] as String? ?? '',
      accountLast4: data['accountLast4'] as String? ?? '',
      ifscCode: data['ifscCode'] as String? ?? '',
      upiId: data['upiId'] as String? ?? '',
      isPrimary: data['isPrimary'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountLast4': accountLast4,
      'ifscCode': ifscCode,
      'upiId': upiId,
      'isPrimary': isPrimary,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
