import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import 'result_screen.dart';

class ScanScreenContent extends StatefulWidget {
  const ScanScreenContent({super.key});

  @override
  State<ScanScreenContent> createState() => _ScanScreenContentState();
}

class _ScanScreenContentState extends State<ScanScreenContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SpaceBackground(child: SizedBox.expand()),

        Container(color: Colors.black.withOpacity(0.5)),

        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  AppStrings.scanInstructionAudio,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              _buildScanCircle(),

              const SizedBox(height: 40),

              Text(
                _isScanning ? AppStrings.listening : 'Scan',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 24),
              ),

              const SizedBox(height: 20),

              if (_isScanning) _buildWaveform(),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: GestureDetector(
                  onTap: _startScanning,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isScanning ? Colors.red : AppColors.primaryBlue,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isScanning ? Colors.red : AppColors.primaryBlue)
                                  .withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isScanning ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanCircle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220 + (30 * _animationController.value),
              height: 220 + (30 * _animationController.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(
                    1.0 - _animationController.value,
                  ),
                  width: 4,
                ),
              ),
            ),

            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue,
                  width: AppSizes.scanCircleBorder,
                ),
                color: AppColors.primaryBlue.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note,
                size: 90,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 80,
      width: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(20, (index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final height =
                  15 +
                  55 *
                      ((index % 2 == 0
                          ? _animationController.value
                          : 1 - _animationController.value));
              return Container(
                width: 4,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
