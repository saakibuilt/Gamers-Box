//
// iOS-optimized v2.3: Proper lifecycle management and performance optimization
//

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game2_character.dart';
import 'backgrounds/game2_background.dart';
import 'materials/game2_material.dart';
import 'game2_start_second.dart';
import 'game2_levels.dart';
import 'game_over_popup.dart';
import '../../total_user_points.dart';
import '../../utils/highest_score_firebase.dart';

class Game2StartPage extends StatefulWidget {
  const Game2StartPage({super.key});
  @override
  State<Game2StartPage> createState() => _Game2StartPageState();
}

class _Game2StartPageState extends State<Game2StartPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<Game2CharacterState> _charKey = GlobalKey();
  final GlobalKey _hudKey = GlobalKey();
  final Set<int> _collected = {};

  double _scroll = 0;
  double _baseSpeed = 1;
  double _speed = 1;
  int _score = 0, _high = 0;
  double _highDist = 0;
  bool _materialStarted = false;
  bool _paused = false;
  bool _gameStart = true;
  bool _gameOverShown = false;
  bool _isDisposed = false;
  bool _appInBackground = false;
  bool _pointsAdded = false; // Track if points were already added
  bool _highScoreRecorded = false; // Track if high score was already recorded

  bool _sliding = false;
  Timer? _slideTimer;

  late final Ticker _ticker;
  Duration _prev = Duration.zero;

  Offset? _dragStart;
  bool _slideTriggered = false;
  static const _swipeDist = 60.0;
  static const _swipeVel = 250.0;

  Game2Levels? _levels;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    //   DeviceOrientation.portraitUp,
    // ]);
    
    _initializeLevels();
    _loadPrefs();
    _ticker = createTicker(_step);
    
    // Start ticker after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _ticker.start();
      }
    });
  }

  void _initializeLevels() {
    _levels = Game2Levels(
      onSpeedChange: (newSpeed) {
        if (!_isDisposed && mounted) {
          _baseSpeed = newSpeed;
          _adjustSpeed();
          _safeSetState(() {});
        }
      },
      onStateUpdate: () {
        if (!_isDisposed && mounted) {
          _safeSetState(() {});
        }
      },
      miles: _miles,
    );
  }

  Future<void> _loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!_isDisposed && mounted) {
        _safeSetState(() {
          _high = p.getInt('g2_high') ?? 0;
          _highDist = p.getDouble('g2_highDist') ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted && !_appInBackground) {
      setState(fn);
    }
  }

  // App lifecycle handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _appInBackground = true;
        if (_gameStart && !_paused) {
          _pause();
        }
        break;
      case AppLifecycleState.resumed:
        _appInBackground = false;
        break;
      case AppLifecycleState.detached:
        _appInBackground = true;
        break;
      case AppLifecycleState.hidden:
        _appInBackground = true;
        break;
    }
  }

  // Slide speed control
  void _adjustSpeed() {
    if (!_isDisposed) {
      _speed = _sliding ? _baseSpeed + 0.7 : _baseSpeed;
    }
  }

  void _beginSlide() {
    if (_isDisposed) return;
    
    _sliding = true;
    _adjustSpeed();
    _slideTimer?.cancel();
    _slideTimer = Timer(const Duration(milliseconds: 1300), () {
      if (!_isDisposed) {
        _endSlide();
      }
    });
  }

  void _endSlide() {
    if (_isDisposed) return;
    
    _sliding = false;
    _adjustSpeed();
  }

  void _triggerSlide() {
    if (!_sliding && !_isDisposed) {
      _charKey.currentState?.slide();
      _beginSlide();
    }
  }

  // Optimized step method with frame rate limiting
  void _step(Duration now) {
    if (_isDisposed || _appInBackground) {
      _prev = now;
      return;
    }

    if (!_gameStart) {
      _prev = now;
      return;
    }

    final dt = (_prev == Duration.zero)
        ? 0.016
        : (now - _prev).inMicroseconds / 1e6;
    _prev = now;

    final cappedDt = dt.clamp(0.0, 0.033); // Max 30 FPS minimum
    
    _scroll += _speed * cappedDt;
    
    // Update level system safely
    _levels?.update(_scroll);
    
    if (!_materialStarted && _scroll >= 3) {
      _materialStarted = true;
    }
    
    _safeSetState(() {});
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    
    // Clean up all resources
    _ticker.dispose();
    _slideTimer?.cancel();
    _levels?.dispose();
    
    // Reset orientation preferences
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    super.dispose();
  }

  void _addScore(int pts) {
    if (!_isDisposed) {
      _safeSetState(() => _score += pts);
    }
  }

  // Add points to total user points system and record high score
  Future<void> _addPointsToTotal() async {
    if (_pointsAdded || _score <= 0) return; // Prevent duplicate additions
    
    _pointsAdded = true;
    
    // Add to total user points
    await TotalUserPointsHelper.addGamePoints(
      'Endless Runner',
      _score,
      {
        'distance': double.parse(_miles(_scroll)),
        'level': _levels?.getCurrentLevelInt() ?? 1,
        'finalScore': _score,
        'finalScroll': _scroll,
      },
    );

    await _recordHighScore();
  }

  Future<void> _recordHighScore() async {
    if (_highScoreRecorded || _score <= 0) return; // Prevent duplicate recordings
    
    _highScoreRecorded = true;
    
    try {
      HighScoreResult result = await HighScoreHelper.updateGameHighScore(_score, 'Endless Runner');
      
      if (result.isGlobalRecord) {
        print('🎉 NEW GLOBAL HIGH SCORE FOR ENDLESS RUNNER! Score: ${result.currentScore}');
        // Could show a special celebration popup here
      } else {
        print('Endless Runner score ${result.currentScore} - Current global high: ${result.globalHighScore}');
      }
    } catch (e) {
      print('Failed to record high score: $e');
    }
  }

  Future<void> _gameOver() async {
    if (_gameOverShown || _isDisposed || !mounted) return;
    
    _gameOverShown = true;
    
    try {
      // Add points to total user points system and record high score
      await _addPointsToTotal();
      
      // Save records before showing dialog
      await GameOverPopup.saveRecords(
        score: _score,
        scroll: _scroll,
        currentHigh: _high,
        currentHighDist: _highDist,
      );

      // Update local high scores
      await _loadPrefs();
      
      _paused = true;
      _gameStart = false;
      
      // Stop the ticker to prevent conflicts
      if (_ticker.isActive) {
        _ticker.stop();
      }
      
      if (!mounted || _isDisposed) {
        _gameOverShown = false;
        return;
      }
      
      // Show the game over popup
      final result = await GameOverPopup.show(
        context: context,
        score: _score,
        scroll: _scroll,
        high: _high,
        highDist: _highDist,
        miles: _miles,
      );
      
      // Handle result immediately after dialog closes
      if (!mounted || _isDisposed) {
        _gameOverShown = false;
        return;
      }
      
      // Reset flag before handling result
      _gameOverShown = false;
      
      await _handleGameOverResult(result);
      
    } catch (e) {
      debugPrint('Error in game over: $e');
      _gameOverShown = false;
      
      // Ensure game can continue even if dialog fails
      if (mounted && !_isDisposed) {
        _paused = false;
        _gameStart = true;
        _prev = Duration.zero;
        if (!_ticker.isActive) {
          _ticker.start();
        }
      }
    }
  }

  Future<void> _handleGameOverResult(String? result) async {
    if (result == 'quit') {
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else if (result == 'restart') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Game2StartPage()),
      );
    } else if (result == 'retry') {
      // Reset game state for continuation
      _paused = false;
      _gameStart = true;
      _prev = Duration.zero;
      
      // Reset character state for continuation
      _charKey.currentState?.resetForRetry();
      
      // Restart ticker for smooth continuation
      if (!_ticker.isActive && !_isDisposed && mounted) {
        _ticker.start();
      }
      
      if (mounted && !_isDisposed) {
        setState(() {});
      }
      
      debugPrint('Game continued from: ${_miles(_scroll)} miles, Score: $_score');
    } else {
      // Dialog dismissed - resume game
      _paused = false;
      _gameStart = true;
      _prev = Duration.zero;
      if (!_ticker.isActive && !_isDisposed && mounted) {
        _ticker.start();
      }
    }
  }

  void _pause() {
    if (!_isDisposed) {
      _safeSetState(() {
        _paused = true;
        _gameStart = false;
      });
    }
  }

  void _resume() {
    if (!_isDisposed) {
      _safeSetState(() {
        _paused = false;
        _gameStart = true;
        _prev = Duration.zero;
      });
    }
  }

  bool _isPointInsideHud(Offset global) {
    if (_isDisposed) return false;
    
    final rb = _hudKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return false;
    
    try {
      final origin = rb.localToGlobal(Offset.zero);
      return (origin & rb.size).contains(global);
    } catch (e) {
      return false;
    }
  }

  String _miles(double m) => (m / 1609.34 * 2).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) {
        if (!_isPointInsideHud(d.globalPosition) && !_paused && !_isDisposed) {
          _charKey.currentState?.tap();
        }
      },
      onDoubleTap: () {
        if (!_isDisposed) {
          _charKey.currentState?.doubleTap();
        }
      },
      onLongPressStart: (_) {
        if (!_isDisposed) {
          _charKey.currentState?.longPress();
        }
      },
      onVerticalDragStart: (d) {
        if (_isPointInsideHud(d.globalPosition) || _isDisposed) return;
        _dragStart = d.globalPosition;
        _slideTriggered = false;
      },
      onVerticalDragUpdate: (d) {
        if (_dragStart == null || _slideTriggered || _isDisposed) return;
        final dy = d.globalPosition.dy - _dragStart!.dy;
        if (dy > _swipeDist) {
          _triggerSlide();
          _slideTriggered = true;
        }
      },
      onVerticalDragEnd: (d) {
        if (_isDisposed) return;
        
        if (!_slideTriggered &&
            d.velocity.pixelsPerSecond.dy > _swipeVel &&
            _dragStart != null &&
            !_isPointInsideHud(_dragStart!)) {
          _triggerSlide();
        }
        _dragStart = null;
        _slideTriggered = false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xff87ceeb),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Game2Background(
              progress: _scroll,
              currentLevel: _levels?.getCurrentLevelInt() ?? 1,
            ),
            if (_materialStarted && !_isDisposed)
              Game2Material(
                progress: _scroll,
                collected: _collected,
                currentSpeed: _speed,
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Game2Character(
                  key: _charKey,
                  speed: _speed,
                  gameStart: _gameStart,
                  collectedIds: _collected,
                  onScore: _addScore,
                  onGameOver: _gameOver,
                  scrollProgress: _scroll,
                ),
              ),
            ),
            Game2StartUI.hud(
              hudKey: _hudKey,
              score: _score,
              scroll: _scroll,
              miles: _miles,
              getCurrentLevel: _levels?.getCurrentLevel ?? (() => "Level 1"),
              baseSpeed: _baseSpeed,
              gameStart: _gameStart,
              pause: _pause,
              resume: _resume,
            ),
            Game2StartUI.startingBanner(_scroll),
            if (_levels != null)
              Game2StartUI.levelBanner(
                _levels!.showLevelBanner, 
                _levels!.bannerText, 
                _levels!.bannerColor
              ),
            if (_paused && !_isDisposed) 
              Game2StartUI.pauseOverlay(
                score: _score,
                resume: _resume,
                quit: () {
                  if (!_isDisposed) {
                    _paused = false;
                    _gameStart = true;
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}