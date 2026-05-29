import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game1_start.dart';

class Game1Page extends StatefulWidget {
  const Game1Page({super.key});

  @override
  State<Game1Page> createState() => _Game1PageState();
}

class _Game1PageState extends State<Game1Page> {
  int maxLevelCompleted = 0;
  int personalBestScore = 0;
  bool hasResumeData = false;
  int currentLevel = 1;
  int currentScore = 0;
  int currentTotalScore = 0;
  int currentLives = 3;

  @override
  void initState() {
    super.initState();
    _loadGameStats();
  }

  Future<void> _loadGameStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      maxLevelCompleted = prefs.getInt('max_level_completed') ?? 0;
      personalBestScore = prefs.getInt('personal_best_score') ?? 0;
      
      // Check for resume data
      final savedLevel = prefs.getInt('current_level');
      final savedScore = prefs.getInt('current_score');
      final savedTotalScore = prefs.getInt('current_total_score');
      final savedLives = prefs.getInt('current_lives');
      
      if (savedLevel != null && savedScore != null && savedTotalScore != null && savedLives != null) {
        hasResumeData = true;
        currentLevel = savedLevel;
        currentScore = savedScore;
        currentTotalScore = savedTotalScore;
        currentLives = savedLives;
      }
    });
  }

  void _startGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Game1StartPage()),
    ).then((_) {
      // Refresh stats when returning from game
      _loadGameStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pac-Man Adventure'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/gif/game1.gif',
            fit: BoxFit.cover,
          ),
          
          // Dark overlay for better text visibility
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          
          Column(
            children: [
              // Stats card at the top
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      '🏆 Your Achievements 🏆',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Best Score',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Text(
                              '$personalBestScore',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 60,
                          width: 1,
                          color: Colors.yellow.withOpacity(0.5),
                        ),
                        Column(
                          children: [
                            Icon(Icons.stairs, color: Colors.purple, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Max Level',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Text(
                              '$maxLevelCompleted',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Resume data card (if available)
              if (hasResumeData)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.play_circle, color: Colors.green, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Continue Previous Game',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildResumeDataItem('Level', '$currentLevel', Colors.cyan),
                          _buildResumeDataItem('Score', '$currentScore', Colors.yellow),
                          _buildResumeDataItem('Total', '$currentTotalScore', Colors.orange),
                          _buildResumeDataItem('Lives', '$currentLives', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              
              Spacer(),
              
              // Start game button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _startGame(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                      textStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, size: 32),
                        SizedBox(width: 8),
                        Text(hasResumeData ? 'Continue Game' : 'Start Game'),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎮 How to Play',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Swipe to move Pac-Man\n• Collect dots and power pellets\n• Avoid ghosts (unless you have power!)\n• Score 500 points to advance levels\n• Game auto-saves your progress',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumeDataItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}