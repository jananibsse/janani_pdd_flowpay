import 'package:flutter/material.dart';

import '../models/bank_account.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/flow_pay_button.dart';
import 'wallet_pin_verification_screen.dart';

class BankLinkScreen extends StatefulWidget {
  const BankLinkScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  State<BankLinkScreen> createState() => _BankLinkScreenState();
}

class _BankLinkScreenState extends State<BankLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _last4Controller = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();
  bool _isPrimary = false;

  bool _isLinkingMode = false;
  bool _isEditingMode = false;
  String? _editingBankId;
  bool _isVerifying = false;
  bool _isActionInProgress = false;

  @override
  void dispose() {
    _holderController.dispose();
    _bankNameController.dispose();
    _last4Controller.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _holderController.clear();
    _bankNameController.clear();
    _last4Controller.clear();
    _ifscController.clear();
    _upiController.clear();
    _isPrimary = false;
    _isLinkingMode = false;
    _isEditingMode = false;
    _editingBankId = null;
  }

  void _startEdit(BankAccount account) {
    setState(() {
      _holderController.text = account.accountHolderName;
      _bankNameController.text = account.bankName;
      _last4Controller.text = account.accountLast4;
      _ifscController.text = account.ifscCode;
      _upiController.text = account.upiId;
      _isPrimary = account.isPrimary;
      _isLinkingMode = true;
      _isEditingMode = true;
      _editingBankId = account.id;
    });
  }

  Future<void> _saveBankAccount(String uid) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final actionText = _isEditingMode ? 'saving bank changes' : 'linking bank account';
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPinVerificationScreen(
          authService: widget.authService,
          walletService: widget.walletService,
          actionDescription: 'Authorize $actionText',
        ),
      ),
    );
    if (verified != true) return;

    setState(() {
      _isVerifying = true;
    });

    // Simulated verification delay
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    try {
      if (_isEditingMode) {
        await widget.walletService.updateBankAccount(
          uid: uid,
          bankId: _editingBankId!,
          bankName: _bankNameController.text.trim(),
          accountHolderName: _holderController.text.trim(),
          accountLast4: _last4Controller.text.trim(),
          ifscCode: _ifscController.text.trim(),
          upiId: _upiController.text.trim(),
          isPrimary: _isPrimary,
        );
      } else {
        await widget.walletService.linkBankAccount(
          uid: uid,
          bankName: _bankNameController.text.trim(),
          accountHolderName: _holderController.text.trim(),
          accountLast4: _last4Controller.text.trim(),
          ifscCode: _ifscController.text.trim(),
          upiId: _upiController.text.trim(),
          isPrimary: _isPrimary,
        );
      }

      setState(() {
        _isVerifying = false;
      });

      final msg = _isEditingMode ? 'Bank Account Updated Successfully' : 'Bank Account Linked Successfully';
      _resetForm();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (error) {
      setState(() {
        _isVerifying = false;
      });
      _showError(error.toString());
    }
  }

  Future<void> _unlinkBank(String uid, String bankId, String bankName, String last4) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Unlink Bank Account', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to unlink $bankName ****$last4 from FlowPay?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Unlink', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (!mounted) return;
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPinVerificationScreen(
          authService: widget.authService,
          walletService: widget.walletService,
          actionDescription: 'Unlink $bankName ****$last4',
        ),
      ),
    );
    if (verified != true) return;

    setState(() => _isActionInProgress = true);

    try {
      await widget.walletService.unlinkBankAccount(uid: uid, bankId: bankId);

      setState(() {
        _isActionInProgress = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank Account Unlinked Successfully')),
      );
    } catch (error) {
      setState(() => _isActionInProgress = false);
      _showError(error.toString());
    }
  }

  Future<void> _setAsPrimary(String uid, BankAccount account) async {
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPinVerificationScreen(
          authService: widget.authService,
          walletService: widget.walletService,
          actionDescription: 'Set ${account.bankName} ****${account.accountLast4} as Primary',
        ),
      ),
    );
    if (verified != true) return;

    setState(() => _isActionInProgress = true);
    try {
      await widget.walletService.setPrimaryBankAccount(
        uid: uid,
        bankId: account.id,
      );
      setState(() => _isActionInProgress = false);
    } catch (e) {
      setState(() => _isActionInProgress = false);
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
        title: Text(_isEditingMode ? 'Edit Bank Account' : 'Bank Accounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isLinkingMode) {
              setState(() {
                _resetForm();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: AsyncStateView(
        isLoading: user == null,
        hasError: false,
        isEmpty: false,
        loadingMessage: 'Loading accounts...',
        child: user == null
            ? const SizedBox.shrink()
            : _isVerifying
                ? _buildVerifyingUI()
                : _isLinkingMode
                    ? _buildLinkNewBankUI(user.uid)
                    : _buildBankListUI(user.uid),
      ),
    );
  }

  Widget _buildVerifyingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.cyanAccent),
          const SizedBox(height: 24),
          Text(
            _isEditingMode ? 'Updating Bank Account...' : 'Verifying Bank Account...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Simulating secure connection with bank node...',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBankListUI(String uid) {
    return StreamBuilder<List<BankAccount>>(
      stream: widget.walletService.watchBankAccounts(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final accounts = snapshot.data ?? [];

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
                        const Text(
                          'Linked Bank Accounts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Manage your linked accounts and set your primary bank for withdrawals.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (accounts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
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
                            'No bank accounts linked yet',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          FlowPayButton(
                            label: 'Link Bank Account',
                            backgroundColor: AppColors.cyanAccent,
                            foregroundColor: Colors.black,
                            onPressed: () {
                              setState(() {
                                _isLinkingMode = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final account = accounts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: AppTheme.panel().copyWith(
                              border: Border.all(
                                color: account.isPrimary
                                    ? AppColors.cyanAccent.withValues(alpha: 0.35)
                                    : Colors.white12,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_rounded,
                                          color: account.isPrimary
                                              ? AppColors.cyanAccent
                                              : Colors.white54,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          account.bankName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (account.isPrimary)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.cyanAccent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.cyanAccent.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const Text(
                                          'PRIMARY',
                                          style: TextStyle(
                                            color: AppColors.cyanAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow('Holder Name', account.accountHolderName),
                                const SizedBox(height: 6),
                                _buildInfoRow('Account Number', '**** ${account.accountLast4}'),
                                const SizedBox(height: 6),
                                _buildInfoRow('IFSC Code', account.ifscCode),
                                const SizedBox(height: 6),
                                _buildInfoRow('UPI ID', account.upiId),
                                const Divider(color: Colors.white12, height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: _isActionInProgress
                                          ? null
                                          : () => _startEdit(account),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(color: AppColors.cyanAccent),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (!account.isPrimary) ...[
                                      TextButton(
                                        onPressed: _isActionInProgress
                                            ? null
                                            : () => _setAsPrimary(uid, account),
                                        child: const Text(
                                          'Set as Primary',
                                          style: TextStyle(color: AppColors.cyanAccent),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    TextButton(
                                      onPressed: _isActionInProgress
                                          ? null
                                          : () => _unlinkBank(
                                                uid,
                                                account.id,
                                                account.bankName,
                                                account.accountLast4,
                                              ),
                                      child: const Text(
                                        'Unlink',
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: accounts.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FlowPayButton(
                        label: 'Link New Bank Account',
                        backgroundColor: AppColors.cyanAccent,
                        foregroundColor: Colors.black,
                        onPressed: () {
                          setState(() {
                            _isLinkingMode = true;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLinkNewBankUI(String uid) {
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
                Text(
                  _isEditingMode ? 'Edit Bank Account' : 'Link a Bank Account',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEditingMode
                      ? 'Update your linked bank account details securely.'
                      : 'Your credentials will be saved securely and used only for transactions.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _holderController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Account Holder Name', Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Account holder name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bankNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Bank Name', Icons.account_balance_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bank name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _last4Controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Account Last 4 Digits', Icons.numbers_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last 4 digits are required';
                    }
                    if (value.trim().length != 4 || int.tryParse(value.trim()) == null) {
                      return 'Must be exactly 4 numeric digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ifscController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('IFSC Code', Icons.qr_code_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'IFSC code is required';
                    }
                    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.trim().toUpperCase())) {
                      return 'Enter a valid IFSC (e.g. SBIN0001234)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _upiController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('UPI ID', Icons.alternate_email_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'UPI ID is required';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(value.trim())) {
                      return 'Enter a valid UPI ID (e.g. janani@oksbi)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Set as Primary Bank',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    Switch(
                      value: _isPrimary,
                      activeColor: AppColors.cyanAccent,
                      onChanged: (val) {
                        setState(() {
                          _isPrimary = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FlowPayButton(
                  label: _isEditingMode ? 'Save Changes' : 'Link Bank Account',
                  backgroundColor: AppColors.cyanAccent,
                  foregroundColor: Colors.black,
                  onPressed: () => _saveBankAccount(uid),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _resetForm,
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
      ),
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
