import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// A slowly-drifting, pulsing aurora background made of blurred gradient orbs.
/// Wrap any Scaffold body with: Stack(children: [const AuroraBackground(), child])
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late final AnimationController _orb1Controller;
  late final AnimationController _orb2Controller;
  late final AnimationController _orb3Controller;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);

    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background fill
        Container(color: AppColors.background),

        // Orb 1 — top-left, purple
        AnimatedBuilder(
          animation: _orb1Controller,
          builder: (context, _) {
            final t = _orb1Controller.value;
            return Positioned(
              left: -80 + t * 120,
              top: -60 + t * 80,
              child: _AuroraOrb(
                size: 380,
                color: AppColors.auroraPurple,
                opacity: 0.65 + t * 0.15,
              ),
            );
          },
        ),

        // Orb 2 — bottom-right, blue
        AnimatedBuilder(
          animation: _orb2Controller,
          builder: (context, _) {
            final size = MediaQuery.sizeOf(context);
            final t = _orb2Controller.value;
            return Positioned(
              right: -100 + t * 100,
              bottom: -80 + t * 60,
              child: _AuroraOrb(
                size: size.width > 700 ? 450 : 320,
                color: AppColors.auroraBlue,
                opacity: 0.55 + t * 0.2,
              ),
            );
          },
        ),

        // Orb 3 — center-top, cyan accent
        AnimatedBuilder(
          animation: _orb3Controller,
          builder: (context, _) {
            final size = MediaQuery.sizeOf(context);
            final t = _orb3Controller.value;
            return Positioned(
              left: size.width * 0.3 + math.sin(t * math.pi) * 60,
              top: -40 + t * 50,
              child: _AuroraOrb(
                size: 260,
                color: AppColors.auroraCyan,
                opacity: 0.4 + t * 0.15,
              ),
            );
          },
        ),

        // Orb 4 — bottom-left, indigo
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final size = MediaQuery.sizeOf(context);
            final t = _pulseController.value;
            return Positioned(
              left: size.width * 0.1,
              bottom: size.height * 0.15 - t * 30,
              child: _AuroraOrb(
                size: 200,
                color: AppColors.auroraIndigo,
                opacity: 0.5 + t * 0.2,
              ),
            );
          },
        ),

        // Fine grain noise overlay (simulated via a translucent pattern)
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),
        ),

        // Child content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _AuroraOrb extends StatelessWidget {
  const _AuroraOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity.clamp(0.0, 0.9)),
            color.withValues(alpha: (opacity * 0.3).clamp(0.0, 0.9)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
