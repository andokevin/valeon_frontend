// lib/screens/scan/scan_screen.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/space_background.dart';
import 'scan_audio_screen.dart';
import 'scan_image_screen.dart';
import 'scan_video_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Scanner',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryBlue,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Audio'),
              Tab(text: 'Image'),
              Tab(text: 'Vidéo'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ScanAudioScreen(),
            ScanImageScreen(),
            ScanVideoScreen(),
          ],
        ),
      ),
    );
  }
}
