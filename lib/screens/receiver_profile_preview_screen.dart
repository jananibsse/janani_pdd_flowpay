import 'package:flutter/material.dart';

import '../models/qr_payment_payload.dart';
import '../models/wallet_user.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/flow_pay_button.dart';
import 'send_money_screen.dart';

class ReceiverProfilePreviewScreen extends StatelessWidget {
  const ReceiverProfilePreviewScreen({
    super.key,
    required this.authService,
    required this.walletService,
    required this.receiver,
    required this.qrPayload,
  });

  final AuthService authService;
  final WalletService walletService;
  final WalletUser receiver;
  final QrPaymentPayload qrPayload;

  @override
  Widget build(BuildContext context) {
    final name = receiver.bankAccountHolder ?? qrPayload.name;
    final phone = receiver.phone.isNotEmpty ? receiver.phone : qrPayload.phone;
    final email = receiver.email.isNotEmpty ? receiver.email : qrPayload.email;
    final upiId = qrPayload.upiId.isNotEmpty ? qrPayload.upiId : 'Not Linked';
    final walletId = receiver.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Payee'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: AppTheme.pagePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppTheme.contentMaxWidth(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.glowCard(accent: AppColors.cyanAccent),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
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
                            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        phone,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 20),
                      
                      // Details Rows
                      _buildDetailRow('Email', email),
                      const SizedBox(height: 12),
                      _buildDetailRow('UPI ID', upiId),
                      const SizedBox(height: 12),
                      _buildDetailRow('Wallet ID', walletId),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FlowPayButton(
                  label: 'Pay Now',
                  backgroundColor: AppColors.purpleAccent,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => SendMoneyScreen(
                          authService: authService,
                          walletService: walletService,
                          receiverUid: walletId,
                          receiverPhone: phone,
                          receiverName: name,
                          receiverEmail: email,
                          receiverUpiId: upiId != 'Not Linked' ? upiId : '',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
