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
  int _timer = 0; // ✅ AJOUTÉ : Timer

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

  // ✅ CORRIGÉ : Avec timer
  void _startScanning() {
    setState(() {
      _isScanning = true;
      _timer = 10;
    });

    // Décrémenter le timer chaque seconde
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
        // ✅ Afficher Bottom Sheet avant ResultScreen
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

  // ✅ AJOUTÉ : Bottom Sheet résultat
  void _showResultBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2B5E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Icône succès
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primaryBlue,
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Résultat trouvé !',
              style: AppTextStyles.titleSmall.copyWith(fontSize: 20),
            ),

            const SizedBox(height: 8),

            Text(
              'Blinding Lights - The Weeknd',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Bouton voir résultat
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Voir le résultat',
                  style: AppTextStyles.button,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bouton scanner encore
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusButton),
                  ),
                ),
                child: Text(
                  'Scanner à nouveau',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
              _buildHeader(),

              const SizedBox(height: 20),

              _buildInstructionText(),

              const SizedBox(height: 20),

              _buildModeSelector(),

              const Spacer(),

              _buildScanCircle(),

              const SizedBox(height: 30),

              _buildScanStatusText(),

              if (_isScanning) ...[
                const SizedBox(height: 20),
                _buildWaveform(),
              ],

              const Spacer(),

              _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
              size: 28,
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
              ),
            ),
          ),
          // ✅ CORRIGÉ : Bouton fermer fonctionnel
          IconButton(
            onPressed: () {
              setState(() {
                _isScanning = false;
                _timer = 0;
                _currentMode = ScanMode.audio;
              });
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _getModeInstruction(),
        style: AppTextStyles.bodyLarge.copyWith(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildModeChip(ScanMode.audio, Icons.mic, 'Audio'),
          const SizedBox(width: 12),
          _buildModeChip(ScanMode.image, Icons.image, 'Image'),
          const SizedBox(width: 12),
          _buildModeChip(ScanMode.video, Icons.videocam, 'Vidéo'),
        ],
      ),
    );
  }

  Widget _buildModeChip(ScanMode mode, IconData icon, String label) {
    final isSelected = _currentMode == mode;

    return GestureDetector(
      onTap: () => _changeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCircle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cercle externe pulsant
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

            // Cercle principal
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
              child: Icon(
                _getModeIcon(),
                size: 90,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ CORRIGÉ : Avec timer visible
  Widget _buildScanStatusText() {
    return Column(
      children: [
        Text(
          _isScanning ? _getScanningText() : _getModeTitle(),
          style: AppTextStyles.titleMedium.copyWith(fontSize: 24),
        ),
        // ✅ Timer visible pendant le scan
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
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
              final height = 15 +
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton principal
        GestureDetector(
          onTap: _isScanning ? _stopScanning : _startScanning,
          child: Container(
            width: 80,
            height: 80,
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
              size: 40,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Boutons d'import
        if (!_isScanning)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImportButton(
                icon: Icons.photo_library,
                label: 'Galerie Photo',
                onTap: () => _importFromGallery(),
              ),
              const SizedBox(width: 20),
              _buildImportButton(
                icon: Icons.video_library,
                label: 'Galerie Vidéo',
                onTap: () => _importFromGallery(),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSheet() {
    return Container(
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
            style: AppTextStyles.titleSmall.copyWith(fontSize: 18),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImportOption(
                icon: Icons.photo_library,
                label: 'Photos',
                color: AppColors.primaryBlue,
                onTap: () {
                  Navigator.pop(context);
                  _simulateImport('Photo');
                },
              ),
              _buildImportOption(
                icon: Icons.video_library,
                label: 'Vidéos',
                color: const Color(0xFF9B59B6),
                onTap: () {
                  Navigator.pop(context);
                  _simulateImport('Vidéo');
                },
              ),
              _buildImportOption(
                icon: Icons.camera_alt,
                label: 'Caméra',
                color: const Color(0xFF2ECC71),
                onTap: () {
                  Navigator.pop(context);
                  _simulateImport('Caméra');
                },
              ),
              _buildImportOption(
                icon: Icons.folder,
                label: 'Fichiers',
                color: const Color(0xFFE67E22),
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
    );
  }

  Widget _buildImportOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 12,
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

  // Helpers
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