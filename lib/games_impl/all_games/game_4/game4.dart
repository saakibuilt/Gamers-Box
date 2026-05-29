
import 'package:flutter/material.dart';
import 'game4_start.dart';

class Game4Page extends StatefulWidget {
  const Game4Page({super.key});

  @override
  State<Game4Page> createState() => _Game4PageState();
}

class _Game4PageState extends State<Game4Page> {
  bool _showInstructions = false;

  void _toggleInstructions() {
    setState(() => _showInstructions = !_showInstructions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tetris Game'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Add top spacing when instructions are not shown
              if (!_showInstructions) 
                SizedBox(height: MediaQuery.of(context).size.height * 0.6),
              
              SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    'Start Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Game4StartPage()),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                  icon: Icon(
                    _showInstructions ? Icons.close : Icons.info,
                    color: Colors.white70,
                  ),
                  label: Text(
                    _showInstructions ? 'Hide Instructions' : 'How to Play',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _toggleInstructions,
                ),
              ),
              
              if (_showInstructions) ...[
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF5DE0E6), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Center(
                        child: Text(
                          '🎮 HOW TO PLAY TETRIS',
                          style: TextStyle(
                            color: Color(0xFF5DE0E6),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildSection(
                        '🎯 CONTROLS',
                        [
                          'TAP anywhere on screen: Rotate piece',
                          'SWIPE LEFT/RIGHT: Move piece horizontally',
                          'SWIPE DOWN: Quick drop piece',
                          'PAUSE button: Pause/resume game',
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildSection(
                        '🏆 OBJECTIVE',
                        [
                          'Clear horizontal lines by filling them completely',
                          'Cleared lines disappear and you earn points',
                          'Prevent pieces from reaching the top',
                          'Survive as long as possible!',
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildSection(
                        '📊 SCORING',
                        [
                          'Each completed line = 5 points',
                          'Clear multiple lines at once for more points',
                          'Score increases your overall ranking',
                          'Challenge yourself to beat your high score!',
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildSection(
                        '⚡ LEVELS',
                        [
                          'Complete required lines to level up',
                          'Higher levels = faster falling speed',
                          'Level 1: 10 lines, Level 2: 12 lines, etc.',
                          'Each level increases difficulty',
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildSection(
                        '✨ FEATURES',
                        [
                          'Auto-save: Progress saved automatically',
                          'Resume: Continue from where you left off',
                          'Modern colors: Beautiful gradient pieces',
                          'Wall kicks: Rotate even in tight spaces',
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Tips
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF004AAD).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF004AAD), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 PRO TIPS',
                              style: TextStyle(
                                color: Color(0xFF5DE0E6),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Plan ahead - use the "Next" piece preview\n'
                              '• Leave space for long pieces (I-blocks)\n'
                              '• Clear lines regularly to avoid stacking too high\n'
                              '• Use wall kicks to rotate in tight corners\n'
                              '• Take breaks - use the pause feature!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40), // Bottom padding
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF5DE0E6),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  color: Color(0xFF004AAD),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}