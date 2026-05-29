import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game3_popup.dart';
import '../../total_user_points.dart';
import '../../utils/highest_score_firebase.dart';

class Game3StartPage extends StatefulWidget {
  const Game3StartPage({super.key});

  @override
  State<Game3StartPage> createState() => _Game3StartPageState();
}

class _Game3StartPageState extends State<Game3StartPage> {
  static const int rows = 35;
  static const int cols = 20;
  static const Duration baseTickRate = Duration(milliseconds: 120);

  static const up = Point(0, -1);
  static const down = Point(0, 1);
  static const left = Point(-1, 0);
  static const right = Point(1, 0);
  static const directions = [up, right, down, left];

  final Random rng = Random();
  List<Point<int>> snake = [const Point(10, 17)];
  Point<int> dir = up;
  Point<int> food = const Point(5, 8);
  Timer? timer;
  bool running = true;
  bool paused = false;
  int level = 1;
  int foodEaten = 0;
  Point<int>? collisionPoint; // Track where collision happened
  String totalPointsDisplay = '0'; // Display total all-time points
  int get scoresnake => foodEaten * 5;

  @override
  void initState() {
    super.initState();
    _loadTotalPoints(); // Load total points on start
    _checkForSavedGame();
  }

  Future<void> _loadTotalPoints() async {
    final formattedTotal = await TotalUserPointsHelper.getFormattedTotalPoints();
    if (mounted) {
      setState(() {
        totalPointsDisplay = formattedTotal;
      });
    }
  }

  Future<void> _checkForSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGame = prefs.getString('snake_game_state');
    
