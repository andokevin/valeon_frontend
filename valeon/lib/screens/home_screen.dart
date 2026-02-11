import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/trending_card.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeMessage(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 32),
                    _buildCentralScanButton(context),
                    const SizedBox(height: 16),
                    _buildInstructionText(),
                    const SizedBox(height: 40),
                    _buildTrendingSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingScreen),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.diamond,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Valeon',
            style: AppTextStyles.titleMedium,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour Alex',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          'Découvrez tout ce qui vous entoure',
          style: AppTextStyles.subtitle.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.searchPlaceholder,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralScanButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Utiliser un callback pour changer de page dans MainNavigation
          // Pour l'instant on garde ça simple
        },
        child: Container(
          width: AppSizes.scanCircleOuter,
          height: AppSizes.scanCircleOuter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primaryBlue.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.5, 1.0],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBlue,
                width: AppSizes.scanCircleBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note,
                size: AppSizes.iconScanCenter,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return Center(
      child: Text(
        AppStrings.scanPrompt,
        style: AppTextStyles.bodyLarge.copyWith(fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.trending,
              style: AppTextStyles.titleSmall.copyWith(fontSize: 20),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                AppStrings.seeAll,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: AppSizes.trendingCardHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              TrendingCard(
                imageUrl: 'placeholder',
                title: 'Film Populaire',
                subtitle: 'Inception',
                onTap: () {},
              ),
              const SizedBox(width: AppSizes.gapMedium),
              TrendingCard(
                imageUrl: 'placeholder',
                title: 'Top Titres',
                subtitle: '2019',
                onTap: () {},
              ),
              const SizedBox(width: AppSizes.gapMedium),
              TrendingCard(
                imageUrl: 'placeholder',
                title: 'Image du',
                subtitle: 'Modern / 268',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}