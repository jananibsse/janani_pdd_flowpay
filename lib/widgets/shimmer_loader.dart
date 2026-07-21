import 'package:flutter/material.dart';

import 'app_theme.dart';

/// A shimmer loading placeholder that sweeps a highlight across the widget area.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _controller.value * 4, 0),
              end: Alignment(0.5 + _controller.value * 4, 0),
              colors: const [
                Color(0xFF0F1629),
                Color(0xFF1A2545),
                Color(0xFF2A3A60),
                Color(0xFF1A2545),
                Color(0xFF0F1629),
              ],
              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A full-width shimmer text placeholder
class ShimmerText extends StatelessWidget {
  const ShimmerText({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// A pre-built shimmer layout for the balance card loading state.
class ShimmerBalanceCard extends StatelessWidget {
  const ShimmerBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glowCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 44, height: 44, borderRadius: 12),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 120, height: 14, borderRadius: 7),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 180, height: 11, borderRadius: 6),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          ShimmerBox(width: 100, height: 12, borderRadius: 6),
          const SizedBox(height: 10),
          ShimmerBox(width: 160, height: 42, borderRadius: 10),
          const SizedBox(height: 24),
          ShimmerBox(width: double.infinity, height: 50, borderRadius: 14),
        ],
      ),
    );
  }
}

/// A shimmer placeholder for list transaction items.
class ShimmerTransactionTile extends StatelessWidget {
  const ShimmerTransactionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ShimmerBox(width: 44, height: 44, borderRadius: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 13, borderRadius: 7),
                const SizedBox(height: 6),
                ShimmerBox(width: 90, height: 11, borderRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ShimmerBox(width: 60, height: 18, borderRadius: 9),
        ],
      ),
    );
  }
}
