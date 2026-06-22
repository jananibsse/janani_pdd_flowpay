import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flowpay_app/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late NotificationService notificationService;

    const testUid = 'user123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      notificationService = NotificationService(firestore: fakeFirestore);
    });

    test('notifyMoneyAdded creates a notification', () async {
      await notificationService.notifyMoneyAdded(uid: testUid, amount: 500);

      final querySnapshot = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('notifications')
          .get();

      expect(querySnapshot.docs.length, 1);
      final data = querySnapshot.docs.first.data();
      expect(data['type'], 'add_money');
      expect(data['title'], 'Money Added');
      expect(data['message'], contains('500.00'));
      expect(data['read'], false);
    });

    test('watchUnreadCount streams correct count', () async {
      // Create 2 unread, 1 read
      final notifRef = fakeFirestore.collection('users').doc(testUid).collection('notifications');
      await notifRef.add({'read': false, 'type': 'test1'});
      await notifRef.add({'read': false, 'type': 'test2'});
      await notifRef.add({'read': true, 'type': 'test3'});

      final countStream = notificationService.watchUnreadCount(testUid);
      expect(await countStream.first, 2);
    });

    test('markAsRead updates the read status', () async {
      final notifRef = fakeFirestore.collection('users').doc(testUid).collection('notifications');
      final doc = await notifRef.add({'read': false, 'type': 'test1'});

      await notificationService.markAsRead(uid: testUid, notificationId: doc.id);

      final updatedDoc = await doc.get();
      expect(updatedDoc.data()?['read'], true);
    });

    test('notifyPaymentSent creates correct notification', () async {
      await notificationService.notifyPaymentSent(
        senderId: testUid,
        amount: 250,
        receiverPhone: '9998887776',
      );

      final querySnapshot = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('notifications')
          .get();

      expect(querySnapshot.docs.length, 1);
      final data = querySnapshot.docs.first.data();
      expect(data['type'], 'payment_sent');
      expect(data['message'], contains('250.00'));
      expect(data['message'], contains('9998887776'));
    });
  });
}
