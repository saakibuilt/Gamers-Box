import 'package:flutter/material.dart';
import 'dart:math';

class Game4Header extends StatelessWidget {
  final int currentLevel;
  final int linesCleared;
  final int linesNeededForNextLevel;
  final int totalLinesCleared;
  final int score;
  final List<Point<int>> nextPiece;
  final Color nextColor;
  final bool showLevelBanner;
  final VoidCallback onPause;

  const Game4Header({
    super.key,
    required this.currentLevel,
    required this.linesCleared,
    required this.linesNeededForNextLevel,
    required this.totalLinesCleared,
    required this.score,
    required this.nextPiece,
    required this.nextColor,
    required this.onPause,
    this.showLevelBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Header stats in one row
        Positioned(
          top: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white38),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Level
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '$currentLevel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Score',
                      style: TextStyle(
                        color: Colors.yellow.shade700,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '$score',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Lines
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lines',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '$linesCleared/$linesNeededForNextLevel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '$totalLinesCleared',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onPause,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white70),
                    ),
                    child: Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Next piece preview
        Positioned(
          top: 100,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white38),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (y) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(4, (x) {
                        bool filled = nextPiece.any((p) => p.x == x && p.y == y);
                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: filled ? nextColor : Colors.transparent,
                            border: Border.all(color: Colors.white10),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        // Level up banner
        if (showLevelBanner)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 140, 141, 142).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                'LEVEL $currentLevel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}