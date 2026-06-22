import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowpay_app/screens/splash_screen.dart';
import 'package:flowpay_app/services/auth_service.dart';
import 'package:flowpay_app/services/wallet_service.dart';

void main() {
  testWidgets('Splash screen shows FlowPay branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          authService: AuthService(),
          walletService: WalletService(),
        ),
      ),
    );

    expect(find.text('FLOWPAY'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
