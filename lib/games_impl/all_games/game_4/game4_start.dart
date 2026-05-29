// Tetris full-screen with minimal edge margin, tap‑to‑rotate, swipe to move,
// quick-drop down, and floating next-piece preview box in top-right.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'game4_header.dart';
import 'game4_popup.dart';
import '../../total_user_points.dart';
import '../../utils/highest_score_firebase.dart';

class Game4StartPage extends StatefulWidget {
  const Game4StartPage({super.key});

  @override
  State<Game4StartPage> createState() => _Game4StartPageState();
}

class _Game4StartPageState extends State<Game4StartPage> with TickerProviderStateMixin {
  static const int rows = 20;
  static const int cols = 10;
  static const Duration normalTickDuration = Duration(milliseconds: 500);
  static const Duration fastTickDuration = Duration(milliseconds: 100);

  late List<List<Color?>> board;
  Timer? timer;
  List<Point<int>> currentPiece = [];
  Color currentColor = Color(0xFF00BCD4); // Bright Cyan
  Point<int> position = const Point(3, 0);
  
  late AnimationController _fallController;
  late Animation<double> _fallAnimation;
  double animatedY = 0.0;

  List<Point<int>> nextPiece = [];
  Color nextColor = Color(0xFF00BCD4); // Bright Cyan
  
  List<int> completedLines = [];
  bool isBlinking = false;
  Timer? blinkTimer;
  int blinkCount = 0;
  
  bool isFastFalling = false;
  Duration currentTickDuration = normalTickDuration;
  
  int currentLevel = 1;
  int linesCleared = 0;
  int totalLinesCleared = 0;
  int score = 0;
  
  bool showLevelBanner = false;
  Timer? levelBannerTimer;
  
  bool isPaused = false;
  bool isGameOver = false;
  
  int get linesNeededForNextLevel {
    switch (currentLevel) {
      case 1: return 10;
      case 2: return 12;
      case 3: return 15;
      case 4: return 18;
      case 5: return 20;
      default: return 20 + ((currentLevel - 5) * 3); // Each level after 5 adds 3 more lines
    }
  }
  
  Duration get levelSpeed {
    return Duration(milliseconds: max(100, 500 - (currentLevel - 1) * 50));
  }

