import 'package:flutter/material.dart';

import '../models/offline_transaction.dart';
import '../services/auth_service.dart';
import '../services/offline_transaction_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/flow_pay_button.dart';
import 'wallet_pin_verification_screen.dart';

class OfflineTransactionsScreen extends StatefulWidget {
  const OfflineTransactionsScreen({
    super.key,
    required this.authService,
    required this.walletService,
    required this.offlineTransactionService,
    this.embedded = false,
  });

  final AuthService authService;
  final WalletService walletService;
  final OfflineTransactionService offlineTransactionService;
  final bool embedded;

  @override
  State<OfflineTransactionsScreen> createState() =>
      _OfflineTransactionsScreenState();
}

class _OfflineTransactionsScreenState extends State<OfflineTransactionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  List<OfflineTransaction> _pendingTransactions = [];
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSaving = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadPendingTransactions();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingTransactions() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final transactions =
          await widget.offlineTransactionService.getPendingTransactions();
      if (!mounted) {
        return;
      }
      setState(() {
        _pendingTransactions = transactions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _saveOfflineTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sender = widget.authService.currentUser;
    if (sender == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      final senderWallet = await widget.walletService.watchWallet(sender.uid).first;
      final senderPhone = senderWallet?.phone ?? '';

      final transaction = OfflineTransaction.create(
        receiverPhone: _phoneController.text,
        amount: amount,
        senderId: sender.uid,
        senderPhone: senderPhone,
      );

      await widget.offlineTransactionService.savePendingTransaction(transaction);

      _phoneController.clear();
      _amountController.clear();
      await _loadPendingTransactions();

      if (!mounted) {
        return;
      }
      _showMessage('Offline transfer saved. Sync when back online.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Failed to save offline transfer.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _syncNow() async {
    if (_pendingTransactions.isEmpty) {
      _showMessage('No pending offline transactions to sync.');
      return;
    }

    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPinVerificationScreen(
          authService: widget.authService,
          walletService: widget.walletService,
          actionDescription: 'Syncing ${_pendingTransactions.length} offline transaction(s)',
        ),
      ),
    );

    if (verified != true) {
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final result = await widget.offlineTransactionService.syncPendingTransactions(
        walletService: widget.walletService,
      );

      await _loadPendingTransactions();

      if (!mounted) {
        return;
      }

      if (result.syncedCount > 0 && !result.hasFailures) {
        _showMessage('Synced ${result.syncedCount} transaction(s) successfully.');
      } else if (result.syncedCount > 0 && result.hasFailures) {
        _showMessage(
          'Synced ${result.syncedCount}, failed ${result.failedCount}.',
        );
      } else if (result.hasFailures) {
        _showMessage(result.errors.first);
      } else {
        _showMessage('Nothing to sync.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Sync failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatAmount(double amount) => '₹${amount.toStringAsFixed(2)}';

  String _formatTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildContent() {
    return RefreshIndicator(
      color: AppColors.cyanAccent,
      onRefresh: _loadPendingTransactions,
      child: ListView(
        padding: AppTheme.pagePadding(context),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glowCard(accent: AppColors.purpleAccent),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Offline mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save transfers locally while offline. Sync them to Firestore when connected.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Receiver phone number',
                      Icons.phone_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter receiver phone number';
                      }
                      if (value.trim().length < 10) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Amount',
                      Icons.currency_rupee,
                    ).copyWith(prefixText: '₹ '),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter an amount';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FlowPayButton(
                    label: 'Save Offline Transfer',
                    backgroundColor: AppColors.purpleAccent,
                    foregroundColor: Colors.white,
                    isLoading: _isSaving,
                    onPressed: _saveOfflineTransfer,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FlowPayButton(
            label: 'Sync Now',
            isLoading: _isSyncing,
            onPressed: _syncNow,
          ),
          const SizedBox(height: 24),
          const Text(
            'Pending Offline Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          AsyncStateView(
            isLoading: _isLoading,
            hasError: _loadFailed,
            isEmpty: _pendingTransactions.isEmpty,
            emptyTitle: 'No pending offline transfers',
            emptyMessage: 'Saved offline payments will appear here.',
            emptyIcon: Icons.cloud_off_outlined,
            errorMessage: 'Unable to load offline transactions.',
            onRetry: _loadPendingTransactions,
            child: Column(
              children: _pendingTransactions.map((transaction) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.panel(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            transaction.type == OfflineTransaction.typeWalletToBank ||
                                    transaction.type == OfflineTransaction.typeBankToWallet
                                ? Icons.account_balance_outlined
                                : Icons.cloud_off_rounded,
                            color: AppColors.purpleAccent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.type == OfflineTransaction.typeWalletToBank
                                      ? 'Transfer to Bank'
                                      : transaction.type == OfflineTransaction.typeBankToWallet
                                          ? 'Add from Bank'
                                          : transaction.receiverPhone,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(transaction.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatAmount(transaction.amount),
                            style: const TextStyle(
                              color: AppColors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.purpleAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          transaction.status,
                          style: const TextStyle(
                            color: AppColors.purpleAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppTheme.contentMaxWidth(context),
        ),
        child: _buildContent(),
      ),
    );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppTheme.pagePadding(context).copyWith(bottom: 8),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Transfers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Queue payments offline and sync later',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Offline Transfers')),
      body: SafeArea(child: content),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cyanAccent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
