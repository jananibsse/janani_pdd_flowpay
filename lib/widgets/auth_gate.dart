import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/wallet_user.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../screens/set_wallet_pin_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/offline_transaction_service.dart';
import '../services/wallet_service.dart';
import 'app_theme.dart';
import 'async_state_view.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
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
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AsyncStateView(
              isLoading: true,
              hasError: false,
              isEmpty: false,
              loadingMessage: 'Connecting to FlowPay...',
              child: const SizedBox.shrink(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AsyncStateView(
              isLoading: false,
              hasError: true,
              isEmpty: false,
              errorMessage: 'Authentication check failed.',
              child: const SizedBox.shrink(),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          // First check if this user is an admin
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('admins')
                .doc(user.uid)
                .snapshots(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: AppColors.background,
                  body: AsyncStateView(
                    isLoading: true,
                    hasError: false,
                    isEmpty: false,
                    loadingMessage: 'Connecting to FlowPay...',
                    child: const SizedBox.shrink(),
                  ),
                );
              }

              final isAdmin = adminSnapshot.data?.exists ?? false;

              // If admin, show ONLY the Admin Dashboard — no other screens
              if (isAdmin) {
                return AdminDashboardScreen(
                  authService: widget.authService,
                  walletService: widget.walletService,
                );
              }

              // Regular user flow: check wallet & PIN
              return StreamBuilder<WalletUser?>(
                stream: widget.walletService.watchWallet(user.uid),
                builder: (context, walletSnapshot) {
                  if (walletSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Scaffold(
                      backgroundColor: AppColors.background,
                      body: AsyncStateView(
                        isLoading: true,
                        hasError: false,
                        isEmpty: false,
                        loadingMessage: 'Connecting to FlowPay...',
                        child: const SizedBox.shrink(),
                      ),
                    );
                  }

                  final walletUser = walletSnapshot.data;
                  if (walletUser == null) {
                    return HomeScreen(
                      authService: widget.authService,
                      walletService: widget.walletService,
                      offlineTransactionService:
                          widget.offlineTransactionService,
                      notificationService: widget.notificationService,
                    );
                  }

                  if (walletUser.walletPinHash == null ||
                      walletUser.walletPinHash!.isEmpty) {
                    return SetWalletPinScreen(
                      authService: widget.authService,
                      walletService: widget.walletService,
                    );
                  }

                  return HomeScreen(
                    authService: widget.authService,
                    walletService: widget.walletService,
                    offlineTransactionService: widget.offlineTransactionService,
                    notificationService: widget.notificationService,
                  );
                },
              );
            },
          );
        }

        return SplashScreen(
          authService: widget.authService,
          walletService: widget.walletService,
        );
      },
    );
  }
}
