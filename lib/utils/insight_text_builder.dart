import '../models/wallet_analytics_summary.dart';

List<String> buildInsightMessages(WalletAnalyticsSummary summary) {
  final insights = <String>[];
  final netFlow = summary.netFlow;

  if (summary.totalAddedMoney > 0) {
    insights.add(
      'You added ₹${summary.totalAddedMoney.toStringAsFixed(2)} to your wallet.',
    );
  }

  if (summary.totalSent > 0) {
    insights.add(
      'You sent ₹${summary.totalSent.toStringAsFixed(2)} in total.',
    );
  }

  if (summary.totalReceived > 0) {
    insights.add(
      'You received ₹${summary.totalReceived.toStringAsFixed(2)} from other users.',
    );
  }

  if (summary.transactionCount > 0) {
    insights.add(
      'You have ${summary.transactionCount} recorded wallet '
      '${summary.transactionCount == 1 ? 'activity' : 'activities'}.',
    );
  }

  if (netFlow > 0) {
    insights.add(
      'Net cash flow is positive by ₹${netFlow.toStringAsFixed(2)}.',
    );
  } else if (netFlow < 0) {
    insights.add(
      'Net cash flow is negative by ₹${netFlow.abs().toStringAsFixed(2)}.',
    );
  } else if (summary.transactionCount > 0) {
    insights.add('Net cash flow is balanced at ₹0.00.');
  }

  if (summary.offlineSyncedCount > 0) {
    final count = summary.offlineSyncedCount;
    insights.add(
      'You synced $count offline ${count == 1 ? 'transaction' : 'transactions'}.',
    );
  }

  return insights.take(5).toList();
}
