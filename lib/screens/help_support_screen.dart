import 'package:flutter/material.dart';

import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/screen_header.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    (
      'How do I send money with QR?',
      'Open Scan QR from the dashboard, scan a FlowPay code, enter the amount, and confirm.',
    ),
    (
      'What is offline sync?',
      'Save transfers while offline. When back online, open Offline tab and tap Sync Now.',
    ),
    (
      'How do I add money?',
      'Tap Add Money on your balance card and enter the amount to top up your wallet.',
    ),
    (
      'Is my wallet secure?',
      'FlowPay uses Firebase Authentication and Firestore security rules. Visit Security Center for more.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Help & Support')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppTheme.contentMaxWidth(context),
          ),
          child: ListView(
            padding: AppTheme.pagePadding(context),
            children: [
              const ScreenHeader(
                title: 'Help & Support',
                subtitle: 'Guides, FAQs, and contact options',
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glowCard(accent: AppColors.purpleAccent),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need help?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email support@flowpay.demo or use the assistant button on any screen.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_faqs.isEmpty)
                const AsyncStateView(
                  isLoading: false,
                  hasError: false,
                  isEmpty: true,
                  emptyTitle: 'No FAQs yet',
                  emptyMessage: 'Support articles will appear here.',
                  child: SizedBox.shrink(),
                )
              else
                ..._faqs.map(
                  (faq) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: AppTheme.panel(),
                    child: ExpansionTile(
                      iconColor: AppColors.cyanAccent,
                      collapsedIconColor: Colors.white54,
                      title: Text(
                        faq.$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              faq.$2,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
