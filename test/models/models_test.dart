import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay_app/models/bank_account.dart';
import 'package:flowpay_app/models/wallet_user.dart';
import 'package:flowpay_app/models/wallet_transaction.dart';
import 'package:flowpay_app/models/payment_transaction.dart';
import 'package:flowpay_app/models/qr_payment_payload.dart';
import 'package:flowpay_app/models/wallet_analytics_summary.dart';

/// ═══════════════════════════════════════════════════════════════
/// FlowPay Backend Test Suite — DATA MODELS (60 Test Cases)
/// Covers: BankAccount, WalletUser, WalletTransaction,
///         PaymentTransaction, QrPaymentPayload, WalletAnalyticsSummary
/// ═══════════════════════════════════════════════════════════════
void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // ─── BANK ACCOUNT MODEL (TC_MDL_001–010) ─────────────────

  group('BankAccount Model', () {
    test('TC_MDL_001 — fromFirestore maps all fields', () async {
      await fakeFirestore.collection('test').doc('b1').set({
        'accountHolderName': 'John', 'bankName': 'SBI', 'accountLast4': '1234',
        'ifscCode': 'SBIN001', 'upiId': 'john@sbi', 'isPrimary': true,
        'createdAt': Timestamp.now(),
      });
      final doc = await fakeFirestore.collection('test').doc('b1').get();
      final ba = BankAccount.fromFirestore(doc);
      expect(ba.id, 'b1');
      expect(ba.accountHolderName, 'John');
      expect(ba.bankName, 'SBI');
      expect(ba.accountLast4, '1234');
      expect(ba.ifscCode, 'SBIN001');
      expect(ba.upiId, 'john@sbi');
      expect(ba.isPrimary, true);
    });

    test('TC_MDL_002 — fromFirestore defaults on missing fields', () async {
      await fakeFirestore.collection('test').doc('b2').set({});
      final doc = await fakeFirestore.collection('test').doc('b2').get();
      final ba = BankAccount.fromFirestore(doc);
      expect(ba.accountHolderName, '');
      expect(ba.bankName, '');
      expect(ba.isPrimary, false);
    });

    test('TC_MDL_003 — toMap includes all fields', () {
      final ba = BankAccount(id: 'x', accountHolderName: 'A', bankName: 'B', accountLast4: '9999', ifscCode: 'IF', upiId: 'u@b', isPrimary: false, createdAt: DateTime(2024));
      final map = ba.toMap();
      expect(map['accountHolderName'], 'A');
      expect(map['bankName'], 'B');
      expect(map['accountLast4'], '9999');
      expect(map['ifscCode'], 'IF');
      expect(map['upiId'], 'u@b');
      expect(map['isPrimary'], false);
    });

    test('TC_MDL_004 — toMap createdAt is Timestamp', () {
      final ba = BankAccount(id: 'x', accountHolderName: 'A', bankName: 'B', accountLast4: '1', ifscCode: 'I', upiId: 'u', isPrimary: false, createdAt: DateTime(2024));
      expect(ba.toMap()['createdAt'], isA<Timestamp>());
    });

    test('TC_MDL_005 — BankAccount with empty strings', () {
      final ba = BankAccount(id: '', accountHolderName: '', bankName: '', accountLast4: '', ifscCode: '', upiId: '', isPrimary: false, createdAt: DateTime.now());
      expect(ba.id, '');
    });
  });

  // ─── WALLET USER MODEL (TC_MDL_006–020) ─────────────────

  group('WalletUser Model', () {
    test('TC_MDL_006 — fromFirestore maps core fields', () async {
      await fakeFirestore.collection('users').doc('wu1').set({
        'uid': 'wu1', 'email': 'wu@t.com', 'phone': '111', 'balance': 5000.0,
      });
      final doc = await fakeFirestore.collection('users').doc('wu1').get();
      final wu = WalletUser.fromFirestore(doc);
      expect(wu.uid, 'wu1');
      expect(wu.email, 'wu@t.com');
      expect(wu.phone, '111');
      expect(wu.balance, 5000.0);
    });

    test('TC_MDL_007 — fromFirestore defaults balance to 0', () async {
      await fakeFirestore.collection('users').doc('wu2').set({});
      final doc = await fakeFirestore.collection('users').doc('wu2').get();
      final wu = WalletUser.fromFirestore(doc);
      expect(wu.balance, 0);
    });

    test('TC_MDL_008 — fromFirestore defaults email to empty', () async {
      await fakeFirestore.collection('users').doc('wu3').set({'balance': 0});
      final doc = await fakeFirestore.collection('users').doc('wu3').get();
      expect(WalletUser.fromFirestore(doc).email, '');
    });

    test('TC_MDL_009 — fromFirestore maps bank fields', () async {
      await fakeFirestore.collection('users').doc('wu4').set({
        'isBankLinked': true, 'bankName': 'HDFC', 'bankBalance': 25000.0,
        'bankAccountHolder': 'Test', 'bankAccountNumber': '****1234', 'bankIfsc': 'HDFC001',
      });
      final doc = await fakeFirestore.collection('users').doc('wu4').get();
      final wu = WalletUser.fromFirestore(doc);
      expect(wu.isBankLinked, true);
      expect(wu.bankName, 'HDFC');
      expect(wu.bankBalance, 25000.0);
    });

    test('TC_MDL_010 — fromFirestore defaults isBankLinked to false', () async {
      await fakeFirestore.collection('users').doc('wu5').set({});
      final doc = await fakeFirestore.collection('users').doc('wu5').get();
      expect(WalletUser.fromFirestore(doc).isBankLinked, false);
    });

    test('TC_MDL_011 — fromFirestore maps walletPinHash', () async {
      await fakeFirestore.collection('users').doc('wu6').set({'walletPinHash': 'abc123'});
      final doc = await fakeFirestore.collection('users').doc('wu6').get();
      expect(WalletUser.fromFirestore(doc).walletPinHash, 'abc123');
    });

    test('TC_MDL_012 — fromFirestore null walletPinHash', () async {
      await fakeFirestore.collection('users').doc('wu7').set({});
      final doc = await fakeFirestore.collection('users').doc('wu7').get();
      expect(WalletUser.fromFirestore(doc).walletPinHash, isNull);
    });

    test('TC_MDL_013 — toMap round-trips core fields', () {
      const wu = WalletUser(uid: 'x', email: 'e', phone: 'p', balance: 100, createdAt: null);
      final map = wu.toMap();
      expect(map['uid'], 'x');
      expect(map['email'], 'e');
      expect(map['phone'], 'p');
      expect(map['balance'], 100);
    });

    test('TC_MDL_014 — uid falls back to doc.id if missing', () async {
      await fakeFirestore.collection('users').doc('fallback').set({'email': 'e'});
      final doc = await fakeFirestore.collection('users').doc('fallback').get();
      expect(WalletUser.fromFirestore(doc).uid, 'fallback');
    });

    test('TC_MDL_015 — balance handles int from Firestore', () async {
      await fakeFirestore.collection('users').doc('intbal').set({'balance': 500});
      final doc = await fakeFirestore.collection('users').doc('intbal').get();
      expect(WalletUser.fromFirestore(doc).balance, 500.0);
    });
  });

  // ─── WALLET TRANSACTION MODEL (TC_MDL_016–030) ─────────────────

  group('WalletTransaction Model', () {
    test('TC_MDL_016 — fromFirestore maps amount', () async {
      await fakeFirestore.collection('tx').doc('t1').set({'amount': 250, 'type': 'credit', 'description': 'Test'});
      final doc = await fakeFirestore.collection('tx').doc('t1').get();
      expect(WalletTransaction.fromFirestore(doc).amount, 250);
    });

    test('TC_MDL_017 — fromFirestore maps type', () async {
      await fakeFirestore.collection('tx').doc('t2').set({'type': 'debit', 'amount': 10, 'description': 'D'});
      final doc = await fakeFirestore.collection('tx').doc('t2').get();
      expect(WalletTransaction.fromFirestore(doc).type, 'debit');
    });

    test('TC_MDL_018 — isCredit true for credit type', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'credit', description: '', createdAt: null);
      expect(tx.isCredit, true);
    });

    test('TC_MDL_019 — isCredit true for add_money type', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'add_money', description: '', createdAt: null);
      expect(tx.isCredit, true);
    });

    test('TC_MDL_020 — isPaymentSent true for debit direction', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'debit', description: '', createdAt: null, direction: 'debit');
      expect(tx.isPaymentSent, true);
    });

    test('TC_MDL_021 — isAddMoney true for add_money type', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'add_money', description: '', createdAt: null);
      expect(tx.isAddMoney, true);
    });

    test('TC_MDL_022 — isAddMoney true for credit + Added money desc', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'credit', description: 'Added money', createdAt: null);
      expect(tx.isAddMoney, true);
    });

    test('TC_MDL_023 — typeLabel for add_money', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'add_money', description: '', createdAt: null);
      expect(tx.typeLabel, 'Add Money');
    });

    test('TC_MDL_024 — typeLabel for wallet_transfer', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'wallet_transfer', description: '', createdAt: null);
      expect(tx.typeLabel, 'Wallet Transfer');
    });

    test('TC_MDL_025 — typeLabel for withdrawal', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'withdrawal', description: '', createdAt: null);
      expect(tx.typeLabel, 'Withdrawal Request');
    });

    test('TC_MDL_026 — typeLabel for offline_transfer', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'offline_transfer', description: '', createdAt: null);
      expect(tx.typeLabel, 'Offline Transfer');
    });

    test('TC_MDL_027 — typeLabel default with added description', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'unknown', description: 'added from bank', createdAt: null);
      expect(tx.typeLabel, 'Add Money');
    });

    test('TC_MDL_028 — typeLabel default with transfer to bank', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'unknown', description: 'transfer to bank', createdAt: null);
      expect(tx.typeLabel, 'Withdrawal Request');
    });

    test('TC_MDL_029 — typeLabel default with offline desc', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'unknown', description: 'offline sync', createdAt: null);
      expect(tx.typeLabel, 'Offline Transfer');
    });

    test('TC_MDL_030 — typeLabel default falls back to Wallet Transfer', () {
      const tx = WalletTransaction(id: 'x', amount: 1, type: 'unknown', description: 'something', createdAt: null);
      expect(tx.typeLabel, 'Wallet Transfer');
    });
  });

  // ─── PAYMENT TRANSACTION MODEL (TC_MDL_031–040) ─────────────────

  group('PaymentTransaction Model', () {
    test('TC_MDL_031 — fromFirestore maps all fields', () async {
      await fakeFirestore.collection('ptx').doc('p1').set({
        'senderId': 's1', 'receiverId': 'r1', 'senderPhone': '111',
        'receiverPhone': '222', 'amount': 500, 'status': 'completed',
      });
      final doc = await fakeFirestore.collection('ptx').doc('p1').get();
      final pt = PaymentTransaction.fromFirestore(doc);
      expect(pt.senderId, 's1');
      expect(pt.receiverId, 'r1');
      expect(pt.amount, 500);
      expect(pt.status, 'completed');
    });

    test('TC_MDL_032 — fromFirestore defaults status to pending', () async {
      await fakeFirestore.collection('ptx').doc('p2').set({'amount': 10});
      final doc = await fakeFirestore.collection('ptx').doc('p2').get();
      expect(PaymentTransaction.fromFirestore(doc).status, 'pending');
    });

    test('TC_MDL_033 — isSentBy returns true for sender', () {
      const pt = PaymentTransaction(id: 'x', senderId: 's', receiverId: 'r', senderPhone: '', receiverPhone: '', amount: 1, status: '', createdAt: null);
      expect(pt.isSentBy('s'), true);
      expect(pt.isSentBy('r'), false);
    });

    test('TC_MDL_034 — isReceivedBy returns true for receiver', () {
      const pt = PaymentTransaction(id: 'x', senderId: 's', receiverId: 'r', senderPhone: '', receiverPhone: '', amount: 1, status: '', createdAt: null);
      expect(pt.isReceivedBy('r'), true);
      expect(pt.isReceivedBy('s'), false);
    });

    test('TC_MDL_035 — fromFirestore defaults on empty doc', () async {
      await fakeFirestore.collection('ptx').doc('p3').set({});
      final doc = await fakeFirestore.collection('ptx').doc('p3').get();
      final pt = PaymentTransaction.fromFirestore(doc);
      expect(pt.senderId, '');
      expect(pt.amount, 0);
    });
  });

  // ─── QR PAYMENT PAYLOAD MODEL (TC_MDL_036–050) ─────────────────

  group('QrPaymentPayload Model', () {
    test('TC_MDL_036 — fromJson maps all fields', () {
      final qr = QrPaymentPayload.fromJson({'type': 'flowpay_user', 'userId': 'u1', 'name': 'John', 'phone': '111', 'email': 'j@t.com', 'walletId': 'w1', 'upiId': 'j@upi'});
      expect(qr.userId, 'u1');
      expect(qr.name, 'John');
      expect(qr.phone, '111');
    });

    test('TC_MDL_037 — fromJson defaults type to flowpay_user', () {
      final qr = QrPaymentPayload.fromJson({'userId': 'u1'});
      expect(qr.type, 'flowpay_user');
    });

    test('TC_MDL_038 — fromJson defaults name to FlowPay User', () {
      final qr = QrPaymentPayload.fromJson({'userId': 'u1'});
      expect(qr.name, 'FlowPay User');
    });

    test('TC_MDL_039 — fromJson throws on empty userId', () {
      expect(() => QrPaymentPayload.fromJson({'userId': ''}), throwsFormatException);
    });

    test('TC_MDL_040 — fromJson throws on missing userId', () {
      expect(() => QrPaymentPayload.fromJson({}), throwsFormatException);
    });

    test('TC_MDL_041 — fromJson accepts uid as fallback for userId', () {
      final qr = QrPaymentPayload.fromJson({'uid': 'fallback1'});
      expect(qr.userId, 'fallback1');
    });

    test('TC_MDL_042 — toJson includes all fields', () {
      const qr = QrPaymentPayload(type: 't', userId: 'u', name: 'n', phone: 'p', email: 'e', walletId: 'w', upiId: 'i');
      final json = qr.toJson();
      expect(json['type'], 't');
      expect(json['userId'], 'u');
      expect(json['name'], 'n');
    });

    test('TC_MDL_043 — encode returns JSON string', () {
      const qr = QrPaymentPayload(type: 't', userId: 'u', name: 'n', phone: 'p', email: 'e', walletId: 'w', upiId: 'i');
      final encoded = qr.encode();
      expect(jsonDecode(encoded), isA<Map>());
    });

    test('TC_MDL_044 — tryParse valid JSON returns payload', () {
      final json = jsonEncode({'userId': 'u1', 'name': 'Test'});
      final result = QrPaymentPayload.tryParse(json);
      expect(result, isNotNull);
      expect(result?.userId, 'u1');
    });

    test('TC_MDL_045 — tryParse invalid JSON returns null', () {
      expect(QrPaymentPayload.tryParse('not json'), isNull);
    });

    test('TC_MDL_046 — tryParse non-map JSON returns null', () {
      expect(QrPaymentPayload.tryParse('"just a string"'), isNull);
    });

    test('TC_MDL_047 — tryParse array JSON returns null', () {
      expect(QrPaymentPayload.tryParse('[1,2,3]'), isNull);
    });

    test('TC_MDL_048 — tryParse with whitespace works', () {
      final json = '  ${jsonEncode({'userId': 'u1'})}  ';
      expect(QrPaymentPayload.tryParse(json), isNotNull);
    });

    test('TC_MDL_049 — tryParse empty userId returns null (throws internally)', () {
      expect(QrPaymentPayload.tryParse(jsonEncode({'userId': ''})), isNull);
    });

    test('TC_MDL_050 — encode then tryParse round-trip', () {
      const qr = QrPaymentPayload(type: 'fp', userId: 'round', name: 'N', phone: 'P', email: 'E', walletId: 'W', upiId: 'U');
      final encoded = qr.encode();
      final decoded = QrPaymentPayload.tryParse(encoded);
      expect(decoded?.userId, 'round');
      expect(decoded?.type, 'fp');
    });
  });

  // ─── WALLET ANALYTICS SUMMARY (TC_MDL_051–060) ─────────────────

  group('WalletAnalyticsSummary Model', () {
    test('TC_MDL_051 — hasData false when no transactions', () {
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [], offlineSyncedCount: 0);
      expect(summary.hasData, false);
    });

    test('TC_MDL_052 — hasData true when transactions exist', () {
      const tx = WalletTransaction(id: 'x', amount: 100, type: 'credit', description: 'Test', createdAt: null);
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [tx], offlineSyncedCount: 0);
      expect(summary.hasData, true);
    });

    test('TC_MDL_053 — totalSent sums debit transactions', () {
      const tx1 = WalletTransaction(id: '1', amount: 100, type: 'debit', description: 'Sent', createdAt: null, direction: 'debit');
      const tx2 = WalletTransaction(id: '2', amount: 200, type: 'debit', description: 'Sent', createdAt: null, direction: 'debit');
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [tx1, tx2], offlineSyncedCount: 0);
      expect(summary.totalSent, 300);
    });

    test('TC_MDL_054 — totalReceived sums received (non-addMoney credit)', () {
      const tx = WalletTransaction(id: '1', amount: 500, type: 'credit', description: 'Received from 999', createdAt: null, direction: 'credit');
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [tx], offlineSyncedCount: 0);
      expect(summary.totalReceived, 500);
    });

    test('TC_MDL_055 — totalAddedMoney sums add_money transactions', () {
      const tx = WalletTransaction(id: '1', amount: 1000, type: 'add_money', description: 'Added', createdAt: null);
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [tx], offlineSyncedCount: 0);
      expect(summary.totalAddedMoney, 1000);
    });

    test('TC_MDL_056 — transactionCount is correct', () {
      const tx1 = WalletTransaction(id: '1', amount: 1, type: 'credit', description: '', createdAt: null);
      const tx2 = WalletTransaction(id: '2', amount: 2, type: 'debit', description: '', createdAt: null);
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [tx1, tx2], offlineSyncedCount: 0);
      expect(summary.transactionCount, 2);
    });

    test('TC_MDL_057 — offlineSyncedCount passed through', () {
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [], offlineSyncedCount: 5);
      expect(summary.offlineSyncedCount, 5);
    });

    test('TC_MDL_058 — netFlow calculated correctly', () {
      const summary = WalletAnalyticsSummary(totalSent: 300, totalReceived: 500, totalAddedMoney: 200, transactionCount: 3, offlineSyncedCount: 0, weeklySent: [0,0,0,0,0,0,0]);
      expect(summary.netFlow, 400); // 500 + 200 - 300
    });

    test('TC_MDL_059 — weeklySent has 7 elements', () {
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [], offlineSyncedCount: 0);
      expect(summary.weeklySent.length, 7);
    });

    test('TC_MDL_060 — weeklySent defaults to all zeros', () {
      final summary = WalletAnalyticsSummary.fromTransactions(transactions: [], offlineSyncedCount: 0);
      expect(summary.weeklySent.every((v) => v == 0), true);
    });
  });
}
