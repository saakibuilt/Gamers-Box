//

import 'dart:ui';
import 'package:flutter/material.dart';

class Game2StartUI {
  // ─────────────────────── HUD ───────────────────────
  static Widget hud({
    required GlobalKey hudKey,
    required int score,
    required double scroll,
    required String Function(double) miles,
    required String Function() getCurrentLevel,
    required double baseSpeed,
    required bool gameStart,
    required VoidCallback pause,
    required VoidCallback resume,
  }) =>
      Positioned(
        top: 32,
        left: 16,
        right: 16,
        child: ClipRRect(
          key: hudKey,
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.14),
                    Colors.white.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _stat('Score', '$score'),
                        _stat('Dist', '${miles(scroll)} mi'),
                        _stat('Level', getCurrentLevel()),
                      ],
                    ),
                  ),
                  _speedButtons(baseSpeed),
                  const SizedBox(width: 12),
                  _iconBtn(gameStart ? Icons.pause : Icons.play_arrow,
                      gameStart ? pause : resume),
                ],
              ),
            ),
          ),
        ),
      );

  static Widget _stat(String l, String v) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(v,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ],
      );

  static Widget _speedButtons(double baseSpeed) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Speed: ${baseSpeed.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      );

  static Widget _iconBtn(IconData ic, VoidCallback f) => InkWell(
        onTap: f,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(ic, color: Colors.white, size: 20),
        ),
      );

  // ─────────────────── BANNER ───────────────────
  static Widget startingBanner(double scroll) {
    final show = scroll >= 2 && scroll < 3;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Starting now',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // ← Level 2 Banner with 3-second display
  static Widget level2Banner(bool showLevel2Banner) {
    return levelBanner(showLevel2Banner, 'Level 2\nSpeed increasing in 3...', 'orange');
  }

  // ← Level 3 Banner with 3-second display
  static Widget level3Banner(bool showLevel3Banner) {
    return levelBanner(showLevel3Banner, 'Level 3\nMaximum speed incoming!', 'red');
  }

  // ← Dynamic Level Banner (for all levels)
  static Widget levelBanner(bool show, String text, String colorType) {
    Color bannerColor;
    switch (colorType) {
      case 'orange':
        bannerColor = Colors.orange;
        break;
      case 'red':
        bannerColor = Colors.red;
        break;
      case 'purple':
        bannerColor = Colors.purple;
        break;
      case 'gold':
        bannerColor = Colors.amber;
        break;
      default:
        bannerColor = Colors.blue;
    }

    // Split text for multi-line display
    final lines = text.split('\n');
    
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 500), // Smoother fade
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: bannerColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lines[0],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white)),
                if (lines.length > 1) ...[
                  const SizedBox(height: 4),
                  Text(lines.sublist(1).join('\n'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, 
                          color: Colors.white70)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────── Pause Overlay ───────────────────
  static Widget pauseOverlay({
    required int score,
    required VoidCallback resume,
    required VoidCallback quit,
  }) =>
      Container(
        color: Colors.black54,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white38),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Paused',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 26)),
                    const SizedBox(height: 8),
                    Text('Score: $score',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: resume,
                      child: const Text('Continue'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: quit,
                      child: const Text('Quit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}