    if (savedGame != null && mounted) {
      // Parse saved game to get stats for popup
      final gameState = jsonDecode(savedGame);
      final savedLevel = gameState['level'] as int;
      final savedFoodEaten = gameState['foodEaten'] as int;
      final savedScore = savedFoodEaten * 5; // Calculate score
      
      // Show popup to ask user if they want to resume
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Game3ResumePopup.show(
          context,
          onResumeGame: () => _loadGame(),
          onNewGame: () => _startNewGame(),
          savedLevel: savedLevel,
          savedScore: savedScore,
          savedFoodEaten: savedFoodEaten,
        );
      });
    } else {
      _startNewGame();
    }
  }

  void _startNewGame() {
    setState(() {
      snake = [const Point(10, 17)];
      dir = up;
      running = true;
      paused = false;
      level = 1;
      foodEaten = 0;
      collisionPoint = null; // Reset collision point
    });
    _spawnFood();
    _startTimer();
  }

  void _pauseGame() {
    if (!running) return; // Don't pause if game is over
    
    setState(() {
      paused = true;
    });
    timer?.cancel();
    
    // Show pause popup
    Game3PausePopup.show(
      context,
      onResumeGame: () => _resumeGame(),
      onRestartGame: () => _reset(),
      onGoHome: () => Navigator.of(context).pop(),
      currentLevel: level,
      currentScore: scoresnake,
      currentFoodEaten: foodEaten,
    );
  }

  void _resumeGame() {
    if (!running) return;
    
    setState(() {
      paused = false;
    });
    _startTimer();
  }

  Future<void> _saveGame() async {
    if (!running) return; // Don't save if game is over
    
    final prefs = await SharedPreferences.getInstance();
    final gameState = {
      'snake': snake.map((p) => {'x': p.x, 'y': p.y}).toList(),
      'dir': {'x': dir.x, 'y': dir.y},
      'food': {'x': food.x, 'y': food.y},
      'level': level,
      'foodEaten': foodEaten,
      'running': running,
    };
    
    await prefs.setString('snake_game_state', jsonEncode(gameState));
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGame = prefs.getString('snake_game_state');
    
    if (savedGame != null) {
      final gameState = jsonDecode(savedGame);
      
      setState(() {
        snake = (gameState['snake'] as List)
            .map((p) => Point<int>(p['x'], p['y']))
            .toList();
        dir = Point<int>(gameState['dir']['x'], gameState['dir']['y']);
        food = Point<int>(gameState['food']['x'], gameState['food']['y']);
        level = gameState['level'];
        foodEaten = gameState['foodEaten'];
        running = gameState['running'];
        paused = false;
        collisionPoint = null; // Reset collision point when loading
      });
      
      _startTimer();
    } else {
      _startNewGame();
    }
  }

  Future<void> _clearSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('snake_game_state');
  }

  void _startTimer() {
    timer?.cancel();
    if (paused || !running) return;
    
    final speedMultiplier = 1 + (level - 1) * 0.3;
    final adjustedTickRate = Duration(
      milliseconds: (baseTickRate.inMilliseconds / speedMultiplier).round()
    );
    timer = Timer.periodic(adjustedTickRate, (_) => _gameLoop());
  }

  void _gameLoop() {
    if (!running || paused) return;
    final next = snake.first + dir;

    // Check if hit wall and turn randomly
    if (!_inBounds(next)) {
      dir = _randomTurn();
    }

    final newHead = snake.first + dir;

    // Check if snake hits itself
    if (snake.contains(newHead)) {
      setState(() {
        running = false;
        collisionPoint = newHead; // Mark collision point
      });
      _clearSavedGame(); // Clear saved game when game ends
      _showGameOverPopup(); // Show game over popup
      return;
    }

    setState(() {
      snake.insert(0, newHead);
      if (newHead == food) {
        foodEaten++;
        _spawnFood();
        
        // Check for level completion
        if (foodEaten > 665 && foodEaten % 665 == 1) {
          level++;
          _startTimer(); // Restart timer with new speed
        }
      } else {
        snake.removeLast();
      }
    });

    // Save game state after each move
    _saveGame();
  }

  void _showGameOverPopup() {
    // Add points to total user points system
    _addPointsToTotal();
    
    // Show popup after a brief delay to let the final game state render
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Game3GameOverPopup.show(
          context,
          onGoHome: () => Navigator.of(context).pop(), // Go back to previous screen
          onRestart: () => _reset(), // Restart the game
          finalLevel: level,
          finalScore: scoresnake,
          finalFoodEaten: foodEaten,
        );
      }
    });
  }

  Future<void> _addPointsToTotal() async {
    // Only add points if the player scored something
    if (scoresnake > 0) {
      await TotalUserPointsHelper.addSnakeGamePoints(
        scoresnake,
        level,
        foodEaten,
      );

      try {
        HighScoreResult result = await HighScoreHelper.updateGameHighScore(scoresnake, 'Snake Game');
        
        if (result.isGlobalRecord) {
          print('🎉 NEW GLOBAL HIGH SCORE FOR SNAKE! Score: ${result.currentScore}');
          // You can show a special popup or notification for global record
        } else {
          print('Score ${result.currentScore} - Current global high: ${result.globalHighScore}');
        }
      } catch (e) {
        print('Failed to update Firebase high score: $e');
      }

      // Update the display
      await _loadTotalPoints();
    }
  }

  bool _inBounds(Point<int> p) =>
      p.x >= 0 && p.x < cols && p.y >= 0 && p.y < rows;

  // New method for random turning when hitting wall
  Point<int> _randomTurn() {
    final head = snake.first;
    final validDirections = <Point<int>>[];
    
    // Find all valid directions (not hitting wall, not reversing, not hitting snake body)
    for (final d in directions) {
      final next = head + d;
      final reverse = Point(-dir.x, -dir.y);
      if (_inBounds(next) && !snake.contains(next) && d != reverse) {
        validDirections.add(d);
      }
    }
    
    if (validDirections.isNotEmpty) {
      // Randomly choose from valid directions
      return validDirections[rng.nextInt(validDirections.length)];
    }
    
    // If no valid directions, keep current direction (will cause collision)
    return dir;
  }

  void _spawnFood() {
    do {
      food = Point(rng.nextInt(cols), rng.nextInt(rows));
    } while (snake.contains(food));
  }

  void _changeDir(Point<int> newDir) {
    if (paused || !running) return; // Don't allow direction change when paused
    final reverse = Point(-dir.x, -dir.y);
    if (newDir != reverse) setState(() => dir = newDir);
  }

  void _reset() {
    _clearSavedGame(); // Clear any saved game
    _startNewGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    // Save game when leaving the screen
    if (running && !paused) {
      _saveGame();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final availableHeight = screenSize.height - kToolbarHeight - MediaQuery.of(context).padding.top - 80; // Reserve more space for scores
    final availableWidth = screenSize.width - 20; // Small side margins
    
    // Calculate tile size based on available space
    final tileHeightSize = availableHeight / rows;
    final tileWidthSize = availableWidth / cols;
    final tileSize = math.min(tileHeightSize, tileWidthSize);
    
    final boardWidth = tileSize * cols;
    final boardHeight = tileSize * rows;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake — Nokia Classic'),
        actions: [
          IconButton(
            onPressed: running && !paused ? _pauseGame : null,
            icon: const Icon(Icons.pause),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (d) =>
            _changeDir(d.delta.dy > 0 ? down : up),
        onHorizontalDragUpdate: (d) =>
            _changeDir(d.delta.dx > 0 ? right : left),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // All-time total points
                  Text(
                    'All-Time Points: $totalPointsDisplay',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Current game stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Level: $level',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        'Food: $foodEaten',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                     Text(
                        'Score: $scoresnake',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: boardWidth,
                        height: boardHeight,
                        child: CustomPaint(
                          painter: _SnakePainter(snake, food, tileSize, dir, collisionPoint),
                        ),
                      ),
                      if (paused)
                        Container(
                          width: boardWidth,
                          height: boardHeight,
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Text(
                              'PAUSED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: tileSize * 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final double tileSize;
  final Point<int> dir;
  final Point<int>? collisionPoint; // Add collision point parameter

  _SnakePainter(this.snake, this.food, this.tileSize, this.dir, this.collisionPoint);

  @override
  void paint(Canvas c, Size size) {
    final gridPaint = Paint()..color = Colors.grey.withOpacity(0.15)..strokeWidth = 0.5;

    // Draw subtle grid
    for (int i = 0; i <= 20; i++) {
      c.drawLine(Offset(i * tileSize, 0), Offset(i * tileSize, size.height), gridPaint);
    }
    for (int i = 0; i <= 35; i++) {
      c.drawLine(Offset(0, i * tileSize), Offset(size.width, i * tileSize), gridPaint);
    }

    // Enhanced snake body with realistic scales and gradients
    for (int i = 1; i < snake.length; i++) {
      final p = snake[i];
      final rect = Rect.fromLTWH(p.x * tileSize, p.y * tileSize, tileSize, tileSize).deflate(tileSize * 0.08);
      final center = rect.center;
      
      // Gradient from dark green to lighter green
      final intensity = (snake.length - i) / snake.length;
      final bodyGradient = RadialGradient(
        colors: [
          Color.lerp(const Color(0xFF2E7D32), const Color(0xFF4CAF50), intensity)!,
          Color.lerp(const Color(0xFF1B5E20), const Color(0xFF2E7D32), intensity)!,
        ],
        stops: const [0.3, 1.0],
      );
      
      final bodyPaint = Paint()..shader = bodyGradient.createShader(rect);
      c.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(tileSize * 0.25)), bodyPaint);
      
      final scalePaint = Paint()..color = Colors.black.withOpacity(0.15)..strokeWidth = 1;
      final scaleRect = rect.deflate(tileSize * 0.1);
      c.drawRRect(RRect.fromRectAndRadius(scaleRect, Radius.circular(tileSize * 0.15)), scalePaint);
      
      final bellyPaint = Paint()..color = const Color(0xFF81C784).withOpacity(0.6);
      final bellyRect = Rect.fromCenter(center: center, width: rect.width * 0.4, height: rect.height * 0.8);
      c.drawRRect(RRect.fromRectAndRadius(bellyRect, Radius.circular(tileSize * 0.1)), bellyPaint);
    }

    // Ultra-realistic snake head
    final head = snake.first;
    final headRect = Rect.fromLTWH(head.x * tileSize, head.y * tileSize, tileSize, tileSize).deflate(tileSize * 0.05);
    
    // Head gradient (brighter than body)
    final headGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [const Color(0xFF66BB6A), const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
      stops: const [0.0, 0.6, 1.0],
    );
    final headPaint = Paint()..shader = headGradient.createShader(headRect);
    c.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(tileSize * 0.2)), headPaint);
    
    // Head outline for definition
    final outlinePaint = Paint()..color = const Color(0xFF1B5E20)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    c.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(tileSize * 0.2)), outlinePaint);

    // Hyper-realistic snake features
    final eyeSize = tileSize * 0.08;
    final pupilSize = eyeSize * 0.65;
    final eyeWhite = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    final irisGradient = const RadialGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8F00)]);
    final nostrilPaint = Paint()..color = Colors.black87;
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.8);
    
    // Dynamic eye positioning based on direction
    late Offset leftEye, rightEye, nostril1, nostril2;
    
    if (dir == Point(0, -1)) { // Up
      leftEye = Offset(headRect.center.dx - tileSize * 0.18, headRect.top + tileSize * 0.3);
      rightEye = Offset(headRect.center.dx + tileSize * 0.18, headRect.top + tileSize * 0.3);
      nostril1 = Offset(headRect.center.dx - tileSize * 0.06, headRect.top + tileSize * 0.15);
      nostril2 = Offset(headRect.center.dx + tileSize * 0.06, headRect.top + tileSize * 0.15);
    } else if (dir == Point(0, 1)) { // Down
      leftEye = Offset(headRect.center.dx - tileSize * 0.18, headRect.bottom - tileSize * 0.3);
      rightEye = Offset(headRect.center.dx + tileSize * 0.18, headRect.bottom - tileSize * 0.3);
      nostril1 = Offset(headRect.center.dx - tileSize * 0.06, headRect.bottom - tileSize * 0.15);
      nostril2 = Offset(headRect.center.dx + tileSize * 0.06, headRect.bottom - tileSize * 0.15);
    } else if (dir == Point(1, 0)) { // Right
      leftEye = Offset(headRect.right - tileSize * 0.3, headRect.center.dy - tileSize * 0.18);
      rightEye = Offset(headRect.right - tileSize * 0.3, headRect.center.dy + tileSize * 0.18);
      nostril1 = Offset(headRect.right - tileSize * 0.15, headRect.center.dy - tileSize * 0.06);
      nostril2 = Offset(headRect.right - tileSize * 0.15, headRect.center.dy + tileSize * 0.06);
    } else { // Left
      leftEye = Offset(headRect.left + tileSize * 0.3, headRect.center.dy - tileSize * 0.18);
      rightEye = Offset(headRect.left + tileSize * 0.3, headRect.center.dy + tileSize * 0.18);
      nostril1 = Offset(headRect.left + tileSize * 0.15, headRect.center.dy - tileSize * 0.06);
      nostril2 = Offset(headRect.left + tileSize * 0.15, headRect.center.dy + tileSize * 0.06);
    }

    // Draw realistic eyes
    for (final eye in [leftEye, rightEye]) {
      // Eye socket shadow
      c.drawCircle(eye, eyeSize * 1.1, Paint()..color = Colors.black.withOpacity(0.3));
      c.drawCircle(eye, eyeSize, eyeWhite);
      // Iris with gradient
      final irisPaint = Paint()..shader = irisGradient.createShader(Rect.fromCircle(center: eye, radius: pupilSize));
      c.drawCircle(eye, pupilSize, irisPaint);
      // Pupil
      c.drawCircle(eye, pupilSize * 0.6, pupilPaint);
      c.drawCircle(Offset(eye.dx - pupilSize * 0.3, eye.dy - pupilSize * 0.3), pupilSize * 0.25, highlightPaint);
      c.drawCircle(eye, eyeSize, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }

    c.drawOval(Rect.fromCenter(center: nostril1, width: tileSize * 0.03, height: tileSize * 0.05), nostrilPaint);
    c.drawOval(Rect.fromCenter(center: nostril2, width: tileSize * 0.03, height: tileSize * 0.05), nostrilPaint);
    
    final mouthPaint = Paint()..color = Colors.black54..strokeWidth = 1.2;
    if (dir == Point(0, -1) || dir == Point(0, 1)) {
      c.drawLine(
        Offset(headRect.center.dx - tileSize * 0.12, headRect.center.dy + (dir.y > 0 ? -tileSize * 0.1 : tileSize * 0.1)),
        Offset(headRect.center.dx + tileSize * 0.12, headRect.center.dy + (dir.y > 0 ? -tileSize * 0.1 : tileSize * 0.1)),
        mouthPaint
      );
    } else {
      c.drawLine(
        Offset(headRect.center.dx + (dir.x > 0 ? -tileSize * 0.1 : tileSize * 0.1), headRect.center.dy - tileSize * 0.12),
        Offset(headRect.center.dx + (dir.x > 0 ? -tileSize * 0.1 : tileSize * 0.1), headRect.center.dy + tileSize * 0.12),
        mouthPaint
      );
    }

    // Draw collision point indicator (red circle)
    if (collisionPoint != null) {
      final collisionCenter = Offset(
        collisionPoint!.x * tileSize + tileSize * 0.5,
        collisionPoint!.y * tileSize + tileSize * 0.5,
      );
      
      // Pulsating red circle with gradient
      final collisionGradient = RadialGradient(
        colors: [
          Colors.red.withOpacity(0.8),
          Colors.red.withOpacity(0.4),
          Colors.red.withOpacity(0.1),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
      
      final collisionPaint = Paint()
        ..shader = collisionGradient.createShader(
          Rect.fromCircle(center: collisionCenter, radius: tileSize * 0.4)
        );
      
      // Draw collision indicator
      c.drawCircle(collisionCenter, tileSize * 0.4, collisionPaint);
      
      // Draw red outline
      c.drawCircle(
        collisionCenter, 
        tileSize * 0.4, 
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
      );
      
      final xPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      
      final xSize = tileSize * 0.2;
      c.drawLine(
        Offset(collisionCenter.dx - xSize, collisionCenter.dy - xSize),
        Offset(collisionCenter.dx + xSize, collisionCenter.dy + xSize),
        xPaint,
      );
      c.drawLine(
        Offset(collisionCenter.dx + xSize, collisionCenter.dy - xSize),
        Offset(collisionCenter.dx - xSize, collisionCenter.dy + xSize),
        xPaint,
      );
    }

    // Realistic food (apple)
    final foodCenter = Offset(food.x * tileSize + tileSize * 0.5, food.y * tileSize + tileSize * 0.5);
    final foodRadius = tileSize * 0.35;
    
    final appleGradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      colors: [const Color(0xFFFF5252), const Color(0xFFD32F2F), const Color(0xFFB71C1C)],
      stops: const [0.0, 0.7, 1.0],
    );
    final applePaint = Paint()..shader = appleGradient.createShader(Rect.fromCircle(center: foodCenter, radius: foodRadius));
    c.drawCircle(foodCenter, foodRadius, applePaint);
    
    c.drawCircle(Offset(foodCenter.dx - foodRadius * 0.3, foodCenter.dy - foodRadius * 0.3), foodRadius * 0.3, 
                Paint()..color = Colors.white.withOpacity(0.4));
    
    final stemPaint = Paint()..color = const Color(0xFF4E342E)..strokeWidth = 2;
    c.drawLine(
      Offset(foodCenter.dx, foodCenter.dy - foodRadius),
      Offset(foodCenter.dx, foodCenter.dy - foodRadius - tileSize * 0.08),
      stemPaint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}