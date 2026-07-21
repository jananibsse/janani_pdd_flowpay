import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/app_theme.dart';
import '../widgets/aurora_background.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.authService,
    required this.walletService,
  });

  final AuthService authService;
  final WalletService walletService;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconRotate;
  late final Animation<double> _iconGlow;

  late final AnimationController _contentController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _iconRotate = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOutSine),
    );
    _iconGlow = Tween<double>(begin: 0.3, end: 0.65).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOutSine),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppTheme.pagePadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppTheme.contentMaxWidth(context),
                ),
                child: FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: GlassCard(
                      padding: const EdgeInsets.all(36),
                      borderRadius: 28,
                      glowColor: AppColors.purpleAccent,
                      glowStrength: 0.2,
                      blurSigma: 24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIcon(),
                          const SizedBox(height: 28),
                          _buildTitle(),
                          const SizedBox(height: 14),
                          _buildSubtitle(),
                          const SizedBox(height: 40),
                          _buildLoginButton(context),
                          const SizedBox(height: 14),
                          _buildRegisterButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _iconRotate.value,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF2D1B69), Color(0xFF0A0F1E)],
              ),
              border: Border.all(
                color: AppColors.purpleAccent.withValues(alpha: _iconGlow.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleAccent
                      .withValues(alpha: _iconGlow.value * 0.5),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 44,
              color: AppColors.purpleAccent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFFCDD6F4)],
      ).createShader(bounds),
      child: const Text(
        'Offline Digital Payments',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Secure QR-based wallet transactions with offline synchronization.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: 15,
        height: 1.5,
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return AnimatedGradientButton(
      label: 'Login',
      gradient: AppTheme.primaryGradient,
      icon: Icons.login_rounded,
      onPressed: () {
        Navigator.push(
          context,
          _fadeSlideRoute(
            LoginScreen(
              authService: widget.authService,
              walletService: widget.walletService,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return NeonOutlineButton(
      label: 'Create an account',
      color: AppColors.cyanAccent,
      icon: Icons.person_add_rounded,
      onPressed: () {
        Navigator.push(
          context,
          _fadeSlideRoute(
            RegisterScreen(
              authService: widget.authService,
              walletService: widget.walletService,
            ),
          ),
        );
      },
    );
  }

  PageRouteBuilder<void> _fadeSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 450),
    );
  }
}
