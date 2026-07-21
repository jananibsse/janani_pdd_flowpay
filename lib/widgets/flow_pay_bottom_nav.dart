import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

class FlowPayBottomNav extends StatefulWidget {
  const FlowPayBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<FlowPayBottomNav> createState() => _FlowPayBottomNavState();
}

class _FlowPayBottomNavState extends State<FlowPayBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  static const _items = [
    _NavData(icon: Icons.dashboard_rounded, label: 'Home'),
    _NavData(icon: Icons.insights_rounded, label: 'Analytics'),
    _NavData(icon: Icons.receipt_long_rounded, label: 'Transactions'),
    _NavData(icon: Icons.cloud_off_rounded, label: 'Offline'),
    _NavData(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final itemCount = _items.length;
    final itemWidth = width / itemCount;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    AppColors.surface.withValues(alpha: 0.92),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.cyanAccent.withValues(
                      alpha: 0.12 + _glowController.value * 0.08,
                    ),
                    width: 0.8,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyanAccent.withValues(
                      alpha: 0.05 + _glowController.value * 0.04,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: SafeArea(
            top: false,
            child: Stack(
              children: [
                // Animated sliding pill indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: itemWidth * widget.currentIndex + itemWidth * 0.15,
                  bottom: 4,
                  child: Container(
                    width: itemWidth * 0.7,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0x2200F5FF),
                          Color(0x228B5CF6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.cyanAccent.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                  ),
                ),

                // Nav items row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final selected = widget.currentIndex == index;
                      return Expanded(
                        child: _AnimatedNavItem(
                          icon: item.icon,
                          label: item.label,
                          selected: selected,
                          compact: width < 400,
                          onTap: () => widget.onTap(index),
                        ),
                      );
                    }),
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

class _NavData {
  const _NavData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _AnimatedNavItem extends StatefulWidget {
  const _AnimatedNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(_AnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.selected ? AppColors.cyanAccent : Colors.white.withValues(alpha: 0.4);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  widget.icon,
                  color: color,
                  size: widget.selected ? 24 : 22,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: widget.compact ? 9 : 10,
                fontWeight:
                    widget.selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: widget.selected ? 0.3 : 0,
              ),
              child: Text(
                widget.compact
                    ? _compactLabel(widget.label)
                    : widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compactLabel(String label) {
    const map = {
      'Analytics': 'Stats',
      'Transactions': 'Txns',
    };
    return map[label] ?? label;
  }
}
