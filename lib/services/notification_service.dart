import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/flowpay_notification.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';

  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore? _firestore;

  FirebaseFirestore get _db =>
      _firestore ??= _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notifications(String uid) =>
      _db.collection(usersCollection).doc(uid).collection(notificationsCollection);

  String _formatAmount(double amount) => '₹${amount.toStringAsFixed(2)}';

  Future<void> _create({
    required String uid,
    required String title,
    required String message,
    required String type,
  }) async {
    await _notifications(uid).add({
      'title': title,
      'message': message,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> notifyMoneyAdded({
    required String uid,
    required double amount,
  }) {
    return _create(
      uid: uid,
      title: 'Money Added',
      message: '${_formatAmount(amount)} added to your wallet',
      type: 'add_money',
    );
  }

  Future<void> notifyTransferToBank({
    required String uid,
    required double amount,
  }) {
    return _create(
      uid: uid,
      title: 'Transfer to Bank',
      message: '${_formatAmount(amount)} transferred from wallet to bank account',
      type: 'transfer_to_bank',
    );
  }

  Future<void> notifyTransferFromBank({
    required String uid,
    required double amount,
  }) {
    return _create(
      uid: uid,
      title: 'Added from Bank',
      message: '${_formatAmount(amount)} added to wallet from bank account',
      type: 'transfer_from_bank',
    );
  }

  Future<void> notifyPaymentSent({
    required String senderId,
    required double amount,
    required String receiverPhone,
  }) {
    return _create(
      uid: senderId,
      title: 'Payment Sent',
      message: '${_formatAmount(amount)} sent to $receiverPhone',
      type: 'payment_sent',
    );
  }

  Future<void> notifyPaymentReceived({
    required String receiverId,
    required double amount,
    required String senderPhone,
  }) {
    return _create(
      uid: receiverId,
      title: 'Payment Received',
      message: '${_formatAmount(amount)} received from $senderPhone',
      type: 'payment_received',
    );
  }

  Future<void> notifyOfflineSyncCompleted({required String uid}) {
    return _create(
      uid: uid,
      title: 'Offline Sync Completed',
      message: 'Your offline transaction was synced successfully',
      type: 'offline_sync',
    );
  }

  Future<void> notifyRazorpaySuccess({
    required String uid,
    required double amount,
    required String paymentId,
  }) {
    return _create(
      uid: uid,
      title: 'Top-up Successful',
      message: '₹${amount.toStringAsFixed(2)} added via Razorpay (ID: $paymentId)',
      type: 'add_money',
    );
  }

  Future<void> notifyRazorpayFailure({
    required String uid,
    required double amount,
    required String message,
  }) {
    return _create(
      uid: uid,
      title: 'Top-up Failed',
      message: '₹${amount.toStringAsFixed(2)} top-up failed: $message',
      type: 'add_money_failed',
    );
  }

  Future<void> notifyBankLinked({
    required String uid,
    required String bankName,
    required String last4,
  }) {
    return _create(
      uid: uid,
      title: 'Bank Linked',
      message: 'Your bank account $bankName ****$last4 has been linked successfully.',
      type: 'bank_linked',
    );
  }

  Future<void> notifyBankUpdated({
    required String uid,
    required String bankName,
    required String last4,
  }) {
    return _create(
      uid: uid,
      title: 'Bank Updated',
      message: 'Your linked bank account details for $bankName ****$last4 have been updated.',
      type: 'bank_updated',
    );
  }

  Future<void> notifyWithdrawalSubmitted({
    required String uid,
    required double amount,
  }) {
    return _create(
      uid: uid,
      title: 'Withdrawal Submitted',
      message: 'Your withdrawal request of ₹${amount.toStringAsFixed(0)} has been submitted.',
      type: 'withdrawal_submitted',
    );
  }

  Future<void> notifyWithdrawalApproved({
    required String uid,
    required double amount,
  }) {
    return _create(
      uid: uid,
      title: 'Withdrawal Approved',
      message: 'Your withdrawal request of ₹${amount.toStringAsFixed(0)} has been approved.',
      type: 'withdrawal_approved',
    );
  }

  Future<void> notifyWithdrawalRejected({
    required String uid,
    required double amount,
  }) {
    return _create(
      uid: uid,
      title: 'Withdrawal Rejected',
      message: 'Your withdrawal request of ₹${amount.toStringAsFixed(0)} has been rejected.',
      type: 'withdrawal_rejected',
    );
  }

  Stream<List<FlowPayNotification>> watchNotifications(
    String uid, {
    int limit = 50,
  }) {
    return _notifications(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(FlowPayNotification.fromFirestore)
              .toList(),
        );
  }

  Stream<int> watchUnreadCount(String uid) {
    return _notifications(uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAsRead({
    required String uid,
    required String notificationId,
  }) async {
    await _notifications(uid).doc(notificationId).update({'read': true});
  }
}
