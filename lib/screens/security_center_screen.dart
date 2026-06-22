import 'package:flutter/material.dart';

import '../models/wallet_user.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/flow_pay_button.dart';
import '../widgets/screen_header.dart';
import 'set_wallet_pin_screen.dart';
import 'wallet_pin_verification_screen.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  int _calculateSecurityScore(bool pinSet, bool bankLinked, bool emailVerified) {
    int score = 0;
    if (pinSet) score += 40;
    if (bankLinked) score += 30;
    if (emailVerified) score += 30;
    return score;
  }

  Future<void> _changePin(bool pinAlreadySet) async {
    final user = widget.authService.currentUser;
    if (user == null) return;

    if (pinAlreadySet) {
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => WalletPinVerificationScreen(
            authService: widget.authService,
            walletService: widget.walletService,
            actionDescription: 'Verify old PIN to change it',
          ),
        ),
      );

      if (verified != true) return;
    }

    if (!mounted) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => SetWalletPinScreen(
          authService: widget.authService,
          walletService: widget.walletService,
          isChangeMode: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Security Center')),
      body: user == null
          ? const SizedBox.shrink()
          : StreamBuilder<WalletUser?>(
              stream: widget.walletService.watchWallet(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.cyanAccent));
                }

                final wallet = snapshot.data;
                final pinSet = wallet?.walletPinHash != null && wallet!.walletPinHash!.isNotEmpty;
                final isBankLinked = wallet?.isBankLinked ?? false;
                final emailVerified = widget.authService.currentFirebaseUser?.emailVerified ?? false;

                final score = _calculateSecurityScore(pinSet, isBankLinked, emailVerified);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppTheme.contentMaxWidth(context),
                    ),
                    child: ListView(
                      padding: AppTheme.pagePadding(context),
                      children: [
                        const ScreenHeader(
                          title: 'Security Center',
                          subtitle: 'Protect your wallet and identity',
                        ),
                        
                        // Security Score Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: AppTheme.glowCard(
                            accent: score >= 70 ? AppColors.cyanAccent : AppColors.purpleAccent,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: score >= 70 ? AppColors.cyanAccent : AppColors.purpleAccent,
                                size: 36,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Security score: $score/100',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      score == 100
                                          ? 'Your account is fully secured. Good job!'
                                          : 'Secure your account further by completing all security recommendations.',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Wallet PIN Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: AppTheme.panel(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Wallet PIN Status',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: pinSet
                                          ? AppColors.cyanAccent.withValues(alpha: 0.15)
                                          : AppColors.error.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      pinSet ? 'Active' : 'Not Set',
                                      style: TextStyle(
                                        color: pinSet ? AppColors.cyanAccent : AppColors.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Your Wallet PIN is required for sending funds, withdrawals, and syncing offline transactions.',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FlowPayButton(
                                  label: pinSet ? 'Change Wallet PIN' : 'Set Wallet PIN',
                                  backgroundColor: AppColors.purpleAccent,
                                  foregroundColor: Colors.white,
                                  onPressed: () => _changePin(pinSet),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bank Linking Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: AppTheme.panel(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bank Linking Status',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'For withdrawing funds securely',
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isBankLinked
                                      ? AppColors.cyanAccent.withValues(alpha: 0.15)
                                      : Colors.white12,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isBankLinked ? 'Linked' : 'Not Linked',
                                  style: TextStyle(
                                    color: isBankLinked ? AppColors.cyanAccent : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Email Verified Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: AppTheme.panel(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email Verification',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Required for absolute account recovery',
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: emailVerified
                                      ? AppColors.cyanAccent.withValues(alpha: 0.15)
                                      : Colors.white12,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  emailVerified ? 'Verified' : 'Unverified',
                                  style: TextStyle(
                                    color: emailVerified ? AppColors.cyanAccent : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Text(
                          'Active Sessions',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _SessionTile(
                          device: 'Chrome · Web Browser',
                          location: 'Current session',
                          active: true,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.device,
    required this.location,
    required this.active,
  });

  final String device;
  final String location;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panel(),
      child: Row(
        children: [
          Icon(
            Icons.devices_rounded,
            color: active ? AppColors.cyanAccent : Colors.white38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(location, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          if (active)
            const Text(
              'Active',
              style: TextStyle(color: AppColors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
