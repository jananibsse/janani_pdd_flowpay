import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// A true glassmorphism card with backdrop blur, frosted border, and neon glow.
/// Always wrap with ClipRRect for correct blur clipping.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.glowColor = AppColors.cyanAccent,
    this.glowStrength = 0.15,
    this.blurSigma = 18,
    this.tintOpacity = 0.08,
    this.borderOpacity = 0.18,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color glowColor;
  final double glowStrength;
  final double blurSigma;
  final double tintOpacity;
  final double borderOpacity;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: tintOpacity + 0.04),
                Colors.white.withValues(alpha: tintOpacity * 0.4),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: glowStrength),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Animated variant that pulses its glow border on entry.
class GlassCardAnimated extends StatefulWidget {
  const GlassCardAnimated({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.glowColor = AppColors.cyanAccent,
    this.delay = Duration.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color glowColor;
  final Duration delay;

  @override
  State<GlassCardAnimated> createState() => _GlassCardAnimatedState();
}

class _GlassCardAnimatedState extends State<GlassCardAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GlassCard(
          padding: widget.padding,
          borderRadius: widget.borderRadius,
          glowColor: widget.glowColor,
          child: widget.child,
        ),
      ),
    );
  }
}
