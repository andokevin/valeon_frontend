// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';

class SplashScreen extends StatelessWidget {
  final bool minimal;

  const SplashScreen({super.key, this.minimal = false});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final logoSize = ResponsiveHelper.logoSize(context);
    final logoIconSize = ResponsiveHelper.logoIconSize(context);

    // Configuration de la barre de statut
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.maxContentWidth(context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Logo animé (simple)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(
                              isTablet ? 40 : 30,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.diamond,
                            size: logoIconSize,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  if (!minimal) ...[
                    const SizedBox(height: 32),

                    // Titre avec fade
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            AppStrings.appName,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontSize: ResponsiveHelper.splashTitleSize(
                                context,
                              ),
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Slogan avec fade retardé
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            AppStrings.tagline,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: isTablet ? 18 : 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ],

                  const Spacer(),

                  if (!minimal) ...[
                    // Indicateur de chargement
                    const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
