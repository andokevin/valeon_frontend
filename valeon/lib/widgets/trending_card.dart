import 'package:flutter/material.dart';
import '../config/constants.dart';

class TrendingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const TrendingCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveHelper.trendingCardWidth(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
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
          mainAxisSize: MainAxisSize.min,
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
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _placeholderImage(isTablet);
                        },
                      )
                    : _placeholderImage(isTablet),
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
                      title,
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
                      subtitle,
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

  Widget _placeholderImage(bool isTablet) {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.image,
        size: isTablet ? 56.0 : 40.0,
        color: Colors.grey,
      ),
    );
  }
}
