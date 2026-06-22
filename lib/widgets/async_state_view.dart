import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'flow_pay_button.dart';

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
    required this.child,
    this.loadingMessage = 'Loading...',
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'Content will appear once available.',
    this.errorMessage = 'Something went wrong.',
    this.onRetry,
    this.emptyIcon = Icons.inbox_outlined,
  });

  final bool isLoading;
  final bool hasError;
  final bool isEmpty;
  final Widget child;
  final String loadingMessage;
  final String emptyTitle;
  final String emptyMessage;
  final String errorMessage;
  final VoidCallback? onRetry;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _StateContainer(
        icon: Icons.hourglass_top_rounded,
        iconColor: AppColors.cyanAccent,
        title: loadingMessage,
        message: 'Please wait a moment.',
        showSpinner: true,
      );
    }

    if (hasError) {
      return _StateContainer(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        title: 'Unable to load',
        message: errorMessage,
        action: onRetry == null
            ? null
            : FlowPayButton(
                label: 'Retry',
                backgroundColor: AppColors.purpleAccent,
                foregroundColor: Colors.white,
                onPressed: onRetry,
              ),
      );
    }

    if (isEmpty) {
      return _StateContainer(
        icon: emptyIcon,
        iconColor: AppColors.purpleAccent,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return child;
  }
}

class _StateContainer extends StatelessWidget {
  const _StateContainer({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.showSpinner = false,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final bool showSpinner;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSpinner)
              const CircularProgressIndicator(color: AppColors.cyanAccent)
            else
              Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
