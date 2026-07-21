import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/bank_account.dart';
import '../models/qr_payment_payload.dart';
import '../models/wallet_user.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';

class PersonalQrScreen extends StatelessWidget {
  const PersonalQrScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  Future<void> _copyText(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AsyncStateView(
        isLoading: user == null,
        hasError: false,
        isEmpty: false,
        loadingMessage: 'Loading QR code...',
        child: user == null
            ? const SizedBox.shrink()
            : StreamBuilder<WalletUser?>(
                stream: walletService.watchWallet(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final wallet = snapshot.data;
                  final phone = wallet?.phone ?? '';
                  final email = wallet?.email ?? user.email ?? '';
                  final displayName = wallet?.bankAccountHolder ?? user.displayName ?? email.split('@').first;

                  return StreamBuilder<BankAccount?>(
                    stream: walletService.watchPrimaryBankAccount(user.uid),
                    builder: (context, bankSnapshot) {
                      final primaryBank = bankSnapshot.data;
                      final upiId = primaryBank?.upiId ?? '';

                      final qrPayload = QrPaymentPayload(
                        type: 'flowpay_user',
                        userId: user.uid,
                        name: displayName,
                        phone: phone,
                        email: email,
                        walletId: user.uid,
                        upiId: upiId,
                      );
                      final encodedData = qrPayload.encode();

                      return Center(
                        child: SingleChildScrollView(
                          padding: AppTheme.pagePadding(context),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: AppTheme.contentMaxWidth(context),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // User Profile Card Header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: AppTheme.glowCard(accent: AppColors.cyanAccent),
                                  child: Column(
                                    children: [
                                      // User Avatar/Initials
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.cyanAccent.withValues(alpha: 0.3),
                                              AppColors.purpleAccent.withValues(alpha: 0.3),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: AppColors.cyanAccent.withValues(alpha: 0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            displayName.isNotEmpty
                                                ? displayName.substring(0, 1).toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        phone.isNotEmpty ? phone : email,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Wallet ID: ${user.uid.substring(0, 8)}...',
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.copy, size: 14, color: AppColors.cyanAccent),
                                            onPressed: () => _copyText(context, user.uid, 'Wallet ID'),
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            tooltip: 'Copy Wallet ID',
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      
                                      // QR Display
                                      if (phone.isEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          margin: const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                          ),
                                          child: const Text(
                                            'Note: Link a phone number to your profile in settings for phone-number based searches.',
                                            style: TextStyle(color: Colors.white70, fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.cyanAccent.withValues(alpha: 0.15),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            )
                                          ]
                                        ),
                                        child: QrImageView(
                                          data: encodedData,
                                          version: QrVersions.auto,
                                          size: MediaQuery.sizeOf(context).width >= 600
                                              ? 260
                                              : 200,
                                          eyeStyle: const QrEyeStyle(
                                            eyeShape: QrEyeShape.square,
                                            color: Colors.black,
                                          ),
                                          dataModuleStyle: const QrDataModuleStyle(
                                            dataModuleShape: QrDataModuleShape.square,
                                            color: Colors.black,
                                          ),
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Scan to transfer money using FlowPay Wallet',
                                        style: TextStyle(
                                          color: AppColors.cyanAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Debug Support Panel
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: AppTheme.panel(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Debug QR Payload',
                                            style: TextStyle(
                                              color: AppColors.cyanAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () => _copyText(context, encodedData, 'QR Data'),
                                            icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.purpleAccent),
                                            label: const Text(
                                              'Copy QR Data',
                                              style: TextStyle(
                                                color: AppColors.purpleAccent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        encodedData,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Your QR contains secure wallet details to facilitate peer-to-peer transfers.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white30, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}


