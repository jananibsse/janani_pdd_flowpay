import 'package:flutter/material.dart';

import 'app_theme.dart';

class BankBalanceCard extends StatelessWidget {
  const BankBalanceCard({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.bankBalance,
    required this.onTransferToBank,
    required this.onAddFromBank,
    this.isLoading = false,
  });

  final String bankName;
  final String accountNumber;
  final double bankBalance;
  final VoidCallback onTransferToBank;
  final VoidCallback onAddFromBank;
  final bool isLoading;

  String get _maskedAccountNumber {
    final clean = accountNumber.trim();
    if (clean.length > 4) {
      return '•••• ${clean.substring(clean.length - 4)}';
    }
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glowCard(accent: AppColors.purpleAccent).copyWith(
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleAccent.withValues(alpha: 0.18),
            blurRadius: 36,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.cyanAccent.withValues(alpha: 0.08),
            blurRadius: 48,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purpleAccent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.purpleAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bankName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _maskedAccountNumber,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cyanAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.cyanAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      'LINKED',
                      style: TextStyle(
                        color: AppColors.cyanAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Simulated Bank Balance',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CircularProgressIndicator(color: AppColors.purpleAccent),
                  ),
                )
              else
                Text(
                  '₹${bankBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.purpleAccent,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    shadows: [
                      Shadow(
                        color: AppColors.purpleAccent,
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : onTransferToBank,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.purpleAccent,
                        side: const BorderSide(color: AppColors.purpleAccent, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                      label: const Text(
                        'To Bank',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading ? null : onAddFromBank,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                      label: const Text(
                        'From Bank',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
