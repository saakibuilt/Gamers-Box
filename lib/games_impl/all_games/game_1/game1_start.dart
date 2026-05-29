import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'game1_ui.dart'; // Import the UI components
import '../../total_user_points.dart';
import '../../utils/highest_score_firebase.dart';

class Game1StartPage extends StatefulWidget {
  const Game1StartPage({super.key});

  @override
  State<Game1StartPage> createState() => _Game1StartPageState();
}

class _Game1StartPageState extends State<Game1StartPage> 
    with TickerProviderStateMixin 
    implements GameStateInterface { // ✅ Implement the interface
  
  Timer? gameTimer;
  Timer? ghostTimer;
  @override
  late AnimationController pacmanAnimController;
  
  @override
  int score = 0;
  @override
  int totalScore = 0;
  @override
  int level = 1;
  @override
  int lives = 3;
  static const int scoreTarget = 500;
  bool gameRunning = false;
  @override
  bool gameOver = false;
  bool _pointsAdded = false; // Track if points were already added
  bool _highScoreRecorded = false; // Track if high score was already recorded
  
  // Progress tracking variables
  @override
  int maxLevelCompleted = 0;
  @override
  int personalBestScore = 0;
  bool hasResumeData = false;
  
  static const int gridWidth = 19;
  static const int gridHeight = 21;
  @override
  double cellWidth = 18.0;
  @override
  double cellHeight = 18.0;
  
  @override
  double pacmanX = 9.0;
  @override
  double pacmanY = 15.0;
  @override
  String direction = 'right';
  @override
  String nextDirection = 'right';
  
  @override
  List<Ghost> ghosts = [];
  @override
  List<List<int>> maze = [];
  @override
  Set<String> dots = {};
  @override
  Set<String> powerPellets = {};
  @override
  bool powerMode = false;
  Timer? powerTimer;
  
  @override
  void initState() {
    super.initState();
    pacmanAnimController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    )..repeat();
    _loadGameProgress();
  }
  
  @override
  void dispose() {
    gameTimer?.cancel();
    ghostTimer?.cancel();
    powerTimer?.cancel();
    pacmanAnimController.dispose();
    super.dispose();
  }
  
  // Implement the interface methods
  
  @override
  Future<void> clearResumeData() => _clearResumeData();
  
  @override
  void initGame() => _initGame();

  // Add points to total user points system and record high score
  Future<void> _addPointsToTotal() async {
    if (_pointsAdded) return; // Prevent duplicate additions
    
    final finalTotalScore = totalScore + score;
    if (finalTotalScore <= 0) return; // Don't add if no score
    
    _pointsAdded = true;
    
    // Add to total user points
    await TotalUserPointsHelper.addGamePoints(
      'Pac-Man Adventure',
      finalTotalScore,
      {
        'level': level,
        'lives': lives,
        'finalScore': finalTotalScore,
        'currentLevelScore': score,
        'maxLevelReached': maxLevelCompleted,
      },
    );

    await _recordHighScore(finalTotalScore);
  }

  Future<void> _recordHighScore(int finalScore) async {
    if (_highScoreRecorded) return; // Prevent duplicate recordings
    
    _highScoreRecorded = true;
    
    try {
      HighScoreResult result = await HighScoreHelper.updatePacManHighScore(finalScore);
      
      if (result.isGlobalRecord) {
        print('🎉 NEW GLOBAL HIGH SCORE FOR PAC-MAN! Score: ${result.currentScore}');
        // Could show a special celebration popup here
      } else if (result.isPersonalRecord) {
        print('🏆 New personal Pac-Man high score! Previous: ${result.previousPersonalScore}, New: ${result.currentScore}');
      } else {
        print('Pac-Man score ${result.currentScore} - Current global high: ${result.globalHighScore}');
      }
    } catch (e) {
      print('Failed to record high score: $e');
    }
  }
  
  // Load saved game progress
  Future<void> _loadGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      maxLevelCompleted = prefs.getInt('max_level_completed') ?? 0;
      personalBestScore = prefs.getInt('personal_best_score') ?? 0;
      
      // Check if there's resume data
      final savedLevel = prefs.getInt('current_level');
      final savedScore = prefs.getInt('current_score');
      final savedTotalScore = prefs.getInt('current_total_score');
      final savedLives = prefs.getInt('current_lives');
      
      if (savedLevel != null && savedScore != null && savedTotalScore != null && savedLives != null) {
        hasResumeData = true;
        // Don't auto-resume, let user choose
      }
    });
    
    if (hasResumeData) {
      _showResumeDialog();
    } else {
      _initGame();
    }
  }
  
  // Show resume dialog
  void _showResumeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Resume Game?', style: TextStyle(color: Colors.yellow, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Found previous game data:', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 10),
            FutureBuilder<List<int>>(
              future: _getResumeData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Column(
                    children: [
                      Text('Level: ${data[0]}', style: TextStyle(color: Colors.cyan, fontSize: 16)),
                      Text('Score: ${data[1]}', style: TextStyle(color: Colors.cyan, fontSize: 16)),
                      Text('Total Score: ${data[2]}', style: TextStyle(color: Colors.cyan, fontSize: 16)),
                      Text('Lives: ${data[3]}', style: TextStyle(color: Colors.cyan, fontSize: 16)),
                    ],
                  );
                }
                return CircularProgressIndicator();
              },
            ),
            SizedBox(height: 15),
            Text('Personal Best: $personalBestScore', style: TextStyle(color: Colors.orange, fontSize: 14)),
            Text('Max Level: $maxLevelCompleted', style: TextStyle(color: Colors.green, fontSize: 14)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _clearResumeData();
              _initGame();
            },
            child: Text('New Game'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _resumeGame();
            },
            child: Text('Resume'),
          ),
        ],
      ),
    );
  }
  
  Future<List<int>> _getResumeData() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      prefs.getInt('current_level') ?? 1,
      prefs.getInt('current_score') ?? 0,
      prefs.getInt('current_total_score') ?? 0,
      prefs.getInt('current_lives') ?? 3,
    ];
  }
  
  // Resume previous game
  Future<void> _resumeGame() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      level = prefs.getInt('current_level') ?? 1;
      score = prefs.getInt('current_score') ?? 0;
      totalScore = prefs.getInt('current_total_score') ?? 0;
      lives = prefs.getInt('current_lives') ?? 3;
    });
    _initGame();
  }
  
  // Clear resume data
  Future<void> _clearResumeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_level');
    await prefs.remove('current_score');
    await prefs.remove('current_total_score');
    await prefs.remove('current_lives');
  }
  
  // Save current game progress
  Future<void> _saveGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_level', level);
    await prefs.setInt('current_score', score);
    await prefs.setInt('current_total_score', totalScore);
    await prefs.setInt('current_lives', lives);
  }
  
  // Save achievements (max level and best score)
  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update max level completed
    if (level > maxLevelCompleted) {
      maxLevelCompleted = level;
      await prefs.setInt('max_level_completed', maxLevelCompleted);
    }
    
    // Update personal best score
    final currentTotal = totalScore + score;
    if (currentTotal > personalBestScore) {
      personalBestScore = currentTotal;
      await prefs.setInt('personal_best_score', personalBestScore);
    }
  }
  
  void _initGame() {
    _createMaze();
    _placeDots();
    _spawnGhosts();
    _startGame();
  }
  
  void _createMaze() {
    maze = [
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1],
      [1,0,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,1,1,0,1],
      [1,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1],
      [1,1,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1],
      [0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0],
      [1,1,1,1,0,1,0,1,0,0,0,1,0,1,0,1,1,1,1],
      [0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0],
      [1,1,1,1,0,1,0,1,1,1,1,1,0,1,0,1,1,1,1],
      [0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0],
      [1,1,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,1,1],
      [1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1],
      [1,0,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0,1],
      [1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1],
      [1,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1],
      [1,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1],
      [1,0,1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,0,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    ];
  }
  
  void _placeDots() {
    dots.clear();
    powerPellets.clear();
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        if (maze[y][x] == 0 && !(x == 9 && y == 15)) {
          if ((y == 7 || y == 9 || y == 11) && (x < 3 || x > 15)) continue;
          
          if ((x == 1 && y == 3) || (x == 17 && y == 3) || 
              (x == 1 && y == 17) || (x == 17 && y == 17)) {
            powerPellets.add('$x,$y');
          } else {
            dots.add('$x,$y');
          }
        }
      }
    }
  }
  
  void _spawnGhosts() {
    ghosts = [
      Ghost(9.0, 9.0, Colors.red, 'Blinky'),
      Ghost(8.0, 9.0, Colors.pink, 'Pinky'),
      Ghost(10.0, 9.0, Colors.cyan, 'Inky'),
      Ghost(9.0, 8.0, Colors.orange, 'Clyde'),
    ];
  }
  
  void _startGame() {
    gameRunning = true;
    
    gameTimer = Timer.periodic(Duration(milliseconds: 180), (timer) {
      if (gameRunning) {
        setState(() {
          _movePacman();
          _checkCollisions();
          _checkWin();
        });
        // Auto-save progress every few moves
        if (timer.tick % 10 == 0) {
          _saveGameProgress();
        }
      }
    });
    
    int ghostSpeed = _getGhostSpeed();
    ghostTimer = Timer.periodic(Duration(milliseconds: ghostSpeed), (timer) {
      if (gameRunning) {
        setState(() {
          _moveGhosts();
        });
      }
    });
  }
  
  int _getGhostSpeed() {
    int baseSpeed = 280;
    int speedReduction = (level - 1) * 15;
    int minSpeed = 150; // Reduced minimum speed for higher levels
    return (baseSpeed - speedReduction).clamp(minSpeed, baseSpeed);
  }
  
  void _movePacman() {
    if (nextDirection != direction) {
      double testX = pacmanX, testY = pacmanY;
      switch (nextDirection) {
        case 'up': testY--; break;
        case 'down': testY++; break;
        case 'left': testX--; break;
        case 'right': testX++; break;
      }
      if (_canMoveTo(testX, testY)) {
        direction = nextDirection;
      }
    }
    
    double newX = pacmanX, newY = pacmanY;
    switch (direction) {
      case 'up': newY--; break;
      case 'down': newY++; break;
      case 'left': newX--; break;
      case 'right': newX++; break;
    }
    
    if (newX < 0 && _isTunnelOpen(pacmanY.round(), 'left')) {
      newX = gridWidth - 1;
    } else if (newX >= gridWidth && _isTunnelOpen(pacmanY.round(), 'right')) {
      newX = 0;
    }
    
    if (_canMoveTo(newX, newY)) {
      pacmanX = newX;
      pacmanY = newY;
    }
    
    String pos = '${pacmanX.round()},${pacmanY.round()}';
    if (dots.remove(pos)) score += 10;
    if (powerPellets.remove(pos)) {
      score += 50;
      powerMode = true;
      powerTimer?.cancel();
      powerTimer = Timer(Duration(seconds: 6), () => powerMode = false);
    }
  }
  
  void _moveGhosts() {
    for (var ghost in ghosts) {
      List<String> moves = [];
      
      // Check valid moves with proper boundary checking
      if (_canGhostMoveTo(ghost.x + 1, ghost.y)) moves.add('right');
      if (_canGhostMoveTo(ghost.x - 1, ghost.y)) moves.add('left');
      if (_canGhostMoveTo(ghost.x, ghost.y + 1)) moves.add('down');
      if (_canGhostMoveTo(ghost.x, ghost.y - 1)) moves.add('up');
      
      // Handle tunnel movement only at specific tunnel positions
      if (ghost.y.round() == 9 && ghost.x.round() <= 1) {
        moves.add('left');
      }
      if (ghost.y.round() == 9 && ghost.x.round() >= gridWidth - 2) {
        moves.add('right');
      }
      
      if (moves.isNotEmpty) {
        String bestMove;
        
        if (powerMode) {
          bestMove = _getAwayMove(ghost, moves);
        } else {
          bestMove = _getChaseMove(ghost, moves);
        }
        
        // Execute the move with boundary checks
        switch (bestMove) {
          case 'up': 
            if (_canGhostMoveTo(ghost.x, ghost.y - 1)) ghost.y--; 
            break;
          case 'down': 
            if (_canGhostMoveTo(ghost.x, ghost.y + 1)) ghost.y++; 
            break;
          case 'left': 
            if (ghost.y.round() == 9 && ghost.x.round() <= 1) {
              ghost.x = gridWidth - 1; // Tunnel wrap
            } else if (_canGhostMoveTo(ghost.x - 1, ghost.y)) {
              ghost.x--;
            }
            break;
          case 'right': 
            if (ghost.y.round() == 9 && ghost.x.round() >= gridWidth - 2) {
              ghost.x = 0; // Tunnel wrap
            } else if (_canGhostMoveTo(ghost.x + 1, ghost.y)) {
              ghost.x++;
            }
            break;
        }
      }
    }
  }

  bool _canGhostMoveTo(double x, double y) {
    int gx = x.round(), gy = y.round();
    
    if (gx < 0 || gx >= gridWidth || gy < 0 || gy >= gridHeight) {
      return false;
    }
    
    // Ghost area restrictions - they must stay in walkable areas (0) or ghost house
    return maze[gy][gx] == 0;
  }

  String _getChaseMove(Ghost ghost, List<String> possibleMoves) {
    if (possibleMoves.isEmpty) return 'right';
    
    String bestMove = possibleMoves[0];
    double shortestDistance = double.infinity;
    
    for (String move in possibleMoves) {
      double testX = ghost.x, testY = ghost.y;
      switch (move) {
        case 'up': testY--; break;
        case 'down': testY++; break;
        case 'left': 
          if (ghost.y.round() == 9 && ghost.x.round() <= 1) {
            testX = gridWidth - 1;
          } else {
            testX--;
          }
          break;
        case 'right': 
          if (ghost.y.round() == 9 && ghost.x.round() >= gridWidth - 2) {
            testX = 0;
          } else {
            testX++;
          }
          break;
      }
      
      double distance = sqrt(pow(testX - pacmanX, 2) + pow(testY - pacmanY, 2));
      
      if (distance < shortestDistance) {
        shortestDistance = distance;
        bestMove = move;
      }
    }
    
    // Progressive difficulty - nearly impossible at level 100
    double chaseChance = _getChaseAccuracy();
    
    if (Random().nextDouble() < chaseChance) {
      return bestMove;
    } else {
      return possibleMoves[Random().nextInt(possibleMoves.length)];
    }
  }

  double _getChaseAccuracy() {
    // Progressive scaling from 40% at level 1 to 99% at level 100
    double baseAccuracy = 0.4;
    double maxAccuracy = 0.99;
    double levelProgress = (level - 1) / 99.0; // 0.0 to 1.0 for levels 1-100
    
    // Exponential curve makes later levels much harder
    num exponentialProgress = pow(levelProgress, 1.5);
    
    return baseAccuracy + (maxAccuracy - baseAccuracy) * exponentialProgress;
  }
  
  String _getAwayMove(Ghost ghost, List<String> possibleMoves) {
    Map<String, double> moveDistances = {};
    
    for (String move in possibleMoves) {
      double testX = ghost.x, testY = ghost.y;
      switch (move) {
        case 'up': testY--; break;
        case 'down': testY++; break;
        case 'left': 
          if (ghost.y.round() == 9 && ghost.x.round() <= 1) {
            testX = gridWidth - 1;
          } else {
            testX--;
          }
          break;
        case 'right': 
          if (ghost.y.round() == 9 && ghost.x.round() >= gridWidth - 2) {
            testX = 0;
          } else {
            testX++;
          }
          break;
      }
      
      double distance = sqrt(pow(testX - pacmanX, 2) + pow(testY - pacmanY, 2));
      moveDistances[move] = distance;
    }
    
    var sortedMoves = moveDistances.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (Random().nextDouble() < 0.8) {
      return sortedMoves.first.key;
    } else {
      return possibleMoves[Random().nextInt(possibleMoves.length)];
    }
  }
  
  void _checkCollisions() {
    for (var ghost in ghosts) {
      if ((ghost.x - pacmanX).abs() < 0.5 && (ghost.y - pacmanY).abs() < 0.5) {
        if (powerMode) {
          ghost.x = 9; ghost.y = 9;
          score += 200;
        } else {
          lives--;
          pacmanX = 9; pacmanY = 15;
          for (int i = 0; i < ghosts.length; i++) {
            switch (i) {
              case 0: ghosts[i].x = 9.0; ghosts[i].y = 9.0; break;
              case 1: ghosts[i].x = 8.0; ghosts[i].y = 9.0; break;
              case 2: ghosts[i].x = 10.0; ghosts[i].y = 9.0; break;
              case 3: ghosts[i].x = 9.0; ghosts[i].y = 8.0; break;
            }
          }
          if (lives <= 0) {
            gameRunning = false;
            gameOver = true;
            gameTimer?.cancel();
            ghostTimer?.cancel();
            _saveAchievements();
            _addPointsToTotal(); // Add points and record high score when game over
            _clearResumeData(); // Clear resume data on game over
          } else {
            _saveGameProgress(); // Save after losing a life
          }
        }
      }
    }
  }
  
  void _checkWin() {
    if (score >= scoreTarget) {
      _showVictoryMessage();
      return;
    }
    
    if (dots.isEmpty && powerPellets.isEmpty) {
      _showVictoryMessage();
    }
  }
  
  void _showVictoryMessage() {
    setState(() {
      gameRunning = false;
    });
    
    _saveAchievements(); // Save achievements on level completion
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Level $level Complete!', style: TextStyle(color: Colors.yellow, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Level Score: $score/$scoreTarget', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 5),
            Text('Total Score: ${totalScore + score}', style: TextStyle(color: Colors.cyan, fontSize: 16)),
            SizedBox(height: 5),
            Text('Personal Best: $personalBestScore', style: TextStyle(color: Colors.orange, fontSize: 14)),
            SizedBox(height: 5),
            Text('Max Level: $maxLevelCompleted', style: TextStyle(color: Colors.green, fontSize: 14)),
            SizedBox(height: 10),
            Text('🎉 Level $level Complete! 🎉', style: TextStyle(color: Colors.green, fontSize: 16)),
            SizedBox(height: 10),
            Text('Ready for Level ${level + 1}?', style: TextStyle(color: Colors.orange, fontSize: 16)),
            if (level >= 50) // Show difficulty warning for higher levels
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('⚠️ Ghosts getting smarter! ⚠️', 
                  style: TextStyle(color: Colors.red, fontSize: 14)),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                totalScore += score;
                score = 0;
                level++;
                pacmanX = 9; 
                pacmanY = 15; 
                direction = 'right'; 
                nextDirection = 'right';
                powerMode = false;
              });
              gameTimer?.cancel();
              ghostTimer?.cancel();
              _saveGameProgress(); // Save progress before starting next level
              _initGame();
            },
            child: Text('Next Level'),
          ),
        ],
      ),
    );
  }
  
  bool _canMoveTo(double x, double y) {
    int gx = x.round(), gy = y.round();
    if (gx < 0 || gx >= gridWidth || gy < 0 || gy >= gridHeight) {
      return false;
    }
    return maze[gy][gx] == 0;
  }
  
  bool _isTunnelOpen(int y, String side) {
    if (side == 'left') {
      return maze[y][0] == 0;
    } else if (side == 'right') {
      return maze[y][gridWidth - 1] == 0;
    }
    return false;
  }
  
  void _onSwipe(String dir) {
    if (['up', 'down', 'left', 'right'].contains(dir) && dir != direction) {
      nextDirection = dir;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GameUI(
      gameState: this, // ✅ Pass 'this' instead of 'direction'
      onSwipe: _onSwipe,
      showPauseMenu: _showPauseMenu,
    );
  }
  
  // Show pause menu with options
  void _showPauseMenu() {
    if (!gameRunning) return;
    
    setState(() {
      gameRunning = false;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('Game Paused', style: TextStyle(color: Colors.yellow, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Level: $level', style: TextStyle(color: Colors.cyan, fontSize: 16)),
            Text('Score: $score', style: TextStyle(color: Colors.cyan, fontSize: 16)),
            Text('Total Score: ${totalScore + score}', style: TextStyle(color: Colors.cyan, fontSize: 16)),
            Text('Lives: $lives', style: TextStyle(color: Colors.cyan, fontSize: 16)),
            SizedBox(height: 10),
            Divider(color: Colors.grey),
            SizedBox(height: 10),
            Text('Personal Best: $personalBestScore', style: TextStyle(color: Colors.green, fontSize: 14)),
            Text('Max Level: $maxLevelCompleted', style: TextStyle(color: Colors.purple, fontSize: 14)),
            SizedBox(height: 10),
            Text('Ghost Accuracy: ${(_getChaseAccuracy() * 100).toStringAsFixed(0)}%', 
              style: TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // Close pause dialog
              Navigator.pop(context); // Exit to main menu
              _saveGameProgress(); // Save progress before exiting (no points added)
            },
            child: Text('Exit to Menu'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                gameRunning = true;
              });
              _saveGameProgress(); // Save progress when resuming
            },
            child: Text('Resume'),
          ),
        ],
      ),
    );
  }
}

class Ghost {
  double x, y;
  Color color;
  String name;
  Ghost(this.x, this.y, this.color, this.name);
}