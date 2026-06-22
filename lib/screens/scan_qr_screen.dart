import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/qr_payment_payload.dart';
import '../models/wallet_user.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/flow_pay_button.dart';
import 'receiver_profile_preview_screen.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;
  bool _cameraError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verifyAndNavigate(QrPaymentPayload payload) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.cyanAccent),
      ),
    );

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(payload.userId)
          .get();

      if (!mounted) return;
      Navigator.pop(context); // Pop loading dialog

      if (!userDoc.exists) {
        _showMessage('FlowPay user not found');
        setState(() => _hasScanned = false);
        _controller.start();
        return;
      }

      final walletUser = WalletUser.fromFirestore(userDoc);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReceiverProfilePreviewScreen(
            authService: widget.authService,
            walletService: widget.walletService,
            receiver: walletUser,
            qrPayload: payload,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading dialog
        _showMessage('Verification failed: $e');
        setState(() => _hasScanned = false);
        _controller.start();
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) {
        continue;
      }

      final payload = QrPaymentPayload.tryParse(raw);
      if (payload == null || payload.type != 'flowpay_user') {
        _showMessage('Invalid FlowPay QR');
        continue;
      }

      final currentUser = widget.authService.currentUser;
      if (currentUser != null && payload.userId == currentUser.uid) {
        _showMessage('You cannot pay yourself.');
        continue;
      }

      setState(() => _hasScanned = true);
      _controller.stop();

      _verifyAndNavigate(payload);
      return;
    }
  }

  Future<void> _showPasteDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Paste QR Data', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            maxLines: 6,
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Paste the encoded JSON QR payload here...',
              hintStyle: TextStyle(color: Colors.white30),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.cyanAccent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Verify', style: TextStyle(color: AppColors.cyanAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null || result.trim().isEmpty) return;

    final payload = QrPaymentPayload.tryParse(result);
    if (payload == null || payload.type != 'flowpay_user') {
      _showMessage('Invalid FlowPay QR data');
      return;
    }

    final currentUser = widget.authService.currentUser;
    if (currentUser != null && payload.userId == currentUser.uid) {
      _showMessage('You cannot pay yourself.');
      return;
    }

    setState(() => _hasScanned = true);
    _controller.stop();
    _verifyAndNavigate(payload);
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Scan QR')),
      body: AsyncStateView(
        isLoading: user == null,
        hasError: false,
        isEmpty: false,
        loadingMessage: 'Starting camera...',
        child: user == null
            ? const SizedBox.shrink()
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppTheme.contentMaxWidth(context),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: AppTheme.pagePadding(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: AppTheme.glowCard(radius: 20),
                              child: _cameraError
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.videocam_off_rounded,
                                              color: Colors.white30,
                                              size: 48,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'Camera feed unavailable',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'You can use the paste button below to enter QR data manually.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : MobileScanner(
                                      controller: _controller,
                                      onDetect: _onDetect,
                                      errorBuilder: (context, error) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (mounted && !_cameraError) {
                                            setState(() => _cameraError = true);
                                          }
                                        });
                                        return const Center(
                                          child: Text(
                                            'Camera unavailable',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: AppTheme.pagePadding(context),
                        child: Column(
                          children: [
                            const Text(
                              'Point your camera at a FlowPay QR code to send money.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '-- OR --',
                              style: TextStyle(color: Colors.white30, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            FlowPayButton(
                              label: 'Paste QR Data',
                              backgroundColor: AppColors.purpleAccent,
                              foregroundColor: Colors.white,
                              onPressed: _showPasteDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

