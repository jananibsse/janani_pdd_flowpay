import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/flow_pay_button.dart';

class SetWalletPinScreen extends StatefulWidget {
  const SetWalletPinScreen({
    super.key,
    required this.authService,
    required this.walletService,
    this.isChangeMode = false,
  });

  final AuthService authService;
  final WalletService walletService;
  final bool isChangeMode;

  @override
  State<SetWalletPinScreen> createState() => _SetWalletPinScreenState();
}

class _SetWalletPinScreenState extends State<SetWalletPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = widget.authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final pin = _pinController.text.trim();
      await widget.walletService.setWalletPin(user.uid, pin);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isChangeMode
                ? 'Wallet PIN changed successfully'
                : 'Wallet PIN created successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.isChangeMode) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isChangeMode ? 'Change Wallet PIN' : 'Create Wallet PIN'),
        automaticallyImplyLeading: widget.isChangeMode,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!widget.isChangeMode)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              onPressed: () => widget.authService.signOut(),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: AppTheme.pagePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppTheme.contentMaxWidth(context),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cyanAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cyanAccent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded,
                        color: AppColors.cyanAccent,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.isChangeMode ? 'Update Security PIN' : 'Set Your Wallet PIN',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A Wallet PIN protects your funds. It is required for transfers, sync, bank links, and withdrawals.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                    decoration: _inputDecoration('Enter 4 or 6-digit PIN'),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a PIN';
                      }
                      if (value.length != 4 && value.length != 6) {
                        return 'PIN must be exactly 4 or 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                    decoration: _inputDecoration('Confirm PIN'),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your PIN';
                      }
                      if (value != _pinController.text) {
                        return 'PINs do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  FlowPayButton(
                    label: widget.isChangeMode ? 'Change PIN' : 'Setup Wallet PIN',
                    backgroundColor: AppColors.purpleAccent,
                    foregroundColor: Colors.white,
                    isLoading: _isLoading,
                    onPressed: _submitPin,
                  ),
                  if (widget.isChangeMode) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, letterSpacing: 0, fontSize: 14),
      alignLabelWithHint: true,
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
