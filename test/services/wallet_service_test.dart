import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flowpay_app/services/wallet_service.dart';
import 'package:flowpay_app/services/notification_service.dart';
import 'package:flowpay_app/services/email_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'wallet_service_test.mocks.dart';

@GenerateMocks([NotificationService, EmailService])
void main() {
  group('WalletService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockNotificationService mockNotificationService;
    late MockEmailService mockEmailService;
    late WalletService walletService;

    const testUid = 'user123';
    const testEmail = 'user123@example.com';
    const testPhone = '1234567890';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockNotificationService = MockNotificationService();
      mockEmailService = MockEmailService();

      walletService = WalletService(
        firestore: fakeFirestore,
        notificationService: mockNotificationService,
        emailService: mockEmailService,
      );
    });

    test('createUserWallet creates wallet with initial balance', () async {
      await walletService.createUserWallet(
        uid: testUid,
        email: testEmail,
        phone: testPhone,
      );

      final doc = await fakeFirestore.collection('users').doc(testUid).get();
      expect(doc.exists, true);
      expect(doc.data()?['balance'], 1000.0);
      expect(doc.data()?['email'], testEmail);
    });

    test('ensureWalletExists only creates wallet if missing', () async {
      await walletService.ensureWalletExists(uid: 'user456', email: 'test@test.com');
      final doc1 = await fakeFirestore.collection('users').doc('user456').get();
      expect(doc1.exists, true);
      expect(doc1.data()?['balance'], 1000.0);

      // Call again, should not reset balance
      await fakeFirestore.collection('users').doc('user456').update({'balance': 5000.0});
      await walletService.ensureWalletExists(uid: 'user456', email: 'test@test.com');
      
      final doc2 = await fakeFirestore.collection('users').doc('user456').get();
      expect(doc2.data()?['balance'], 5000.0);
    });

    test('addMoney increments balance and creates transaction', () async {
      await walletService.createUserWallet(uid: testUid, email: testEmail, phone: testPhone);

      when(mockNotificationService.notifyMoneyAdded(uid: testUid, amount: 500.0))
          .thenAnswer((_) async {});

      await walletService.addMoney(uid: testUid, amount: 500.0);

      final doc = await fakeFirestore.collection('users').doc(testUid).get();
      expect(doc.data()?['balance'], 1500.0);

      final txSnapshot = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .get();
      
      expect(txSnapshot.docs.length, 1);
      expect(txSnapshot.docs.first.data()['amount'], 500.0);
      expect(txSnapshot.docs.first.data()['type'], 'credit');
    });

    test('addMoney throws if amount is zero or less', () async {
      expect(
        () => walletService.addMoney(uid: testUid, amount: -100),
        throwsArgumentError,
      );
    });

    test('sendMoney successfully transfers funds', () async {
      const senderId = 'sender1';
      const receiverId = 'receiver1';

      await walletService.createUserWallet(uid: senderId, email: 's@s.com', phone: '111');
      await walletService.createUserWallet(uid: receiverId, email: 'r@r.com', phone: '222');

      when(mockNotificationService.notifyPaymentSent(
              senderId: anyNamed('senderId'), amount: anyNamed('amount'), receiverPhone: anyNamed('receiverPhone')))
          .thenAnswer((_) async {});
      when(mockNotificationService.notifyPaymentReceived(
              receiverId: anyNamed('receiverId'), amount: anyNamed('amount'), senderPhone: anyNamed('senderPhone')))
          .thenAnswer((_) async {});
      
      when(mockEmailService.sendPaymentSentEmail(
        toEmail: anyNamed('toEmail'),
        userName: anyNamed('userName'),
        amount: anyNamed('amount'),
        receiverPhone: anyNamed('receiverPhone'),
        transactionId: anyNamed('transactionId'),
        timestamp: anyNamed('timestamp'),
      )).thenAnswer((_) async {});

      when(mockEmailService.sendPaymentReceivedEmail(
        toEmail: anyNamed('toEmail'),
        userName: anyNamed('userName'),
        amount: anyNamed('amount'),
        senderPhone: anyNamed('senderPhone'),
        transactionId: anyNamed('transactionId'),
        timestamp: anyNamed('timestamp'),
      )).thenAnswer((_) async {});

      await walletService.sendMoney(
        senderId: senderId,
        senderPhone: '111',
        receiverId: receiverId,
        receiverPhone: '222',
        amount: 200,
      );

      final senderDoc = await fakeFirestore.collection('users').doc(senderId).get();
      final receiverDoc = await fakeFirestore.collection('users').doc(receiverId).get();

      expect(senderDoc.data()?['balance'], 800.0);
      expect(receiverDoc.data()?['balance'], 1200.0);

      final payments = await fakeFirestore.collection('transactions').get();
      expect(payments.docs.length, 1);
      expect(payments.docs.first.data()['amount'], 200);
      expect(payments.docs.first.data()['status'], 'completed');
    });

    test('sendMoney throws error if insufficient funds', () async {
      const senderId = 'sender1';
      const receiverId = 'receiver1';

      await walletService.createUserWallet(uid: senderId, email: 's@s.com', phone: '111');
      await walletService.createUserWallet(uid: receiverId, email: 'r@r.com', phone: '222');

      expect(
        () => walletService.sendMoney(
          senderId: senderId,
          senderPhone: '111',
          receiverId: receiverId,
          receiverPhone: '222',
          amount: 5000,
        ),
        throwsA(isA<WalletException>().having((e) => e.message, 'message', 'Insufficient balance.')),
      );
    });

    test('verifyWalletPin correctly hashes and checks PIN', () async {
      await walletService.createUserWallet(uid: testUid, email: testEmail, phone: testPhone);
      await walletService.setWalletPin(testUid, '123456');

      final isCorrect = await walletService.verifyWalletPin(testUid, '123456');
      expect(isCorrect, isTrue);

      final isWrong = await walletService.verifyWalletPin(testUid, '654321');
      expect(isWrong, isFalse);
    });
  });
}
