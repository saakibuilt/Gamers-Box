import 'package:flutter/material.dart';

class Game4Popup extends StatelessWidget {
  final VoidCallback? onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final bool isGameOver;

  const Game4Popup({
    super.key,
    this.onResume,
    required this.onRestart,
    required this.onExit,
    this.isGameOver = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                isGameOver ? 'GAME OVER' : 'GAME PAUSED',
                style: TextStyle(
                  color: isGameOver ? Colors.red : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 30),
              
              // Resume button (only for pause, not game over)
              if (!isGameOver && onResume != null) ...[
                _buildButton(
                  text: 'RESUME',
                  icon: Icons.play_arrow,
                  color: Colors.green,
                  onPressed: onResume!,
                ),
                SizedBox(height: 16),
              ],
              
              _buildButton(
                text: 'RESTART',
                icon: Icons.refresh,
                color: Colors.orange,
                onPressed: onRestart,
              ),
              SizedBox(height: 16),
              
              _buildButton(
                text: isGameOver ? 'GO TO HOME' : 'EXIT',
                icon: isGameOver ? Icons.home : Icons.exit_to_app,
                color: Colors.red,
                onPressed: onExit,
              ),
              
              SizedBox(height: 20),
              
              // Instructions (only show for pause)
              if (!isGameOver)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CONTROLS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '🎯 TAP: Rotate piece\n'
                        '⬅️➡️ SWIPE: Move left/right\n'
                        '⬇️ SWIPE DOWN: Quick drop',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}