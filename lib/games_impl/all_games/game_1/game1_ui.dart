import 'package:flutter/material.dart';
import 'dart:math';
import 'game1_start.dart';

// Create a public interface for accessing game state
abstract class GameStateInterface {
  int get level;
  int get score;
  int get totalScore;
  int get lives;
  bool get gameOver;
  bool get powerMode;
  double get pacmanX;
  double get pacmanY;
  String get direction;
  String get nextDirection;
  int get maxLevelCompleted;
  int get personalBestScore;
  List<List<int>> get maze;
  Set<String> get dots;
  Set<String> get powerPellets;
  List<Ghost> get ghosts;
  AnimationController get pacmanAnimController;

  double get cellWidth;
  double get cellHeight;
  set cellWidth(double value);
  set cellHeight(double value);
  
  void setState(VoidCallback fn);
  Future<void> clearResumeData();
  void initGame();
}

class GameUI extends StatelessWidget {
  final GameStateInterface gameState;
  final Function(String) onSwipe;
  final VoidCallback showPauseMenu;

  const GameUI({
    super.key,
    required this.gameState,
    required this.onSwipe,
    required this.showPauseMenu,
  });

  // Constants
  static const int gridWidth = 19;
  static const int gridHeight = 21;
  static const int scoreTarget = 500;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    
    final availableHeight = screenSize.height - topPadding - 140;
    final availableWidth = screenSize.width - 20;
    
    gameState.cellWidth = availableWidth / gridWidth;
    gameState.cellHeight = availableHeight / gridHeight;
    
