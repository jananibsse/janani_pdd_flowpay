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
void main() {
  group('OfflineTransactionService Tests', () {
    late OfflineTransactionService offlineService;
    late MockWalletService mockWalletService;
    late MockNotificationService mockNotificationService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      mockWalletService = MockWalletService();
      mockNotificationService = MockNotificationService();

      offlineService = OfflineTransactionService(
        preferences: prefs,
        notificationService: mockNotificationService,
      );
    });

    test('getPendingTransactions returns empty list initially', () async {
      final transactions = await offlineService.getPendingTransactions();
      expect(transactions, isEmpty);
    });

    test('savePendingTransaction saves transaction to preferences', () async {
      final tx = OfflineTransaction.create(
        amount: 100,
        senderId: 'sender1',
        senderPhone: '111',
        receiverPhone: '222',
        type: 'peer_to_peer',
      );

      await offlineService.savePendingTransaction(tx);
      final pending = await offlineService.getPendingTransactions();

      expect(pending.length, 1);
      expect(pending.first.amount, 100);
      expect(pending.first.receiverPhone, '222');
    });

    test('removeTransaction deletes a specific transaction', () async {
      final tx1 = OfflineTransaction.create(amount: 10, senderId: 's', senderPhone: '1', receiverPhone: '2', type: 'peer_to_peer');
      await Future.delayed(const Duration(milliseconds: 10));
      final tx2 = OfflineTransaction.create(amount: 20, senderId: 's', senderPhone: '1', receiverPhone: '3', type: 'peer_to_peer');

      await offlineService.savePendingTransaction(tx1);
      await offlineService.savePendingTransaction(tx2);

      var pending = await offlineService.getPendingTransactions();
      expect(pending.length, 2);

      await offlineService.removeTransaction(tx1.localId);
      
      pending = await offlineService.getPendingTransactions();
      expect(pending.length, 1);
      expect(pending.first.localId, tx2.localId);
    });

    test('syncPendingTransactions processes and removes successful txs', () async {
      final tx = OfflineTransaction.create(
        amount: 50,
        senderId: 's1',
        senderPhone: '111',
        receiverPhone: '222',
        type: 'peer_to_peer',
      );

      await offlineService.savePendingTransaction(tx);

      when(mockWalletService.getUserIdByPhone('222')).thenAnswer((_) async => 'r1');
      when(mockWalletService.sendMoney(
        senderId: 's1',
        senderPhone: '111',
        receiverId: 'r1',
        receiverPhone: '222',
        amount: 50,
      )).thenAnswer((_) async {});
      when(mockWalletService.saveSyncedOfflineTransaction(any)).thenAnswer((_) async {});
      when(mockNotificationService.notifyOfflineSyncCompleted(uid: 's1')).thenAnswer((_) async {});

      final result = await offlineService.syncPendingTransactions(walletService: mockWalletService);

      expect(result.syncedCount, 1);
      expect(result.failedCount, 0);
      
      final pending = await offlineService.getPendingTransactions();
      expect(pending, isEmpty);
    });
  });
}
