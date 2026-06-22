import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/app_theme.dart';

class FlowPayNotification {
  const FlowPayNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime? createdAt;

  factory FlowPayNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return FlowPayNotification(
      id: doc.id,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      read: data['read'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  IconData get icon {
    switch (type) {
      case 'add_money':
        return Icons.add_card_rounded;
      case 'add_money_failed':
        return Icons.error_outline_rounded;
      case 'payment_sent':
        return Icons.north_east_rounded;
      case 'payment_received':
        return Icons.south_west_rounded;
      case 'offline_sync':
        return Icons.cloud_done_rounded;
      case 'withdrawal':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get accentColor {
    switch (type) {
      case 'payment_sent':
      case 'add_money_failed':
        return AppColors.error;
      case 'payment_received':
      case 'add_money':
        return AppColors.cyanAccent;
      case 'offline_sync':
      case 'withdrawal':
        return AppColors.purpleAccent;
      default:
        return AppColors.cyanAccent;
    }
  }
}
