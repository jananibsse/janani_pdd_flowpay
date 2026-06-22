import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/wallet_analytics_summary.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_user.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../utils/insight_text_builder.dart';
import '../widgets/screen_header.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({
    super.key,
    required this.authService,
    required this.walletService,
    this.embedded = false,
  });

  final AuthService authService;
  final WalletService walletService;
  final bool embedded;

  static const int _analyticsLimit = 100;

  Widget _buildAnalyticsContent({
    required BuildContext context,
    required WalletAnalyticsSummary summary,
    required double walletBalance,
    required int offlineCount,
    required int withdrawalCount,
  }) {
    return SingleChildScrollView(
      padding: AppTheme.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat grid displaying the 6 key metrics
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatChip(
                label: 'Wallet Balance',
                value: '₹${walletBalance.toStringAsFixed(2)}',
                color: AppColors.cyanAccent,
              ),
              _StatChip(
                label: 'Total Added Money',
                value: '₹${summary.totalAddedMoney.toStringAsFixed(2)}',
                color: AppColors.cyanAccent,
              ),
              _StatChip(
                label: 'Total Sent',
                value: '₹${summary.totalSent.toStringAsFixed(2)}',
                color: Colors.redAccent,
              ),
              _StatChip(
                label: 'Total Received',
                value: '₹${summary.totalReceived.toStringAsFixed(2)}',
                color: AppColors.cyanAccent,
              ),
              _StatChip(
                label: 'Offline Sync Count',
                value: '$offlineCount',
                color: AppColors.purpleAccent,
              ),
              _StatChip(
                label: 'Withdrawal Requests',
                value: '$withdrawalCount',
                color: AppColors.purpleAccent,
              ),
            ],
          ),
          
          if (summary.totalSent > 0) ...[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Weekly Outflow Trend',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: AppTheme.glowCard(accent: AppColors.cyanAccent),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            labels[index],
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        summary.weeklySent.length,
                        (i) => FlSpot(i.toDouble(), summary.weeklySent[i]),
                      ),
                      isCurved: true,
                      color: AppColors.cyanAccent,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.cyanAccent.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          if (summary.totalSent > 0 || summary.totalReceived > 0) ...[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Funds Distribution',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.panel(),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    if (summary.totalSent > 0)
                      PieChartSectionData(
                        value: summary.totalSent,
                        color: AppColors.purpleAccent,
                        title: 'Sent',
                        radius: 50,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (summary.totalReceived > 0)
                      PieChartSectionData(
                        value: summary.totalReceived,
                        color: AppColors.cyanAccent,
                        title: 'Received',
                        radius: 50,
                        titleStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _RealInsightsPanel(summary: summary),
        ],
      ),
    );
  }

  Widget _buildDataStream(String uid) {
    return StreamBuilder<WalletUser?>(
      stream: walletService.watchWallet(uid),
      builder: (context, walletSnapshot) {
        return StreamBuilder<List<WalletTransaction>>(
          stream: walletService.watchTransactions(uid, limit: _analyticsLimit),
          builder: (context, txSnapshot) {
            return StreamBuilder<int>(
              stream: walletService.watchOfflineSyncedCount(uid),
              builder: (context, offlineSnapshot) {
                return StreamBuilder<int>(
                  stream: walletService.watchWithdrawalRequestsCount(uid),
                  builder: (context, withdrawalSnapshot) {
                    final walletLoading =
                        walletSnapshot.connectionState == ConnectionState.waiting &&
                            !walletSnapshot.hasData;
                    final txLoading =
                        txSnapshot.connectionState == ConnectionState.waiting &&
                            !txSnapshot.hasData;
                    final offlineLoading =
                        offlineSnapshot.connectionState == ConnectionState.waiting &&
                            !offlineSnapshot.hasData;
                    final withdrawalLoading =
                        withdrawalSnapshot.connectionState == ConnectionState.waiting &&
                            !withdrawalSnapshot.hasData;

                    final isLoading = walletLoading || txLoading || offlineLoading || withdrawalLoading;
                    final hasError = walletSnapshot.hasError ||
                        txSnapshot.hasError ||
                        offlineSnapshot.hasError ||
                        withdrawalSnapshot.hasError;

                    if (hasError) {
                      return AsyncStateView(
                        isLoading: false,
                        hasError: true,
                        isEmpty: false,
                        errorMessage:
                            'Unable to load analytics. Check your connection and try again.',
                        child: const SizedBox.shrink(),
                      );
                    }

                    if (isLoading) {
                      return const AsyncStateView(
                        isLoading: true,
                        hasError: false,
                        isEmpty: false,
                        loadingMessage: 'Loading analytics...',
                        child: SizedBox.shrink(),
                      );
                    }

                    final walletUser = walletSnapshot.data;
                    final transactions = txSnapshot.data ?? [];
                    final offlineCount = offlineSnapshot.data ?? 0;
                    final withdrawalCount = withdrawalSnapshot.data ?? 0;

                    final summary = WalletAnalyticsSummary.fromTransactions(
                      transactions: transactions,
                      offlineSyncedCount: offlineCount,
                    );

                    if (!summary.hasData) {
                      return const AsyncStateView(
                        isLoading: false,
                        hasError: false,
                        isEmpty: true,
                        emptyTitle: 'Not enough data yet',
                        emptyMessage: 'Complete a few transactions to generate insights.',
                        emptyIcon: Icons.insights_rounded,
                        child: SizedBox.shrink(),
                      );
                    }

                    return _buildAnalyticsContent(
                      context: context,
                      summary: summary,
                      walletBalance: walletUser?.balance ?? 0.0,
                      offlineCount: offlineCount,
                      withdrawalCount: withdrawalCount,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    final body = AsyncStateView(
      isLoading: user == null,
      hasError: false,
      isEmpty: false,
      loadingMessage: 'Loading analytics...',
      child: user == null ? const SizedBox.shrink() : _buildDataStream(user.uid),
    );

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(
            title: 'Analytics',
            subtitle: 'Insights from your real wallet activity',
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppTheme.contentMaxWidth(context),
                ),
                child: body,
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analytics')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(context)),
          child: body,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final chipWidth = width >= 700 ? 180.0 : (width - 52) / 2;

    return SizedBox(
      width: chipWidth,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.panel().copyWith(
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RealInsightsPanel extends StatelessWidget {
  const _RealInsightsPanel({required this.summary});

  final WalletAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final insights = buildInsightMessages(summary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowCard(accent: AppColors.purpleAccent, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: AppColors.cyanAccent),
              SizedBox(width: 10),
              Text(
                'Spending insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InsightRow(text: text),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.cyanAccent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

