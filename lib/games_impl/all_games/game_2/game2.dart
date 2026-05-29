import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game2_start.dart';

class Game2Page extends StatefulWidget {
  const Game2Page({super.key});

  @override
  State<Game2Page> createState() => _Game2PageState();
}

class _Game2PageState extends State<Game2Page> with TickerProviderStateMixin {
  bool _isInstructionsMinimized = false;
  bool _hasShownInstructionsBefore = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadInstructionsState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructionsState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('game2_instructions_shown') ?? false;
    
    setState(() {
      _hasShownInstructionsBefore = hasShown;
      _isInstructionsMinimized = hasShown;
    });
    
    if (!hasShown) {
      _animationController.forward();
    }
  }

  Future<void> _toggleInstructions() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _isInstructionsMinimized = !_isInstructionsMinimized;
    });
    
    if (!_hasShownInstructionsBefore) {
      await prefs.setBool('game2_instructions_shown', true);
      setState(() {
        _hasShownInstructionsBefore = true;
      });
    }

    if (_isInstructionsMinimized) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _startGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Game2StartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/gif/game2.gif',
            fit: BoxFit.cover,
          ),
          
          // 60% transparent black overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minimized instructions toggle button
                  if (_isInstructionsMinimized)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: _toggleInstructions,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Show Controls',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Full instructions container
                  if (!_isInstructionsMinimized)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with minimize button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🎮 Game Controls',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.blue.withOpacity(0.8),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _toggleInstructions,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Instructions with fancy styling
                            _buildFancyInstruction(
                              '🏆',
                              'Jump to collect points',
                              Colors.amber,
                            ),
                            _buildFancyInstruction(
                              '⚠️',
                              'Dodge red boxes and attacks',
                              Colors.red,
                            ),
                            _buildFancyInstruction(
                              '👆',
                              'Tap once to jump',
                              Colors.green,
                            ),
                            _buildFancyInstruction(
                              '👆👆',
                              'Double tap for higher jump',
                              Colors.blue,
                            ),
                            _buildFancyInstruction(
                              '👆➡️',
                              'Long press for long jump',
                              Colors.purple,
                            ),
                            
                            // Special slide instruction with visual demonstration
                            Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.3),
                                    Colors.red.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '👇',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Slide anywhere on screen',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            shadows: [
                                              Shadow(
                                                color: Colors.orange.withOpacity(0.8),
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.swipe_down,
                                              color: Colors.orange.shade300,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Swipe down to slide',
                                              style: TextStyle(
                                                color: Colors.orange.shade200,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 30),
                  
                  // Fancy animated start button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.purple.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _startGame(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'START GAME',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ); 
  }

  Widget _buildFancyInstruction(String emoji, String text, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: accentColor.withOpacity(0.6),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}