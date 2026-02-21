import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB8860B), AppTheme.premium, Color(0xFFFFECB3)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 56),
                  Icon(Icons.star_rounded, color: Colors.black, size: 64),
                  SizedBox(height: 8),
                  Text('Valeon Premium',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                      color: Colors.black)),
                  Text('Libérez tout le potentiel',
                    style: TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(delegate: SliverChildListDelegate([
            const Text('Ce que vous obtenez',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: AppTheme.onBackground)),
            const SizedBox(height: 20),
            ..._features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.premium.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(f.$1, color: AppTheme.premium, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.$2, style: const TextStyle(fontWeight: FontWeight.w600,
                    color: AppTheme.onBackground)),
                  Text(f.$3, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13)),
                ])),
              ]),
            )),
            const SizedBox(height: 32),
            _PriceCard(
              title: 'Mensuel',
              price: '9,99€',
              period: '/mois',
              onTap: () => _showPaywall(context),
            ),
            const SizedBox(height: 12),
            _PriceCard(
              title: 'Annuel',
              price: '79,99€',
              period: '/an',
              badge: 'Économisez 33%',
              isHighlighted: true,
              onTap: () => _showPaywall(context),
            ),
            const SizedBox(height: 32),
          ])),
        ),
      ]),
    );
  }

  void _showPaywall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Intégration paiement à configurer (Stripe/RevenueCat)')));
  }

  static const _features = [
    (Icons.videocam_rounded, 'Scans vidéo', 'Identifiez films et séries depuis une vidéo'),
    (Icons.all_inclusive_rounded, 'Scans illimités', '999 scans/jour sans restriction'),
    (Icons.recommend_rounded, 'Recommandations IA', 'Personnalisées par GPT-4'),
    (Icons.download_rounded, 'Export bibliothèque', 'Exportez vos données en CSV/JSON'),
    (Icons.support_agent_rounded, 'Support prioritaire', 'Réponse en moins de 24h'),
  ];
}

class _PriceCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool isHighlighted;
  final VoidCallback onTap;
  const _PriceCard({required this.title, required this.price, required this.period,
    this.badge, this.isHighlighted = false, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted ? AppTheme.premium.withOpacity(0.1) : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppTheme.premium : AppTheme.surface, width: 2),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700,
              color: AppTheme.onBackground)),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.premium, borderRadius: BorderRadius.circular(8)),
                child: Text(badge!, style: const TextStyle(color: Colors.black,
                  fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
        ])),
        RichText(text: TextSpan(children: [
          TextSpan(text: price, style: const TextStyle(fontSize: 20,
            fontWeight: FontWeight.w800, color: AppTheme.premium)),
          TextSpan(text: period, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13)),
        ])),
      ]),
    ),
  );
}
