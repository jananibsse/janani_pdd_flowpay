import 'package:flutter/material.dart';

import '../models/flowpay_notification.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/async_state_view.dart';
import '../widgets/screen_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.authService,
    required this.notificationService,
  });

  final AuthService authService;
  final NotificationService notificationService;

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Just now';
    }
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} hr ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppTheme.contentMaxWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(
                title: 'Notifications',
                subtitle: 'Real alerts from your wallet activity',
              ),
              Expanded(
                child: user == null
                    ? const AsyncStateView(
                        isLoading: true,
                        hasError: false,
                        isEmpty: false,
                        loadingMessage: 'Loading notifications...',
                        child: SizedBox.shrink(),
                      )
                    : StreamBuilder<List<FlowPayNotification>>(
                        stream: notificationService.watchNotifications(user.uid),
                        builder: (context, snapshot) {
                          final isLoading =
                              snapshot.connectionState == ConnectionState.waiting &&
                                  !snapshot.hasData;
                          final hasError = snapshot.hasError;
                          final items = snapshot.data ?? [];

                          return AsyncStateView(
                            isLoading: isLoading,
                            hasError: hasError,
                            isEmpty: !hasError && items.isEmpty,
                            emptyTitle: 'No notifications',
                            emptyMessage:
                                'Add money, send payments, or sync offline transfers to see alerts here.',
                            emptyIcon: Icons.notifications_none_rounded,
                            errorMessage:
                                'Unable to load notifications. Check your connection and try again.',
                            child: ListView.builder(
                              padding: AppTheme.pagePadding(context).copyWith(top: 0),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return _NotificationTile(
                                  notification: item,
                                  timeLabel: _formatTime(item.createdAt),
                                  onTap: () {
                                    if (!item.read) {
                                      notificationService.markAsRead(
                                        uid: user.uid,
                                        notificationId: item.id,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.timeLabel,
    required this.onTap,
  });

  final FlowPayNotification notification;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: AppTheme.panel().copyWith(
              border: Border.all(
                color: notification.read
                    ? Colors.white12
                    : notification.accentColor.withValues(alpha: 0.35),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(notification.icon, color: notification.accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              notification.read ? FontWeight.w500 : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.read)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: notification.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
