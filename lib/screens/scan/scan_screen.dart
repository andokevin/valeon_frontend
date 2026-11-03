// lib/screens/scan/scan_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/layout/space_background.dart';
import 'scan_audio_screen.dart';

/// Valeon reconnaît uniquement l'audio : musique, dialogues de films, interviews.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        ),
        body: const ScanAudioScreen(),
      ),
    );
  }
}
