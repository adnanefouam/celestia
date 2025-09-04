import 'package:celestia/core/design_system/app_colors.dart';
import 'package:celestia/core/design_system/app_spacing.dart';
import 'package:celestia/core/design_system/app_typography.dart';
import 'package:celestia/core/api/weather_service.dart';
import 'package:celestia/core/api/api_config.dart';
import 'package:celestia/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/routes/app_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _marqueeController;
  late Animation<double> _marqueeAnimation;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    _marqueeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _marqueeController,
      curve: Curves.linear,
    ));

    _marqueeController.repeat();
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    super.dispose();
  }

  Future<void> _initializeWeatherService() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      WeatherService.initialize(
        apiKey: '2b82ccf3fb883f1267530199e5e0d4e6',
        environment: Environment.development,
        defaultQueryParameters: {
          'units': 'metric',
          'lang': 'en',
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize WeatherService: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        margin: isDesktop
            ? EdgeInsets.symmetric(horizontal: (size.width - 440) / 2)
            : EdgeInsets.zero,
        child: Column(
          children: [
            // Hero Image Section
            _buildHeroSection(context)
                .animate()
                .fadeIn(duration: 800.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0, duration: 800.ms, delay: 100.ms),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: AppSpacing.paddingHorizontalLG,
                      child: Column(
                        children: [
                          AppSpacing.gapVerticalXL,

                          // Welcome Text & Title
                          _buildWelcomeSection(context)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 400.ms)
                              .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 600.ms,
                                  delay: 400.ms),

                          AppSpacing.gapVerticalLG,

                          // Description
                          _buildDescriptionSection(context)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 700.ms)
                              .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 600.ms,
                                  delay: 700.ms),

                          AppSpacing.gapVerticalXXL,
                        ],
                      ),
                    ),

                    // Cities Marquee - Full width without padding
                    _buildCitiesMarquee(context)
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 1000.ms),

                    AppSpacing.gapVerticalXXL,
                  ],
                ),
              ),
            ),

            // Bottom section with button and footer
            Padding(
              padding: AppSpacing.paddingHorizontalLG
                  .add(EdgeInsets.only(bottom: 60)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CTA Button
                  _buildCTAButton(context)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 1200.ms)
                      .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          duration: 400.ms,
                          delay: 1200.ms,
                          curve: Curves.elasticOut),

                  AppSpacing.gapVerticalLG,

                  // Footer
                  _buildFooter(context)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 1600.ms),

                  AppSpacing.gapVerticalMD,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heroHeight = size.height * 0.4;

    return Stack(
      children: [
        Container(
          height: heroHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.firstScreenImage.provider(),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Assets.icons.sunLogo
              .svg(
                width: 50,
                height: 50,
              )
              .animate()
              .fadeIn(duration: 800.ms, delay: 600.ms)
              .slideY(begin: 1.0, end: 0, duration: 800.ms, delay: 600.ms),
        ),
        AppSpacing.gapVerticalSM,
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome to',
          textAlign: TextAlign.center,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.gapVerticalSM,
        Assets.icons.celestiaLogo.svg(
          width: 50,
          height: 50,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        'Accurate, real-time weather insights to keep you ahead of the storm.',
        textAlign: TextAlign.center,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCitiesMarquee(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = 100.0;
    final spacing = 8.0;
    final totalCardWidth = cardWidth + spacing;

    return Container(
      height: 140,
      width: double.infinity,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _marqueeAnimation,
          builder: (context, child) {
            // Start position simulates 5 cards already passed
            final startPosition = -5 * totalCardWidth;
            final currentPosition =
                startPosition - (_marqueeAnimation.value * screenWidth * 2);

            return Stack(
              children: List.generate(30, (index) {
                final cardPosition = currentPosition + (index * totalCardWidth);

                // Create infinite loop by repositioning cards that went off screen
                final adjustedPosition = cardPosition +
                    ((cardPosition < -totalCardWidth)
                        ? (30 * totalCardWidth)
                        : 0.0);

                return Positioned(
                  left: adjustedPosition,
                  top: 10,
                  child: _buildCityCard(index),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCityCard(int index) {
    final cityAssets = [
      Assets.images.city1,
      Assets.images.city2,
      Assets.images.city3,
      Assets.images.city4,
      Assets.images.city5,
    ];

    final assetIndex = index % cityAssets.length;
    final rotation = (index % 7) * 0.1 - 0.3; // Slight rotation variation

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(
              color: AppColors.backgroundPrimary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            child: Image(
              image: cityAssets[assetIndex].provider(),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryOrange,
            AppColors.primaryOrange.withOpacity(0.8),
          ],
        ),
        borderRadius: AppRadius.radiusCircular,
        border: Border.all(
          color: AppColors.backgroundPrimary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange,
            blurRadius: 0,
            offset: const Offset(0, 0),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: AppRadius.radiusCircular,
        onTap: () async {
          // Initialize WeatherService before navigation
          await _initializeWeatherService();
          if (mounted) {
            // Add a small delay to avoid navigation conflicts
            Future.microtask(() => context.go(AppRouter.weather));
          }
        },
        child: Center(
          child: _isInitializing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.backgroundPrimary,
                        ),
                      ),
                    ),
                    AppSpacing.gapHorizontalSM,
                    Text(
                      'Initializing...',
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.backgroundPrimary,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Discover the weather',
                  style: AppTypography.buttonLarge.copyWith(
                    color: AppColors.backgroundPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Designed & developed with ❤ by ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          TextSpan(
            text: '@Fouham Adnane',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
