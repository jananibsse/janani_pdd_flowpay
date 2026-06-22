class OfflineTransaction {
  const OfflineTransaction({
    required this.localId,
    required this.receiverPhone,
    required this.amount,
    required this.senderId,
    required this.senderPhone,
    required this.status,
    required this.createdAt,
    this.type = typeWalletToWallet,
  });

  final String localId;
  final String receiverPhone;
  final double amount;
  final String senderId;
  final String senderPhone;
  final String status;
  final DateTime createdAt;
  final String type;

  static const String pendingStatus = 'pending_sync';
  static const String syncedStatus = 'synced';

  static const String typeWalletToWallet = 'wallet_to_wallet';
  static const String typeWalletToBank = 'wallet_to_bank';
  static const String typeBankToWallet = 'bank_to_wallet';

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'receiverPhone': receiverPhone,
      'amount': amount,
      'senderId': senderId,
      'senderPhone': senderPhone,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
    };
  }

  factory OfflineTransaction.fromJson(Map<String, dynamic> json) {
    return OfflineTransaction(
      localId: json['localId'] as String,
      receiverPhone: json['receiverPhone'] as String,
      amount: (json['amount'] as num).toDouble(),
      senderId: json['senderId'] as String,
      senderPhone: json['senderPhone'] as String,
      status: json['status'] as String? ?? pendingStatus,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['type'] as String? ?? typeWalletToWallet,
    );
  }

  factory OfflineTransaction.create({
    required String receiverPhone,
    required double amount,
    required String senderId,
    required String senderPhone,
    String type = typeWalletToWallet,
  }) {
    return OfflineTransaction(
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
      receiverPhone: receiverPhone.trim(),
      amount: amount,
      senderId: senderId,
      senderPhone: senderPhone.trim(),
      status: pendingStatus,
      createdAt: DateTime.now(),
      type: type,
    );
  }
}
