import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  State<WithdrawalHistoryScreen> createState() => _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  String _activeFilter = 'All'; // Options: All, Pending, Approved, Rejected

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.cyanAccent;
      case 'rejected':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdrawal History'),
      ),
      body: AsyncStateView(
        isLoading: user == null,
        hasError: false,
        isEmpty: false,
        child: user == null
            ? const SizedBox.shrink()
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('withdrawals')
                    .where('uid', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.cyanAccent));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Failed to load history: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.data?.docs ?? []);
                  // Sort in memory by createdAt descending to avoid composite index requirement
                  docs.sort((a, b) {
                    final aTime = a.data()['createdAt'] as Timestamp?;
                    final bTime = b.data()['createdAt'] as Timestamp?;
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });
                  final filteredDocs = docs.where((doc) {
                    if (_activeFilter == 'All') return true;
                    final status = doc.data()['status'] as String? ?? 'pending';
                    return status.toLowerCase() == _activeFilter.toLowerCase();
                  }).toList();

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: AppTheme.contentMaxWidth(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Filter Chips
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: ['All', 'Pending', 'Approved', 'Rejected'].map((filter) {
                                final isSelected = _activeFilter == filter;
                                return ChoiceChip(
                                  label: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.cyanAccent,
                                  backgroundColor: AppColors.surface,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _activeFilter = filter;
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                          // Withdrawals list
                          Expanded(
                            child: filteredDocs.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.receipt_long_outlined,
                                          size: 64,
                                          color: Colors.white30,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No $_activeFilter withdrawals found',
                                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredDocs.length,
                                    itemBuilder: (context, index) {
                                      final data = filteredDocs[index].data();
                                      final bankName = data['bankName'] as String? ?? 'Bank Account';
                                      final accountLast4 = data['accountLast4'] as String? ?? '0000';
                                      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
                                      final status = data['status'] as String? ?? 'pending';
                                      final createdAt = data['createdAt'];

                                      final statusColor = _getStatusColor(status);

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: AppTheme.panel(),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: statusColor.withValues(alpha: 0.15),
                                              child: Icon(
                                                Icons.account_balance_outlined,
                                                color: statusColor,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$bankName (**** $accountLast4)',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _formatDate(createdAt),
                                                    style: const TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '₹${amount.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                                  ),
                                                  child: Text(
                                                    status.toUpperCase(),
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
