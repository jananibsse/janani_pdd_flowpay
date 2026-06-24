import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flowpay_app/services/wallet_service.dart';
import 'package:flowpay_app/services/notification_service.dart';
import 'package:flowpay_app/services/email_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'wallet_service_test.mocks.dart';

@GenerateMocks([NotificationService, EmailService])

/// ═══════════════════════════════════════════════════════════════
/// FlowPay Backend Test Suite — WALLET SERVICE (100 Test Cases)
/// Covers: Wallet CRUD, Transfers, Banking, PIN, Razorpay,
///         Withdrawals, and Edge Cases
/// ═══════════════════════════════════════════════════════════════
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockNotificationService mockNotif;
  late MockEmailService mockEmail;
  late WalletService ws;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockNotif = MockNotificationService();
    mockEmail = MockEmailService();
    ws = WalletService(
      firestore: fakeFirestore,
      notificationService: mockNotif,
      emailService: mockEmail,
    );

    // Stub all notification methods so they don't throw
    when(mockNotif.notifyMoneyAdded(uid: anyNamed('uid'), amount: anyNamed('amount')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyPaymentSent(senderId: anyNamed('senderId'), amount: anyNamed('amount'), receiverPhone: anyNamed('receiverPhone')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyPaymentReceived(receiverId: anyNamed('receiverId'), amount: anyNamed('amount'), senderPhone: anyNamed('senderPhone')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyTransferToBank(uid: anyNamed('uid'), amount: anyNamed('amount')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyTransferFromBank(uid: anyNamed('uid'), amount: anyNamed('amount')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyBankLinked(uid: anyNamed('uid'), bankName: anyNamed('bankName'), last4: anyNamed('last4')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyBankUpdated(uid: anyNamed('uid'), bankName: anyNamed('bankName'), last4: anyNamed('last4')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyWithdrawalSubmitted(uid: anyNamed('uid'), amount: anyNamed('amount')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyWithdrawalApproved(uid: anyNamed('uid'), amount: anyNamed('amount')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyWithdrawalRejected(uid: anyNamed('uid'), amount: anyNamed('amount')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyRazorpaySuccess(uid: anyNamed('uid'), amount: anyNamed('amount'), paymentId: anyNamed('paymentId')))
        .thenAnswer((_) async {});
    when(mockNotif.notifyRazorpayFailure(uid: anyNamed('uid'), amount: anyNamed('amount'), message: anyNamed('message')))
        .thenAnswer((_) async {});
    when(mockEmail.sendPaymentSentEmail(toEmail: anyNamed('toEmail'), userName: anyNamed('userName'), amount: anyNamed('amount'), receiverPhone: anyNamed('receiverPhone'), transactionId: anyNamed('transactionId'), timestamp: anyNamed('timestamp')))
        .thenAnswer((_) async {});
    when(mockEmail.sendPaymentReceivedEmail(toEmail: anyNamed('toEmail'), userName: anyNamed('userName'), amount: anyNamed('amount'), senderPhone: anyNamed('senderPhone'), transactionId: anyNamed('transactionId'), timestamp: anyNamed('timestamp')))
        .thenAnswer((_) async {});
    when(mockEmail.sendWithdrawalSubmittedEmail(toEmail: anyNamed('toEmail'), userName: anyNamed('userName'), amount: anyNamed('amount'), bankName: anyNamed('bankName'), accountLast4: anyNamed('accountLast4'), upiId: anyNamed('upiId'), withdrawalId: anyNamed('withdrawalId'), timestamp: anyNamed('timestamp')))
        .thenAnswer((_) async {});
  });

  Future<String> createWallet({String uid = 'default', String email = 'u@t.com', String phone = '111', double balance = 1000}) async {
    await fakeFirestore.collection('users').doc(uid).set({
      'uid': uid, 'email': email, 'phone': phone, 'balance': balance,
    });
    return uid;
  }

  Future<String> createLinkedWallet({String uid = 'linked_user', double balance = 1000, double bankBalance = 25000}) async {
    await fakeFirestore.collection('users').doc(uid).set({
      'uid': uid, 'email': '$uid@t.com', 'phone': '111', 'balance': balance,
      'isBankLinked': true, 'bankName': 'SBI', 'bankBalance': bankBalance,
    });
    return uid;
  }

  // ─── WALLET CREATION (TC_WAL_001–020) ─────────────────

  group('WalletService — Wallet Creation', () {
    test('TC_WAL_001 — createUserWallet creates doc with initial balance 1000', () async {
      await ws.createUserWallet(uid: 'w1', email: 'w1@t.com', phone: '111');
      final doc = await fakeFirestore.collection('users').doc('w1').get();
      expect(doc.exists, true);
      expect(doc.data()?['balance'], 1000.0);
    });

    test('TC_WAL_002 — createUserWallet stores email', () async {
      await ws.createUserWallet(uid: 'w2', email: 'w2@t.com', phone: '222');
      final doc = await fakeFirestore.collection('users').doc('w2').get();
      expect(doc.data()?['email'], 'w2@t.com');
    });

    test('TC_WAL_003 — createUserWallet stores phone', () async {
      await ws.createUserWallet(uid: 'w3', email: 'w3@t.com', phone: '333');
      final doc = await fakeFirestore.collection('users').doc('w3').get();
      expect(doc.data()?['phone'], '333');
    });

    test('TC_WAL_004 — createUserWallet trims email', () async {
      await ws.createUserWallet(uid: 'w4', email: '  w4@t.com  ', phone: '444');
      final doc = await fakeFirestore.collection('users').doc('w4').get();
      expect(doc.data()?['email'], 'w4@t.com');
    });

    test('TC_WAL_005 — createUserWallet trims phone', () async {
      await ws.createUserWallet(uid: 'w5', email: 'w5@t.com', phone: '  555  ');
      final doc = await fakeFirestore.collection('users').doc('w5').get();
      expect(doc.data()?['phone'], '555');
    });

    test('TC_WAL_006 — createUserWallet stores uid field', () async {
      await ws.createUserWallet(uid: 'w6', email: 'w6@t.com', phone: '666');
      final doc = await fakeFirestore.collection('users').doc('w6').get();
      expect(doc.data()?['uid'], 'w6');
    });

    test('TC_WAL_007 — ensureWalletExists creates wallet if not exist', () async {
      await ws.ensureWalletExists(uid: 'e7', email: 'e7@t.com');
      final doc = await fakeFirestore.collection('users').doc('e7').get();
      expect(doc.exists, true);
      expect(doc.data()?['balance'], 1000.0);
    });

    test('TC_WAL_008 — ensureWalletExists does not overwrite existing wallet', () async {
      Future<String> createWalletHelper({double initialBalance = 1000}) async {
        await ws.ensureWalletExists(uid: 'e8', email: 'e8@t.com');
        if (initialBalance != 1000) {
          await ws.addMoney(uid: 'e8', amount: initialBalance - 1000);
        }
        return 'e8';
      }
      await createWalletHelper(initialBalance: 5000);
      await ws.ensureWalletExists(uid: 'e8', email: 'e8@t.com');
      final doc = await fakeFirestore.collection('users').doc('e8').get();
      expect(doc.data()?['balance'], 5000.0);
    });

    test('TC_WAL_009 — getUserIdByEmail returns uid for existing email', () async {
      await createWallet(uid: 'u9', email: 'find@t.com');
      final id = await ws.getUserIdByEmail('find@t.com');
      expect(id, 'u9');
    });

    test('TC_WAL_010 — getUserIdByEmail returns null for non-existent email', () async {
      final id = await ws.getUserIdByEmail('ghost@t.com');
      expect(id, isNull);
    });

    test('TC_WAL_011 — getUserIdByEmail trims input', () async {
      await createWallet(uid: 'u11', email: 'trim@t.com');
      final id = await ws.getUserIdByEmail('  trim@t.com  ');
      expect(id, 'u11');
    });

    test('TC_WAL_012 — getUserIdByPhone returns uid for existing phone', () async {
      await createWallet(uid: 'u12', phone: '9876');
      final id = await ws.getUserIdByPhone('9876');
      expect(id, 'u12');
    });

    test('TC_WAL_013 — getUserIdByPhone returns null for non-existent phone', () async {
      final id = await ws.getUserIdByPhone('0000');
      expect(id, isNull);
    });

    test('TC_WAL_014 — getUserIdByPhone trims input', () async {
      await createWallet(uid: 'u14', phone: '1414');
      final id = await ws.getUserIdByPhone('  1414  ');
      expect(id, 'u14');
    });

    test('TC_WAL_015 — initialBalance constant is 1000', () {
      expect(WalletService.initialBalance, 1000);
    });

    test('TC_WAL_016 — usersCollection constant is users', () {
      expect(WalletService.usersCollection, 'users');
    });

    test('TC_WAL_017 — Multiple wallets can be created for different users', () async {
      await ws.createUserWallet(uid: 'ma', email: 'ma@t.com', phone: '1');
      await ws.createUserWallet(uid: 'mb', email: 'mb@t.com', phone: '2');
      final a = await fakeFirestore.collection('users').doc('ma').get();
      final b = await fakeFirestore.collection('users').doc('mb').get();
      expect(a.exists, true);
      expect(b.exists, true);
    });

    test('TC_WAL_018 — createUserWallet with empty phone', () async {
      await ws.createUserWallet(uid: 'ep', email: 'ep@t.com', phone: '');
      final doc = await fakeFirestore.collection('users').doc('ep').get();
      expect(doc.data()?['phone'], '');
    });

    test('TC_WAL_019 — createUserWallet with unicode email', () async {
      await ws.createUserWallet(uid: 'ue', email: 'über@t.com', phone: '19');
      final doc = await fakeFirestore.collection('users').doc('ue').get();
      expect(doc.exists, true);
    });

    test('TC_WAL_020 — ensureWalletExists with default phone parameter', () async {
      await ws.ensureWalletExists(uid: 'dp', email: 'dp@t.com');
      final doc = await fakeFirestore.collection('users').doc('dp').get();
      expect(doc.data()?['phone'], '');
    });
  });

  // ─── ADD MONEY (TC_WAL_021–035) ─────────────────

  group('WalletService — Add Money', () {
    test('TC_WAL_021 — addMoney increments balance', () async {
      await createWallet(uid: 'am1');
      await ws.addMoney(uid: 'am1', amount: 500);
      final doc = await fakeFirestore.collection('users').doc('am1').get();
      expect(doc.data()?['balance'], 1500.0);
    });

    test('TC_WAL_022 — addMoney creates credit transaction record', () async {
      await createWallet(uid: 'am2');
      await ws.addMoney(uid: 'am2', amount: 200);
      final txs = await fakeFirestore.collection('users').doc('am2').collection('transactions').get();
      expect(txs.docs.length, 1);
      expect(txs.docs.first.data()['type'], 'credit');
    });

    test('TC_WAL_023 — addMoney transaction has correct amount', () async {
      await createWallet(uid: 'am3');
      await ws.addMoney(uid: 'am3', amount: 750);
      final txs = await fakeFirestore.collection('users').doc('am3').collection('transactions').get();
      expect(txs.docs.first.data()['amount'], 750);
    });

    test('TC_WAL_024 — addMoney transaction description is Added money', () async {
      await createWallet(uid: 'am4');
      await ws.addMoney(uid: 'am4', amount: 100);
      final txs = await fakeFirestore.collection('users').doc('am4').collection('transactions').get();
      expect(txs.docs.first.data()['description'], 'Added money');
    });

    test('TC_WAL_025 — addMoney throws ArgumentError for zero amount', () {
      expect(() => ws.addMoney(uid: 'am5', amount: 0), throwsArgumentError);
    });

    test('TC_WAL_026 — addMoney throws ArgumentError for negative amount', () {
      expect(() => ws.addMoney(uid: 'am6', amount: -100), throwsArgumentError);
    });

    test('TC_WAL_027 — addMoney calls notification service', () async {
      await createWallet(uid: 'am7');
      await ws.addMoney(uid: 'am7', amount: 100);
      verify(mockNotif.notifyMoneyAdded(uid: 'am7', amount: 100)).called(1);
    });

    test('TC_WAL_028 — addMoney with very small amount (0.01)', () async {
      await createWallet(uid: 'am8');
      await ws.addMoney(uid: 'am8', amount: 0.01);
      final doc = await fakeFirestore.collection('users').doc('am8').get();
      expect(doc.data()?['balance'], closeTo(1000.01, 0.001));
    });

    test('TC_WAL_029 — addMoney with very large amount (999999)', () async {
      await createWallet(uid: 'am9');
      await ws.addMoney(uid: 'am9', amount: 999999);
      final doc = await fakeFirestore.collection('users').doc('am9').get();
      expect(doc.data()?['balance'], 1000999);
    });

    test('TC_WAL_030 — addMoney twice accumulates correctly', () async {
      await createWallet(uid: 'am10');
      await ws.addMoney(uid: 'am10', amount: 300);
      await ws.addMoney(uid: 'am10', amount: 200);
      final doc = await fakeFirestore.collection('users').doc('am10').get();
      expect(doc.data()?['balance'], 1500.0);
    });

    test('TC_WAL_031 — addMoney creates 2 transaction records after 2 calls', () async {
      await createWallet(uid: 'am11');
      await ws.addMoney(uid: 'am11', amount: 100);
      await ws.addMoney(uid: 'am11', amount: 200);
      final txs = await fakeFirestore.collection('users').doc('am11').collection('transactions').get();
      expect(txs.docs.length, 2);
    });

    test('TC_WAL_032 — addMoney with decimal amount (123.45)', () async {
      await createWallet(uid: 'am12');
      await ws.addMoney(uid: 'am12', amount: 123.45);
      final doc = await fakeFirestore.collection('users').doc('am12').get();
      expect(doc.data()?['balance'], closeTo(1123.45, 0.01));
    });

    test('TC_WAL_033 — addMoney to wallet with zero balance', () async {
      await createWallet(uid: 'am13', balance: 0);
      await ws.addMoney(uid: 'am13', amount: 500);
      final doc = await fakeFirestore.collection('users').doc('am13').get();
      expect(doc.data()?['balance'], 500.0);
    });

    test('TC_WAL_034 — addMoney with amount just above zero (0.001)', () async {
      await createWallet(uid: 'am14');
      await ws.addMoney(uid: 'am14', amount: 0.001);
      final doc = await fakeFirestore.collection('users').doc('am14').get();
      expect(doc.data()?['balance'], closeTo(1000.001, 0.0001));
    });

    test('TC_WAL_035 — addMoney to different users independently', () async {
      await createWallet(uid: 'amA', balance: 100);
      await createWallet(uid: 'amB', balance: 200);
      await ws.addMoney(uid: 'amA', amount: 50);
      await ws.addMoney(uid: 'amB', amount: 75);
      final a = await fakeFirestore.collection('users').doc('amA').get();
      final b = await fakeFirestore.collection('users').doc('amB').get();
      expect(a.data()?['balance'], 150.0);
      expect(b.data()?['balance'], 275.0);
    });
  });

  // ─── SEND MONEY (TC_WAL_036–060) ─────────────────

  group('WalletService — Send Money', () {
    test('TC_WAL_036 — sendMoney deducts from sender', () async {
      await createWallet(uid: 's1', balance: 1000);
      await createWallet(uid: 'r1', balance: 500);
      await ws.sendMoney(senderId: 's1', senderPhone: '1', receiverId: 'r1', receiverPhone: '2', amount: 200);
      final doc = await fakeFirestore.collection('users').doc('s1').get();
      expect(doc.data()?['balance'], 800.0);
    });

    test('TC_WAL_037 — sendMoney credits receiver', () async {
      await createWallet(uid: 's2', balance: 1000);
      await createWallet(uid: 'r2', balance: 500);
      await ws.sendMoney(senderId: 's2', senderPhone: '1', receiverId: 'r2', receiverPhone: '2', amount: 200);
      final doc = await fakeFirestore.collection('users').doc('r2').get();
      expect(doc.data()?['balance'], 700.0);
    });

    test('TC_WAL_038 — sendMoney creates payment transaction', () async {
      await createWallet(uid: 's3', balance: 1000);
      await createWallet(uid: 'r3', balance: 500);
      await ws.sendMoney(senderId: 's3', senderPhone: '1', receiverId: 'r3', receiverPhone: '2', amount: 100);
      final txs = await fakeFirestore.collection('transactions').get();
      expect(txs.docs.isNotEmpty, true);
      expect(txs.docs.first.data()['status'], 'completed');
    });

    test('TC_WAL_039 — sendMoney creates debit record for sender', () async {
      await createWallet(uid: 's4', balance: 1000);
      await createWallet(uid: 'r4', balance: 500);
      await ws.sendMoney(senderId: 's4', senderPhone: '1', receiverId: 'r4', receiverPhone: '2', amount: 100);
      final txs = await fakeFirestore.collection('users').doc('s4').collection('transactions').get();
      expect(txs.docs.any((d) => d.data()['type'] == 'debit'), true);
    });

    test('TC_WAL_040 — sendMoney creates credit record for receiver', () async {
      await createWallet(uid: 's5', balance: 1000);
      await createWallet(uid: 'r5', balance: 500);
      await ws.sendMoney(senderId: 's5', senderPhone: '1', receiverId: 'r5', receiverPhone: '2', amount: 100);
      final txs = await fakeFirestore.collection('users').doc('r5').collection('transactions').get();
      expect(txs.docs.any((d) => d.data()['type'] == 'credit'), true);
    });

    test('TC_WAL_041 — sendMoney throws on self-transfer', () {
      expect(
        () => ws.sendMoney(senderId: 'same', senderPhone: '1', receiverId: 'same', receiverPhone: '2', amount: 100),
        throwsA(isA<WalletException>()),
      );
    });

    test('TC_WAL_042 — sendMoney self-transfer error message', () {
      expect(
        () => ws.sendMoney(senderId: 'same', senderPhone: '1', receiverId: 'same', receiverPhone: '2', amount: 100),
        throwsA(isA<WalletException>().having((e) => e.message, 'msg', 'You cannot send money to yourself.')),
      );
    });

    test('TC_WAL_043 — sendMoney throws for zero amount', () {
      expect(
        () => ws.sendMoney(senderId: 'a', senderPhone: '1', receiverId: 'b', receiverPhone: '2', amount: 0),
        throwsA(isA<WalletException>()),
      );
    });

    test('TC_WAL_044 — sendMoney throws for negative amount', () {
      expect(
        () => ws.sendMoney(senderId: 'a', senderPhone: '1', receiverId: 'b', receiverPhone: '2', amount: -50),
        throwsA(isA<WalletException>()),
      );
    });

    test('TC_WAL_045 — sendMoney throws for insufficient balance', () async {
      await createWallet(uid: 's45', balance: 100);
      await createWallet(uid: 'r45', balance: 0);
      expect(
        () => ws.sendMoney(senderId: 's45', senderPhone: '1', receiverId: 'r45', receiverPhone: '2', amount: 500),
        throwsA(isA<WalletException>().having((e) => e.message, 'msg', 'Insufficient balance.')),
      );
    });

    test('TC_WAL_046 — sendMoney exact balance succeeds', () async {
      await createWallet(uid: 's46', balance: 500);
      await createWallet(uid: 'r46', balance: 0);
      await ws.sendMoney(senderId: 's46', senderPhone: '1', receiverId: 'r46', receiverPhone: '2', amount: 500);
      final doc = await fakeFirestore.collection('users').doc('s46').get();
      expect(doc.data()?['balance'], 0.0);
    });

    test('TC_WAL_047 — sendMoney calls notifyPaymentSent', () async {
      await createWallet(uid: 's47', balance: 1000);
      await createWallet(uid: 'r47', balance: 0);
      await ws.sendMoney(senderId: 's47', senderPhone: '1', receiverId: 'r47', receiverPhone: '2', amount: 100);
      verify(mockNotif.notifyPaymentSent(senderId: 's47', amount: 100, receiverPhone: '2')).called(1);
    });

    test('TC_WAL_048 — sendMoney calls notifyPaymentReceived', () async {
      await createWallet(uid: 's48', balance: 1000);
      await createWallet(uid: 'r48', balance: 0);
      await ws.sendMoney(senderId: 's48', senderPhone: '1', receiverId: 'r48', receiverPhone: '2', amount: 100);
      verify(mockNotif.notifyPaymentReceived(receiverId: 'r48', amount: 100, senderPhone: '1')).called(1);
    });

    test('TC_WAL_049 — sendMoney with decimal amount', () async {
      await createWallet(uid: 's49', balance: 1000);
      await createWallet(uid: 'r49', balance: 0);
      await ws.sendMoney(senderId: 's49', senderPhone: '1', receiverId: 'r49', receiverPhone: '2', amount: 99.99);
      final s = await fakeFirestore.collection('users').doc('s49').get();
      expect(s.data()?['balance'], closeTo(900.01, 0.01));
    });

    test('TC_WAL_050 — sendMoney payment record has correct amount', () async {
      await createWallet(uid: 's50', balance: 1000);
      await createWallet(uid: 'r50', balance: 0);
      await ws.sendMoney(senderId: 's50', senderPhone: '1', receiverId: 'r50', receiverPhone: '2', amount: 333);
      final txs = await fakeFirestore.collection('transactions').get();
      final match = txs.docs.where((d) => d.data()['amount'] == 333).toList();
      expect(match.isNotEmpty, true);
    });

    test('TC_WAL_051 — sendMoney payment has senderId field', () async {
      await createWallet(uid: 's51', balance: 1000);
      await createWallet(uid: 'r51', balance: 0);
      await ws.sendMoney(senderId: 's51', senderPhone: '1', receiverId: 'r51', receiverPhone: '2', amount: 100);
      final txs = await fakeFirestore.collection('transactions').get();
      expect(txs.docs.first.data()['senderId'], 's51');
    });

    test('TC_WAL_052 — sendMoney payment has receiverId field', () async {
      await createWallet(uid: 's52', balance: 1000);
      await createWallet(uid: 'r52', balance: 0);
      await ws.sendMoney(senderId: 's52', senderPhone: '1', receiverId: 'r52', receiverPhone: '2', amount: 100);
      final txs = await fakeFirestore.collection('transactions').get();
      expect(txs.docs.first.data()['receiverId'], 'r52');
    });

    test('TC_WAL_053 — sendMoney trims receiver phone', () async {
      await createWallet(uid: 's53', balance: 1000);
      await createWallet(uid: 'r53', balance: 0);
      await ws.sendMoney(senderId: 's53', senderPhone: '  111  ', receiverId: 'r53', receiverPhone: '  222  ', amount: 50);
      final txs = await fakeFirestore.collection('transactions').get();
      expect(txs.docs.first.data()['receiverPhone'], '222');
    });

    test('TC_WAL_054 — sendMoney sender tx description contains receiver phone', () async {
      await createWallet(uid: 's54', balance: 1000);
      await createWallet(uid: 'r54', balance: 0);
      await ws.sendMoney(senderId: 's54', senderPhone: '1', receiverId: 'r54', receiverPhone: '9999', amount: 50);
      final txs = await fakeFirestore.collection('users').doc('s54').collection('transactions').get();
      expect(txs.docs.first.data()['description'], contains('9999'));
    });

    test('TC_WAL_055 — sendMoney receiver tx description contains sender phone', () async {
      await createWallet(uid: 's55', balance: 1000);
      await createWallet(uid: 'r55', balance: 0);
      await ws.sendMoney(senderId: 's55', senderPhone: '8888', receiverId: 'r55', receiverPhone: '2', amount: 50);
      final txs = await fakeFirestore.collection('users').doc('r55').collection('transactions').get();
      expect(txs.docs.first.data()['description'], contains('8888'));
    });

    test('TC_WAL_056 — Multiple sequential sends reduce balance correctly', () async {
      await createWallet(uid: 's56', balance: 1000);
      await createWallet(uid: 'r56', balance: 0);
      await ws.sendMoney(senderId: 's56', senderPhone: '1', receiverId: 'r56', receiverPhone: '2', amount: 100);
      await ws.sendMoney(senderId: 's56', senderPhone: '1', receiverId: 'r56', receiverPhone: '2', amount: 200);
      final s = await fakeFirestore.collection('users').doc('s56').get();
      expect(s.data()?['balance'], 700.0);
    });

    test('TC_WAL_057 — sendMoney receiver balance after multiple receives', () async {
      await createWallet(uid: 's57', balance: 1000);
      await createWallet(uid: 'r57', balance: 100);
      await ws.sendMoney(senderId: 's57', senderPhone: '1', receiverId: 'r57', receiverPhone: '2', amount: 150);
      await ws.sendMoney(senderId: 's57', senderPhone: '1', receiverId: 'r57', receiverPhone: '2', amount: 250);
      final r = await fakeFirestore.collection('users').doc('r57').get();
      expect(r.data()?['balance'], 500.0);
    });

    test('TC_WAL_058 — sendMoney with minimum amount (0.01)', () async {
      await createWallet(uid: 's58', balance: 1000);
      await createWallet(uid: 'r58', balance: 0);
      await ws.sendMoney(senderId: 's58', senderPhone: '1', receiverId: 'r58', receiverPhone: '2', amount: 0.01);
      final s = await fakeFirestore.collection('users').doc('s58').get();
      expect(s.data()?['balance'], closeTo(999.99, 0.01));
    });

    test('TC_WAL_059 — sendMoney with large amount (99999)', () async {
      await createWallet(uid: 's59', balance: 100000);
      await createWallet(uid: 'r59', balance: 0);
      await ws.sendMoney(senderId: 's59', senderPhone: '1', receiverId: 'r59', receiverPhone: '2', amount: 99999);
      final s = await fakeFirestore.collection('users').doc('s59').get();
      expect(s.data()?['balance'], 1.0);
    });

    test('TC_WAL_060 — sendMoney bidirectional (A→B then B→A)', () async {
      await createWallet(uid: 'a60', balance: 1000);
      await createWallet(uid: 'b60', balance: 1000);
      await ws.sendMoney(senderId: 'a60', senderPhone: '1', receiverId: 'b60', receiverPhone: '2', amount: 300);
      await ws.sendMoney(senderId: 'b60', senderPhone: '2', receiverId: 'a60', receiverPhone: '1', amount: 150);
      final a = await fakeFirestore.collection('users').doc('a60').get();
      final b = await fakeFirestore.collection('users').doc('b60').get();
      expect(a.data()?['balance'], 850.0);
      expect(b.data()?['balance'], 1150.0);
    });
  });

  // ─── PIN HASHING & VERIFICATION (TC_WAL_061–075) ─────────────────

  group('WalletService — PIN Hashing & Verification', () {
    test('TC_WAL_061 — hashPin returns non-empty string', () {
      expect(ws.hashPin('1234').isNotEmpty, true);
    });

    test('TC_WAL_062 — hashPin returns 64-char hex (SHA-256)', () {
      expect(ws.hashPin('1234').length, 64);
    });

    test('TC_WAL_063 — hashPin is deterministic', () {
      expect(ws.hashPin('5678'), ws.hashPin('5678'));
    });

    test('TC_WAL_064 — Different PINs produce different hashes', () {
      expect(ws.hashPin('1234'), isNot(ws.hashPin('5678')));
    });

    test('TC_WAL_065 — setWalletPin stores hash in Firestore', () async {
      await createWallet(uid: 'p65');
      await ws.setWalletPin('p65', '123456');
      final doc = await fakeFirestore.collection('users').doc('p65').get();
      expect(doc.data()?['walletPinHash'], isNotNull);
      expect(doc.data()?['walletPinHash'], ws.hashPin('123456'));
    });

    test('TC_WAL_066 — verifyWalletPin returns true for correct PIN', () async {
      await createWallet(uid: 'p66');
      await ws.setWalletPin('p66', '111111');
      expect(await ws.verifyWalletPin('p66', '111111'), true);
    });

    test('TC_WAL_067 — verifyWalletPin returns false for wrong PIN', () async {
      await createWallet(uid: 'p67');
      await ws.setWalletPin('p67', '111111');
      expect(await ws.verifyWalletPin('p67', '222222'), false);
    });

    test('TC_WAL_068 — verifyWalletPin throws if PIN not set', () async {
      await createWallet(uid: 'p68');
      expect(
        () => ws.verifyWalletPin('p68', '123456'),
        throwsA(isA<WalletException>().having((e) => e.message, 'msg', 'Wallet PIN not set.')),
      );
    });

    test('TC_WAL_069 — verifyWalletPin throws if user not found', () async {
      expect(
        () => ws.verifyWalletPin('ghost', '123456'),
        throwsA(isA<WalletException>()),
      );
    });

    test('TC_WAL_070 — setWalletPin can be called twice (updates hash)', () async {
      await createWallet(uid: 'p70');
      await ws.setWalletPin('p70', '111111');
      await ws.setWalletPin('p70', '222222');
      expect(await ws.verifyWalletPin('p70', '222222'), true);
      expect(await ws.verifyWalletPin('p70', '111111'), false);
    });

    test('TC_WAL_071 — hashPin of empty string returns valid hash', () {
      expect(ws.hashPin('').length, 64);
    });

    test('TC_WAL_072 — hashPin of very long PIN returns 64-char hash', () {
      expect(ws.hashPin('1' * 1000).length, 64);
    });

    test('TC_WAL_073 — hashPin of unicode PIN returns valid hash', () {
      expect(ws.hashPin('パスワード').length, 64);
    });

    test('TC_WAL_074 — hashPin of alphanumeric PIN', () {
      expect(ws.hashPin('abc123'), isNot(ws.hashPin('123abc')));
    });

    test('TC_WAL_075 — setWalletPin and verify with 4-digit PIN', () async {
      await createWallet(uid: 'p75');
      await ws.setWalletPin('p75', '9999');
      expect(await ws.verifyWalletPin('p75', '9999'), true);
    });
  });

  // ─── BANK TRANSFERS (TC_WAL_076–090) ─────────────────

  group('WalletService — Bank Transfers', () {
    test('TC_WAL_076 — transferWalletToBank deducts wallet balance', () async {
      await createLinkedWallet(uid: 'tb76');
      await ws.transferWalletToBank(uid: 'tb76', amount: 200);
      final doc = await fakeFirestore.collection('users').doc('tb76').get();
      expect(doc.data()?['balance'], 800.0);
    });

    test('TC_WAL_077 — transferWalletToBank increases bank balance', () async {
      await createLinkedWallet(uid: 'tb77', bankBalance: 5000);
      await ws.transferWalletToBank(uid: 'tb77', amount: 300);
      final doc = await fakeFirestore.collection('users').doc('tb77').get();
      expect(doc.data()?['bankBalance'], 5300.0);
    });

    test('TC_WAL_078 — transferWalletToBank creates debit transaction', () async {
      await createLinkedWallet(uid: 'tb78');
      await ws.transferWalletToBank(uid: 'tb78', amount: 100);
      final txs = await fakeFirestore.collection('users').doc('tb78').collection('transactions').get();
      expect(txs.docs.first.data()['type'], 'debit');
    });

    test('TC_WAL_079 — transferWalletToBank throws for insufficient balance', () async {
      await createLinkedWallet(uid: 'tb79', balance: 50);
      expect(
        () => ws.transferWalletToBank(uid: 'tb79', amount: 200),
        throwsA(isA<WalletException>().having((e) => e.message, 'msg', 'Insufficient wallet balance.')),
      );
    });

    test('TC_WAL_080 — transferWalletToBank throws for zero amount', () {
      expect(() => ws.transferWalletToBank(uid: 'x', amount: 0), throwsA(isA<WalletException>()));
    });

    test('TC_WAL_081 — transferWalletToBank throws for negative amount', () {
      expect(() => ws.transferWalletToBank(uid: 'x', amount: -100), throwsA(isA<WalletException>()));
    });

    test('TC_WAL_082 — transferWalletToBank throws if bank not linked', () async {
      await createWallet(uid: 'tb82');
      expect(
        () => ws.transferWalletToBank(uid: 'tb82', amount: 100),
        throwsA(isA<WalletException>().having((e) => e.message, 'msg', 'Bank account is not linked.')),
      );
    });

    test('TC_WAL_083 — transferBankToWallet increases wallet balance', () async {
      await createLinkedWallet(uid: 'tb83', bankBalance: 5000);
      await ws.transferBankToWallet(uid: 'tb83', amount: 500);
      final doc = await fakeFirestore.collection('users').doc('tb83').get();
      expect(doc.data()?['balance'], 1500.0);
    });

    test('TC_WAL_084 — transferBankToWallet decreases bank balance', () async {
      await createLinkedWallet(uid: 'tb84', bankBalance: 5000);
      await ws.transferBankToWallet(uid: 'tb84', amount: 500);
      final doc = await fakeFirestore.collection('users').doc('tb84').get();
      expect(doc.data()?['bankBalance'], 4500.0);
    });

    test('TC_WAL_085 — transferBankToWallet creates credit transaction', () async {
      await createLinkedWallet(uid: 'tb85', bankBalance: 5000);
      await ws.transferBankToWallet(uid: 'tb85', amount: 100);
      final txs = await fakeFirestore.collection('users').doc('tb85').collection('transactions').get();
      expect(txs.docs.first.data()['type'], 'credit');
    });

    test('TC_WAL_086 — transferBankToWallet throws for insufficient bank balance', () async {
      await createLinkedWallet(uid: 'tb86', bankBalance: 50);
      expect(
        () => ws.transferBankToWallet(uid: 'tb86', amount: 200),
        throwsA(isA<WalletException>().having((e) => e.message, 'msg', 'Insufficient bank balance.')),
      );
    });

    test('TC_WAL_087 — transferBankToWallet throws for zero amount', () {
      expect(() => ws.transferBankToWallet(uid: 'x', amount: 0), throwsA(isA<WalletException>()));
    });

    test('TC_WAL_088 — transferBankToWallet throws if bank not linked', () async {
      await createWallet(uid: 'tb88');
      expect(
        () => ws.transferBankToWallet(uid: 'tb88', amount: 100),
        throwsA(isA<WalletException>().having((e) => e.message, 'msg', 'Bank account is not linked.')),
      );
    });

    test('TC_WAL_089 — transferWalletToBank calls notifyTransferToBank', () async {
      await createLinkedWallet(uid: 'tb89');
      await ws.transferWalletToBank(uid: 'tb89', amount: 100);
      verify(mockNotif.notifyTransferToBank(uid: 'tb89', amount: 100)).called(1);
    });

    test('TC_WAL_090 — transferBankToWallet calls notifyTransferFromBank', () async {
      await createLinkedWallet(uid: 'tb90', bankBalance: 5000);
      await ws.transferBankToWallet(uid: 'tb90', amount: 100);
      verify(mockNotif.notifyTransferFromBank(uid: 'tb90', amount: 100)).called(1);
    });
  });

  // ─── RAZORPAY (TC_WAL_091–100) ─────────────────

  group('WalletService — Razorpay Transactions', () {
    test('TC_WAL_091 — recordRazorpayTransaction success increments balance', () async {
      await createWallet(uid: 'rz91');
      await ws.recordRazorpayTransaction(uid: 'rz91', amount: 500, status: 'success', razorpayPaymentId: 'pay_123');
      final doc = await fakeFirestore.collection('users').doc('rz91').get();
      expect(doc.data()?['balance'], 1500.0);
    });

    test('TC_WAL_092 — recordRazorpayTransaction failure does not change balance', () async {
      await createWallet(uid: 'rz92');
      await ws.recordRazorpayTransaction(uid: 'rz92', amount: 500, status: 'failed');
      final doc = await fakeFirestore.collection('users').doc('rz92').get();
      expect(doc.data()?['balance'], 1000.0);
    });

    test('TC_WAL_093 — recordRazorpayTransaction success creates add_money tx', () async {
      await createWallet(uid: 'rz93');
      await ws.recordRazorpayTransaction(uid: 'rz93', amount: 500, status: 'success', razorpayPaymentId: 'pay_x');
      final txs = await fakeFirestore.collection('users').doc('rz93').collection('transactions').get();
      expect(txs.docs.first.data()['type'], 'add_money');
    });

    test('TC_WAL_094 — recordRazorpayTransaction stores razorpayPaymentId', () async {
      await createWallet(uid: 'rz94');
      await ws.recordRazorpayTransaction(uid: 'rz94', amount: 100, status: 'success', razorpayPaymentId: 'pay_test');
      final txs = await fakeFirestore.collection('users').doc('rz94').collection('transactions').get();
      expect(txs.docs.first.data()['razorpayPaymentId'], 'pay_test');
    });

    test('TC_WAL_095 — recordRazorpayTransaction throws for zero amount', () {
      expect(() => ws.recordRazorpayTransaction(uid: 'rz', amount: 0, status: 'success'), throwsArgumentError);
    });

    test('TC_WAL_096 — recordRazorpayTransaction throws for negative amount', () {
      expect(() => ws.recordRazorpayTransaction(uid: 'rz', amount: -10, status: 'success'), throwsArgumentError);
    });

    test('TC_WAL_097 — recordRazorpayTransaction success calls notifyRazorpaySuccess', () async {
      await createWallet(uid: 'rz97');
      await ws.recordRazorpayTransaction(uid: 'rz97', amount: 100, status: 'success', razorpayPaymentId: 'pay_97');
      verify(mockNotif.notifyRazorpaySuccess(uid: 'rz97', amount: 100, paymentId: 'pay_97')).called(1);
    });

    test('TC_WAL_098 — recordRazorpayTransaction failure calls notifyRazorpayFailure', () async {
      await createWallet(uid: 'rz98');
      await ws.recordRazorpayTransaction(uid: 'rz98', amount: 100, status: 'failed');
      verify(mockNotif.notifyRazorpayFailure(uid: 'rz98', amount: 100, message: 'Payment failed')).called(1);
    });

    test('TC_WAL_099 — recordRazorpayTransaction success description', () async {
      await createWallet(uid: 'rz99');
      await ws.recordRazorpayTransaction(uid: 'rz99', amount: 100, status: 'success', razorpayPaymentId: 'p');
      final txs = await fakeFirestore.collection('users').doc('rz99').collection('transactions').get();
      expect(txs.docs.first.data()['description'], 'Added money via Razorpay');
    });

    test('TC_WAL_100 — recordRazorpayTransaction failure description', () async {
      await createWallet(uid: 'rz100');
      await ws.recordRazorpayTransaction(uid: 'rz100', amount: 100, status: 'failed');
      final txs = await fakeFirestore.collection('users').doc('rz100').collection('transactions').get();
      expect(txs.docs.first.data()['description'], 'Razorpay top-up failed');
    });
  });
}
