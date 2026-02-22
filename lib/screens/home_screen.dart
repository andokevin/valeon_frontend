// lib/screens/home_screen.dart (MODIFIÉ - Version corrigée)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/error_view.dart';
import '../providers/auth_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/connectivity_provider.dart';
import '../models/content_model.dart';
import 'result_screen.dart';
import 'search_screen.dart';
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
                _buildHeader(context, hPadding, connectivity.isOnline, auth),
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

  Widget _buildHeader(
    BuildContext context,
    double hPadding,
    bool isOnline,
    AuthProvider auth,
  ) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          // Logo
          Container(
            width: isTablet ? 52.0 : 44.0,
            height: isTablet ? 52.0 : 44.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.lightPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.diamond,
              color: Colors.white,
              size: isTablet ? 30.0 : 26.0,
            ),
          ),
          SizedBox(width: isTablet ? 16.0 : 12.0),

          // Titre
          Text(
            'Valeon',
            style: TextStyle(
              fontSize: isTablet ? 28.0 : 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
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
                size: isTablet ? 24.0 : 20.0,
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
              color: Colors.white,
              size: isTablet ? 30.0 : 26.0,
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
              color: Colors.white,
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
            auth.getUserName,
            isTablet,
          ),

          const SizedBox(height: 20),

          // Barre de recherche
          _buildSearchBar(context),

          const SizedBox(height: 32),

          // Boutons de scan rapide
          _buildQuickScanButtons(context),

          const SizedBox(height: 32),

          // Section Tendances
          if (recs.trending.isNotEmpty) ...[
            _buildSectionHeader(context, 'Tendances', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            _buildTrendingList(context, recs.trending, isTablet),
          ],

          const SizedBox(height: 32),

          // Section Pour vous
          if (recs.forYou.isNotEmpty) ...[
            _buildSectionHeader(context, 'Pour vous', () {
              // Voir tout
            }),
            const SizedBox(height: 16),
            _buildForYouList(context, recs.forYou, isTablet),
          ],

          const SizedBox(height: 32),

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
          'Bonjour $name 👋',
          style: TextStyle(
            fontSize: isTablet ? 32.0 : 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Découvrez tout ce qui vous entoure',
          style: TextStyle(
            fontSize: isTablet ? 18.0 : 16.0,
            color: Colors.white.withOpacity(0.8),
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
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.8),
              size: isTablet ? 26.0 : 22.0,
            ),
            SizedBox(width: isTablet ? 16.0 : 12.0),
            Expanded(
              child: Text(
                AppStrings.searchPlaceholder,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isTablet ? 17.0 : 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickScanButtons(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final btnSize = isTablet ? 100.0 : 80.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScanButton(
          context,
          Icons.music_note,
          'Audio',
          AppColors.primaryBlue,
          btnSize,
          () {
            if (widget.onNavigate != null) {
              widget.onNavigate!(1);
            }
          },
        ),
        _buildScanButton(
          context,
          Icons.image,
          'Image',
          const Color(0xFF9B59B6),
          btnSize,
          () {
            if (widget.onNavigate != null) {
              widget.onNavigate!(1);
            }
          },
        ),
        _buildScanButton(
          context,
          Icons.videocam,
          'Vidéo',
          const Color(0xFF2ECC71),
          btnSize,
          () {
            if (widget.onNavigate != null) {
              widget.onNavigate!(1);
            }
          },
        ),
        _buildScanButton(
          context,
          Icons.camera_alt,
          'Caméra',
          const Color(0xFFE67E22),
          btnSize,
          () {
            if (widget.onNavigate != null) {
              widget.onNavigate!(1);
            }
          },
        ),
      ],
    );
  }

  Widget _buildScanButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    double size,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.isTablet(context) ? 14.0 : 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          style: TextStyle(
            fontSize: isTablet ? 24.0 : 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'Voir tout',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: isTablet ? 16.0 : 14.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingList(
    BuildContext context,
    List<ContentModel> items,
    bool isTablet,
  ) {
    return SizedBox(
      height: isTablet ? 240 : 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildTrendingCard(context, item, isTablet);
        },
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
              imageUrl: item.imageUrl,
              contentId: item.id,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Container(
                height: isTablet ? 140.0 : 100.0,
                width: double.infinity,
                color: _getTypeColor(item.type).withOpacity(0.3),
                child: Center(
                  child: Icon(
                    _getTypeIcon(item.type),
                    color: _getTypeColor(item.type),
                    size: isTablet ? 60 : 40,
                  ),
                ),
              ),
            ),
            // Texte
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16.0 : 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.artist,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isTablet ? 14.0 : 12.0,
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

  Widget _buildForYouList(
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

  Widget _buildPersonalizedItem(
    BuildContext context,
    ContentModel item,
    bool isTablet,
  ) {
    final thumbSize = isTablet ? 70.0 : 60.0;
    final thumbIconSize = isTablet ? 36.0 : 30.0;

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
              contentId: item.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: _getTypeColor(item.type).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getTypeColor(item.type).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                _getTypeIcon(item.type),
                color: _getTypeColor(item.type),
                size: thumbIconSize,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18.0 : 16.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.artist,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isTablet ? 15.0 : 14.0,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                          border: Border.all(
                            color: _getTypeColor(item.type).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          item.genre,
                          style: TextStyle(
                            color: _getTypeColor(item.type),
                            fontSize: isTablet ? 13.0 : 12.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.year,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
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
              color: Colors.white.withOpacity(0.5),
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
