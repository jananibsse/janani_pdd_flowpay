import 'package:flutter/material.dart';

import '../models/bank_account.dart';
import '../models/wallet_user.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/flow_pay_button.dart';
import 'bank_link_screen.dart';
import 'wallet_pin_verification_screen.dart';

class WithdrawToBankScreen extends StatefulWidget {
  const WithdrawToBankScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  State<WithdrawToBankScreen> createState() => _WithdrawToBankScreenState();
}

class _WithdrawToBankScreenState extends State<WithdrawToBankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  BankAccount? _selectedBankAccount;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal(String uid, double currentBalance) async {
    if (!_formKey.currentState!.validate() || _selectedBankAccount == null) {
      return;
    }

    final user = widget.authService.currentUser;
    if (user == null) return;
    final userName = user.displayName ?? user.email?.split('@').first ?? 'FlowPay User';

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      _showError('Amount must be greater than zero.');
      return;
    }

    if (amount > currentBalance) {
      _showError('Insufficient wallet balance.');
      return;
    }

    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPinVerificationScreen(
          authService: widget.authService,
          walletService: widget.walletService,
          actionDescription: 'Withdraw ₹${amount.toStringAsFixed(2)} to ${_selectedBankAccount!.bankName}',
        ),
      ),
    );

    if (verified != true) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.walletService.submitWithdrawalRequest(
        uid: uid,
        userName: userName,
        bankId: _selectedBankAccount!.id,
        bankName: _selectedBankAccount!.bankName,
        accountLast4: _selectedBankAccount!.accountLast4,
        accountHolderName: _selectedBankAccount!.accountHolderName,
        ifscCode: _selectedBankAccount!.ifscCode,
        upiId: _selectedBankAccount!.upiId,
        amount: amount,
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      // Show dialog or snackbar with requested text
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Withdrawal Request', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Withdrawal Request Submitted',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: const Text('OK', style: TextStyle(color: AppColors.cyanAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.pop(context); // Pop withdrawal screen
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdraw to Bank'),
      ),
      body: AsyncStateView(
        isLoading: user == null,
        hasError: false,
        isEmpty: false,
        loadingMessage: 'Preparing withdrawal...',
        child: user == null
            ? const SizedBox.shrink()
            : StreamBuilder<WalletUser?>(
                stream: widget.walletService.watchWallet(user.uid),
                builder: (context, walletSnapshot) {
                  if (walletSnapshot.connectionState == ConnectionState.waiting && !walletSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final wallet = walletSnapshot.data;
                  final balance = wallet?.balance ?? 0.0;

                  return StreamBuilder<List<BankAccount>>(
                    stream: widget.walletService.watchBankAccounts(user.uid),
                    builder: (context, accountsSnapshot) {
                      if (accountsSnapshot.connectionState == ConnectionState.waiting && !accountsSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final accounts = accountsSnapshot.data ?? [];

                      if (accounts.isEmpty) {
                        return _buildNoBankAccountsUI();
                      }

                      // Automatically select primary bank if not already selected, or if the previously selected bank is no longer in the list
                      if (_selectedBankAccount == null || !accounts.any((acc) => acc.id == _selectedBankAccount!.id)) {
                        final primary = accounts.firstWhere((acc) => acc.isPrimary, orElse: () => accounts.first);
                        _selectedBankAccount = primary;
                      } else {
                        // Make sure we use the current instance from the stream to match references if needed
                        _selectedBankAccount = accounts.firstWhere((acc) => acc.id == _selectedBankAccount!.id);
                      }

                      return SingleChildScrollView(
                        padding: AppTheme.pagePadding(context),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: AppTheme.contentMaxWidth(context),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Withdraw Funds',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Deduct funds from your FlowPay Wallet to a linked bank account.',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: AppTheme.panel(),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Available Balance',
                                          style: TextStyle(color: Colors.white54, fontSize: 14),
                                        ),
                                        Text(
                                          '₹${balance.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.cyanAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Select Linked Bank Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedBankAccount?.id,
                                        dropdownColor: AppColors.surface,
                                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                                        isExpanded: true,
                                        items: accounts.map((BankAccount account) {
                                          return DropdownMenuItem<String>(
                                            value: account.id,
                                            child: Text(
                                              '${account.bankName} (**** ${account.accountLast4})',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedBankAccount = accounts.firstWhere((acc) => acc.id == value);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_selectedBankAccount != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'UPI ID: ${_selectedBankAccount!.upiId}  |  IFSC: ${_selectedBankAccount!.ifscCode}',
                                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _amountController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Amount',
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      prefixText: '₹ ',
                                      prefixStyle: const TextStyle(color: AppColors.purpleAccent, fontWeight: FontWeight.bold),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.white24),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.purpleAccent),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter amount';
                                      }
                                      final amt = double.tryParse(value.trim());
                                      if (amt == null || amt <= 0) {
                                        return 'Enter a valid positive number';
                                      }
                                      if (amt > balance) {
                                        return 'Insufficient balance';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  FlowPayButton(
                                    label: 'Confirm & Withdraw',
                                    backgroundColor: AppColors.purpleAccent,
                                    foregroundColor: Colors.white,
                                    isLoading: _isSubmitting,
                                    onPressed: () => _submitWithdrawal(user.uid, balance),
                                  ),
                                ],
                              ),
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

  Widget _buildNoBankAccountsUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_outlined,
              size: 64,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Bank Account Linked',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You must link a bank account to FlowPay before making a withdrawal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            FlowPayButton(
              label: 'Link Bank Account',
              backgroundColor: AppColors.cyanAccent,
              foregroundColor: Colors.black,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BankLinkScreen(
                      authService: widget.authService,
                      walletService: widget.walletService,
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
