import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/offline_transaction.dart';
import '../models/payment_transaction.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_user.dart';
import '../models/bank_account.dart';
import 'notification_service.dart';
import 'email_service.dart';

class WalletException implements Exception {
  WalletException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WalletService {
  WalletService({
    FirebaseFirestore? firestore,
    NotificationService? notificationService,
    EmailService? emailService,
  })  : _firestoreOverride = firestore,
        _notificationService = notificationService,
        _emailService = emailService ?? EmailService();

  final NotificationService? _notificationService;
  final EmailService _emailService;

  static const String usersCollection = 'users';
  static const String userTransactionsCollection = 'transactions';
  static const String paymentTransactionsCollection = 'transactions';
  static const String offlineTransactionsCollection = 'offline_transactions';
  static const double initialBalance = 0;

  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore? _firestore;

  FirebaseFirestore get _db =>
      _firestore ??= _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(usersCollection);

  CollectionReference<Map<String, dynamic>> get _payments =>
      _db.collection(paymentTransactionsCollection);

  CollectionReference<Map<String, dynamic>> get _offlineTransactions =>
      _db.collection(offlineTransactionsCollection);

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _users.doc(uid);

  Future<void> createUserWallet({
    required String uid,
    required String email,
    required String phone,
  }) async {
    await _userDoc(uid).set({
      'uid': uid,
      'email': email.trim(),
      'phone': phone.trim(),
      'balance': initialBalance,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureWalletExists({
    required String uid,
    required String email,
    String phone = '',
  }) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) {
      await createUserWallet(uid: uid, email: email, phone: phone);
    }
  }

  Future<String?> getUserIdByEmail(String email) async {
    final snapshot = await _users
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.id;
  }

  Future<String?> getUserIdByPhone(String phone) async {
    final snapshot = await _users
        .where('phone', isEqualTo: phone.trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.id;
  }

  Stream<WalletUser?> watchWallet(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return WalletUser.fromFirestore(doc);
    });
  }

  Stream<List<WalletTransaction>> watchTransactions(
    String uid, {
    int limit = 10,
  }) {
    return _userDoc(uid)
        .collection(userTransactionsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(WalletTransaction.fromFirestore)
              .toList(),
        );
  }

  Stream<int> watchOfflineSyncedCount(String uid) {
    return _offlineTransactions
        .where('senderId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where(
                (doc) =>
                    doc.data()['status'] == OfflineTransaction.syncedStatus,
              )
              .length,
        );
  }

