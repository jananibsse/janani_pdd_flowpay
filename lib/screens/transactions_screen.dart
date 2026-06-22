import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({
    super.key,
    required this.authService,
    required this.walletService,
    this.embedded = false,
  });

  final AuthService authService;
  final WalletService walletService;
  final bool embedded;

  static const int _transactionLimit = 50;

  String _formatAmount(double amount) => '₹${amount.toStringAsFixed(2)}';

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Just now';
    }
    
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year • $hour:$minute';
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'success':
        badgeColor = AppColors.cyanAccent.withValues(alpha: 0.15);
        textColor = AppColors.cyanAccent;
        break;
      case 'failed':
        badgeColor = Colors.redAccent.withValues(alpha: 0.15);
        textColor = Colors.redAccent;
        break;
      case 'pending':
      default:
        badgeColor = AppColors.purpleAccent.withValues(alpha: 0.15);
        textColor = AppColors.purpleAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBody(String uid) {
    return StreamBuilder<List<WalletTransaction>>(
      stream: walletService.watchTransactions(uid, limit: _transactionLimit),
      builder: (context, snapshot) {
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData;
        final hasError = snapshot.hasError;
        final transactions = snapshot.data ?? [];

        return AsyncStateView(
          isLoading: isLoading,
          hasError: hasError,
          isEmpty: !hasError && transactions.isEmpty,
          emptyTitle: 'No transactions yet',
          emptyMessage: 'Send money or link your bank account to create activity.',
          emptyIcon: Icons.receipt_long_outlined,
          errorMessage:
              'Unable to load transactions. Check your connection and try again.',
          child: ListView.separated(
            padding: AppTheme.pagePadding(context),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isCredit = transaction.isCredit;
              final color = isCredit ? AppColors.cyanAccent : AppColors.error;
              final prefix = isCredit ? '+' : '-';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.panel(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCredit
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: color,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              transaction.typeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$prefix${_formatAmount(transaction.amount)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (transaction.description.isNotEmpty) ...[
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: ${transaction.id.length > 10 ? transaction.id.substring(0, 10) : transaction.id}',
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatTime(transaction.createdAt),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(transaction.status),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    final content = AsyncStateView(
      isLoading: user == null,
      hasError: false,
      isEmpty: false,
      loadingMessage: 'Loading transactions...',
      child: user == null ? const SizedBox.shrink() : _buildBody(user.uid),
    );

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppTheme.pagePadding(context).copyWith(bottom: 8),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your real wallet activity from Firestore',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppTheme.contentMaxWidth(context),
                ),
                child: content,
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transactions')),
      body: content,
    );
  }
}

