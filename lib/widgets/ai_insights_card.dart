import 'package:flutter/material.dart';

import '../models/wallet_analytics_summary.dart';
import '../models/wallet_transaction.dart';
import '../services/wallet_service.dart';
import '../utils/insight_text_builder.dart';
import 'app_theme.dart';

class AiInsightsCard extends StatelessWidget {
  const AiInsightsCard({
    super.key,
    required this.uid,
    required this.walletService,
  });

  final String uid;
  final WalletService walletService;

  static const int _insightLimit = 100;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WalletTransaction>>(
      stream: walletService.watchTransactions(uid, limit: _insightLimit),
      builder: (context, txSnapshot) {
        return StreamBuilder<int>(
          stream: walletService.watchOfflineSyncedCount(uid),
          builder: (context, offlineSnapshot) {
            final isLoading =
                (txSnapshot.connectionState == ConnectionState.waiting &&
                    !txSnapshot.hasData) ||
                (offlineSnapshot.connectionState == ConnectionState.waiting &&
                    !offlineSnapshot.hasData);
            final hasError = txSnapshot.hasError || offlineSnapshot.hasError;

            if (hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.panel(),
                child: const Text(
                  'Unable to load insights right now.',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            if (isLoading) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.glowCard(accent: AppColors.purpleAccent),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.cyanAccent,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final summary = WalletAnalyticsSummary.fromTransactions(
              transactions: txSnapshot.data ?? [],
              offlineSyncedCount: offlineSnapshot.data ?? 0,
            );

            if (!summary.hasData) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glowCard(accent: AppColors.purpleAccent),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.cyanAccent),
                        SizedBox(width: 10),
                        Text(
                          'Spending Insights',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Complete a transaction to generate personalized insights.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              );
            }

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
                      Icon(Icons.auto_awesome_rounded, color: AppColors.cyanAccent),
                      SizedBox(width: 10),
                      Text(
                        'Spending Insights',
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
          },
        );
      },
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
