import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/drive_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeTitle;
  late final Animation<double> _fadeFooter;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeTitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Cubic(0.16, 1, 0.3, 1),
      ),
    );
    _fadeFooter = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Cubic(0.16, 1, 0.3, 1),
      ),
    );

    _progressController.forward();
    _fadeController.forward();

    _prefetchData();
  }

  Future<void> _prefetchData() async {
    // Start fetching data in the background
    ref.read(driveRootDataProvider.future);
    ref.read(fileCountsProvider.future);
    ref.read(onlineResourcesProvider.future);

    // Brief display, then navigate
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _progressController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: Stack(
        children: [
          // Central content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo wrapper with float + glow shadow
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1d1e2e).withAlpha(153),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF424655).withAlpha(77),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A6FFF).withValues(
                                alpha: _glowAnimation.value,
                              ),
                              blurRadius: 32,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: const Color(0xFF1A6FFF).withValues(
                                alpha: _glowAnimation.value * 0.5,
                              ),
                              blurRadius: 64,
                              spreadRadius: 16,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(23),
                          child: Image.asset(
                            'images/csb-hero-logo_org.png',
                            width: 96,
                            height: 96,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.stackLg),

                // Title
                FadeTransition(
                  opacity: _fadeTitle,
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          height: 56 / 48,
                          letterSpacing: -0.02,
                          color: Colors.white,
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: FadeTransition(
              opacity: _fadeFooter,
              child: Center(
                child: SizedBox(
                  width: 192,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(
                      children: [
                        Container(
                          color: const Color(0xFF323344).withAlpha(77),
                        ),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, _) {
                            return FractionallySizedBox(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A6FFF),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1A6FFF)
                                          .withAlpha(153),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: FadeTransition(
              opacity: _fadeFooter,
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  AppLocalizations.of(context)!.splashFooter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 20 / 14,
                    color: AppColorsDark.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
