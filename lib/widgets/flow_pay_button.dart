import 'package:flutter/material.dart';

import 'animated_button.dart';
import 'app_theme.dart';

class FlowPayButton extends StatelessWidget {
  const FlowPayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.purpleAccent,
    this.foregroundColor = Colors.white,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Use gradient based on the requested background color
    final LinearGradient gradient;
    if (backgroundColor == AppColors.cyanAccent ||
        backgroundColor == Colors.cyanAccent) {
      gradient = AppTheme.cyanGradient;
    } else if (backgroundColor == AppColors.purpleAccent ||
        backgroundColor == Colors.purpleAccent) {
      gradient = AppTheme.primaryGradient;
    } else {
      gradient = LinearGradient(
        colors: [backgroundColor, backgroundColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return AnimatedGradientButton(
      label: label,
      onPressed: onPressed,
      gradient: gradient,
      foregroundColor: foregroundColor,
      isLoading: isLoading,
    );
  }
}
