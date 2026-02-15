import 'package:flutter/material.dart';
import '../config/constants.dart';
import 'dart:math' as math;

class SpaceBackground extends StatefulWidget {
  final Widget child;
  
  const SpaceBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient de fond
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.spaceGradient,
          ),
        ),
        
        // Étoiles animées
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: StarsPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        
        // Contenu
        widget.child,
      ],
    );
  }
}

class StarsPainter extends CustomPainter {
  final double animationValue;
  
  StarsPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42); // Seed fixe pour cohérence
    
    // Dessiner 100 étoiles
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (0.3 + random.nextDouble() * 0.7) * 
                     (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi + i));
      final radius = 1.0 + random.nextDouble() * 2.0;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}