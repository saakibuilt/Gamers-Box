import 'package:flutter/material.dart';
import 'game3_start.dart';

class Game3Page extends StatelessWidget {
  const Game3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game 3')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Game3StartPage()),
                );
              },
              child: const Text('Start Game'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _showHowToPlay(context),
              child: const Text('How to Play'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('How to Play'),
        content: const Text(
          '1. Tap “Start Game” to begin.\n'
          '2. Control your character with on-screen buttons.\n'
          '3. Collect points, avoid obstacles, and reach the goal.\n'
          '4. Pause anytime with the pause icon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
