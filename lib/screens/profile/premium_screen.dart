// lib/screens/profile/premium_screen.dart (CORRIGÉ - sans débordement)
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/space_background.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, hPadding, isTablet),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(hPadding),
                child: Column(
                  children: [
                    _buildPremiumHeader(isTablet),
                    const SizedBox(height: 20),
                    _buildFeatureList(),
                    const SizedBox(height: 24),
                    _buildPricingCards(context, isTablet),
                    const SizedBox(height: 16),
                    _buildGuarantee(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Text(
              'Premium',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.premium, Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.premium.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              size: isTablet ? 40 : 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Valeon Premium',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Libérez tout le potentiel de Valeon',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    const features = [
      {
        'icon': Icons.videocam,
        'title': 'Scans vidéo',
        'description': 'Identifiez films et séries depuis une vidéo',
      },
      {
        'icon': Icons.all_inclusive,
        'title': 'Scans illimités',
        'description': '999 scans/jour sans restriction',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Recommandations IA',
        'description': 'Personnalisées par intelligence artificielle',
      },
      {
        'icon': Icons.download,
        'title': 'Mode hors ligne',
        'description': 'Accédez à vos scans sans internet',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Support prioritaire',
        'description': 'Réponse en moins de 24h',
      },
    ];

    return Column(
      children: features.map((feature) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.premium.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.premium.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppColors.premium,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature['description'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingCards(BuildContext context, bool isTablet) {
    return Column(
      children: [
        _buildPricingCard(
          title: 'Mensuel',
          price: '9,99€',
          period: '/mois',
          isPopular: false,
          onTap: () => _showPaywall(context),
          isTablet: isTablet,
        ),
        const SizedBox(height: 10),
        _buildPricingCard(
          title: 'Annuel',
          price: '19,99€', // ← CORRIGÉ : prix annuel correct
          period: '/an',
          isPopular: true,
          badge: 'Économisez 33%',
          onTap: () => _showPaywall(context),
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required bool isPopular,
    String? badge,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isPopular
              ? LinearGradient(
                  colors: [
                    AppColors.premium.withOpacity(0.2),
                    AppColors.premium.withOpacity(0.1),
                  ],
                )
              : null,
          color: isPopular ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isPopular ? AppColors.premium : Colors.white.withOpacity(0.2),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (badge != null)
              Positioned(
                top: -10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.premium,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: isPopular ? AppColors.premium : Colors.white,
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      period,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuarantee() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, color: Colors.green, size: 14),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Paiement sécurisé • Annulation à tout moment',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Paiement',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: const Text(
          'L\'intégration du paiement (Stripe/RevenueCat) est à configurer.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
