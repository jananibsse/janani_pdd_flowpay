import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_user.dart';
import '../models/offline_transaction.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/offline_transaction_service.dart';
import '../services/wallet_service.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/balance_card.dart';
import '../widgets/bank_balance_card.dart';
import '../widgets/flow_pay_bottom_nav.dart';
import '../widgets/help_assistant_fab.dart';
import '../widgets/quick_action_grid.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';
import 'offline_transactions_screen.dart';
import 'personal_qr_screen.dart';
import 'profile_screen.dart';
import 'scan_qr_screen.dart';
import 'send_money_screen.dart';
import 'transactions_screen.dart';
import 'bank_link_screen.dart';
import 'withdraw_to_bank_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  bool _isAddingMoney = false;
  late Razorpay _razorpay;
  String? _pendingAddMoneyUid;
  double? _pendingAddMoneyAmount;

  @override
  void initState() {
    super.initState();
    _ensureWallet();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingAddMoneyUid == null || _pendingAddMoneyAmount == null) return;
    
    setState(() => _isAddingMoney = true);
    try {
      await widget.walletService.recordRazorpayTransaction(
        uid: _pendingAddMoneyUid!,
        amount: _pendingAddMoneyAmount!,
        status: 'success',
        razorpayPaymentId: response.paymentId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added ₹${_pendingAddMoneyAmount!.toStringAsFixed(2)}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update wallet transaction.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingMoney = false);
      }
      _pendingAddMoneyUid = null;
      _pendingAddMoneyAmount = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    if (_pendingAddMoneyUid == null || _pendingAddMoneyAmount == null) return;

    try {
      await widget.walletService.recordRazorpayTransaction(
        uid: _pendingAddMoneyUid!,
        amount: _pendingAddMoneyAmount!,
        status: 'failed',
      );
    } catch (e) {
      debugPrint('Error recording failed payment: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _pendingAddMoneyUid = null;
    _pendingAddMoneyAmount = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _ensureWallet() async {
    final user = widget.authService.currentUser;
    if (user == null) return;

    try {
      await widget.walletService.ensureWalletExists(
        uid: user.uid,
        email: user.email ?? '',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load wallet. Please retry.')),
      );
    }
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _goToTab(int index) {
    setState(() => _tabIndex = index);
  }

  Future<void> _showAddMoneyDialog(String uid) async {
    final amountController = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Add Money', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.white70),
              prefixText: '₹ ',
              prefixStyle: TextStyle(color: AppColors.cyanAccent),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.cyanAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(amountController.text.trim());
                if (value == null || value <= 0) return;
                Navigator.pop(context, value);
              },
              child: const Text(
                'Add',
                style: TextStyle(color: AppColors.cyanAccent),
              ),
            ),
          ],
        );
      },
    );

    amountController.dispose();

    if (amount == null || !mounted) return;

    final user = widget.authService.currentUser;
    final options = {
      'key': 'rzp_test_T0fNohZivcVKls',
      'amount': (amount * 100).toInt(),
      'name': 'FlowPay',
      'description': 'Add Money to Wallet',
      'prefill': {
        'contact': '',
        'email': user?.email ?? '',
      },
    };

    _pendingAddMoneyUid = uid;
    _pendingAddMoneyAmount = amount;

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open payment gateway.')),
      );
      _pendingAddMoneyUid = null;
      _pendingAddMoneyAmount = null;
    }
  }

  Future<double?> _showAmountInputDialog({
    required String title,
    required String labelText,
    required String buttonText,
    required Color accentColor,
  }) async {
    final amountController = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: const TextStyle(color: Colors.white70),
              prefixText: '₹ ',
              prefixStyle: TextStyle(color: accentColor),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                final val = double.tryParse(amountController.text.trim());
                if (val == null || val <= 0) return;
                Navigator.pop(context, val);
              },
              child: Text(
                buttonText,
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    amountController.dispose();
    return amount;
  }

  Future<void> _handleAddFromBank(String uid, WalletUser wallet) async {
    final amount = await _showAmountInputDialog(
      title: 'Add from Bank',
      labelText: 'Amount to Add',
      buttonText: 'Add',
      accentColor: AppColors.purpleAccent,
    );

    if (amount == null || !mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final currentBankBalance = wallet.bankBalance ?? 0.0;
    if (currentBankBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient bank balance.')),
      );
      return;
    }

    setState(() => _isAddingMoney = true);

    try {
      await widget.walletService
          .transferBankToWallet(uid: uid, amount: amount)
          .timeout(const Duration(seconds: 4));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ₹${amount.toStringAsFixed(2)} from bank.')),
      );
    } catch (error) {
      if (!mounted) return;

      if (error is WalletException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      } else {
        try {
          final transaction = OfflineTransaction.create(
            receiverPhone: '',
            amount: amount,
            senderId: uid,
            senderPhone: wallet.phone,
            type: OfflineTransaction.typeBankToWallet,
          );

          await widget.offlineTransactionService.savePendingTransaction(transaction);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offline: Add Money queued for sync.'),
            ),
          );
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transfer failed.')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingMoney = false);
      }
    }
  }

  String _formatBalance(double balance) => '₹${balance.toStringAsFixed(2)}';

  String _formatTransactionTime(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  List<QuickActionItem> _quickActions(String uid) {
    return [
      QuickActionItem(
        icon: Icons.qr_code_2_rounded,
        label: 'My QR',
        color: AppColors.cyanAccent,
        onTap: () => _open(
          PersonalQrScreen(
            authService: widget.authService,
            walletService: widget.walletService,
          ),
        ),
      ),
      QuickActionItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan QR',
        color: AppColors.purpleAccent,
        onTap: () => _open(
          ScanQrScreen(
            authService: widget.authService,
            walletService: widget.walletService,
          ),
        ),
      ),
      QuickActionItem(
        icon: Icons.send_rounded,
        label: 'Send Money',
        color: AppColors.cyanAccent,
        onTap: () => _open(
          SendMoneyScreen(
            authService: widget.authService,
            walletService: widget.walletService,
          ),
        ),
      ),
      QuickActionItem(
        icon: Icons.account_balance_rounded,
        label: 'Link Bank',
        color: AppColors.cyanAccent,
        onTap: () => _open(
          BankLinkScreen(
            authService: widget.authService,
            walletService: widget.walletService,
          ),
        ),
      ),
      QuickActionItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Withdraw',
        color: AppColors.purpleAccent,
        onTap: () => _open(
          WithdrawToBankScreen(
            authService: widget.authService,
            walletService: widget.walletService,
          ),
        ),
      ),
      QuickActionItem(
        icon: Icons.cloud_off_rounded,
        label: 'Offline',
        color: AppColors.purpleAccent,
        onTap: () => _goToTab(3),
      ),
      QuickActionItem(
        icon: Icons.receipt_long_rounded,
        label: 'History',
        color: AppColors.cyanAccent,
        onTap: () => _goToTab(2),
      ),
      QuickActionItem(
        icon: Icons.insights_rounded,
        label: 'Analytics',
        color: AppColors.purpleAccent,
        onTap: () => _goToTab(1),
      ),
      QuickActionItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        color: AppColors.cyanAccent,
        onTap: () => _goToTab(4),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: const HelpAssistantFab(),
      body: SafeArea(
        child: AsyncStateView(
          isLoading: user == null,
          hasError: false,
          isEmpty: false,
          loadingMessage: 'Loading dashboard...',
          child: user == null
              ? const SizedBox.shrink()
              : IndexedStack(
                  index: _tabIndex,
                  children: [
                    _DashboardTab(
                      userUid: user.uid,
                      userEmail: user.email ?? 'FlowPay user',
                      formatBalance: _formatBalance,
                      formatTransactionTime: _formatTransactionTime,
                      isAddingMoney: _isAddingMoney,
                      walletService: widget.walletService,
                      notificationService: widget.notificationService,
                      quickActions: _quickActions(user.uid),
                      onAddMoney: () => _showAddMoneyDialog(user.uid),
                      onOpenNotifications: () => _open(
                        NotificationsScreen(
                          authService: widget.authService,
                          notificationService: widget.notificationService,
                        ),
                      ),
                      onTransferToBank: (wallet) => _open(
                        WithdrawToBankScreen(
                          authService: widget.authService,
                          walletService: widget.walletService,
                        ),
                      ),
                      onAddFromBank: (wallet) => _handleAddFromBank(user.uid, wallet),
                    ),
                    AnalyticsScreen(
                      authService: widget.authService,
                      walletService: widget.walletService,
                      embedded: true,
                    ),
                    TransactionsScreen(
                      authService: widget.authService,
                      walletService: widget.walletService,
                      embedded: true,
                    ),
                    OfflineTransactionsScreen(
                      authService: widget.authService,
                      walletService: widget.walletService,
                      offlineTransactionService:
                          widget.offlineTransactionService,
                      embedded: true,
                    ),
                    ProfileScreen(
                      authService: widget.authService,
                      walletService: widget.walletService,
                      notificationService: widget.notificationService,
                      embedded: true,
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: FlowPayBottomNav(
        currentIndex: _tabIndex,
        onTap: _goToTab,
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.userUid,
    required this.userEmail,
    required this.formatBalance,
    required this.formatTransactionTime,
    required this.isAddingMoney,
    required this.walletService,
    required this.notificationService,
    required this.quickActions,
    required this.onAddMoney,
    required this.onOpenNotifications,
    required this.onTransferToBank,
    required this.onAddFromBank,
  });

  final String userUid;
  final String userEmail;
  final String Function(double) formatBalance;
  final String Function(DateTime?) formatTransactionTime;
  final bool isAddingMoney;
  final WalletService walletService;
  final NotificationService notificationService;
  final List<QuickActionItem> quickActions;
  final VoidCallback onAddMoney;
  final VoidCallback onOpenNotifications;
  final void Function(WalletUser wallet) onTransferToBank;
  final void Function(WalletUser wallet) onAddFromBank;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppTheme.contentMaxWidth(context),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: AppTheme.pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardHeader(
                      userUid: userUid,
                      notificationService: notificationService,
                      onNotificationsTap: onOpenNotifications,
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<WalletUser?>(
                      stream: walletService.watchWallet(userUid),
                      builder: (context, snapshot) {
                        final isLoading =
                            snapshot.connectionState == ConnectionState.waiting;
                        final hasError = snapshot.hasError;
                        final wallet = snapshot.data;
                        final email = wallet?.email ?? userEmail;
                        final balance = wallet?.balance ?? 0;

                        if (hasError) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: AppTheme.panel(),
                            child: const Text(
                              'Unable to load wallet balance.',
                              style: TextStyle(color: AppColors.error),
                            ),
                          );
                        }

                        final isBankLinked = wallet?.isBankLinked ?? false;

                        return Column(
                          children: [
                            BalanceCard(
                              email: email,
                              balance: balance,
                              balanceLabel: formatBalance(balance),
                              onAddMoney: onAddMoney,
                              isLoading: isLoading || isAddingMoney,
                            ),
                            if (isBankLinked && wallet != null) ...[
                              const SizedBox(height: 20),
                              BankBalanceCard(
                                bankName: wallet.bankName ?? 'Bank Account',
                                accountNumber: wallet.bankAccountNumber ?? '',
                                bankBalance: wallet.bankBalance ?? 0.0,
                                onTransferToBank: () => onTransferToBank(wallet),
                                onAddFromBank: () => onAddFromBank(wallet),
                                isLoading: isLoading || isAddingMoney,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    AiInsightsCard(
                      uid: userUid,
                      walletService: walletService,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuickActionGrid(actions: quickActions),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            StreamBuilder<List<WalletTransaction>>(
              stream: walletService.watchTransactions(userUid),
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                final hasError = snapshot.hasError;
                final transactions = snapshot.data ?? [];

                return SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        AppTheme.pagePadding(context).copyWith(top: 0, bottom: 24),
                    child: AsyncStateView(
                      isLoading: isLoading,
                      hasError: hasError,
                      isEmpty: transactions.isEmpty,
                      emptyTitle: 'No recent activity',
                      emptyMessage:
                          'Your wallet transfers and top-ups will appear here.',
                      emptyIcon: Icons.receipt_long_outlined,
                      errorMessage: 'Unable to load recent activity.',
                      child: Column(
                        children: List.generate(transactions.length, (index) {
                          final transaction = transactions[index];
                          final prefix = transaction.isCredit ? '+' : '-';
                          final color = transaction.isCredit
                              ? AppColors.cyanAccent
                              : AppColors.error;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: AppTheme.panel(),
                              child: Row(
                                children: [
                                  Icon(
                                    transaction.isCredit
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: color,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transaction.description,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatTransactionTime(
                                            transaction.createdAt,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$prefix${formatBalance(transaction.amount)}',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.userUid,
    required this.notificationService,
    required this.onNotificationsTap,
  });

  final String userUid;
  final NotificationService notificationService;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.cyanAccent, AppColors.purpleAccent],
                ).createShader(bounds),
                child: const Text(
                  'FlowPay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Cyber-fintech command center',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onNotificationsTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.cyanAccent.withValues(alpha: 0.25),
                ),
              ),
              child: StreamBuilder<int>(
                stream: notificationService.watchUnreadCount(userUid),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Badge(
                    isLabelVisible: count > 0,
                    label: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: AppColors.purpleAccent,
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.cyanAccent,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}