    if (gameState.maze.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.amber,
            strokeWidth: 3,
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: GestureDetector(
        onPanStart: (details) {},
        onPanUpdate: (details) {
          final threshold = 10.0;
          if (details.delta.dx.abs() > threshold || details.delta.dy.abs() > threshold) {
            if (details.delta.dx.abs() > details.delta.dy.abs()) {
              onSwipe(details.delta.dx > 0 ? 'right' : 'left');
            } else {
              onSwipe(details.delta.dy > 0 ? 'down' : 'up');
            }
          }
        },
        child: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            children: [
              _buildGameArea(screenSize, topPadding, context),
              _buildUIOverlay(screenSize, topPadding, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameArea(Size screenSize, double topPadding, BuildContext context) {
    return Positioned(
      top: topPadding + 140,
      left: 10,
      child: Container(
        width: gridWidth * gameState.cellWidth,
        height: gridHeight * gameState.cellHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.cyan.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF0F0F1E),
                      const Color(0xFF0A0A0A),
                    ],
                  ),
                ),
              ),
              
              // Maze walls with modern styling
              ...List.generate(gridHeight, (y) => 
                Positioned(
                  top: y * gameState.cellHeight,
                  child: Row(
                    children: List.generate(gridWidth, (x) => 
                      Container(
                        width: gameState.cellWidth,
                        height: gameState.cellHeight,
                        decoration: BoxDecoration(
                          color: gameState.maze[y][x] == 1 
                            ? Colors.cyan.withOpacity(0.8)
                            : Colors.transparent,
                          borderRadius: gameState.maze[y][x] == 1 
                            ? BorderRadius.circular(2) 
                            : null,
                          boxShadow: gameState.maze[y][x] == 1 ? [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ] : null,
                        ),
                        child: gameState.maze[y][x] == 0 
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.cyan.withOpacity(0.05),
                                  width: 0.5,
                                ),
                              ),
                            )
                          : null,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Modern tunnel indicators
              if (_isTunnelOpen(7, 'left'))
                Positioned(
                  left: -gameState.cellWidth/2,
                  top: 7 * gameState.cellHeight,
                  child: Container(
                    width: gameState.cellWidth/2,
                    height: gameState.cellHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.purple.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_isTunnelOpen(7, 'right'))
                Positioned(
                  right: -gameState.cellWidth/2,
                  top: 7 * gameState.cellHeight,
                  child: Container(
                    width: gameState.cellWidth/2,
                    height: gameState.cellHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.transparent,
                          Colors.purple.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Enhanced dots with glow effect
              ...gameState.dots.map((dot) {
                var coords = dot.split(',');
                return Positioned(
                  left: double.parse(coords[0]) * gameState.cellWidth + gameState.cellWidth/2 - 3,
                  top: double.parse(coords[1]) * gameState.cellHeight + gameState.cellHeight/2 - 3,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
              // Enhanced power pellets with animation
              ...gameState.powerPellets.map((pellet) {
                var coords = pellet.split(',');
                return Positioned(
                  left: double.parse(coords[0]) * gameState.cellWidth + gameState.cellWidth/2 - 10,
                  top: double.parse(coords[1]) * gameState.cellHeight + gameState.cellHeight/2 - 10,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 2 * pi),
                    duration: Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyan,
                                Colors.blue,
                                Colors.purple,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.8),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              
              ...gameState.ghosts.map((ghost) => Positioned(
                left: ghost.x * gameState.cellWidth + 2,
                top: ghost.y * gameState.cellHeight + 2,
                child: Container(
                  width: gameState.cellWidth - 4,
                  height: gameState.cellHeight - 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: (gameState.powerMode ? Colors.blue : ghost.color).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: ModernGhostPainter(
                      color: gameState.powerMode ? Colors.blue : ghost.color,
                      isVulnerable: gameState.powerMode,
                    ),
                  ),
                ),
              )),
              
              Positioned(
                left: gameState.pacmanX * gameState.cellWidth + 2,
                top: gameState.pacmanY * gameState.cellHeight + 2,
                child: AnimatedBuilder(
                  animation: gameState.pacmanAnimController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _getRotationAngle(),
                      child: Container(
                        width: gameState.cellWidth - 4,
                        height: gameState.cellHeight - 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: (gameState.powerMode ? Colors.yellowAccent : Colors.amber).withOpacity(0.8),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: ModernPacmanPainter(
                            animationValue: gameState.pacmanAnimController.value,
                            powerMode: gameState.powerMode,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUIOverlay(Size screenSize, double topPadding, BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: topPadding + 15,
          left: 0,
          right: 0,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.cyan.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level ${gameState.level}: ${gameState.score}/$scoreTarget', 
                      style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text('${gameState.lives}', 
                          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                
                // Progress bar with modern styling
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.cyan.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (gameState.score / scoreTarget).clamp(0.0, 1.0),
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        gameState.score >= scoreTarget ? Colors.green : Colors.cyan,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Best: ${gameState.personalBestScore}', 
                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Max Level: ${gameState.maxLevelCompleted}', 
                          style: TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('Total: ${gameState.totalScore + gameState.score}', 
                      style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Modern pause button
        Positioned(
          top: topPadding + 15,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              onPressed: showPauseMenu,
              icon: Icon(Icons.pause_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
        
        if (gameState.gameOver)
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.95),
                ],
              ),
            ),
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('GAME OVER', 
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Level ${gameState.level}', 
                      style: TextStyle(color: Colors.cyan, fontSize: 20)),
                    SizedBox(height: 10),
                    Text('Score: ${gameState.totalScore + gameState.score}', 
                      style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Best: ${gameState.personalBestScore}', 
                      style: TextStyle(color: Colors.green, fontSize: 18)),
                    SizedBox(height: 30),
                    if (gameState.totalScore + gameState.score > gameState.personalBestScore)
                      Column(
                        children: [
                          Text('🎉 NEW RECORD! 🎉', 
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () {
                        gameState.clearResumeData().then((_) {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text('Return to Menu', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _isTunnelOpen(int y, String side) {
    if (side == 'left') {
      return gameState.maze[y][0] == 0;
    } else if (side == 'right') {
      return gameState.maze[y][gridWidth - 1] == 0;
    }
    return false;
  }

  double _getRotationAngle() {
    switch (gameState.direction) {
      case 'up': return -1.5708;
      case 'down': return 1.5708;
      case 'left': return 3.14159;
      case 'right': return 0;
      default: return 0;
    }
  }

  // double _getChaseAccuracy() {
  //   double baseAccuracy = 0.4;
  //   double levelBonus = (gameState.level - 1) * 0.04;
  //   return (baseAccuracy + levelBonus).clamp(0.4, 0.8);
  // }
}

class ModernGhostPainter extends CustomPainter {
  final Color color;
  final bool isVulnerable;
  
  ModernGhostPainter({required this.color, this.isVulnerable = false});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final width = size.width;
    final height = size.height;
    
    final path = Path();
    
    // Smoother ghost body
    path.moveTo(0, height);
    path.lineTo(width * 0.15, height * 0.85);
    path.lineTo(width * 0.25, height);
    path.lineTo(width * 0.4, height * 0.85);
    path.lineTo(width * 0.5, height);
    path.lineTo(width * 0.6, height * 0.85);
    path.lineTo(width * 0.75, height);
    path.lineTo(width * 0.85, height * 0.85);
    path.lineTo(width, height);
    path.lineTo(width, height * 0.3);
    
    path.arcToPoint(
      Offset(0, height * 0.3),
      radius: Radius.circular(width / 2),
      clockwise: false,
    );
    
    path.close();
    canvas.drawPath(path, paint);
    
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final pupilPaint = Paint()
      ..color = isVulnerable ? Colors.red : Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(width * 0.3, height * 0.35), 
      width * 0.1, 
      eyePaint
    );
    canvas.drawCircle(
      Offset(width * 0.32, height * 0.35), 
      width * 0.05, 
      pupilPaint
    );
    
    canvas.drawCircle(
      Offset(width * 0.7, height * 0.35), 
      width * 0.1, 
      eyePaint
    );
    canvas.drawCircle(
      Offset(width * 0.68, height * 0.35), 
      width * 0.05, 
      pupilPaint
    );
    
    // Vulnerable state indicator
    if (isVulnerable) {
      final zigzagPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      
      final zigzagPath = Path();
      zigzagPath.moveTo(width * 0.2, height * 0.6);
      zigzagPath.lineTo(width * 0.3, height * 0.5);
      zigzagPath.lineTo(width * 0.4, height * 0.6);
      zigzagPath.lineTo(width * 0.5, height * 0.5);
      zigzagPath.lineTo(width * 0.6, height * 0.6);
      zigzagPath.lineTo(width * 0.7, height * 0.5);
      zigzagPath.lineTo(width * 0.8, height * 0.6);
      
      canvas.drawPath(zigzagPath, zigzagPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ModernPacmanPainter extends CustomPainter {
  final double animationValue;
  final bool powerMode;
  
  ModernPacmanPainter({this.animationValue = 0.0, this.powerMode = false});
  
  @override
  void paint(Canvas canvas, Size size) {
    final radius = min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: powerMode 
          ? [Colors.yellowAccent, Colors.amber, Colors.orange]
          : [Colors.amber, Colors.yellow, Colors.orange],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, bodyPaint);
    
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final mouthAngle = 0.8 + (sin(animationValue * 2 * pi) * 0.4);
    
    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      -mouthAngle / 2,
      mouthAngle,
      false,
    );
    path.close();
    
    canvas.drawPath(path, mouthPaint);
    
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx - radius * 0.15, center.dy - radius * 0.4),
      radius * 0.12,
      eyePaint,
    );
    
    // Power mode effects
    if (powerMode) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      
      canvas.drawCircle(center, radius + 3, glowPaint);
      
      // Additional glow rings
      final outerGlowPaint = Paint()
        ..color = Colors.amber.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(center, radius + 6, outerGlowPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}