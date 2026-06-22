import 'wallet_transaction.dart';

class WalletAnalyticsSummary {
  const WalletAnalyticsSummary({
    required this.totalSent,
    required this.totalReceived,
    required this.totalAddedMoney,
    required this.transactionCount,
    required this.offlineSyncedCount,
    required this.weeklySent,
  });

  final double totalSent;
  final double totalReceived;
  final double totalAddedMoney;
  final int transactionCount;
  final int offlineSyncedCount;
  final List<double> weeklySent;

  bool get hasData => transactionCount > 0;

  double get netFlow => totalReceived + totalAddedMoney - totalSent;

  factory WalletAnalyticsSummary.fromTransactions({
    required List<WalletTransaction> transactions,
    required int offlineSyncedCount,
  }) {
    var totalSent = 0.0;
    var totalReceived = 0.0;
    var totalAddedMoney = 0.0;
    final weeklySent = List<double>.filled(7, 0);
    final now = DateTime.now();

    for (final transaction in transactions) {
      if (transaction.isAddMoney) {
        totalAddedMoney += transaction.amount;
      } else if (transaction.isPaymentSent) {
        totalSent += transaction.amount;
        final created = transaction.createdAt;
        if (created != null) {
          final diff = now.difference(created).inDays;
          if (diff >= 0 && diff < 7) {
            weeklySent[6 - diff] += transaction.amount;
          }
        }
      } else if (transaction.isPaymentReceived) {
        totalReceived += transaction.amount;
      }
    }

    return WalletAnalyticsSummary(
      totalSent: totalSent,
      totalReceived: totalReceived,
      totalAddedMoney: totalAddedMoney,
      transactionCount: transactions.length,
      offlineSyncedCount: offlineSyncedCount,
      weeklySent: weeklySent,
    );
  }
}
