import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flowpay_app/services/notification_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// FlowPay Backend Test Suite — NOTIFICATION SERVICE (50 Test Cases)
/// Covers: All notification types, read/unread, streaming, edge cases
/// ═══════════════════════════════════════════════════════════════
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late NotificationService ns;
  const uid = 'user1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    ns = NotificationService(firestore: fakeFirestore);
  });

  Future<int> _notifCount() async {
  Future<int> notifCount() async {
    final q = await fakeFirestore.collection('users').doc(uid).collection('notifications').get();
    return q.docs.length;
  }

  Future<Map<String, dynamic>> lastNotif() async {
    final q = await fakeFirestore.collection('users').doc(uid).collection('notifications').get();
    return q.docs.last.data();
  }

  // ─── MONEY ADDED (TC_NOTIF_001–005) ─────────────────

  group('NotificationService — Money Added', () {
    test('TC_NOTIF_001 — notifyMoneyAdded creates notification', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 500);
      expect(await notifCount(), 1);
    });

    test('TC_NOTIF_002 — notifyMoneyAdded has type add_money', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 500);
      expect((await lastNotif())['type'], 'add_money');
    });

    test('TC_NOTIF_003 — notifyMoneyAdded title is Money Added', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 500);
      expect((await lastNotif())['title'], 'Money Added');
    });

    test('TC_NOTIF_004 — notifyMoneyAdded message contains formatted amount', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 500);
      expect((await lastNotif())['message'], contains('₹500.00'));
    });

    test('TC_NOTIF_005 — notifyMoneyAdded read defaults to false', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 500);
      expect((await lastNotif())['read'], false);
    });
  });

  // ─── PAYMENT SENT (TC_NOTIF_006–010) ─────────────────

  group('NotificationService — Payment Sent', () {
    test('TC_NOTIF_006 — notifyPaymentSent creates notification', () async {
      await ns.notifyPaymentSent(senderId: uid, amount: 200, receiverPhone: '999');
      expect(await notifCount(), 1);
    });

    test('TC_NOTIF_007 — notifyPaymentSent type is payment_sent', () async {
      await ns.notifyPaymentSent(senderId: uid, amount: 200, receiverPhone: '999');
      expect((await lastNotif())['type'], 'payment_sent');
    });

    test('TC_NOTIF_008 — notifyPaymentSent title is Payment Sent', () async {
      await ns.notifyPaymentSent(senderId: uid, amount: 200, receiverPhone: '999');
      expect((await lastNotif())['title'], 'Payment Sent');
    });

    test('TC_NOTIF_009 — notifyPaymentSent message contains amount', () async {
      await ns.notifyPaymentSent(senderId: uid, amount: 200, receiverPhone: '999');
      expect((await lastNotif())['message'], contains('₹200.00'));
    });

    test('TC_NOTIF_010 — notifyPaymentSent message contains receiver phone', () async {
      await ns.notifyPaymentSent(senderId: uid, amount: 200, receiverPhone: '9998887776');
      expect((await lastNotif())['message'], contains('9998887776'));
    });
  });

  // ─── PAYMENT RECEIVED (TC_NOTIF_011–015) ─────────────────

  group('NotificationService — Payment Received', () {
    test('TC_NOTIF_011 — notifyPaymentReceived creates notification', () async {
      await ns.notifyPaymentReceived(receiverId: uid, amount: 300, senderPhone: '888');
      expect(await notifCount(), 1);
    });

    test('TC_NOTIF_012 — notifyPaymentReceived type is payment_received', () async {
      await ns.notifyPaymentReceived(receiverId: uid, amount: 300, senderPhone: '888');
      expect((await lastNotif())['type'], 'payment_received');
    });

    test('TC_NOTIF_013 — notifyPaymentReceived title is Payment Received', () async {
      await ns.notifyPaymentReceived(receiverId: uid, amount: 300, senderPhone: '888');
      expect((await lastNotif())['title'], 'Payment Received');
    });

    test('TC_NOTIF_014 — notifyPaymentReceived message contains amount', () async {
      await ns.notifyPaymentReceived(receiverId: uid, amount: 300, senderPhone: '888');
      expect((await lastNotif())['message'], contains('₹300.00'));
    });

    test('TC_NOTIF_015 — notifyPaymentReceived message contains sender phone', () async {
      await ns.notifyPaymentReceived(receiverId: uid, amount: 300, senderPhone: '7778889990');
      expect((await lastNotif())['message'], contains('7778889990'));
    });
  });

  // ─── BANK LINKED / UPDATED (TC_NOTIF_016–021) ─────────────────

  group('NotificationService — Bank Linked & Updated', () {
    test('TC_NOTIF_016 — notifyBankLinked creates notification', () async {
      await ns.notifyBankLinked(uid: uid, bankName: 'SBI', last4: '1234');
      expect(await notifCount(), 1);
    });

    test('TC_NOTIF_017 — notifyBankLinked type is bank_linked', () async {
      await ns.notifyBankLinked(uid: uid, bankName: 'SBI', last4: '1234');
      expect((await lastNotif())['type'], 'bank_linked');
    });

    test('TC_NOTIF_018 — notifyBankLinked message contains bank name', () async {
      await ns.notifyBankLinked(uid: uid, bankName: 'HDFC', last4: '5678');
      expect((await lastNotif())['message'], contains('HDFC'));
    });

    test('TC_NOTIF_019 — notifyBankLinked message contains last4', () async {
      await ns.notifyBankLinked(uid: uid, bankName: 'SBI', last4: '9999');
      expect((await lastNotif())['message'], contains('9999'));
    });

    test('TC_NOTIF_020 — notifyBankUpdated creates notification with bank_updated type', () async {
      await ns.notifyBankUpdated(uid: uid, bankName: 'ICICI', last4: '4321');
      expect((await lastNotif())['type'], 'bank_updated');
    });

    test('TC_NOTIF_021 — notifyBankUpdated title is Bank Updated', () async {
      await ns.notifyBankUpdated(uid: uid, bankName: 'ICICI', last4: '4321');
      expect((await lastNotif())['title'], 'Bank Updated');
    });
  });

  // ─── TRANSFER NOTIFICATIONS (TC_NOTIF_022–027) ─────────────────

  group('NotificationService — Transfer Notifications', () {
    test('TC_NOTIF_022 — notifyTransferToBank type is transfer_to_bank', () async {
      await ns.notifyTransferToBank(uid: uid, amount: 1000);
      expect((await lastNotif())['type'], 'transfer_to_bank');
    });

    test('TC_NOTIF_023 — notifyTransferToBank title is Transfer to Bank', () async {
      await ns.notifyTransferToBank(uid: uid, amount: 1000);
      expect((await lastNotif())['title'], 'Transfer to Bank');
    });

    test('TC_NOTIF_024 — notifyTransferToBank message contains amount', () async {
      await ns.notifyTransferToBank(uid: uid, amount: 750);
      expect((await lastNotif())['message'], contains('₹750.00'));
    });

    test('TC_NOTIF_025 — notifyTransferFromBank type is transfer_from_bank', () async {
      await ns.notifyTransferFromBank(uid: uid, amount: 500);
      expect((await lastNotif())['type'], 'transfer_from_bank');
    });

    test('TC_NOTIF_026 — notifyTransferFromBank title is Added from Bank', () async {
      await ns.notifyTransferFromBank(uid: uid, amount: 500);
      expect((await lastNotif())['title'], 'Added from Bank');
    });

    test('TC_NOTIF_027 — notifyTransferFromBank message contains amount', () async {
      await ns.notifyTransferFromBank(uid: uid, amount: 250);
      expect((await lastNotif())['message'], contains('₹250.00'));
    });
  });

  // ─── WITHDRAWAL (TC_NOTIF_028–033) ─────────────────

  group('NotificationService — Withdrawal Notifications', () {
    test('TC_NOTIF_028 — notifyWithdrawalSubmitted type is withdrawal_submitted', () async {
      await ns.notifyWithdrawalSubmitted(uid: uid, amount: 500);
      expect((await lastNotif())['type'], 'withdrawal_submitted');
    });

    test('TC_NOTIF_029 — notifyWithdrawalSubmitted title is Withdrawal Submitted', () async {
      await ns.notifyWithdrawalSubmitted(uid: uid, amount: 500);
      expect((await lastNotif())['title'], 'Withdrawal Submitted');
    });

    test('TC_NOTIF_030 — notifyWithdrawalApproved type is withdrawal_approved', () async {
      await ns.notifyWithdrawalApproved(uid: uid, amount: 500);
      expect((await lastNotif())['type'], 'withdrawal_approved');
    });

    test('TC_NOTIF_031 — notifyWithdrawalApproved title is Withdrawal Approved', () async {
      await ns.notifyWithdrawalApproved(uid: uid, amount: 500);
      expect((await lastNotif())['title'], 'Withdrawal Approved');
    });

    test('TC_NOTIF_032 — notifyWithdrawalRejected type is withdrawal_rejected', () async {
      await ns.notifyWithdrawalRejected(uid: uid, amount: 500);
      expect((await lastNotif())['type'], 'withdrawal_rejected');
    });

    test('TC_NOTIF_033 — notifyWithdrawalRejected title is Withdrawal Rejected', () async {
      await ns.notifyWithdrawalRejected(uid: uid, amount: 500);
      expect((await lastNotif())['title'], 'Withdrawal Rejected');
    });
  });

  // ─── RAZORPAY (TC_NOTIF_034–037) ─────────────────

  group('NotificationService — Razorpay Notifications', () {
    test('TC_NOTIF_034 — notifyRazorpaySuccess type is add_money', () async {
      await ns.notifyRazorpaySuccess(uid: uid, amount: 100, paymentId: 'pay_x');
      expect((await lastNotif())['type'], 'add_money');
    });

    test('TC_NOTIF_035 — notifyRazorpaySuccess message contains paymentId', () async {
      await ns.notifyRazorpaySuccess(uid: uid, amount: 100, paymentId: 'pay_abc');
      expect((await lastNotif())['message'], contains('pay_abc'));
    });

    test('TC_NOTIF_036 — notifyRazorpayFailure type is add_money_failed', () async {
      await ns.notifyRazorpayFailure(uid: uid, amount: 100, message: 'Gateway error');
      expect((await lastNotif())['type'], 'add_money_failed');
    });

    test('TC_NOTIF_037 — notifyRazorpayFailure message contains error reason', () async {
      await ns.notifyRazorpayFailure(uid: uid, amount: 100, message: 'Gateway error');
      expect((await lastNotif())['message'], contains('Gateway error'));
    });
  });

  // ─── OFFLINE SYNC (TC_NOTIF_038–039) ─────────────────

  group('NotificationService — Offline Sync', () {
    test('TC_NOTIF_038 — notifyOfflineSyncCompleted type is offline_sync', () async {
      await ns.notifyOfflineSyncCompleted(uid: uid);
      expect((await lastNotif())['type'], 'offline_sync');
    });

    test('TC_NOTIF_039 — notifyOfflineSyncCompleted title is Offline Sync Completed', () async {
      await ns.notifyOfflineSyncCompleted(uid: uid);
      expect((await lastNotif())['title'], 'Offline Sync Completed');
    });
  });

  // ─── READ/UNREAD & STREAMS (TC_NOTIF_040–050) ─────────────────

  group('NotificationService — Read/Unread & Streams', () {
    test('TC_NOTIF_040 — markAsRead updates read to true', () async {
      final ref = await fakeFirestore.collection('users').doc(uid).collection('notifications')
          .add({'read': false, 'type': 'test'});
      await ns.markAsRead(uid: uid, notificationId: ref.id);
      final doc = await ref.get();
      expect(doc.data()?['read'], true);
    });

    test('TC_NOTIF_041 — watchUnreadCount returns 0 when all read', () async {
      await fakeFirestore.collection('users').doc(uid).collection('notifications')
          .add({'read': true, 'type': 'a'});
      expect(await ns.watchUnreadCount(uid).first, 0);
    });

    test('TC_NOTIF_042 — watchUnreadCount returns correct unread count', () async {
      final ref = fakeFirestore.collection('users').doc(uid).collection('notifications');
      await ref.add({'read': false, 'type': 'a'});
      await ref.add({'read': false, 'type': 'b'});
      await ref.add({'read': true, 'type': 'c'});
      expect(await ns.watchUnreadCount(uid).first, 2);
    });

    test('TC_NOTIF_043 — watchUnreadCount returns 0 when no notifications', () async {
      expect(await ns.watchUnreadCount(uid).first, 0);
    });

    test('TC_NOTIF_044 — Multiple notifications increment count', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 100);
      await ns.notifyMoneyAdded(uid: uid, amount: 200);
      await ns.notifyMoneyAdded(uid: uid, amount: 300);
      expect(await notifCount(), 3);
    });

    test('TC_NOTIF_045 — markAsRead does not affect other notifications', () async {
      final ref = fakeFirestore.collection('users').doc(uid).collection('notifications');
      final a = await ref.add({'read': false, 'type': 'a'});
      await ref.add({'read': false, 'type': 'b'});
      await ns.markAsRead(uid: uid, notificationId: a.id);
      expect(await ns.watchUnreadCount(uid).first, 1);
    });

    test('TC_NOTIF_046 — Notification for different users are isolated', () async {
      await ns.notifyMoneyAdded(uid: 'userA', amount: 100);
      await ns.notifyMoneyAdded(uid: 'userB', amount: 200);
      final a = await fakeFirestore.collection('users').doc('userA').collection('notifications').get();
      final b = await fakeFirestore.collection('users').doc('userB').collection('notifications').get();
      expect(a.docs.length, 1);
      expect(b.docs.length, 1);
    });

    test('TC_NOTIF_047 — Amount formatting with small decimals', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 0.50);
      expect((await lastNotif())['message'], contains('₹0.50'));
    });

    test('TC_NOTIF_048 — Amount formatting with large number', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 99999.99);
      expect((await lastNotif())['message'], contains('₹99999.99'));
    });

    test('TC_NOTIF_049 — Amount formatting with whole number', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 1000);
      expect((await lastNotif())['message'], contains('₹1000.00'));
    });

    test('TC_NOTIF_050 — All notification types have read=false', () async {
      await ns.notifyMoneyAdded(uid: uid, amount: 1);
      await ns.notifyPaymentSent(senderId: uid, amount: 1, receiverPhone: '1');
      await ns.notifyPaymentReceived(receiverId: uid, amount: 1, senderPhone: '1');
      await ns.notifyBankLinked(uid: uid, bankName: 'X', last4: '1');
      await ns.notifyOfflineSyncCompleted(uid: uid);

      final snapshot = await fakeFirestore.collection('users').doc(uid).collection('notifications').get();
      int unreadCount = 0;
      for (final doc in snapshot.docs) {
        if (doc.data()['read'] == false) {
          unreadCount++;
        }
      }
      expect(unreadCount, 5);
    });
  });
}