  Stream<List<PaymentTransaction>> watchPaymentTransactions(String uid) {
    return _payments
        .where(
          Filter.or(
            Filter('senderId', isEqualTo: uid),
            Filter('receiverId', isEqualTo: uid),
          ),
        )
        .orderBy('createdAt', descending: true)
        .limit(25)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PaymentTransaction.fromFirestore)
              .toList(),
        );
  }

  Future<void> addMoney({
    required String uid,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero.');
    }

    final userRef = _userDoc(uid);
    final transactionRef =
        userRef.collection(userTransactionsCollection).doc();

    final batch = _db.batch();
    batch.update(userRef, {
      'balance': FieldValue.increment(amount),
    });
    batch.set(transactionRef, {
      'amount': amount,
      'type': 'credit',
      'description': 'Added money',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();

    await _notificationService?.notifyMoneyAdded(uid: uid, amount: amount);
  }

  Future<void> sendMoney({
    required String senderId,
    required String senderPhone,
    required String receiverId,
    required String receiverPhone,
    required double amount,
  }) async {
    if (senderId == receiverId) {
      throw WalletException('You cannot send money to yourself.');
    }
    if (amount <= 0) {
      throw WalletException('Amount must be greater than zero.');
    }

    try {
      await _db.runTransaction((transaction) async {
        final senderRef = _userDoc(senderId);
        final receiverRef = _userDoc(receiverId);

        final senderSnap = await transaction.get(senderRef);
        final receiverSnap = await transaction.get(receiverRef);

        if (!senderSnap.exists) {
          throw WalletException('Sender wallet not found.');
        }
        if (!receiverSnap.exists) {
          throw WalletException('Receiver wallet not found.');
        }

        final senderBalance =
            (senderSnap.data()?['balance'] as num?)?.toDouble() ?? 0;
        if (senderBalance < amount) {
          throw WalletException('Insufficient balance.');
        }

        final receiverBalance =
            (receiverSnap.data()?['balance'] as num?)?.toDouble() ?? 0;

        transaction.update(senderRef, {'balance': senderBalance - amount});
        transaction.update(receiverRef, {'balance': receiverBalance + amount});

        final paymentRef = _payments.doc();
        transaction.set(paymentRef, {
          'senderId': senderId,
          'receiverId': receiverId,
          'senderPhone': senderPhone.trim(),
          'receiverPhone': receiverPhone.trim(),
          'amount': amount,
          'status': 'completed',
          'createdAt': FieldValue.serverTimestamp(),
        });

        final senderTxRef =
            senderRef.collection(userTransactionsCollection).doc();
        transaction.set(senderTxRef, {
          'amount': amount,
          'type': 'debit',
          'description': 'Sent to ${receiverPhone.trim()}',
          'createdAt': FieldValue.serverTimestamp(),
        });

        final receiverTxRef =
            receiverRef.collection(userTransactionsCollection).doc();
        transaction.set(receiverTxRef, {
          'amount': amount,
          'type': 'credit',
          'description': 'Received from ${senderPhone.trim()}',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await _notificationService?.notifyPaymentSent(
        senderId: senderId,
        amount: amount,
        receiverPhone: receiverPhone,
      );
      await _notificationService?.notifyPaymentReceived(
        receiverId: receiverId,
        amount: amount,
        senderPhone: senderPhone,
      );

      // Send email notifications for the payment
      try {
        final senderDoc = await _userDoc(senderId).get();
        final receiverDoc = await _userDoc(receiverId).get();
        final senderEmail = senderDoc.data()?['email'] as String? ?? '';
        final receiverEmail = receiverDoc.data()?['email'] as String? ?? '';
        final senderName = senderDoc.data()?['email']?.toString().split('@').first ?? 'User';
        final receiverName = receiverDoc.data()?['email']?.toString().split('@').first ?? 'User';
        final txId = DateTime.now().millisecondsSinceEpoch.toString();
        final now = DateTime.now();
        if (senderEmail.isNotEmpty) {
          await _emailService.sendPaymentSentEmail(
            toEmail: senderEmail,
            userName: senderName,
            amount: amount.toStringAsFixed(2),
            receiverPhone: receiverPhone.trim(),
            transactionId: txId,
            timestamp: now,
          );
        }
        if (receiverEmail.isNotEmpty) {
          await _emailService.sendPaymentReceivedEmail(
            toEmail: receiverEmail,
            userName: receiverName,
            amount: amount.toStringAsFixed(2),
            senderPhone: senderPhone.trim(),
            transactionId: txId,
            timestamp: now,
          );
        }
      } catch (_) {
        // Email failures are non-critical; swallow silently.
      }
    } on WalletException {
      rethrow;
    } on FirebaseException catch (error) {
      throw WalletException(error.message ?? 'Payment failed. Please try again.');
    }
  }

  Future<void> saveSyncedOfflineTransaction(
    OfflineTransaction transaction,
  ) async {
    await _offlineTransactions.add({
      'receiverPhone': transaction.receiverPhone,
      'amount': transaction.amount,
      'senderId': transaction.senderId,
      'senderPhone': transaction.senderPhone,
      'status': OfflineTransaction.syncedStatus,
      'createdAt': Timestamp.fromDate(transaction.createdAt),
      'syncedAt': FieldValue.serverTimestamp(),
      'type': transaction.type,
    });
  }

  Stream<List<BankAccount>> watchBankAccounts(String uid) {
    return _userDoc(uid)
        .collection('bank_accounts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BankAccount.fromFirestore(doc)).toList());
  }

  Stream<BankAccount?> watchPrimaryBankAccount(String uid) {
    return _userDoc(uid)
        .collection('bank_accounts')
        .where('isPrimary', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return BankAccount.fromFirestore(snapshot.docs.first);
    });
  }

  Stream<int> watchWithdrawalRequestsCount(String uid) {
    return _db
        .collection('withdrawals')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> linkBankAccount({
    required String uid,
    required String bankName,
    required String accountHolderName,
    required String accountLast4,
    required String ifscCode,
    required String upiId,
    required bool isPrimary,
  }) async {
    try {
      final bankAccountsRef = _userDoc(uid).collection('bank_accounts');
      final existingAccounts = await bankAccountsRef.get();
      final bool shouldBePrimary = isPrimary || existingAccounts.docs.isEmpty;

      await _db.runTransaction((transaction) async {
        if (shouldBePrimary) {
          for (final doc in existingAccounts.docs) {
            transaction.update(doc.reference, {'isPrimary': false});
          }
        }

        final newDocRef = bankAccountsRef.doc();
        transaction.set(newDocRef, {
          'accountHolderName': accountHolderName.trim(),
          'bankName': bankName.trim(),
          'accountLast4': accountLast4.trim(),
          'ifscCode': ifscCode.trim().toUpperCase(),
          'upiId': upiId.trim().toLowerCase(),
          'isPrimary': shouldBePrimary,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(_userDoc(uid), {
          'isBankLinked': true,
          'bankName': bankName.trim(),
          'bankAccountHolder': accountHolderName.trim(),
          'bankAccountNumber': '****${accountLast4.trim()}',
          'bankIfsc': ifscCode.trim().toUpperCase(),
          'bankUpiId': upiId.trim().toLowerCase(),
          'bankBalance': 25000.0,
        });
      });

      await _notificationService?.notifyBankLinked(
        uid: uid,
        bankName: bankName.trim(),
        last4: accountLast4.trim(),
      );
    } on FirebaseException catch (error) {
      throw WalletException(error.message ?? 'Failed to link bank account.');
    }
  }

  Future<void> unlinkBankAccount({
    required String uid,
    required String bankId,
  }) async {
    try {
      final bankAccountsRef = _userDoc(uid).collection('bank_accounts');
      
      await _db.runTransaction((transaction) async {
        transaction.delete(bankAccountsRef.doc(bankId));

        final remaining = await bankAccountsRef.get();
        final list = remaining.docs.where((doc) => doc.id != bankId).toList();

        if (list.isEmpty) {
          transaction.update(_userDoc(uid), {
            'isBankLinked': false,
            'bankName': FieldValue.delete(),
            'bankAccountHolder': FieldValue.delete(),
            'bankAccountNumber': FieldValue.delete(),
            'bankIfsc': FieldValue.delete(),
          });
        } else {
          final wasPrimary = (await bankAccountsRef.doc(bankId).get()).data()?['isPrimary'] as bool? ?? false;
          if (wasPrimary) {
            transaction.update(list.first.reference, {'isPrimary': true});
            final firstData = list.first.data();
            transaction.update(_userDoc(uid), {
              'bankName': firstData['bankName'],
              'bankAccountHolder': firstData['accountHolderName'],
              'bankAccountNumber': '****${firstData['accountLast4']}',
              'bankIfsc': firstData['ifscCode'],
            });
          }
        }
      });
    } on FirebaseException catch (error) {
      throw WalletException(error.message ?? 'Failed to unlink bank account.');
    }
  }

  Future<void> recordRazorpayTransaction({
    required String uid,
    required double amount,
    required String status,
    String? razorpayPaymentId,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero.');
    }

    final userRef = _userDoc(uid);
    final transactionRef = userRef.collection(userTransactionsCollection).doc();

    final batch = _db.batch();
    if (status == 'success') {
      batch.update(userRef, {
        'balance': FieldValue.increment(amount),
      });
    }

    batch.set(transactionRef, {
      'amount': amount,
      'type': 'add_money',
      'paymentMode': 'razorpay',
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      'status': status,
      'description': status == 'success' ? 'Added money via Razorpay' : 'Razorpay top-up failed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    if (status == 'success') {
      await _notificationService?.notifyRazorpaySuccess(
        uid: uid,
        amount: amount,
        paymentId: razorpayPaymentId ?? '',
      );
    } else {
      await _notificationService?.notifyRazorpayFailure(
        uid: uid,
        amount: amount,
        message: 'Payment failed',
      );
    }
  }

  Future<void> submitWithdrawalRequest({
    required String uid,
    required String userName,
    required String bankId,
    required String bankName,
    required String accountLast4,
    required String accountHolderName,
    required String ifscCode,
    required String upiId,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw WalletException('Amount must be greater than zero.');
    }

    try {
      await _db.runTransaction((transaction) async {
        final userRef = _userDoc(uid);
        final userSnap = await transaction.get(userRef);

        if (!userSnap.exists) {
          throw WalletException('Wallet not found.');
        }

        final data = userSnap.data() ?? {};
        final walletBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;

        if (walletBalance < amount) {
          throw WalletException('Insufficient wallet balance.');
        }

        transaction.update(userRef, {
          'balance': walletBalance - amount,
        });

        final withdrawalRef = _db.collection('withdrawals').doc();
        transaction.set(withdrawalRef, {
          'withdrawalId': withdrawalRef.id,
          'uid': uid,
          'userName': userName,
          'bankId': bankId,
          'bankName': bankName,
          'accountLast4': accountLast4,
          'accountHolderName': accountHolderName,
          'ifscCode': ifscCode,
          'upiId': upiId,
          'amount': amount,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        final txRef = userRef.collection(userTransactionsCollection).doc();
        transaction.set(txRef, {
          'amount': amount,
          'type': 'withdrawal',
          'status': 'pending',
          'description': 'Withdrawal to $bankName',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await _notificationService?.notifyWithdrawalSubmitted(
        uid: uid,
        amount: amount,
      );

      // Send withdrawal submitted email
      try {
        final userDoc = await _userDoc(uid).get();
        final email = userDoc.data()?['email'] as String? ?? '';
        final name = email.split('@').first;
        if (email.isNotEmpty) {
          await _emailService.sendWithdrawalSubmittedEmail(
            toEmail: email,
            userName: name,
            amount: amount.toStringAsFixed(2),
            bankName: bankName,
            accountLast4: accountLast4,
            upiId: upiId.isNotEmpty ? upiId : 'N/A',
            withdrawalId: uid.substring(0, 8).toUpperCase(),
            timestamp: DateTime.now(),
          );
        }
      } catch (_) {
        // Email failures are non-critical; swallow silently.
      }
    } on WalletException {
      rethrow;
    } on FirebaseException catch (error) {
      throw WalletException(error.message ?? 'Withdrawal request failed.');
    }
  }

  Future<void> updateBankAccount({
    required String uid,
    required String bankId,
    required String bankName,
    required String accountHolderName,
    required String accountLast4,
    required String ifscCode,
    required String upiId,
    required bool isPrimary,
  }) async {
    try {
      final bankAccountsRef = _userDoc(uid).collection('bank_accounts');
      final existingAccounts = await bankAccountsRef.get();

      await _db.runTransaction((transaction) async {
        if (isPrimary) {
          for (final doc in existingAccounts.docs) {
            transaction.update(doc.reference, {'isPrimary': false});
          }
        }

        final docRef = bankAccountsRef.doc(bankId);
        transaction.update(docRef, {
          'accountHolderName': accountHolderName.trim(),
          'bankName': bankName.trim(),
          'accountLast4': accountLast4.trim(),
          'ifscCode': ifscCode.trim().toUpperCase(),
          'upiId': upiId.trim().toLowerCase(),
          'isPrimary': isPrimary,
        });

        if (isPrimary) {
          transaction.update(_userDoc(uid), {
            'bankName': bankName.trim(),
            'bankAccountHolder': accountHolderName.trim(),
            'bankAccountNumber': '****${accountLast4.trim()}',
            'bankIfsc': ifscCode.trim().toUpperCase(),
            'bankUpiId': upiId.trim().toLowerCase(),
          });
        }
      });

      await _notificationService?.notifyBankUpdated(
        uid: uid,
        bankName: bankName.trim(),
        last4: accountLast4.trim(),
      );
    } on FirebaseException catch (error) {
      throw WalletException(error.message ?? 'Failed to update bank account.');
    }
  }

  Future<void> setPrimaryBankAccount({
    required String uid,
    required String bankId,
  }) async {
    try {
      final bankAccountsRef = _userDoc(uid).collection('bank_accounts');
      final existingAccounts = await bankAccountsRef.get();
      final targetDoc = await bankAccountsRef.doc(bankId).get();
      if (!targetDoc.exists) {
        throw WalletException('Bank account not found.');
      }
      final targetData = targetDoc.data() ?? {};

      await _db.runTransaction((transaction) async {
        for (final doc in existingAccounts.docs) {
          transaction.update(doc.reference, {'isPrimary': doc.id == bankId});
        }

        transaction.update(_userDoc(uid), {
          'bankName': targetData['bankName'],
          'bankAccountHolder': targetData['accountHolderName'],
          'bankAccountNumber': '****${targetData['accountLast4']}',
          'bankIfsc': targetData['ifscCode'],
          'bankUpiId': (targetData['upiId'] as String? ?? '').toLowerCase(),
        });
      });
    } on FirebaseException catch (error) {
      throw WalletException(error.message ?? 'Failed to set primary bank account.');
    }
  }

  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> setWalletPin(String uid, String pin) async {
    try {
      final hashedPin = hashPin(pin);
      await _userDoc(uid).update({
        'walletPinHash': hashedPin,
      });
    } on FirebaseException catch (e) {
      throw WalletException(e.message ?? 'Failed to set wallet PIN.');
    }
  }

  Future<bool> verifyWalletPin(String uid, String pin) async {
    try {
      final userDoc = await _userDoc(uid).get();
      if (!userDoc.exists) {
        throw WalletException('User wallet not found.');
      }
      final walletUser = WalletUser.fromFirestore(userDoc);
      if (walletUser.walletPinHash == null) {
        throw WalletException('Wallet PIN not set.');
      }
      final hashedInput = hashPin(pin);
      return walletUser.walletPinHash == hashedInput;
    } on FirebaseException catch (e) {
      throw WalletException(e.message ?? 'Failed to verify wallet PIN.');
    }
  }

  Future<void> updateWithdrawalStatus({
    required String withdrawalId,
    required String uid,
    required double amount,
    required String status,
  }) async {
    try {
      final withdrawalRef = _db.collection('withdrawals').doc(withdrawalId);
      final userRef = _userDoc(uid);

      await _db.runTransaction((transaction) async {
        final withdrawalSnap = await transaction.get(withdrawalRef);
        if (!withdrawalSnap.exists) {
          throw WalletException('Withdrawal request not found.');
        }

        final currentStatus = withdrawalSnap.data()?['status'] as String? ?? 'pending';
        if (currentStatus != 'pending') {
          throw WalletException('Withdrawal has already been $currentStatus.');
        }

        transaction.update(withdrawalRef, {
          'status': status,
        });

        if (status == 'rejected') {
          final userSnap = await transaction.get(userRef);
          if (userSnap.exists) {
            final balance = (userSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
            transaction.update(userRef, {
              'balance': balance + amount,
            });

            final txRef = userRef.collection(userTransactionsCollection).doc();
            transaction.set(txRef, {
              'amount': amount,
              'type': 'credit',
              'description': 'Refund: Withdrawal rejected',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });

      if (status == 'approved') {
        await _notificationService?.notifyWithdrawalApproved(uid: uid, amount: amount);
      } else if (status == 'rejected') {
        await _notificationService?.notifyWithdrawalRejected(uid: uid, amount: amount);
      }

      // Send email for withdrawal status change
      try {
        final userDoc = await _userDoc(uid).get();
        final email = userDoc.data()?['email'] as String? ?? '';
        final name = email.split('@').first;
        final withdrawalSnap = await _db.collection('withdrawals').doc(withdrawalId).get();
        final wData = withdrawalSnap.data() ?? {};
        final bankName = wData['bankName'] as String? ?? 'N/A';
        final accountLast4 = wData['accountLast4'] as String? ?? '????';
        final upiId = wData['upiId'] as String? ?? 'N/A';
        if (email.isNotEmpty) {
          if (status == 'approved') {
            await _emailService.sendWithdrawalApprovedEmail(
              toEmail: email,
              userName: name,
              amount: amount.toStringAsFixed(2),
              bankName: bankName,
              accountLast4: accountLast4,
              upiId: upiId,
              withdrawalId: withdrawalId.substring(0, 8).toUpperCase(),
            );
          } else if (status == 'rejected') {
            await _emailService.sendWithdrawalRejectedEmail(
              toEmail: email,
              userName: name,
              amount: amount.toStringAsFixed(2),
              bankName: bankName,
              accountLast4: accountLast4,
              withdrawalId: withdrawalId.substring(0, 8).toUpperCase(),
            );
          }
        }
      } catch (_) {
        // Email failures are non-critical; swallow silently.
      }
    } on FirebaseException catch (e) {
      throw WalletException(e.message ?? 'Failed to update withdrawal status.');
    }
  }

  Future<void> transferWalletToBank({
    required String uid,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw WalletException('Amount must be greater than zero.');
    }

    try {
      await _db.runTransaction((transaction) async {
        final userRef = _userDoc(uid);
        final userSnap = await transaction.get(userRef);

        if (!userSnap.exists) {
          throw WalletException('Wallet not found.');
        }

        final data = userSnap.data() ?? {};
        final bool isBankLinked = data['isBankLinked'] as bool? ?? false;
        if (!isBankLinked) {
          throw WalletException('Bank account is not linked.');
        }

        final walletBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final bankBalance = (data['bankBalance'] as num?)?.toDouble() ?? 0.0;

        if (walletBalance < amount) {
          throw WalletException('Insufficient wallet balance.');
        }

        transaction.update(userRef, {
          'balance': walletBalance - amount,
          'bankBalance': bankBalance + amount,
        });

        final txRef = userRef.collection(userTransactionsCollection).doc();
        transaction.set(txRef, {
          'amount': amount,
          'type': 'debit',
          'description': 'Transfer to Bank',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await _notificationService?.notifyTransferToBank(uid: uid, amount: amount);
    } on WalletException {
      rethrow;
    } on FirebaseException catch (error) {
      throw WalletException(error.message ?? 'Transfer failed.');
    }
  }

  Future<void> transferBankToWallet({
    required String uid,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw WalletException('Amount must be greater than zero.');
    }

    try {
      await _db.runTransaction((transaction) async {
        final userRef = _userDoc(uid);
        final userSnap = await transaction.get(userRef);

        if (!userSnap.exists) {
          throw WalletException('Wallet not found.');
        }

        final data = userSnap.data() ?? {};
        final bool isBankLinked = data['isBankLinked'] as bool? ?? false;
        if (!isBankLinked) {
          throw WalletException('Bank account is not linked.');
        }

        final walletBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final bankBalance = (data['bankBalance'] as num?)?.toDouble() ?? 0.0;

        if (bankBalance < amount) {
          throw WalletException('Insufficient bank balance.');
        }

        transaction.update(userRef, {
          'balance': walletBalance + amount,
          'bankBalance': bankBalance - amount,
        });

        final txRef = userRef.collection(userTransactionsCollection).doc();
        transaction.set(txRef, {
          'amount': amount,
          'type': 'credit',
          'description': 'Add from Bank',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await _notificationService?.notifyTransferFromBank(uid: uid, amount: amount);
    } on WalletException {
      rethrow;
    } on FirebaseException catch (error) {
      throw WalletException(error.message ?? 'Transfer failed.');
    }
  }
}
