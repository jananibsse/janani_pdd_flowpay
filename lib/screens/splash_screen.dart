import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/flow_pay_button.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
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
        child: SingleChildScrollView(
          padding: AppTheme.pagePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppTheme.contentMaxWidth(context),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: AppTheme.glowCard(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 90,
                    color: AppColors.cyanAccent,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'FLOWPAY',
                    style: TextStyle(
                      color: AppColors.cyanAccent,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Payments Beyond Internet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  FlowPayButton(
                    label: 'Get Started',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => WelcomeScreen(
                            authService: authService,
                            walletService: walletService,
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
      ),
    );
  }
}
