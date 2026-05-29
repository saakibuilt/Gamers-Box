import 'package:flutter/material.dart';

class Game3ResumePopup extends StatelessWidget {
  final VoidCallback onResumeGame;
  final VoidCallback onNewGame;
  final int savedLevel;
  final int savedScore;
  final int savedFoodEaten;

  const Game3ResumePopup({
    super.key,
    required this.onResumeGame,
    required this.onNewGame,
    required this.savedLevel,
    required this.savedScore,
    required this.savedFoodEaten,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.green, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/games/snake.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.green.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.games,
                        color: Colors.green,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Game Found!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'You have a saved game in progress.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Saved game stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Saved Game Stats',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Level', savedLevel.toString(), Icons.layers),
                      _buildStatItem('Score', savedScore.toString(), Icons.star),
                      _buildStatItem('Food', savedFoodEaten.toString(), Icons.apple),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNewGame();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'New Game',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onResumeGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Resume Game',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.greenAccent,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Show the resume popup dialog
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onResumeGame,
    required VoidCallback onNewGame,
    required int savedLevel,
    required int savedScore,
    required int savedFoodEaten,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Force user to choose
      builder: (context) => Game3ResumePopup(
        onResumeGame: onResumeGame,
        onNewGame: onNewGame,
        savedLevel: savedLevel,
        savedScore: savedScore,
        savedFoodEaten: savedFoodEaten,
      ),
    );
  }
}

class Game3PausePopup extends StatelessWidget {
  final VoidCallback onResumeGame;
  final VoidCallback onRestartGame;
  final VoidCallback onGoHome;
  final int currentLevel;
  final int currentScore;
  final int currentFoodEaten;

  const Game3PausePopup({
    super.key,
    required this.onResumeGame,
    required this.onRestartGame,
    required this.onGoHome,
    required this.currentLevel,
    required this.currentScore,
    required this.currentFoodEaten,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.orange, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pause icon with snake
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/games/snake.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.orange.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.games,
                              color: Colors.orange,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Pause symbol overlay
                  Center(
                    child: Icon(
                      Icons.pause,
                      color: Colors.orange.withValues(alpha: 0.8),
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Game Paused',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Take a break! Your progress is saved.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Current game stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Current Stats',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Level', currentLevel.toString(), Icons.layers, Colors.orange),
                      _buildStatItem('Score', currentScore.toString(), Icons.star, Colors.orange),
                      _buildStatItem('Food', currentFoodEaten.toString(), Icons.apple, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onResumeGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Resume Game',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Secondary buttons row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRestartGame();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Restart',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onGoHome();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Home',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Show the pause popup dialog
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onResumeGame,
    required VoidCallback onRestartGame,
    required VoidCallback onGoHome,
    required int currentLevel,
    required int currentScore,
    required int currentFoodEaten,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Force user to choose
      builder: (context) => Game3PausePopup(
        onResumeGame: onResumeGame,
        onRestartGame: onRestartGame,
        onGoHome: onGoHome,
        currentLevel: currentLevel,
        currentScore: currentScore,
        currentFoodEaten: currentFoodEaten,
      ),
    );
  }
}

class Game3GameOverPopup extends StatelessWidget {
  final VoidCallback onGoHome;
  final VoidCallback onRestart;
  final int finalLevel;
  final int finalScore;
  final int finalFoodEaten;

  const Game3GameOverPopup({
    super.key,
    required this.onGoHome,
    required this.onRestart,
    required this.finalLevel,
    required this.finalScore,
    required this.finalFoodEaten,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/games/snake.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.red.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.games,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Game Over!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Your snake crashed! Better luck next time.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Final game stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Final Stats',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Level', finalLevel.toString(), Icons.layers, Colors.redAccent),
                      _buildStatItem('Score', finalScore.toString(), Icons.star, Colors.redAccent),
                      _buildStatItem('Food', finalFoodEaten.toString(), Icons.apple, Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onGoHome();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Go to Home',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRestart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Restart',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Show the game over popup dialog
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onGoHome,
    required VoidCallback onRestart,
    required int finalLevel,
    required int finalScore,
    required int finalFoodEaten,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Force user to choose
      builder: (context) => Game3GameOverPopup(
        onGoHome: onGoHome,
        onRestart: onRestart,
        finalLevel: finalLevel,
        finalScore: finalScore,
        finalFoodEaten: finalFoodEaten,
      ),
    );
  }
}