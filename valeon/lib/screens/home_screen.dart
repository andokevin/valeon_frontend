import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/trending_card.dart';
import 'result_screen.dart';
import 'search_screen.dart';

class HomeScreenContent extends StatelessWidget {
  final Function(int)? onNavigate;

  const HomeScreenContent({
    Key? key,
    this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);

    return SpaceBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.maxContentWidth(context),
            ),
            child: Column(
              children: [
                _buildHeader(context, hPadding),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(hPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeMessage(context, isTablet),
                        SizedBox(height: isTablet ? 28.0 : 20.0),
                        _buildSearchBar(context),
                        SizedBox(height: isTablet ? 44.0 : 32.0),
                        _buildCentralScanButton(context, isTablet),
                        SizedBox(height: isTablet ? 24.0 : 16.0),
                        _buildInstructionText(context, isTablet),
                        SizedBox(height: isTablet ? 52.0 : 40.0),
                        _buildTrendingSection(context, isTablet),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          Container(
            width: isTablet ? 52.0 : 40.0,
            height: isTablet ? 52.0 : 40.0,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.diamond,
              color: Colors.white,
              size: isTablet ? 30.0 : 24.0,
            ),
          ),
          SizedBox(width: isTablet ? 16.0 : 12.0),
          Text(
            'Valeon',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: isTablet ? 28.0 : 22.0,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: isTablet ? 34.0 : 28.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour Alex',
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: isTablet ? 30.0 : 24.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Découvrez tout ce qui vous entoure',
          style: AppTextStyles.subtitle.copyWith(
            fontSize: isTablet ? 17.0 : 14.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 18.0 : 14.0,
        ),
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
              size: isTablet ? 24.0 : 20.0,
            ),
            SizedBox(width: isTablet ? 16.0 : 12.0),
            Expanded(
              child: Text(
                AppStrings.searchPlaceholder,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 16.0 : 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralScanButton(BuildContext context, bool isTablet) {
    final outerSize = ResponsiveHelper.scanCircleOuter(context);
    final iconSize = ResponsiveHelper.iconScanCenter(context);

    return Center(
      child: GestureDetector(
        onTap: () {
          if (onNavigate != null) {
            onNavigate!(1);
          }
        },
        child: Container(
          width: outerSize,
          height: outerSize,
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
              child: Icon(
                Icons.music_note,
                size: iconSize,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText(BuildContext context, bool isTablet) {
    return Center(
      child: Text(
        AppStrings.scanPrompt,
        style: AppTextStyles.bodyLarge.copyWith(
          fontSize: isTablet ? 18.0 : 15.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context, bool isTablet) {
    final cardHeight = ResponsiveHelper.trendingCardHeight(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.trending,
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: isTablet ? 24.0 : 20.0,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
              child: Text(
                AppStrings.seeAll,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: isTablet ? 16.0 : 14.0,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: isTablet ? 20.0 : 16.0),
        
        SizedBox(
          height: cardHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              TrendingCard(
                imageUrl: 'placeholder',
                title: 'Film Populaire',
                subtitle: 'Inception',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResultScreen(
                        title: 'Inception',
                        artist: 'Christopher Nolan',
                        year: '2010',
                        genre: 'Science-fiction',
                        description: 'Un voleur qui s\'infiltre dans les rêves des autres pour voler leurs secrets.',
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: AppSizes.gapMedium),
              TrendingCard(
                imageUrl: 'placeholder',
                title: 'Top Titres',
                subtitle: '2019',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResultScreen(
                        title: 'Blinding Lights',
                        artist: 'The Weeknd',
                        year: '2019',
                        genre: 'Synth-pop',
                        description: 'Chanson populaire de The Weeknd sortie en 2019.',
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: AppSizes.gapMedium),
              TrendingCard(
                imageUrl: 'placeholder',
                title: 'Image du',
                subtitle: 'Modern / 268',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResultScreen(
                        title: 'La Nuit Étoilée',
                        artist: 'Vincent Van Gogh',
                        year: '1889',
                        genre: 'Post-impressionnisme',
                        description: 'Tableau célèbre de Van Gogh représentant un ciel nocturne tourbillonnant.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}