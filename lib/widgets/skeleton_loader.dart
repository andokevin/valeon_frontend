// lib/widgets/skeleton_loader.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/constants.dart';

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const SkeletonLoader({super.key, required this.child, this.isLoading = true});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSizes.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final padding = ResponsiveHelper.paddingScreen(context);

    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        // Header
        Row(
          children: [
            const SkeletonCircle(size: 40),
            const SizedBox(width: 12),
            Expanded(child: SkeletonLine(height: 24)),
          ],
        ),
        const SizedBox(height: 20),

        // Welcome message
        SkeletonLine(width: 150, height: 20),
        const SizedBox(height: 8),
        SkeletonLine(width: 200, height: 16),
        const SizedBox(height: 20),

        // Search bar
        SkeletonLine(height: 50),
        const SizedBox(height: 32),

        // Scan circle
        Center(child: SkeletonCircle(size: 220)),
        const SizedBox(height: 16),

        // Instruction
        Center(child: SkeletonLine(width: 250, height: 18)),
        const SizedBox(height: 40),

        // Trending section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonLine(width: 100, height: 20),
            SkeletonLine(width: 60, height: 16),
          ],
        ),
        const SizedBox(height: 16),

        // Trending cards
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) => const SkeletonCard(width: 110, height: 150),
          ),
        ),
      ],
    );
  }
}
