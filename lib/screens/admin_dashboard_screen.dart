import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  // Cache user details fetched from /users/{uid}
  final Map<String, Map<String, dynamic>> _userCache = {};

  Future<Map<String, dynamic>> _fetchUserDetails(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid]!;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      _userCache[uid] = data;
      return data;
    } catch (_) {
      return {};
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to log out of the admin portal?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.authService.signOut();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.day}/${dt.month}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }

  // ── Approval confirmation dialog ──────────────────────────────────────────
  Future<void> _confirmApprove({
    required String withdrawalId,
    required String uid,
    required double amount,
    required Map<String, dynamic> data,
    required Map<String, dynamic> userData,
  }) async {
    final userName = _resolveUserName(data, userData);
    final email = userData['email'] as String? ?? 'N/A';
    final phone = userData['phone'] as String? ?? 'N/A';
    final accountHolder =
        _resolve(data, 'accountHolderName', userData, 'bankAccountHolder');
    final bankName = _resolve(data, 'bankName', userData, 'bankName');
    final accountLast4 =
        _resolveAccountLast4(data, userData);
    final ifsc = _resolve(data, 'ifscCode', userData, 'bankIfsc');
    final upiRaw = data['upiId'] as String? ?? '';
    final upi = upiRaw.isNotEmpty
        ? upiRaw
        : (userData['bankUpiId'] as String? ?? 'N/A');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyanAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_outlined,
                        color: AppColors.cyanAccent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Confirm Approval',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Verify all details before approving. The money will need to be sent manually.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),
              _dialogRow('User', userName),
              _dialogRow('Email', email),
              _dialogRow('Phone', phone),
              _dialogRow('Amount', '₹${amount.toStringAsFixed(2)}'),
              const Divider(color: Colors.white12, height: 20),
              _dialogRow('Bank', bankName),
              _dialogRow('Account Holder', accountHolder),
              _dialogRow('Account No', '**** $accountLast4'),
              _dialogRow('IFSC', ifsc),
              _dialogRow('UPI ID', upi),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.5)),
                        foregroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Approve',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _doUpdateStatus(withdrawalId, uid, amount, 'approved');
    }
  }

  // ── Reject confirmation dialog ─────────────────────────────────────────────
  Future<void> _confirmReject({
    required String withdrawalId,
    required String uid,
    required double amount,
    required String userName,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cancel_outlined,
                        color: AppColors.error, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Reject Withdrawal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Reject ₹${amount.toStringAsFixed(2)} withdrawal from $userName?\n\nThe amount will be refunded to their wallet.',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        foregroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reject & Refund',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _doUpdateStatus(withdrawalId, uid, amount, 'rejected');
    }
  }

  Future<void> _doUpdateStatus(
      String withdrawalId, String uid, double amount, String status) async {
    setState(() => _isProcessing = true);
    try {
      await widget.walletService.updateWithdrawalStatus(
        withdrawalId: withdrawalId,
        uid: uid,
        amount: amount,
        status: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                status == 'approved'
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text('Withdrawal $status successfully'),
            ],
          ),
          backgroundColor: status == 'approved'
              ? AppColors.cyanAccent.withValues(alpha: 0.9)
              : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── Helper: resolve value from withdrawal doc, fallback to user doc ────────
  String _resolve(Map<String, dynamic> wData, String wKey,
      Map<String, dynamic> uData, String uKey) {
    final v = wData[wKey] as String?;
    if (v != null && v.isNotEmpty) return v;
    return uData[uKey] as String? ?? 'N/A';
  }

  String _resolveUserName(
      Map<String, dynamic> wData, Map<String, dynamic> uData) {
    final v = wData['userName'] as String?;
    if (v != null && v.isNotEmpty && v != 'FlowPay User') return v;
    final email = uData['email'] as String?;
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'User';
  }

  String _resolveAccountLast4(
      Map<String, dynamic> wData, Map<String, dynamic> uData) {
    final v = wData['accountLast4'] as String?;
    if (v != null && v.isNotEmpty) return v;
    final num = uData['bankAccountNumber'] as String?;
    if (num != null && num.length >= 4) return num.substring(num.length - 4);
    return '????';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_outlined,
                  color: AppColors.cyanAccent, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Admin Portal'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 18),
              label: const Text('Logout',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4))),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.cyanAccent,
          labelColor: AppColors.cyanAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('withdrawals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.cyanAccent));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error)),
            );
          }

          final allDocs =
              List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
                  snapshot.data?.docs ?? []);

          // Sort newest first
          allDocs.sort((a, b) {
            final aTs = a.data()['createdAt'] as Timestamp?;
            final bTs = b.data()['createdAt'] as Timestamp?;
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return bTs.compareTo(aTs);
          });

          final pending =
              allDocs.where((d) => d.data()['status'] == 'pending').toList();
          final approved =
              allDocs.where((d) => d.data()['status'] == 'approved').toList();
          final rejected =
              allDocs.where((d) => d.data()['status'] == 'rejected').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(pending, 'pending'),
              _buildList(approved, 'approved'),
              _buildList(rejected, 'rejected'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> list, String status) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending'
                  ? Icons.hourglass_empty_outlined
                  : status == 'approved'
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
              size: 56,
              color: Colors.white24,
            ),
            const SizedBox(height: 12),
            Text(
              'No $status withdrawal requests',
              style: const TextStyle(color: Colors.white54, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final doc = list[index];
        final data = doc.data();
        final uid = data['uid'] as String? ?? '';

        return FutureBuilder<Map<String, dynamic>>(
          future: _fetchUserDetails(uid),
          builder: (context, userSnap) {
            final userData = userSnap.data ?? {};
            return _WithdrawalCard(
              doc: doc,
              userData: userData,
              status: status,
              isProcessing: _isProcessing,
              formatDate: _formatDate,
              resolveUserName: _resolveUserName,
              resolveAccountLast4: _resolveAccountLast4,
              resolve: _resolve,
              onApprove: () => _confirmApprove(
                withdrawalId: doc.id,
                uid: uid,
                amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
                data: data,
                userData: userData,
              ),
              onReject: () => _confirmReject(
                withdrawalId: doc.id,
                uid: uid,
                amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
                userName: _resolveUserName(data, userData),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Individual withdrawal card ─────────────────────────────────────────────────
class _WithdrawalCard extends StatelessWidget {
  const _WithdrawalCard({
    required this.doc,
    required this.userData,
    required this.status,
    required this.isProcessing,
    required this.formatDate,
    required this.resolveUserName,
    required this.resolveAccountLast4,
    required this.resolve,
    required this.onApprove,
    required this.onReject,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final Map<String, dynamic> userData;
  final String status;
  final bool isProcessing;
  final String Function(dynamic) formatDate;
  final String Function(Map<String, dynamic>, Map<String, dynamic>)
      resolveUserName;
  final String Function(Map<String, dynamic>, Map<String, dynamic>)
      resolveAccountLast4;
  final String Function(Map<String, dynamic>, String, Map<String, dynamic>,
      String) resolve;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  Color get _statusColor {
    switch (status) {
      case 'approved':
        return AppColors.cyanAccent;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

    // Resolve fields with fallback to user document
    final userName = resolveUserName(data, userData);
    final email = userData['email'] as String? ?? 'N/A';
    final phone = userData['phone'] as String? ?? 'N/A';
    final accountHolder =
        resolve(data, 'accountHolderName', userData, 'bankAccountHolder');
    final bankName = resolve(data, 'bankName', userData, 'bankName');
    final accountLast4 = resolveAccountLast4(data, userData);
    final ifsc = resolve(data, 'ifscCode', userData, 'bankIfsc');
    // Resolve UPI ID: withdrawal doc first, then user doc (bankUpiId field)
    final upiRaw = data['upiId'] as String? ?? '';
    final upi = upiRaw.isNotEmpty
        ? upiRaw
        : (userData['bankUpiId'] as String? ?? 'N/A');
    final createdAt = formatDate(data['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ─────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _statusColor.withValues(alpha: 0.2),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                        color: _statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text(email,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                      Text(phone,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: _statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: _statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                            color: _statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(createdAt,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),

          // ── Bank Details ────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_outlined,
                        size: 12, color: AppColors.cyanAccent),
                    const SizedBox(width: 5),
                    const Text('Bank Account Details',
                        style: TextStyle(
                            color: AppColors.cyanAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4)),
                  ],
                ),
                const SizedBox(height: 10),

                // Compact detail rows
                _compactRow(Icons.person_outline, 'Account Holder',
                    accountHolder),
                _compactRow(Icons.business_outlined, 'Bank', bankName),
                _compactRow(Icons.credit_card_outlined, 'Account No',
                    '**** $accountLast4'),
                _compactRow(Icons.tag_outlined, 'IFSC Code', ifsc),
                const SizedBox(height: 8),

                // UPI highlighted row
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.purpleAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            AppColors.purpleAccent.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_outlined,
                          size: 16, color: AppColors.purpleAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('UPI ID',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    letterSpacing: 0.2)),
                            Text(upi,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: upi));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('UPI ID copied'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Icon(Icons.copy_outlined,
                            size: 15, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Action Buttons (Pending only) ──────────────────────────────
          if (status == 'pending') ...[
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.5)),
                        foregroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: isProcessing ? null : onReject,
                      icon: const Icon(Icons.cancel_outlined, size: 14),
                      label: const Text('Reject',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: isProcessing ? null : onApprove,
                      icon: isProcessing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.verified_outlined, size: 14),
                      label: Text(
                          isProcessing ? 'Processing...' : 'Confirm & Approve',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _compactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.white38),
          const SizedBox(width: 6),
          SizedBox(
            width: 110,
            child: Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 11)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

