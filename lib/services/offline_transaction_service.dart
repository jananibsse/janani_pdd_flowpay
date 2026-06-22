import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/offline_transaction.dart';
import 'notification_service.dart';
import 'wallet_service.dart';

class SyncResult {
  const SyncResult({
    required this.syncedCount,
    required this.failedCount,
    required this.errors,
  });

  final int syncedCount;
  final int failedCount;
  final List<String> errors;

  bool get hasFailures => failedCount > 0;
}

class OfflineTransactionService {
  OfflineTransactionService({
    SharedPreferences? preferences,
    NotificationService? notificationService,
  })  : _preferencesOverride = preferences,
        _notificationService = notificationService;

  final NotificationService? _notificationService;

  static const String _storageKey = 'flowpay_offline_transactions';

  final SharedPreferences? _preferencesOverride;

  Future<SharedPreferences> get _preferences async {
    return _preferencesOverride ?? await SharedPreferences.getInstance();
  }

  Future<List<OfflineTransaction>> getPendingTransactions() async {
    final prefs = await _preferences;
    final rawList = prefs.getStringList(_storageKey) ?? [];

    return rawList
        .map((raw) => OfflineTransaction.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .where((tx) => tx.status == OfflineTransaction.pendingStatus)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> savePendingTransaction(OfflineTransaction transaction) async {
    final prefs = await _preferences;
    final existing = prefs.getStringList(_storageKey) ?? [];

    existing.add(jsonEncode(transaction.toJson()));
    await prefs.setStringList(_storageKey, existing);
  }

  Future<void> removeTransaction(String localId) async {
    final prefs = await _preferences;
    final existing = prefs.getStringList(_storageKey) ?? [];

    final updated = existing.where((raw) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded['localId'] != localId;
    }).toList();

    await prefs.setStringList(_storageKey, updated);
  }

  Future<SyncResult> syncPendingTransactions({
    required WalletService walletService,
  }) async {
    final pending = await getPendingTransactions();
    var syncedCount = 0;
    var failedCount = 0;
    final errors = <String>[];

    for (final transaction in pending) {
      try {
        if (transaction.type == OfflineTransaction.typeWalletToBank) {
          await walletService.transferWalletToBank(
            uid: transaction.senderId,
            amount: transaction.amount,
          );
        } else if (transaction.type == OfflineTransaction.typeBankToWallet) {
          await walletService.transferBankToWallet(
            uid: transaction.senderId,
            amount: transaction.amount,
          );
        } else {
          final receiverId =
              await walletService.getUserIdByPhone(transaction.receiverPhone);
          if (receiverId == null) {
            failedCount++;
            errors.add(
              '${transaction.receiverPhone}: No FlowPay wallet found.',
            );
            continue;
          }

          await walletService.sendMoney(
            senderId: transaction.senderId,
            senderPhone: transaction.senderPhone,
            receiverId: receiverId,
            receiverPhone: transaction.receiverPhone,
            amount: transaction.amount,
          );
        }

        await walletService.saveSyncedOfflineTransaction(transaction);
        await removeTransaction(transaction.localId);
        await _notificationService?.notifyOfflineSyncCompleted(
          uid: transaction.senderId,
        );
        syncedCount++;
      } on WalletException catch (error) {
        failedCount++;
        errors.add('${transaction.receiverPhone.isNotEmpty ? transaction.receiverPhone : "Bank Transfer"}: ${error.message}');
      } catch (error) {
        failedCount++;
        errors.add('${transaction.receiverPhone.isNotEmpty ? transaction.receiverPhone : "Bank Transfer"}: Sync failed.');
      }
    }

    return SyncResult(
      syncedCount: syncedCount,
      failedCount: failedCount,
      errors: errors,
    );
  }
}
