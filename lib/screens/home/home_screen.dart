import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../widgets/home/scan_action_card.dart';
import '../../widgets/home/trending_section.dart';
import '../../widgets/home/recommendation_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bonjour, ${user?.userFullName.split(' ').first ?? ''} 👋',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: AppTheme.onBackground)),
                  const Text('Que souhaitez-vous identifier ?',
                    style: TextStyle(fontSize: 11, color: AppTheme.onSurface)),
                ],
              ),
            ),
            actions: [
              if (!isPremium)
                TextButton.icon(
                  onPressed: () => context.go('/premium'),
                  icon: const Icon(Icons.star_rounded, color: AppTheme.premium, size: 16),
                  label: const Text('Premium',
                    style: TextStyle(color: AppTheme.premium, fontSize: 12)),
                ),
              IconButton(
                icon: const Icon(Icons.person_rounded, color: AppTheme.onBackground),
                onPressed: () => context.go('/profile'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Scan actions
                const Text('Scanner',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppTheme.onBackground)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: ScanActionCard(
                      icon: Icons.mic_rounded,
                      label: 'Audio',
                      color: AppTheme.primary,
                      onTap: () => context.go('/scan/audio'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ScanActionCard(
                      icon: Icons.image_rounded,
                      label: 'Image',
                      color: const Color(0xFF00B4D8),
                      onTap: () => context.go('/scan/image'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ScanActionCard(
                      icon: Icons.videocam_rounded,
                      label: 'Vidéo',
                      color: AppTheme.secondary,
                      isPremiumOnly: !isPremium,
                      onTap: () {
                        if (!isPremium) {
                          context.go('/premium');
                        } else {
                          context.go('/scan/video');
                        }
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 32),
                const TrendingSection(),
                const SizedBox(height: 32),
                const RecommendationSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
