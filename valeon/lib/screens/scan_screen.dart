import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import 'result_screen.dart';

class ScanScreenContent extends StatefulWidget {
  const ScanScreenContent({Key? key}) : super(key: key);

  @override
  State<ScanScreenContent> createState() => _ScanScreenContentState();
}

class _ScanScreenContentState extends State<ScanScreenContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = false;
  ScanMode _currentMode = ScanMode.audio;
  int _timer = 0;

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
      _timer = 10;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isScanning) return false;
      setState(() {
        _timer--;
      });
      return _timer > 0;
    }).then((_) {
      if (mounted && _isScanning) {
        setState(() {
          _isScanning = false;
          _timer = 0;
        });
        _showResultBottomSheet();
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
      _timer = 0;
    });
  }

  void _changeMode(ScanMode mode) {
    setState(() {
      _currentMode = mode;
      _isScanning = false;
      _timer = 0;
    });
  }

  void _importFromGallery() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImportSheet(),
    );
  }

  void _showResultBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        final isTablet = ResponsiveHelper.isTablet(context);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 560.0 : double.infinity,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF2A2B5E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: isTablet ? 90.0 : 70.0,
                    height: isTablet ? 90.0 : 70.0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.primaryBlue,
                      size: isTablet ? 50.0 : 40.0,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Résultat trouvé !',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: isTablet ? 24.0 : 20.0,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Blinding Lights - The Weeknd',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 16.0 : 14.0,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResultScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 20.0 : 16.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Voir le résultat',
                        style: AppTextStyles.button.copyWith(
                          fontSize: isTablet ? 18.0 : 16.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isScanning = false;
                          _timer = 0;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 20.0 : 16.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                        ),
                      ),
                      child: Text(
                        'Scanner à nouveau',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: isTablet ? 18.0 : 16.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Stack(
      children: [
        const SpaceBackground(child: SizedBox.expand()),

        Container(color: Colors.black.withOpacity(0.5)),

        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 700.0 : double.infinity,
              ),
              child: Column(
                children: [
                  _buildHeader(context, isTablet),

                  SizedBox(height: isTablet ? 28.0 : 20.0),

                  _buildInstructionText(isTablet),

                  SizedBox(height: isTablet ? 28.0 : 20.0),

                  _buildModeSelector(isTablet),

                  const Spacer(),

                  _buildScanCircle(isTablet),

                  SizedBox(height: isTablet ? 40.0 : 30.0),

                  _buildScanStatusText(isTablet),

                  if (_isScanning) ...[
                    SizedBox(height: isTablet ? 28.0 : 20.0),
                    _buildWaveform(isTablet),
                  ],

                  const Spacer(),

                  _buildActionButtons(isTablet),

                  SizedBox(height: isTablet ? 32.0 : 20.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMode(ScanMode.camera),
            icon: Icon(
              Icons.videocam,
              color: _currentMode == ScanMode.camera
                  ? AppColors.primaryBlue
                  : Colors.white,
              size: isTablet ? 34.0 : 28.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getModeTitle(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 17.0 : 14.0,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isScanning = false;
                _timer = 0;
                _currentMode = ScanMode.audio;
              });
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: isTablet ? 34.0 : 28.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _getModeInstruction(),
        style: AppTextStyles.bodyLarge.copyWith(
          fontSize: isTablet ? 18.0 : 16.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildModeSelector(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModeChip(ScanMode.audio, Icons.mic, 'Audio', isTablet),
          const SizedBox(width: 12),
          _buildModeChip(ScanMode.image, Icons.image, 'Image', isTablet),
          const SizedBox(width: 12),
          _buildModeChip(ScanMode.video, Icons.videocam, 'Vidéo', isTablet),
        ],
      ),
    );
  }

  Widget _buildModeChip(ScanMode mode, IconData icon, String label, bool isTablet) {
    final isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () => _changeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 22.0 : 16.0,
          vertical: isTablet ? 14.0 : 10.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: isTablet ? 22.0 : 18.0),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: isTablet ? 16.0 : 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCircle(bool isTablet) {
    final baseSize = isTablet ? 300.0 : 220.0;
    final pulseExtra = isTablet ? 40.0 : 30.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: baseSize + (pulseExtra * _animationController.value),
              height: baseSize + (pulseExtra * _animationController.value),
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
              width: baseSize,
              height: baseSize,
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
              child: Icon(
                _getModeIcon(),
                size: isTablet ? 120.0 : 90.0,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanStatusText(bool isTablet) {
    return Column(
      children: [
        Text(
          _isScanning ? _getScanningText() : _getModeTitle(),
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: isTablet ? 30.0 : 24.0,
          ),
        ),
        if (_isScanning)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.5),
                ),
              ),
              child: Text(
                '$_timer s',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: isTablet ? 22.0 : 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWaveform(bool isTablet) {
    return SizedBox(
      height: isTablet ? 110.0 : 80.0,
      width: isTablet ? 300.0 : 220.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(20, (index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final height = 15 +
                  55 *
                      ((index % 2 == 0
                          ? _animationController.value
                          : 1 - _animationController.value));
              return Container(
                width: isTablet ? 6.0 : 4.0,
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

  Widget _buildActionButtons(bool isTablet) {
    final mainBtnSize = isTablet ? 100.0 : 80.0;
    final mainIconSize = isTablet ? 52.0 : 40.0;
    final importBtnSize = isTablet ? 72.0 : 56.0;
    final importIconSize = isTablet ? 36.0 : 28.0;

    return Column(
      children: [
        GestureDetector(
          onTap: _isScanning ? _stopScanning : _startScanning,
          child: Container(
            width: mainBtnSize,
            height: mainBtnSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isScanning ? Colors.red : AppColors.primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: (_isScanning ? Colors.red : AppColors.primaryBlue)
                      .withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              _isScanning ? Icons.stop : _getMainButtonIcon(),
              color: Colors.white,
              size: mainIconSize,
            ),
          ),
        ),

        SizedBox(height: isTablet ? 28.0 : 20.0),

        if (!_isScanning)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImportButton(
                icon: Icons.photo_library,
                label: 'Galerie Photo',
                onTap: () => _importFromGallery(),
                btnSize: importBtnSize,
                iconSize: importIconSize,
                isTablet: isTablet,
              ),
              SizedBox(width: isTablet ? 32.0 : 20.0),
              _buildImportButton(
                icon: Icons.video_library,
                label: 'Galerie Vidéo',
                onTap: () => _importFromGallery(),
                btnSize: importBtnSize,
                iconSize: importIconSize,
                isTablet: isTablet,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildImportButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double btnSize,
    required double iconSize,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: isTablet ? 13.0 : 11.0,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSheet() {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 560.0 : double.infinity,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2B5E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Importer depuis',
                style: AppTextStyles.titleSmall.copyWith(
                  fontSize: isTablet ? 22.0 : 18.0,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImportOption(
                    icon: Icons.photo_library,
                    label: 'Photos',
                    color: AppColors.primaryBlue,
                    isTablet: isTablet,
                    onTap: () {
                      Navigator.pop(context);
                      _simulateImport('Photo');
                    },
                  ),
                  _buildImportOption(
                    icon: Icons.video_library,
                    label: 'Vidéos',
                    color: const Color(0xFF9B59B6),
                    isTablet: isTablet,
                    onTap: () {
                      Navigator.pop(context);
                      _simulateImport('Vidéo');
                    },
                  ),
                  _buildImportOption(
                    icon: Icons.camera_alt,
                    label: 'Caméra',
                    color: const Color(0xFF2ECC71),
                    isTablet: isTablet,
                    onTap: () {
                      Navigator.pop(context);
                      _simulateImport('Caméra');
                    },
                  ),
                  _buildImportOption(
                    icon: Icons.folder,
                    label: 'Fichiers',
                    color: const Color(0xFFE67E22),
                    isTablet: isTablet,
                    onTap: () {
                      Navigator.pop(context);
                      _simulateImport('Fichier');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    final optionSize = isTablet ? 80.0 : 64.0;
    final optionIconSize = isTablet ? 40.0 : 32.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: optionSize,
            height: optionSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: optionIconSize),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 14.0 : 12.0,
            ),
          ),
        ],
      ),
    );
  }

  void _simulateImport(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type importée - Analyse en cours...'),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showResultBottomSheet();
      }
    });
  }

  String _getModeTitle() {
    switch (_currentMode) {
      case ScanMode.audio:
        return 'Scan Audio';
      case ScanMode.image:
        return 'Scan Image';
      case ScanMode.video:
        return 'Scan Vidéo';
      case ScanMode.camera:
        return 'Caméra';
    }
  }

  String _getModeInstruction() {
    switch (_currentMode) {
      case ScanMode.audio:
        return AppStrings.scanInstructionAudio;
      case ScanMode.image:
        return 'Importez une image ou prenez une photo pour l\'identifier...';
      case ScanMode.video:
        return 'Importez une vidéo ou scannez une scène pour l\'identifier...';
      case ScanMode.camera:
        return 'Pointez votre caméra vers ce que vous voulez identifier...';
    }
  }

  String _getScanningText() {
    switch (_currentMode) {
      case ScanMode.audio:
        return AppStrings.listening;
      case ScanMode.image:
        return 'Analyse image...';
      case ScanMode.video:
        return 'Analyse vidéo...';
      case ScanMode.camera:
        return 'Analyse en cours...';
    }
  }

  IconData _getModeIcon() {
    switch (_currentMode) {
      case ScanMode.audio:
        return Icons.music_note;
      case ScanMode.image:
        return Icons.image_search;
      case ScanMode.video:
        return Icons.video_library;
      case ScanMode.camera:
        return Icons.camera_alt;
    }
  }

  IconData _getMainButtonIcon() {
    switch (_currentMode) {
      case ScanMode.audio:
        return Icons.mic;
      case ScanMode.image:
        return Icons.image_search;
      case ScanMode.video:
        return Icons.video_library;
      case ScanMode.camera:
        return Icons.camera_alt;
    }
  }
}

enum ScanMode {
  audio,
  image,
  video,
  camera,
}