  final pieces = <List<Point<int>>>[
    [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)], // Square
    [Point(0, 1), Point(1, 1), Point(2, 1), Point(1, 0)], // T
    [Point(0, 1), Point(1, 1), Point(1, 0), Point(2, 0)], // Z
    [Point(0, 0), Point(1, 0), Point(2, 0), Point(3, 0)], // Line
  ];

  // Only 3 bright, sober colors
  final colors = [
    Color(0xFF00BCD4), // Bright Cyan - Professional and calming
    Color(0xFF4CAF50), // Bright Green - Fresh and energetic
    Color(0xFF2196F3), // Bright Blue - Trustworthy and stable
  ];

  Offset? _horizontalDragStart;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    board = List.generate(rows, (_) => List.filled(cols, null));
    
    currentTickDuration = levelSpeed;
    _fallController = AnimationController(
      duration: currentTickDuration,
      vsync: this,
    );
    _fallAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fallController, curve: Curves.linear),
    );
    _fallAnimation.addListener(() {
      setState(() {
        animatedY = _fallAnimation.value;
      });
    });
    _fallController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeFall();
      }
    });
    
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final boardData = prefs.getString('tetris_board');
    
    if (boardData != null) {
      try {
        final gameData = jsonDecode(boardData);
        
        // Check if this is an old save file with incompatible colors
        bool hasOldColors = false;
        final boardList = gameData['board'] as List;
        for (final row in boardList) {
          final rowList = row as List;
          for (final cell in rowList) {
            if (cell != null) {
              final colorStr = cell.toString();
              if (colorStr.startsWith('grey') || 
                  !['cyan', 'green', 'blue'].contains(colorStr)) {
                hasOldColors = true;
                break;
              }
            }
          }
          if (hasOldColors) break;
        }
        
        // If old colors detected, start fresh
        if (hasOldColors) {
          await _clearSavedProgress();
          _startNewGame();
          return;
        }
        
        // Restore board state with proper type casting
        board = boardList.map((row) {
          final rowList = row as List;
          return rowList.map((cell) => cell != null ? _stringToColor(cell.toString()) : null).toList();
        }).toList();
        
        // Restore game stats
        currentLevel = gameData['level'] ?? 1;
        linesCleared = gameData['linesCleared'] ?? 0;
        totalLinesCleared = gameData['totalLinesCleared'] ?? 0;
        score = gameData['score'] ?? 0;
        currentTickDuration = levelSpeed;
        
        // Restore next piece with proper type casting
        if (gameData['nextPiece'] != null) {
          final nextPieceList = gameData['nextPiece'] as List;
          nextPiece = nextPieceList.map((p) {
            final point = p as Map<String, dynamic>;
            return Point<int>(point['x'] as int, point['y'] as int);
          }).toList();
          nextColor = _stringToColor(gameData['nextColor'].toString());
        } else {
          _generateNext();
        }
        
        setState(() {}); // Update UI with loaded data
        _spawnPiece();
        _startFalling();
      } catch (e) {
        // If loading fails, start fresh
        print('Failed to load progress: $e');
        _startNewGame();
      }
    } else {
      // No saved data, start fresh
      _startNewGame();
    }
  }

  void _startNewGame() {
    _generateNext();
    _spawnPiece();
    _startFalling();
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final gameData = {
        'board': board.map((row) => 
          row.map((cell) => cell != null ? _colorToString(cell) : null).toList()
        ).toList(),
        'level': currentLevel,
        'linesCleared': linesCleared,
        'totalLinesCleared': totalLinesCleared,
        'score': score,
        'nextPiece': nextPiece.map((p) => {'x': p.x, 'y': p.y}).toList(),
        'nextColor': _colorToString(nextColor),
      };
      
      await prefs.setString('tetris_board', jsonEncode(gameData));
    } catch (e) {
      // Silently fail if save doesn't work
      print('Failed to save progress: $e');
    }
  }

  String _colorToString(Color color) {
    if (color == Color(0xFF00BCD4)) return 'cyan';
    if (color == Color(0xFF4CAF50)) return 'green';
    if (color == Color(0xFF2196F3)) return 'blue';
    return 'cyan'; // Default fallback
  }

  Color _stringToColor(String colorString) {
    switch (colorString) {
      case 'cyan': return Color(0xFF00BCD4);
      case 'green': return Color(0xFF4CAF50);
      case 'blue': return Color(0xFF2196F3);
      // Backward compatibility - convert any old colors to new ones
      default: 
        final rand = Random();
        return colors[rand.nextInt(colors.length)];
    }
  }

  Future<void> _clearSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tetris_board');
    } catch (e) {
      print('Failed to clear progress: $e');
    }
  }

  void _generateNext() {
    final rand = Random();
    nextPiece = pieces[rand.nextInt(pieces.length)];
    nextColor = colors[rand.nextInt(colors.length)];
  }

  void _spawnPiece() {
    currentPiece = nextPiece;
    currentColor = nextColor;
    position = const Point(3, 0);
    animatedY = 0.0;
    _generateNext();
    _saveProgress(); // Save after spawning new piece
  }

  void _startFalling() {
    if (!isPaused) {
      _fallController.duration = currentTickDuration;
      _fallController.reset();
      _fallController.forward();
    }
  }

  void _completeFall() {
    if (isPaused) return;
    
    if (!_movePiece(const Point(0, 1))) {
      _placePiece();
      _clearLines();
      _spawnPiece();
      if (!_isValidPosition(position, currentPiece)) {
        _fallController.stop();
        _showGameOverPopup();
        return;
      }
    }
    _startFalling();
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      if (!_movePiece(const Point(0, 1))) {
        _placePiece();
        _clearLines();
        _spawnPiece();
        if (!_isValidPosition(position, currentPiece)) {
          timer?.cancel();
          _showGameOverPopup();
        }
      }
    });
  }

  bool _movePiece(Point<int> offset) {
    final newPos = position + offset;
    if (_isValidPosition(newPos, currentPiece)) {
      position = newPos;
      return true;
    }
    return false;
  }

  void _placePiece() {
    for (final block in currentPiece) {
      final x = position.x + block.x;
      final y = position.y + block.y;
      if (y >= 0 && y < rows && x >= 0 && x < cols) {
        board[y][x] = currentColor;
      }
    }
    _saveProgress(); // Save after placing piece
  }

  void _clearLines() {
    completedLines = [];
    for (int y = 0; y < rows; y++) {
      if (board[y].every((cell) => cell != null)) {
        completedLines.add(y);
      }
    }
    
    if (completedLines.isNotEmpty) {
      isBlinking = true;
      blinkCount = 0;
      _fallController.stop();
      _startBlinking();
    }
  }
  
  void _startBlinking() {
    blinkTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        blinkCount++;
        if (blinkCount >= 6) { // 3 blinks = 6 state changes
          _removeCompletedLines();
          _stopBlinking();
        }
      });
    });
  }
  
  void _removeCompletedLines() {
    int clearedCount = completedLines.length;
    for (int lineIndex in completedLines.reversed) {
      board.removeAt(lineIndex);
      board.insert(0, List.filled(cols, null));
    }
    
    // Add score: 5 points per completed line
    score += clearedCount * 5;
    
    linesCleared += clearedCount;
    totalLinesCleared += clearedCount;
    
    // Check for level up
    if (linesCleared >= linesNeededForNextLevel) {
      _levelUp();
    }
  }
  
  void _levelUp() {
    currentLevel++;
    linesCleared = 0;
    currentTickDuration = levelSpeed;
    if (!isFastFalling) {
      // Only update normal speed, keep fast speed if user is swiping
      _fallController.duration = currentTickDuration;
    }
    
    // Show level banner for 2 seconds
    if (mounted) {
      setState(() {
        showLevelBanner = true;
      });
    }
    
    levelBannerTimer?.cancel();
    levelBannerTimer = Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showLevelBanner = false;
        });
      }
    });
    
    _saveProgress(); // Save after level up
  }
  
  void _stopBlinking() {
    blinkTimer?.cancel();
    isBlinking = false;
    completedLines.clear();
    blinkCount = 0;
    _startFalling();
  }

  void _rotatePiece() {
    if (isPaused) return;
    
    final rotated = currentPiece.map((p) => Point(-p.y, p.x)).toList();
    
    // Try rotation at current position first
    if (_isValidPosition(position, rotated)) {
      setState(() => currentPiece = rotated);
      return;
    }
    
    // If current position doesn't work, try wall kicks
    final wallKicks = [
      Point(-1, 0), // Try moving left
      Point(1, 0),  // Try moving right
      Point(-2, 0), // Try moving further left
      Point(2, 0),  // Try moving further right
      Point(0, -1), // Try moving up
      Point(-1, -1), // Try moving left and up
      Point(1, -1),  // Try moving right and up
    ];
    
    for (final kick in wallKicks) {
      final newPos = position + kick;
      if (_isValidPosition(newPos, rotated)) {
        setState(() {
          currentPiece = rotated;
          position = newPos;
        });
        return;
      }
    }
    
    // If no wall kick worked, rotation is not possible (rare case)
  }

  bool _isValidPosition(Point<int> pos, List<Point<int>> piece) {
    for (final block in piece) {
      final x = pos.x + block.x;
      final y = pos.y + block.y;
      if (x < 0 || x >= cols || y >= rows) return false;
      if (y >= 0 && board[y][x] != null) return false;
    }
    return true;
  }

  void _quickDrop() {
    if (isPaused) return;
    
    if (!isFastFalling) {
      isFastFalling = true;
      currentTickDuration = fastTickDuration;
      _fallController.duration = currentTickDuration;
      _fallController.reset();
      _fallController.forward();
    }
  }

  void _resumeNormalSpeed() {
    if (isFastFalling) {
      isFastFalling = false;
      currentTickDuration = levelSpeed; // Use level-based speed
    }
  }

  void _moveHorizontal(int dir) {
    if (isPaused) return;
    setState(() => _movePiece(Point(dir, 0)));
  }

  void _pauseGame() {
    if (mounted) {
      setState(() {
        isPaused = true;
      });
    }
    _fallController.stop();
  }

  void _resumeGame() {
    if (mounted) {
      setState(() {
        isPaused = false;
      });
    }
    _startFalling();
  }

  void _restartGame() {
    if (mounted) {
      setState(() {
        isPaused = false;
        isGameOver = false;
      });
    }
    _gameOver();
  }

  void _exitGame() {
    Navigator.pop(context);
  }

  void _showGameOverPopup() {
    // Stop all timers and animations
    _fallController.stop();
    levelBannerTimer?.cancel();
    blinkTimer?.cancel();
    
    // Record score in total user points
    _recordGameScore();
    
    // Clear saved progress since game is over
    _clearSavedProgress();
    
    if (mounted) {
      setState(() {
        isGameOver = true;
        isPaused = false;
      });
    }
  }

  Future<void> _recordGameScore() async {
    try {
      // Record the final score in total user points system
      await TotalUserPointsHelper.addGamePoints(
        'Tetris Game',
        score,
        {
          'finalLevel': currentLevel,
          'totalLinesCleared': totalLinesCleared,
          'finalScore': score,
          'gameEndReason': 'pieces_reached_top',
          'playDuration': DateTime.now().toIso8601String(),
        },
      );

      HighScoreResult result = await HighScoreHelper.updateTetrisHighScore(score);
      
      if (result.isGlobalRecord) {
        print('🎉 NEW GLOBAL HIGH SCORE! Score: ${result.currentScore}');
        // You can show a special popup or notification for global record
      } else if (result.isPersonalRecord) {
        print('🏆 New personal high score! Previous: ${result.previousPersonalScore}, New: ${result.currentScore}');
      } else {
        print('Score ${result.currentScore} - Current global high: ${result.globalHighScore}');
      }
    } catch (e) {
      print('Failed to record game score: $e');
    }
  }

  void _gameOver() {
    // Reset to level 1 and clear stats
    if (mounted) {
      setState(() {
        currentLevel = 1;
        linesCleared = 0;
        totalLinesCleared = 0;
        score = 0;
        showLevelBanner = false;
        isBlinking = false;
        completedLines.clear();
        blinkCount = 0;
        isFastFalling = false;
        isPaused = false;
        isGameOver = false;
        currentTickDuration = levelSpeed;
      });
    }
    
    // Clear the board
    board = List.generate(rows, (_) => List.filled(cols, null));
    
    // Generate new pieces and restart
    _generateNext();
    _spawnPiece();
    _startFalling();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    timer?.cancel();
    blinkTimer?.cancel();
    levelBannerTimer?.cancel();
    _fallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cellSize = min(screenSize.width / cols, screenSize.height / rows) * 0.8;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen tap detector for rotation
          Positioned.fill(
            child: GestureDetector(
              onTap: _rotatePiece,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Game board with movement controls - allows taps to pass through
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _rotatePiece, // Also handle taps here for grid area
              onVerticalDragStart: (_) => _quickDrop(),
              onVerticalDragEnd: (_) => _resumeNormalSpeed(),
              onHorizontalDragStart: (d) => _horizontalDragStart = d.localPosition,
              onHorizontalDragUpdate: (d) {
                if (_horizontalDragStart == null) return;
                final dx = d.localPosition.dx - _horizontalDragStart!.dx;
                if (dx.abs() > 20) {
                  _moveHorizontal(dx > 0 ? 1 : -1);
                  _horizontalDragStart = d.localPosition;
                }
              },
              onHorizontalDragEnd: (_) => _horizontalDragStart = null,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(rows, (y) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(cols, (x) {
                        Color? color = board[y][x];
                        
                        // Show current piece with smooth falling animation
                        for (final block in currentPiece) {
                          final bx = position.x + block.x;
                          final by = position.y + block.y + animatedY;
                          if (bx == x && by >= y && by < y + 1) {
                            color = currentColor;
                            break;
                          }
                        }
                        
                        // Handle completed line blinking
                        if (isBlinking && completedLines.contains(y)) {
                          color = (blinkCount % 2 == 0) ? Colors.red : (color ?? Colors.black);
                        }
                        
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            color: color ?? Colors.black,
                            border: Border.all(color: Colors.white, width: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
          Game4Header(
            currentLevel: currentLevel,
            linesCleared: linesCleared,
            linesNeededForNextLevel: linesNeededForNextLevel,
            totalLinesCleared: totalLinesCleared,
            score: score,
            nextPiece: nextPiece,
            nextColor: nextColor,
            showLevelBanner: showLevelBanner,
            onPause: _pauseGame,
          ),
          // Pause popup overlay (topmost layer)
          if (isPaused)
            Game4Popup(
              onResume: _resumeGame,
              onRestart: _restartGame,
              onExit: _exitGame,
              isGameOver: false,
            ),
          // Game over popup overlay (topmost layer)
          if (isGameOver)
            Game4Popup(
              onRestart: _restartGame,
              onExit: _exitGame,
              isGameOver: true,
            ),
        ],
      ),
    );
  }
}