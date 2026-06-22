import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/flow_pay_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 90,
              color: AppColors.purpleAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Offline Digital Payments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Secure QR-based wallet transactions with offline synchronization.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),
            const SizedBox(height: 40),
            FlowPayButton(
              label: 'Login',
              backgroundColor: AppColors.purpleAccent,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => LoginScreen(
                      authService: authService,
                      walletService: walletService,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => RegisterScreen(
                      authService: authService,
                      walletService: walletService,
                    ),
                  ),
                );
              },
              child: const Text(
                'Create an account',
                style: TextStyle(color: AppColors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
