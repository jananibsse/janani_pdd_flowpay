import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/offline_transaction_service.dart';
import 'services/wallet_service.dart';
import 'widgets/app_theme.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();
  final walletService = WalletService(
    notificationService: notificationService,
  );
  final offlineTransactionService = OfflineTransactionService(
    notificationService: notificationService,
  );

  runApp(
    FlowPayApp(
      authService: AuthService(),
      walletService: walletService,
      offlineTransactionService: offlineTransactionService,
      notificationService: notificationService,
    ),
  );
}

class FlowPayApp extends StatelessWidget {
  const FlowPayApp({
    super.key,
    required this.authService,
    required this.walletService,
    required this.offlineTransactionService,
    required this.notificationService,
  });

  final AuthService authService;
  final WalletService walletService;
  final OfflineTransactionService offlineTransactionService;
  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowPay',
      theme: AppTheme.flowPayTheme(),
      home: AuthGate(
        authService: authService,
        walletService: walletService,
        offlineTransactionService: offlineTransactionService,
        notificationService: notificationService,
      ),
    );
  }
}
