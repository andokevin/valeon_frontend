import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';

class CachedImageWidget extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const CachedImageWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _fallback();
    }
    Widget image = CachedNetworkImage(
      imageUrl: url!,
      width: width, height: height, fit: fit,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.surfaceVariant,
        highlightColor: AppTheme.surface,
        child: Container(color: AppTheme.surfaceVariant, width: width, height: height),
      ),
      errorWidget: (_, __, ___) => _fallback(),
    );
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _fallback() => placeholder ?? Container(
    width: width, height: height,
    color: AppTheme.surfaceVariant,
    child: const Icon(Icons.image_rounded, color: AppTheme.onSurface),
  );
}
