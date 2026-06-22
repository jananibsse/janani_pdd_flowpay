import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bank_account.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/flow_pay_button.dart';
import '../widgets/menu_tile.dart';
import '../widgets/screen_header.dart';
import 'help_support_screen.dart';
import 'notifications_screen.dart';
import 'security_center_screen.dart';
import 'settings_screen.dart';
import 'bank_link_screen.dart';
import 'withdraw_to_bank_screen.dart';
import 'withdrawal_history_screen.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.authService,
    required this.walletService,
    required this.notificationService,
    this.embedded = false,
  });

  final AuthService authService;
  final WalletService walletService;
  final NotificationService notificationService;
  final bool embedded;

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  Future<void> _copyWalletId(BuildContext context, String uid) async {
    await Clipboard.setData(ClipboardData(text: uid));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet ID copied to clipboard.')),
    );
  }

  String _formatMemberSince(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Recently joined';
    }
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  int _calculateSecurityScore(bool pinSet, bool bankLinked, bool emailVerified) {
    int score = 0;
    if (pinSet) score += 40;
    if (bankLinked) score += 30;
    if (emailVerified) score += 30;
    return score;
  }

  String _securityScoreLabel(int score) {
    if (score >= 85) {
      return 'Strong ($score/100)';
    }
    if (score >= 70) {
      return 'Good ($score/100)';
    }
    return 'Needs Attention ($score/100)';
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    final body = AsyncStateView(
      isLoading: user == null,
      hasError: false,
      isEmpty: false,
      loadingMessage: 'Loading profile...',
      child: user == null
          ? const SizedBox.shrink()
          : StreamBuilder<WalletUser?>(
              stream: walletService.watchWallet(user.uid),
              builder: (context, walletSnapshot) {
                return StreamBuilder<List<WalletTransaction>>(
                  stream: walletService.watchTransactions(user.uid, limit: 100),
                  builder: (context, txSnapshot) {
                    return StreamBuilder<BankAccount?>(
                      stream: walletService.watchPrimaryBankAccount(user.uid),
                      builder: (context, primaryBankSnapshot) {
                        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('admins').doc(user.uid).snapshots(),
                          builder: (context, adminSnapshot) {
                            final walletLoading = walletSnapshot.connectionState == ConnectionState.waiting && !walletSnapshot.hasData;
                            final txLoading = txSnapshot.connectionState == ConnectionState.waiting && !txSnapshot.hasData;

                            if (walletSnapshot.hasError || txSnapshot.hasError) {
                              return const AsyncStateView(
                                isLoading: false,
                                hasError: true,
                                isEmpty: false,
                                errorMessage: 'Unable to load profile data.',
                                child: SizedBox.shrink(),
                              );
                            }

                            if (walletLoading || txLoading) {
                              return const AsyncStateView(
                                isLoading: true,
                                hasError: false,
                                isEmpty: false,
                                loadingMessage: 'Loading profile...',
                                child: SizedBox.shrink(),
                              );
                            }

                            final wallet = walletSnapshot.data;
                            final transactionCount = txSnapshot.data?.length ?? 0;
                            final email = wallet?.email ?? user.email ?? 'No email';
                            final phone = wallet?.phone ?? 'No phone number';
                            final isBankLinked = wallet?.isBankLinked ?? false;
                            final primaryBank = primaryBankSnapshot.data;
                            final isAdmin = adminSnapshot.data?.exists ?? false;

                            final pinSet = wallet?.walletPinHash != null && wallet!.walletPinHash!.isNotEmpty;
                            final emailVerified = authService.currentFirebaseUser?.emailVerified ?? false;
                            final scoreVal = _calculateSecurityScore(pinSet, isBankLinked, emailVerified);
                            final scoreLabel = _securityScoreLabel(scoreVal);

                            return _ProfileContent(
                              email: email,
                              phone: phone,
                              displayName: user.displayName ?? email.split('@').first,
                              isBankLinked: isBankLinked,
                              primaryBank: primaryBank,
                              walletId: user.uid,
                              balance: wallet?.balance ?? 0,
                              transactionCount: transactionCount,
                              memberSince: _formatMemberSince(wallet?.createdAt),
                              securityScore: scoreLabel,
                              isAdmin: isAdmin,
                              onCopyWalletId: () => _copyWalletId(context, user.uid),
                              onLogout: () => authService.signOut(),
                              onSettings: () => _open(context, const SettingsScreen()),
                              onHelp: () => _open(context, const HelpSupportScreen()),
                              onNotifications: () => _open(
                                context,
                                NotificationsScreen(
                                  authService: authService,
                                  notificationService: notificationService,
                                ),
                              ),
                              onSecurity: () => _open(
                                context,
                                SecurityCenterScreen(
                                  authService: authService,
                                  walletService: walletService,
                                ),
                              ),
                              onLinkBank: () => _open(
                                context,
                                BankLinkScreen(
                                  authService: authService,
                                  walletService: walletService,
                                ),
                              ),
                              onWithdrawFunds: () => _open(
                                context,
                                WithdrawToBankScreen(
                                  authService: authService,
                                  walletService: walletService,
                                ),
                              ),
                              onWithdrawalHistory: () => _open(
                                context,
                                WithdrawalHistoryScreen(
                                  authService: authService,
                                  walletService: walletService,
                                ),
                              ),
                              onAdminDashboard: () => _open(
                                context,
                                AdminDashboardScreen(
                                  authService: authService,
                                  walletService: walletService,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(
            title: 'Profile',
            subtitle: 'Account, settings, and security',
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: body,
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.email,
    required this.phone,
    required this.displayName,
    required this.isBankLinked,
    required this.primaryBank,
    required this.walletId,
    required this.balance,
    required this.transactionCount,
    required this.memberSince,
    required this.securityScore,
    required this.isAdmin,
    required this.onCopyWalletId,
    required this.onLogout,
    required this.onSettings,
    required this.onHelp,
    required this.onNotifications,
    required this.onSecurity,
    required this.onLinkBank,
    required this.onWithdrawFunds,
    required this.onWithdrawalHistory,
    required this.onAdminDashboard,
  });

  final String email;
  final String phone;
  final String displayName;
  final bool isBankLinked;
  final BankAccount? primaryBank;
  final String walletId;
  final double balance;
  final int transactionCount;
  final String memberSince;
  final String securityScore;
  final bool isAdmin;
  final VoidCallback onCopyWalletId;
  final VoidCallback onLogout;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onNotifications;
  final VoidCallback onSecurity;
  final VoidCallback onLinkBank;
  final VoidCallback onWithdrawFunds;
  final VoidCallback onWithdrawalHistory;
  final VoidCallback onAdminDashboard;

  @override
  Widget build(BuildContext context) {
    final primaryBankLabel = primaryBank != null
        ? '${primaryBank!.bankName} ****${primaryBank!.accountLast4}'
        : 'Not Linked';
    final primaryUpiId = primaryBank?.upiId ?? 'Not Linked';
    final bankStatusLabel = isBankLinked ? 'Linked' : 'Not Linked';

    return SingleChildScrollView(
      padding: AppTheme.pagePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppTheme.contentMaxWidth(context),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.glowCard(accent: AppColors.purpleAccent),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.cyanAccent.withValues(alpha: 0.35),
                            AppColors.purpleAccent.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Balance: ₹${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Linked Bank Account Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.panel().copyWith(
                  border: Border.all(
                    color: isBankLinked
                        ? AppColors.cyanAccent.withValues(alpha: 0.25)
                        : Colors.white12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_rounded, color: AppColors.cyanAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Primary Bank Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _buildDetailRow('Primary Bank', primaryBankLabel),
                    const SizedBox(height: 8),
                    _buildDetailRow('UPI ID', primaryUpiId),
                    const SizedBox(height: 8),
                    _buildDetailRow('Bank Status', bankStatusLabel),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _InfoTile(icon: Icons.phone_outlined, label: 'Phone Number', value: phone),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.badge_outlined,
                label: 'Wallet ID',
                value: walletId,
                trailing: IconButton(
                  tooltip: 'Copy wallet ID',
                  onPressed: onCopyWalletId,
                  icon: const Icon(Icons.copy_rounded, color: AppColors.cyanAccent),
                ),
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.receipt_long_outlined,
                label: 'Total transactions',
                value: '$transactionCount',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.calendar_month_outlined,
                label: 'Member since',
                value: memberSince,
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.shield_outlined,
                label: 'Security score',
                value: securityScore,
              ),
              const SizedBox(height: 20),

              // About FlowPay Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.panel(),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About FlowPay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Version 2.0', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 6),
                    Text(
                      'Powered by:',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Flutter • Firebase • Firestore • Razorpay',
                      style: TextStyle(color: AppColors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: AppColors.purpleAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Offline Wallet Synchronization Enabled',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              MenuTile(
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'Notifications, privacy, and preferences',
                onTap: onSettings,
              ),
              MenuTile(
                icon: Icons.account_balance_rounded,
                title: 'Linked Bank Accounts',
                subtitle: isBankLinked ? 'Manage your linked bank accounts' : 'Link your bank account to FlowPay',
                accent: AppColors.cyanAccent,
                onTap: onLinkBank,
              ),
              MenuTile(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Withdraw Funds',
                subtitle: 'Withdraw money from wallet to your bank',
                accent: AppColors.purpleAccent,
                onTap: onWithdrawFunds,
              ),
              MenuTile(
                icon: Icons.history_rounded,
                title: 'Withdrawal History',
                subtitle: 'View your withdrawal request history',
                accent: AppColors.cyanAccent,
                onTap: onWithdrawalHistory,
              ),
              MenuTile(
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Payment alerts and sync updates',
                accent: AppColors.purpleAccent,
                onTap: onNotifications,
              ),
              MenuTile(
                icon: Icons.shield_rounded,
                title: 'Security Center',
                subtitle: '2FA, sessions, and payment protection',
                onTap: onSecurity,
              ),
              MenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'FAQs and contact options',
                accent: AppColors.purpleAccent,
                onTap: onHelp,
              ),
              if (isAdmin)
                MenuTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin Dashboard',
                  subtitle: 'Manage withdrawals and users',
                  accent: AppColors.cyanAccent,
                  onTap: onAdminDashboard,
                ),
              const SizedBox(height: 16),
              FlowPayButton(
                label: 'Logout',
                backgroundColor: AppColors.purpleAccent,
                foregroundColor: Colors.white,
                onPressed: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panel(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cyanAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
