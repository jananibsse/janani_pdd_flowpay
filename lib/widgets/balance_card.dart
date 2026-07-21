import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'shimmer_loader.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.email,
    required this.balance,
    required this.balanceLabel,
    required this.onAddMoney,
    this.isLoading = false,
  });

  final String email;
  final double balance;
  final String balanceLabel;
  final VoidCallback onAddMoney;
  final bool isLoading;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with TickerProviderStateMixin {
  // 3D tilt
  double _rotX = 0;
  double _rotY = 0;

  // Entry animation
  late final AnimationController _entryController;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // Glow pulse
  late final AnimationController _glowController;

  // Button press
  late final AnimationController _btnController;
  late final Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event, BoxConstraints constraints) {
    final cx = constraints.maxWidth / 2;
    final cy = constraints.maxHeight / 2;
    final dx = (event.localPosition.dx - cx) / cx;
    final dy = (event.localPosition.dy - cy) / cy;
    setState(() {
      _rotX = -dy * 6; // degrees
      _rotY = dx * 6;
    });
  }

  void _onHoverExit(PointerEvent _) {
    setState(() {
      _rotX = 0;
      _rotY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const ShimmerBalanceCard();
    }

    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return MouseRegion(
              onHover: (e) => _onHover(e, constraints),
              onExit: _onHoverExit,
              child: AnimatedBuilder(
                animation: Listenable.merge([_glowController]),
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(_rotX * math.pi / 180)
                      ..rotateY(_rotY * math.pi / 180),
                    child: child,
                  );
                },
                child: _buildCardContent(context),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowAlpha = 0.28 + _glowController.value * 0.14;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1F3C),
                Color(0xFF0D1224),
                Color(0xFF121A32),
              ],
            ),
            border: Border.all(
              color: AppColors.cyanAccent.withValues(alpha: glowAlpha),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyanAccent.withValues(alpha: glowAlpha * 0.8),
                blurRadius: 40,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: AppColors.purpleAccent.withValues(alpha: 0.12),
                blurRadius: 60,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          // Decorative glowing orb top-right
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyanAccent.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Decorative orb bottom-left
          Positioned(
            bottom: -20,
            left: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purpleAccent.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Card content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildBalanceSection(),
              const SizedBox(height: 24),
              _buildAddMoneyButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0x2200F5FF), Color(0x228B5CF6)],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.cyanAccent.withValues(alpha: 0.3),
            ),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.cyanAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FlowPay Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.email,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0x228B5CF6), Color(0x226366F1)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.purpleAccent.withValues(alpha: 0.5),
            ),
          ),
          child: const Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.purpleAccent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Balance',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.cyanAccent, Color(0xFF00B4D8)],
          ).createShader(bounds),
          child: Text(
            widget.balanceLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoneyButton() {
    return GestureDetector(
      onTapDown: (_) => _btnController.forward(),
      onTapUp: (_) {
        _btnController.reverse();
        widget.onAddMoney();
      },
      onTapCancel: () => _btnController.reverse(),
      child: ScaleTransition(
        scale: _btnScale,
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.cyanGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyanAccent.withValues(
                      alpha: 0.35 + _glowController.value * 0.15,
                    ),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.black, size: 22),
              SizedBox(width: 8),
              Text(
                'Add Money',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
