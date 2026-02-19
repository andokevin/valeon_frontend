// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/trending_card.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/error_view.dart';
import '../providers/auth_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/connectivity_provider.dart';
import 'result_screen.dart';
import 'search_screen.dart';
import 'scan_screen.dart';
import 'chat_screen.dart';

class HomeScreenContent extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreenContent({super.key, this.onNavigate});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final recs = Provider.of<RecommendationProvider>(context, listen: false);

    if (auth.user != null) {
      await recs.loadRecommendations(auth.user!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final recs = Provider.of<RecommendationProvider>(context);

    return SpaceBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.maxContentWidth(context),
            ),
            child: Column(
              children: [
                _buildHeader(context, hPadding, connectivity.isOnline),

                Expanded(
                  child: recs.isLoading
                      ? const HomeSkeleton()
                      : recs.errorMessage != null
                      ? ErrorView(
                          message: recs.errorMessage,
                          onRetry: _loadData,
                        )
                      : _buildContent(context, recs, auth, isTablet),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding, bool isOnline) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final auth = Provider.of<AuthProvider>(context);

    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          // Logo
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

          // Titre
          Text(
            'Valeon',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: isTablet ? 28.0 : 22.0,
            ),
          ),

          const Spacer(),

          // Indicateur hors ligne
          if (!isOnline)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off,
                color: Colors.orange,
                size: isTablet ? 24.0 : 18.0,
              ),
            ),

          // Bouton chat IA
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            icon: Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textPrimary,
              size: isTablet ? 30.0 : 24.0,
            ),
          ),

          // Bouton recherche
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
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

  Widget _buildContent(
    BuildContext context,
    RecommendationProvider recs,
    AuthProvider auth,
    bool isTablet,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message de bienvenue
          _buildWelcomeMessage(
            context,
            auth.user?.displayName ?? 'Utilisateur',
            isTablet,
          ),

          const SizedBox(height: 20),

          // Barre de recherche
          _buildSearchBar(context),

          const SizedBox(height: 32),

          // Bouton de scan central
          _buildCentralScanButton(context, isTablet),

          const SizedBox(height: 16),

          // Texte d'instruction
          _buildInstructionText(context, isTablet),

          const SizedBox(height: 40),

          // Section Pour vous
          if (recs.forYou.isNotEmpty) ...[
            _buildSectionHeader(context, 'Pour vous', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            _buildForYouList(context, recs.forYou, isTablet),
          ],

          const SizedBox(height: 24),

          // Section Tendances
          if (recs.trending.isNotEmpty) ...[
            _buildSectionHeader(context, 'Tendances', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            _buildTrendingList(context, recs.trending, isTablet),
          ],

          const SizedBox(height: 24),

          // Section Recommandations personnalisées
          if (recs.personalized.isNotEmpty) ...[
            _buildSectionHeader(context, 'Recommandé pour vous', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            _buildPersonalizedList(context, recs.personalized, isTablet),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(
    BuildContext context,
    String name,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour $name',
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
          MaterialPageRoute(builder: (context) => const SearchScreen()),
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
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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
          if (widget.onNavigate != null) {
            widget.onNavigate!(1);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScanScreenContent(),
              ),
            );
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: isTablet ? 22.0 : 18.0,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'Voir tout',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryBlue,
              fontSize: isTablet ? 16.0 : 14.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForYouList(
    BuildContext context,
    List<ContentModel> items,
    bool isTablet,
  ) {
    return SizedBox(
      height: isTablet ? 240 : 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildContentCard(context, item, isTablet);
        },
      ),
    );
  }

  Widget _buildTrendingList(
    BuildContext context,
    List<ContentModel> items,
    bool isTablet,
  ) {
    return SizedBox(
      height: isTablet ? 220 : 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildTrendingCard(context, item, isTablet);
        },
      ),
    );
  }

  Widget _buildPersonalizedList(
    BuildContext context,
    List<ContentModel> items,
    bool isTablet,
  ) {
    return Column(
      children: items.take(3).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPersonalizedItem(context, item, isTablet),
        );
      }).toList(),
    );
  }

  Widget _buildContentCard(
    BuildContext context,
    ContentModel item,
    bool isTablet,
  ) {
    final width = isTablet ? 160.0 : 140.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: item.title,
              artist: item.artist,
              year: item.year,
              genre: item.genre,
              description: item.description,
              imageUrl: item.imageUrl,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: width,
              decoration: BoxDecoration(
                color: _getTypeColor(item.type).withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: Center(
                child: Icon(
                  _getTypeIcon(item.type),
                  color: _getTypeColor(item.type),
                  size: isTablet ? 50 : 40,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 15 : 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.artist,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 13 : 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(
    BuildContext context,
    ContentModel item,
    bool isTablet,
  ) {
    final width = ResponsiveHelper.trendingCardWidth(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: item.title,
              artist: item.artist,
              year: item.year,
              genre: item.genre,
              description: item.description,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusMedium),
              ),
              child: Container(
                height: isTablet ? 130.0 : 90.0,
                width: double.infinity,
                color: Colors.grey[300],
                child: Icon(
                  _getTypeIcon(item.type),
                  color: _getTypeColor(item.type),
                  size: isTablet ? 50 : 40,
                ),
              ),
            ),
            // Texte
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 15.0 : 13.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.artist,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 13.0 : 11.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedItem(
    BuildContext context,
    ContentModel item,
    bool isTablet,
  ) {
    final thumbSize = isTablet ? 70.0 : 55.0;
    final thumbIconSize = isTablet ? 36.0 : 28.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: item.title,
              artist: item.artist,
              year: item.year,
              genre: item.genre,
              description: item.description,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: _getTypeColor(item.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getTypeColor(item.type).withOpacity(0.4),
                ),
              ),
              child: Icon(
                _getTypeIcon(item.type),
                color: _getTypeColor(item.type),
                size: thumbIconSize,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18.0 : 16.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.artist,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 15.0 : 14.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(item.type).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.genre,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _getTypeColor(item.type),
                            fontSize: isTablet ? 13.0 : 11.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.year,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: isTablet ? 13.0 : 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: isTablet ? 20.0 : 16.0,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(ContentType type) {
    switch (type) {
      case ContentType.music:
        return AppColors.primaryBlue;
      case ContentType.film:
        return const Color(0xFF9B59B6);
      case ContentType.image:
        return const Color(0xFF2ECC71);
    }
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.music:
        return Icons.music_note;
      case ContentType.film:
        return Icons.movie;
      case ContentType.image:
        return Icons.image;
    }
  }
}
