import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/app_theme.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo bloom
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowRadius;

  // Text shimmer + slide
  late final AnimationController _textController;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // Subtitle
  late final AnimationController _subtitleController;
  late final Animation<double> _subtitleOpacity;

  // Button
  late final AnimationController _buttonController;
  late final Animation<double> _buttonOpacity;
  late final Animation<Offset> _buttonSlide;

  // Orbs drift
  late final AnimationController _orb1Controller;
  late final AnimationController _orb2Controller;
  late final AnimationController _orb3Controller;

  // Continuous glow pulse on logo
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Orbs
    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    // Logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _glowRadius = Tween<double>(begin: 0, end: 60).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Glow pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Text
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Subtitle
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeOut,
    );

    // Button
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonOpacity = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic),
    );

    // Sequence the animations
    _logoController.forward().then((_) {
      _pulseController.repeat(reverse: true);
      _textController.forward().then((_) {
        _subtitleController.forward().then((_) {
          _buttonController.forward();
        });
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    _buttonController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Aurora orbs
          _buildOrb(_orb1Controller, -80, -60, size.width * 0.9,
              AppColors.auroraPurple, 0.7),
          _buildOrb(_orb2Controller, size.width * 0.4, size.height * 0.55,
              size.width * 0.7, AppColors.auroraBlue, 0.6),
          _buildOrb(_orb3Controller, size.width * 0.1, size.height * 0.4,
              200, AppColors.auroraCyan, 0.5),

          // Vignette
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Color(0xAA030712)],
                radius: 0.9,
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: AppTheme.pagePadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppTheme.contentMaxWidth(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 32),
                    _buildTitle(),
                    const SizedBox(height: 14),
                    _buildSubtitle(),
                    const SizedBox(height: 52),
                    _buildButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(AnimationController ctrl, double left, double top,
      double size, Color color, double maxOpacity) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final t = ctrl.value;
        return Positioned(
          left: left + t * 60,
          top: top + t * 40,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: maxOpacity * (0.7 + t * 0.3)),
                  color.withValues(alpha: maxOpacity * 0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, _) {
        final glow = _glowRadius.value;
        final pulse = _pulseController.value;
        return ScaleTransition(
          scale: _logoScale,
          child: FadeTransition(
            opacity: _logoOpacity,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF1A2545), Color(0xFF0A0F1E)],
                ),
                border: Border.all(
                  color: AppColors.cyanAccent.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyanAccent
                        .withValues(alpha: 0.4 + pulse * 0.2),
                    blurRadius: glow + pulse * 20,
                    spreadRadius: pulse * 4,
                  ),
                  BoxShadow(
                    color: AppColors.purpleAccent.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 50,
                color: AppColors.cyanAccent,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _textOpacity,
      child: SlideTransition(
        position: _textSlide,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.cyanAccent, AppColors.purpleAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'FLOWPAY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return FadeTransition(
      opacity: _subtitleOpacity,
      child: Text(
        'Payments Beyond Internet',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return FadeTransition(
      opacity: _buttonOpacity,
      child: SlideTransition(
        position: _buttonSlide,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: AnimatedGradientButton(
            label: 'Get Started',
            gradient: AppTheme.neonGradient,
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.push(
                context,
                _createRoute(
                  WelcomeScreen(
                    authService: widget.authService,
                    walletService: widget.walletService,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Route<void> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
