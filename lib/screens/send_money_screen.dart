import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/flow_pay_button.dart';
import 'wallet_pin_verification_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({
    super.key,
    required this.authService,
    required this.walletService,
    this.receiverUid,
    this.receiverPhone,
    this.receiverName,
    this.receiverEmail,
    this.receiverUpiId,
  });

  final AuthService authService;
  final WalletService walletService;
  final String? receiverUid;
  final String? receiverPhone;
  final String? receiverName;
  final String? receiverEmail;
  final String? receiverUpiId;

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _ScanReceiverDetails {
  _ScanReceiverDetails({
    required this.uid,
    required this.phone,
    required this.name,
    this.email = '',
    this.upiId = '',
  });
  final String uid;
  final String phone;
  final String name;
  final String email;
  final String upiId;
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isSending = false;
  late final bool _receiverLocked;

  // Variables for dynamic lookup
  bool _isLookingUp = false;
  String? _lookupError;
  _ScanReceiverDetails? _resolvedReceiver;

  @override
  void initState() {
    super.initState();
    _receiverLocked = widget.receiverUid != null && widget.receiverPhone != null;
    if (widget.receiverPhone != null) {
      _phoneController.text = widget.receiverPhone!;
    }
    
    if (_receiverLocked) {
      _resolvedReceiver = _ScanReceiverDetails(
        uid: widget.receiverUid!,
        phone: widget.receiverPhone!,
        name: widget.receiverName ?? 'FlowPay User',
        email: widget.receiverEmail ?? '',
        upiId: widget.receiverUpiId ?? '',
      );
    } else {
      _phoneController.addListener(_onPhoneChanged);
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.trim();
    if (text.length == 10) {
      _lookupReceiver(text);
    } else {
      if (_resolvedReceiver != null || _lookupError != null) {
        setState(() {
          _resolvedReceiver = null;
          _lookupError = null;
        });
      }
    }
  }

  Future<void> _lookupReceiver(String phone) async {
    final sender = widget.authService.currentUser;
    if (sender == null) return;

    setState(() {
      _isLookingUp = true;
      _lookupError = null;
      _resolvedReceiver = null;
    });

    try {
      final uid = await widget.walletService.getUserIdByPhone(phone);
      if (uid == null) {
        setState(() => _lookupError = 'No FlowPay wallet found for this number.');
        return;
      }

      if (uid == sender.uid) {
        setState(() => _lookupError = 'You cannot send money to yourself.');
        return;
      }

      final wallet = await widget.walletService.watchWallet(uid).first;
      if (wallet == null) {
        setState(() => _lookupError = 'Unable to retrieve user details.');
        return;
      }

      String? upi;
      if (wallet.isBankLinked) {
        final primaryBank = await widget.walletService.watchPrimaryBankAccount(uid).first;
        upi = primaryBank?.upiId;
      }

      setState(() {
        _resolvedReceiver = _ScanReceiverDetails(
          uid: uid,
          phone: phone,
          name: wallet.bankAccountHolder ?? wallet.email.split('@').first,
          email: wallet.email,
          upiId: upi ?? '',
        );
      });
    } catch (e) {
      setState(() => _lookupError = 'Error looking up number.');
    } finally {
      setState(() => _isLookingUp = false);
    }
  }

  Future<void> _sendMoney() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sender = widget.authService.currentUser;
    if (sender == null) {
      return;
    }

    final receiver = _resolvedReceiver;
    if (receiver == null) {
      _showError('Please enter a valid, registered recipient number.');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WalletPinVerificationScreen(
          authService: widget.authService,
          walletService: widget.walletService,
          actionDescription: 'Send ₹${amount.toStringAsFixed(2)} to ${receiver.name}',
        ),
      ),
    );

    if (verified != true) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final senderWallet = await widget.walletService.watchWallet(sender.uid).first;
      final senderPhone = senderWallet?.phone ?? '';

      await widget.walletService.sendMoney(
        senderId: sender.uid,
        senderPhone: senderPhone,
        receiverId: receiver.uid,
        receiverPhone: receiver.phone,
        amount: amount,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent ₹${amount.toStringAsFixed(2)} to ${receiver.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } on WalletException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sender = widget.authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AsyncStateView(
        isLoading: sender == null,
        hasError: false,
        isEmpty: false,
        loadingMessage: 'Preparing transfer...',
        child: sender == null
            ? const SizedBox.shrink()
            : SafeArea(
                child: Center(
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
                            const Text(
                              'Transfer funds',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enter receiver phone number and amount.',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 32),
                            
                            // Phone Number Field
                            TextFormField(
                              controller: _phoneController,
                              readOnly: _receiverLocked,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                'Receiver phone number',
                                Icons.phone_outlined,
                              ).copyWith(
                                suffixIcon: _isLookingUp
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanAccent),
                                          ),
                                        ),
                                      )
                                    : _resolvedReceiver != null
                                        ? const Icon(Icons.check_circle, color: AppColors.cyanAccent)
                                        : null,
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
                            
                            // Lookup Feedback & Errors
                            if (_lookupError != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  _lookupError!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              ),
                            ],

                            // Receiver Profile Card
                            if (_resolvedReceiver != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: AppTheme.glowCard(accent: AppColors.cyanAccent),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: AppColors.cyanAccent.withValues(alpha: 0.15),
                                      child: Text(
                                        _resolvedReceiver!.name.isNotEmpty
                                            ? _resolvedReceiver!.name.substring(0, 1).toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: AppColors.cyanAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _resolvedReceiver!.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Phone: ${_resolvedReceiver!.phone}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (_resolvedReceiver!.email.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Email: ${_resolvedReceiver!.email}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          if (_resolvedReceiver!.upiId.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'UPI ID: ${_resolvedReceiver!.upiId}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 2),
                                          Text(
                                            'Wallet: ${_resolvedReceiver!.uid}',
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.verified, color: AppColors.cyanAccent, size: 24),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 20),
                            
                            // Amount Field
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
                            const SizedBox(height: 32),
                            
                            // Submit Button
                            FlowPayButton(
                              label: 'Send Money',
                              backgroundColor: AppColors.purpleAccent,
                              foregroundColor: Colors.white,
                              isLoading: _isSending,
                              onPressed: _resolvedReceiver != null ? _sendMoney : null,
                            ),
                          ],
                        ),
                      ),
                    ),
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

