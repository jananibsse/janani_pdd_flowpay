import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowpay_app/services/offline_transaction_service.dart';
import 'package:flowpay_app/services/wallet_service.dart';
import 'package:flowpay_app/services/notification_service.dart';
import 'package:flowpay_app/models/offline_transaction.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'offline_transaction_service_test.mocks.dart';

@GenerateMocks([WalletService, NotificationService])

/// ═══════════════════════════════════════════════════════════════
/// FlowPay Backend Test Suite — OFFLINE TRANSACTION SERVICE (50 Test Cases)
/// Covers: Queue, Save, Remove, Sync, Edge Cases
/// ═══════════════════════════════════════════════════════════════
void main() {
  late OfflineTransactionService ots;
  late MockWalletService mockWs;
  late MockNotificationService mockNs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockWs = MockWalletService();
    mockNs = MockNotificationService();
    ots = OfflineTransactionService(preferences: prefs, notificationService: mockNs);
  });

  OfflineTransaction _makeTx({
    double amount = 100,
    String senderId = 's',
    String senderPhone = '111',
    String receiverPhone = '222',
    String type = 'wallet_to_wallet',
  }) {
    return OfflineTransaction.create(
      amount: amount,
      senderId: senderId,
      senderPhone: senderPhone,
      receiverPhone: receiverPhone,
      type: type,
    );
  }

  // ─── QUEUE MANAGEMENT (TC_OFL_001–015) ─────────────────

  group('OfflineTransactionService — Queue Management', () {
    test('TC_OFL_001 — getPendingTransactions returns empty initially', () async {
      expect(await ots.getPendingTransactions(), isEmpty);
    });

    test('TC_OFL_002 — savePendingTransaction adds one item', () async {
      await ots.savePendingTransaction(_makeTx());
      expect((await ots.getPendingTransactions()).length, 1);
    });

    test('TC_OFL_003 — savePendingTransaction preserves amount', () async {
      await ots.savePendingTransaction(_makeTx(amount: 250));
      final tx = (await ots.getPendingTransactions()).first;
      expect(tx.amount, 250);
    });

    test('TC_OFL_004 — savePendingTransaction preserves senderId', () async {
      await ots.savePendingTransaction(_makeTx(senderId: 'myId'));
      final tx = (await ots.getPendingTransactions()).first;
      expect(tx.senderId, 'myId');
    });

    test('TC_OFL_005 — savePendingTransaction preserves senderPhone', () async {
      await ots.savePendingTransaction(_makeTx(senderPhone: '9876'));
      final tx = (await ots.getPendingTransactions()).first;
      expect(tx.senderPhone, '9876');
    });

    test('TC_OFL_006 — savePendingTransaction preserves receiverPhone', () async {
      await ots.savePendingTransaction(_makeTx(receiverPhone: '5432'));
      final tx = (await ots.getPendingTransactions()).first;
      expect(tx.receiverPhone, '5432');
    });

    test('TC_OFL_007 — savePendingTransaction preserves type', () async {
      await ots.savePendingTransaction(_makeTx(type: 'wallet_to_bank'));
      final tx = (await ots.getPendingTransactions()).first;
      expect(tx.type, 'wallet_to_bank');
    });

    test('TC_OFL_008 — savePendingTransaction sets status to pending_sync', () async {
      await ots.savePendingTransaction(_makeTx());
      final tx = (await ots.getPendingTransactions()).first;
      expect(tx.status, OfflineTransaction.pendingStatus);
    });

    test('TC_OFL_009 — Multiple saves create multiple items', () async {
      await ots.savePendingTransaction(_makeTx(amount: 10));
      await Future.delayed(const Duration(milliseconds: 5));
      await ots.savePendingTransaction(_makeTx(amount: 20));
      await Future.delayed(const Duration(milliseconds: 5));
      await ots.savePendingTransaction(_makeTx(amount: 30));
      expect((await ots.getPendingTransactions()).length, 3);
    });

    test('TC_OFL_010 — Transactions sorted by createdAt descending', () async {
      final tx1 = _makeTx(amount: 10);
      await Future.delayed(const Duration(milliseconds: 10));
      final tx2 = _makeTx(amount: 20);
      await ots.savePendingTransaction(tx1);
      await ots.savePendingTransaction(tx2);
      final pending = await ots.getPendingTransactions();
      expect(pending.first.amount, 20); // Newest first
    });

    test('TC_OFL_011 — removeTransaction removes specific item', () async {
      final tx = _makeTx(amount: 100);
      await ots.savePendingTransaction(tx);
      await ots.removeTransaction(tx.localId);
      expect(await ots.getPendingTransactions(), isEmpty);
    });

    test('TC_OFL_012 — removeTransaction leaves other items', () async {
      final tx1 = _makeTx(amount: 10);
      await Future.delayed(const Duration(milliseconds: 10));
      final tx2 = _makeTx(amount: 20);
      await ots.savePendingTransaction(tx1);
      await ots.savePendingTransaction(tx2);
      await ots.removeTransaction(tx1.localId);
      final pending = await ots.getPendingTransactions();
      expect(pending.length, 1);
      expect(pending.first.amount, 20);
    });

    test('TC_OFL_013 — removeTransaction with non-existent id has no effect', () async {
      await ots.savePendingTransaction(_makeTx());
      await ots.removeTransaction('non_existent_id');
      expect((await ots.getPendingTransactions()).length, 1);
    });

    test('TC_OFL_014 — Save and remove multiple times', () async {
      final tx1 = _makeTx(amount: 10);
      await Future.delayed(const Duration(milliseconds: 10));
      final tx2 = _makeTx(amount: 20);
      await ots.savePendingTransaction(tx1);
      await ots.savePendingTransaction(tx2);
      await ots.removeTransaction(tx1.localId);
      await ots.removeTransaction(tx2.localId);
      expect(await ots.getPendingTransactions(), isEmpty);
    });

    test('TC_OFL_015 — localId is unique per transaction', () async {
      final tx1 = _makeTx(amount: 10);
      await Future.delayed(const Duration(milliseconds: 5));
      final tx2 = _makeTx(amount: 20);
      expect(tx1.localId, isNot(tx2.localId));
    });
  });

  // ─── SYNC (TC_OFL_016–030) ─────────────────

  group('OfflineTransactionService — Sync', () {
    test('TC_OFL_016 — syncPendingTransactions with empty queue', () async {
      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.syncedCount, 0);
      expect(result.failedCount, 0);
    });

    test('TC_OFL_017 — syncPendingTransactions syncs wallet_to_wallet tx', () async {
      final tx = _makeTx(receiverPhone: '333');
      await ots.savePendingTransaction(tx);

      when(mockWs.getUserIdByPhone('333')).thenAnswer((_) async => 'receiver1');
      when(mockWs.sendMoney(senderId: anyNamed('senderId'), senderPhone: anyNamed('senderPhone'), receiverId: anyNamed('receiverId'), receiverPhone: anyNamed('receiverPhone'), amount: anyNamed('amount')))
          .thenAnswer((_) async {});
      when(mockWs.saveSyncedOfflineTransaction(any)).thenAnswer((_) async {});
      when(mockNs.notifyOfflineSyncCompleted(uid: anyNamed('uid'))).thenAnswer((_) async {});

      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.syncedCount, 1);
    });

    test('TC_OFL_018 — syncPendingTransactions removes synced tx from queue', () async {
      final tx = _makeTx(receiverPhone: '333');
      await ots.savePendingTransaction(tx);

      when(mockWs.getUserIdByPhone('333')).thenAnswer((_) async => 'r1');
      when(mockWs.sendMoney(senderId: anyNamed('senderId'), senderPhone: anyNamed('senderPhone'), receiverId: anyNamed('receiverId'), receiverPhone: anyNamed('receiverPhone'), amount: anyNamed('amount')))
          .thenAnswer((_) async {});
      when(mockWs.saveSyncedOfflineTransaction(any)).thenAnswer((_) async {});
      when(mockNs.notifyOfflineSyncCompleted(uid: anyNamed('uid'))).thenAnswer((_) async {});

      await ots.syncPendingTransactions(walletService: mockWs);
      expect(await ots.getPendingTransactions(), isEmpty);
    });

    test('TC_OFL_019 — syncPendingTransactions fails if receiver not found', () async {
      final tx = _makeTx(receiverPhone: '404');
      await ots.savePendingTransaction(tx);

      when(mockWs.getUserIdByPhone('404')).thenAnswer((_) async => null);

      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.failedCount, 1);
      expect(result.errors.first, contains('404'));
    });

    test('TC_OFL_020 — syncPendingTransactions hasFailures is true on failure', () async {
      final tx = _makeTx(receiverPhone: '404');
      await ots.savePendingTransaction(tx);
      when(mockWs.getUserIdByPhone('404')).thenAnswer((_) async => null);
      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.hasFailures, true);
    });

    test('TC_OFL_021 — syncPendingTransactions hasFailures false on success', () async {
      final tx = _makeTx(receiverPhone: '333');
      await ots.savePendingTransaction(tx);
      when(mockWs.getUserIdByPhone('333')).thenAnswer((_) async => 'r1');
      when(mockWs.sendMoney(senderId: anyNamed('senderId'), senderPhone: anyNamed('senderPhone'), receiverId: anyNamed('receiverId'), receiverPhone: anyNamed('receiverPhone'), amount: anyNamed('amount')))
          .thenAnswer((_) async {});
      when(mockWs.saveSyncedOfflineTransaction(any)).thenAnswer((_) async {});
      when(mockNs.notifyOfflineSyncCompleted(uid: anyNamed('uid'))).thenAnswer((_) async {});

      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.hasFailures, false);
    });

    test('TC_OFL_022 — sync calls saveSyncedOfflineTransaction', () async {
      final tx = _makeTx(receiverPhone: '333');
      await ots.savePendingTransaction(tx);
      when(mockWs.getUserIdByPhone('333')).thenAnswer((_) async => 'r1');
      when(mockWs.sendMoney(senderId: anyNamed('senderId'), senderPhone: anyNamed('senderPhone'), receiverId: anyNamed('receiverId'), receiverPhone: anyNamed('receiverPhone'), amount: anyNamed('amount')))
          .thenAnswer((_) async {});
      when(mockWs.saveSyncedOfflineTransaction(any)).thenAnswer((_) async {});
      when(mockNs.notifyOfflineSyncCompleted(uid: anyNamed('uid'))).thenAnswer((_) async {});

      await ots.syncPendingTransactions(walletService: mockWs);
      verify(mockWs.saveSyncedOfflineTransaction(any)).called(1);
    });

    test('TC_OFL_023 — sync calls notifyOfflineSyncCompleted', () async {
      final tx = _makeTx(senderId: 'myS', receiverPhone: '333');
      await ots.savePendingTransaction(tx);
      when(mockWs.getUserIdByPhone('333')).thenAnswer((_) async => 'r1');
      when(mockWs.sendMoney(senderId: anyNamed('senderId'), senderPhone: anyNamed('senderPhone'), receiverId: anyNamed('receiverId'), receiverPhone: anyNamed('receiverPhone'), amount: anyNamed('amount')))
          .thenAnswer((_) async {});
      when(mockWs.saveSyncedOfflineTransaction(any)).thenAnswer((_) async {});
      when(mockNs.notifyOfflineSyncCompleted(uid: anyNamed('uid'))).thenAnswer((_) async {});

      await ots.syncPendingTransactions(walletService: mockWs);
      verify(mockNs.notifyOfflineSyncCompleted(uid: 'myS')).called(1);
    });

    test('TC_OFL_024 — sync with WalletException counts as failure', () async {
      final tx = _makeTx(receiverPhone: '333');
      await ots.savePendingTransaction(tx);
      when(mockWs.getUserIdByPhone('333')).thenAnswer((_) async => 'r1');
      when(mockWs.sendMoney(senderId: anyNamed('senderId'), senderPhone: anyNamed('senderPhone'), receiverId: anyNamed('receiverId'), receiverPhone: anyNamed('receiverPhone'), amount: anyNamed('amount')))
          .thenThrow(WalletException('Insufficient balance.'));

      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.failedCount, 1);
    });

    test('TC_OFL_025 — sync with generic exception counts as failure', () async {
      final tx = _makeTx(receiverPhone: '333');
      await ots.savePendingTransaction(tx);
      when(mockWs.getUserIdByPhone('333')).thenAnswer((_) async => 'r1');
      when(mockWs.sendMoney(senderId: anyNamed('senderId'), senderPhone: anyNamed('senderPhone'), receiverId: anyNamed('receiverId'), receiverPhone: anyNamed('receiverPhone'), amount: anyNamed('amount')))
          .thenThrow(Exception('Network error'));

      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.failedCount, 1);
      expect(result.errors.first, contains('Sync failed'));
    });

    test('TC_OFL_026 — sync wallet_to_bank calls transferWalletToBank', () async {
      final tx = _makeTx(type: OfflineTransaction.typeWalletToBank, receiverPhone: '');
      await ots.savePendingTransaction(tx);
      when(mockWs.transferWalletToBank(uid: anyNamed('uid'), amount: anyNamed('amount'))).thenAnswer((_) async {});
      when(mockWs.saveSyncedOfflineTransaction(any)).thenAnswer((_) async {});
      when(mockNs.notifyOfflineSyncCompleted(uid: anyNamed('uid'))).thenAnswer((_) async {});

      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.syncedCount, 1);
      verify(mockWs.transferWalletToBank(uid: anyNamed('uid'), amount: anyNamed('amount'))).called(1);
    });

    test('TC_OFL_027 — sync bank_to_wallet calls transferBankToWallet', () async {
      final tx = _makeTx(type: OfflineTransaction.typeBankToWallet, receiverPhone: '');
      await ots.savePendingTransaction(tx);
      when(mockWs.transferBankToWallet(uid: anyNamed('uid'), amount: anyNamed('amount'))).thenAnswer((_) async {});
      when(mockWs.saveSyncedOfflineTransaction(any)).thenAnswer((_) async {});
      when(mockNs.notifyOfflineSyncCompleted(uid: anyNamed('uid'))).thenAnswer((_) async {});

      final result = await ots.syncPendingTransactions(walletService: mockWs);
      expect(result.syncedCount, 1);
    });

    test('TC_OFL_028 — SyncResult constructor works', () {
      const r = SyncResult(syncedCount: 3, failedCount: 1, errors: ['err']);
      expect(r.syncedCount, 3);
      expect(r.failedCount, 1);
      expect(r.errors.length, 1);
    });

    test('TC_OFL_029 — SyncResult hasFailures false when 0 failures', () {
      const r = SyncResult(syncedCount: 5, failedCount: 0, errors: []);
      expect(r.hasFailures, false);
    });

    test('TC_OFL_030 — SyncResult hasFailures true when >0 failures', () {
      const r = SyncResult(syncedCount: 2, failedCount: 1, errors: ['e']);
      expect(r.hasFailures, true);
    });
  });

  // ─── OFFLINE TRANSACTION MODEL (TC_OFL_031–050) ─────────────────

  group('OfflineTransaction Model', () {
    test('TC_OFL_031 — create() sets status to pending_sync', () {
      final tx = _makeTx();
      expect(tx.status, 'pending_sync');
    });

    test('TC_OFL_032 — create() trims receiverPhone', () {
      final tx = OfflineTransaction.create(amount: 1, senderId: 's', senderPhone: '1', receiverPhone: '  222  ', type: 'wallet_to_wallet');
      expect(tx.receiverPhone, '222');
    });

    test('TC_OFL_033 — create() trims senderPhone', () {
      final tx = OfflineTransaction.create(amount: 1, senderId: 's', senderPhone: '  111  ', receiverPhone: '2', type: 'wallet_to_wallet');
      expect(tx.senderPhone, '111');
    });

    test('TC_OFL_034 — create() generates localId from timestamp', () {
      final tx = _makeTx();
      expect(int.tryParse(tx.localId), isNotNull);
    });

    test('TC_OFL_035 — toJson() includes all fields', () {
      final tx = _makeTx(amount: 42, senderId: 'sid', senderPhone: '111', receiverPhone: '222');
      final json = tx.toJson();
      expect(json['amount'], 42);
      expect(json['senderId'], 'sid');
      expect(json['senderPhone'], '111');
      expect(json['receiverPhone'], '222');
      expect(json['status'], 'pending_sync');
      expect(json['localId'], isNotNull);
      expect(json['createdAt'], isNotNull);
      expect(json['type'], 'wallet_to_wallet');
    });

    test('TC_OFL_036 — fromJson() round-trips correctly', () {
      final tx = _makeTx(amount: 99);
      final json = tx.toJson();
      final restored = OfflineTransaction.fromJson(json);
      expect(restored.amount, 99);
      expect(restored.localId, tx.localId);
    });

    test('TC_OFL_037 — fromJson() parses amount as num', () {
      final json = {
        'localId': '1', 'receiverPhone': '2', 'amount': 50,
        'senderId': 's', 'senderPhone': '1', 'status': 'pending_sync',
        'createdAt': DateTime.now().toIso8601String(), 'type': 'wallet_to_wallet',
      };
      final tx = OfflineTransaction.fromJson(json);
      expect(tx.amount, 50.0);
    });

    test('TC_OFL_038 — fromJson() defaults status to pending_sync', () {
      final json = {
        'localId': '1', 'receiverPhone': '2', 'amount': 50,
        'senderId': 's', 'senderPhone': '1',
        'createdAt': DateTime.now().toIso8601String(),
      };
      final tx = OfflineTransaction.fromJson(json);
      expect(tx.status, 'pending_sync');
    });

    test('TC_OFL_039 — fromJson() defaults type to wallet_to_wallet', () {
      final json = {
        'localId': '1', 'receiverPhone': '2', 'amount': 50,
        'senderId': 's', 'senderPhone': '1', 'status': 'pending_sync',
        'createdAt': DateTime.now().toIso8601String(),
      };
      final tx = OfflineTransaction.fromJson(json);
      expect(tx.type, 'wallet_to_wallet');
    });

    test('TC_OFL_040 — pendingStatus constant', () {
      expect(OfflineTransaction.pendingStatus, 'pending_sync');
    });

    test('TC_OFL_041 — syncedStatus constant', () {
      expect(OfflineTransaction.syncedStatus, 'synced');
    });

    test('TC_OFL_042 — typeWalletToWallet constant', () {
      expect(OfflineTransaction.typeWalletToWallet, 'wallet_to_wallet');
    });

    test('TC_OFL_043 — typeWalletToBank constant', () {
      expect(OfflineTransaction.typeWalletToBank, 'wallet_to_bank');
    });

    test('TC_OFL_044 — typeBankToWallet constant', () {
      expect(OfflineTransaction.typeBankToWallet, 'bank_to_wallet');
    });

    test('TC_OFL_045 — toJson createdAt is ISO 8601 string', () {
      final tx = _makeTx();
      final json = tx.toJson();
      expect(DateTime.tryParse(json['createdAt'] as String), isNotNull);
    });

    test('TC_OFL_046 — Decimal amount preserved through serialization', () {
      final tx = _makeTx(amount: 123.456);
      final json = tx.toJson();
      final restored = OfflineTransaction.fromJson(json);
      expect(restored.amount, closeTo(123.456, 0.001));
    });

    test('TC_OFL_047 — Zero amount preserved', () {
      final tx = OfflineTransaction(localId: '1', receiverPhone: '2', amount: 0, senderId: 's', senderPhone: '1', status: 'pending_sync', createdAt: DateTime.now());
      expect(tx.amount, 0);
    });

    test('TC_OFL_048 — Empty receiverPhone preserved', () {
      final tx = OfflineTransaction(localId: '1', receiverPhone: '', amount: 100, senderId: 's', senderPhone: '1', status: 'pending_sync', createdAt: DateTime.now());
      expect(tx.receiverPhone, '');
    });

    test('TC_OFL_049 — Constructor with all params', () {
      final now = DateTime.now();
      final tx = OfflineTransaction(localId: 'id1', receiverPhone: '999', amount: 500, senderId: 'sid', senderPhone: '111', status: 'synced', createdAt: now, type: 'wallet_to_bank');
      expect(tx.localId, 'id1');
      expect(tx.type, 'wallet_to_bank');
      expect(tx.status, 'synced');
    });

    test('TC_OFL_050 — JSON encode/decode round-trip via jsonEncode', () {
      final tx = _makeTx(amount: 77);
      final encoded = jsonEncode(tx.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final restored = OfflineTransaction.fromJson(decoded);
      expect(restored.amount, 77);
    });
  });
}
