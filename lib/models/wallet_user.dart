import 'package:cloud_firestore/cloud_firestore.dart';

class WalletUser {
  const WalletUser({
    required this.uid,
    required this.email,
    required this.phone,
    required this.balance,
    required this.createdAt,
    this.isBankLinked = false,
    this.bankName,
    this.bankAccountHolder,
    this.bankAccountNumber,
    this.bankIfsc,
    this.bankBalance,
    this.walletPinHash,
  });

  final String uid;
  final String email;
  final String phone;
  final double balance;
  final DateTime? createdAt;
  final bool isBankLinked;
  final String? bankName;
  final String? bankAccountHolder;
  final String? bankAccountNumber;
  final String? bankIfsc;
  final double? bankBalance;
  final String? walletPinHash;

  factory WalletUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return WalletUser(
      uid: data['uid'] as String? ?? doc.id,
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isBankLinked: data['isBankLinked'] as bool? ?? false,
      bankName: data['bankName'] as String?,
      bankAccountHolder: data['bankAccountHolder'] as String?,
      bankAccountNumber: data['bankAccountNumber'] as String?,
      bankIfsc: data['bankIfsc'] as String?,
      bankBalance: (data['bankBalance'] as num?)?.toDouble(),
      walletPinHash: data['walletPinHash'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'balance': balance,
      'createdAt': FieldValue.serverTimestamp(),
      'isBankLinked': isBankLinked,
      'bankName': bankName,
      'bankAccountHolder': bankAccountHolder,
      'bankAccountNumber': bankAccountNumber,
      'bankIfsc': bankIfsc,
      'bankBalance': bankBalance,
      'walletPinHash': walletPinHash,
    };
  }
}
