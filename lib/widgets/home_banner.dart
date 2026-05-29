import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math'; // Added for random shuffling
import 'highest_score_firebase.dart';

class HomeBanner extends StatefulWidget {
  final String? message;
  final double height;
  final double speed;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;

  const HomeBanner({
    super.key,
    this.message,
    this.height = 54, // Reduced height to fit content
    this.speed = 50,
    this.backgroundColor,
    this.textColor,
    this.textStyle, required Row child,
  });

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  
  List<GlobalHighScore> _highScores = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  Timer? _scrollTimer;
  Timer? _resumeTimer;
  final Random _random = Random(); // Added for randomization
  bool _isUserScrolling = false;
  bool _autoScrollEnabled = true;
  bool _hasRandomizedOnce = false; // Track if we've randomized

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadHighScores();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshTimer?.cancel();
    _scrollTimer?.cancel();
    _resumeTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadHighScores();
    });
  }

  Future<void> _loadHighScores() async {
    try {
      final scores = await HighScoreHelper.getAllGlobalHighScores();
      print('Loaded ${scores.length} high scores for banner');
      
      if (mounted) {
        setState(() {
          // Only shuffle on first load (app launch), maintain order on refreshes
          if (!_hasRandomizedOnce) {
            _highScores = List.from(scores)..shuffle(_random);
            _hasRandomizedOnce = true;
          } else {
            // Keep the same order, just update the data
            final Map<String, GlobalHighScore> scoreMap = {
              for (var score in scores) score.gameName: score
            };
            
            // Update existing scores in current order, add new ones at the end
            List<GlobalHighScore> updatedScores = [];
            for (var existingScore in _highScores) {
              if (scoreMap.containsKey(existingScore.gameName)) {
                updatedScores.add(scoreMap[existingScore.gameName]!);
                scoreMap.remove(existingScore.gameName);
              }
            }
            // Add any new games that weren't in the previous list
            updatedScores.addAll(scoreMap.values);
            
            _highScores = updatedScores;
          }
          _isLoading = false;
        });
        _startScrolling();
      }
    } catch (e) {
      print('Error loading high scores for banner: $e');
      if (mounted) {
        setState(() {
          _highScores = [];
          _isLoading = false;
        });
      }
    }
  }

  String _formatGameName(String gameName) {
    return gameName
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatScore(int score) {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _startScrolling() {
    _scrollTimer?.cancel();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _scrollController.hasClients) {
        _autoScroll();
      }
    });
  }

  void _autoScroll() {
    if (!mounted || !_scrollController.hasClients || _isUserScrolling || !_autoScrollEnabled) return;

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || !_scrollController.hasClients || _isUserScrolling || !_autoScrollEnabled) {
        timer.cancel();
        return;
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      
      final newOffset = currentScroll + 1.5; // Adjust speed here
      
      if (newOffset >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(newOffset);
      }
    });
  }

  void _pauseAutoScroll() {
    _scrollTimer?.cancel();
    _resumeTimer?.cancel();
    setState(() {
      _isUserScrolling = true;
    });
  }

  void _resumeAutoScroll() {
    _resumeTimer?.cancel();
    // Resume immediately when manual scroll stops
    if (mounted) {
      setState(() {
        _isUserScrolling = false;
      });
      _autoScroll();
    }
  }

  Widget _buildGameCard(GlobalHighScore score) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Game-specific icons only
    IconData gameIcon = Icons.games;
    
    if (score.gameName.contains('pac_man')) {
      gameIcon = Icons.circle; // Use a yellow color to look like Pac-Man
    } else if (score.gameName.contains('snake')) {
      gameIcon = Icons.settings_ethernet; // Resembles a snake movement
    } else if (score.gameName.contains('tetris')) {
      gameIcon = Icons.grid_view;
    } else if (score.gameName.contains('endless_runner')) {
      gameIcon = Icons.directions_run;
    }

    // Theme-based colors
    final cardBackgroundColor = isDark 
      ? const Color.fromARGB(255, 0, 0, 0) 
      : Colors.white;
    
    final borderColor = isDark 
      ? const Color.fromARGB(255, 43, 43, 43) 
      : Colors.grey.withOpacity(0.4);
    
    final gameNameColor = isDark 
      ? Colors.white 
      : Colors.black;
    
    final scoreColor = isDark 
      ? Colors.green 
      : Colors.green;
    
    final iconColor = isDark 
      ? Colors.grey[400] 
      : Colors.grey[600];
    
    final dividerColor = isDark 
      ? Colors.grey[700]!.withOpacity(0.2) 
      : Colors.grey.withOpacity(0.2);

    // Calculate heights based on widget height
    final cardHeight = widget.height - 2; // Account for container borders
    final gameNameHeight = (cardHeight * 0.5).clamp(20.0, 30.0);
    final scoreHeight = cardHeight - gameNameHeight;

    return Container(
      width: 110,
      height: cardHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        color: cardBackgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: gameNameHeight,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              border: Border(
                bottom: BorderSide(color: dividerColor, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  gameIcon,
                  size: (gameNameHeight * 0.5).clamp(12.0, 16.0),
                  color: iconColor,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    _formatGameName(score.gameName),
                    style: TextStyle(
                      color: gameNameColor,
                      fontSize: (gameNameHeight * 0.4).clamp(10.0, 14.0),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
              ),
              child: Center(
                child: Text(
                  _formatScore(score.highestScore),
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: (scoreHeight * 0.4).clamp(12.0, 16.0),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticMessage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final cardBackgroundColor = isDark 
      ? const Color.fromARGB(255, 0, 0, 0) 
      : Colors.white;
    
    final borderColor = isDark 
      ? const Color.fromARGB(255, 0, 0, 0) 
      : Colors.grey.withOpacity(0.4);
    
    final textColor = isDark 
      ? Colors.white 
      : Colors.black;

    // Calculate dimensions based on widget height
    final cardHeight = widget.height - 2; // Account for container borders

    return Container(
      width: 180,
      height: cardHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        color: cardBackgroundColor,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            widget.message ?? 'GamersBox',
            style: TextStyle(
              color: textColor,
              fontSize: (cardHeight * 0.25).clamp(14.0, 18.0),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBannerWidgets() {
    List<Widget> widgets = [];
    
    // Add static message if provided
    if (widget.message != null && widget.message!.isNotEmpty) {
      widgets.add(_buildStaticMessage());
    }
    
    for (final score in _highScores) {
      widgets.add(_buildGameCard(score));
    }
    
    // Create a copy of widgets for seamless loop (avoid concurrent modification)
    final List<Widget> originalWidgets = List.from(widgets);
    widgets.addAll(originalWidgets);
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = widget.backgroundColor ?? 
        (isDark ? Colors.grey[900]! : Colors.grey[100]!);
    
    final topBottomBorderColor = isDark 
      ? const Color.fromARGB(255, 0, 0, 0) 
      : Colors.grey[300]!;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: topBottomBorderColor,
            width: 1,
          ),
          bottom: BorderSide(
            color: topBottomBorderColor,
            width: 1,
          ),
        ),
      ),
      child: _isLoading
          ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : _highScores.isEmpty
              ? Center(
                  child: Text(
                    widget.message ?? 'No scores available',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollStartNotification) {
                      // User started scrolling manually
                      _pauseAutoScroll();
                    } else if (notification is ScrollEndNotification) {
                      // User stopped scrolling manually
                      _resumeAutoScroll();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(), // Changed to allow manual scrolling
                    child: Container(
                      height: widget.height - 2, // Use full allocated height minus borders
                      child: Row(
                        children: _buildBannerWidgets(),
                      ),
                    ),
                  ),
                ),
    );
  }
}

// Alternative simple card-based banner without scrolling
class SimpleCardBanner extends StatefulWidget {
  final double height;

  const SimpleCardBanner({
    super.key,
    this.height = 60,
  });

  @override
  State<SimpleCardBanner> createState() => _SimpleCardBannerState();
}

class _SimpleCardBannerState extends State<SimpleCardBanner> {
  List<GlobalHighScore> _highScores = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  final Random _random = Random(); // Added for randomization
  bool _hasRandomizedOnce = false; // Track if we've randomized

  @override
  void initState() {
    super.initState();
    _loadHighScores();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadHighScores();
    });
  }

  Future<void> _loadHighScores() async {
    try {
      final scores = await HighScoreHelper.getAllGlobalHighScores();
      if (mounted) {
        setState(() {
          // Only shuffle on first load (app launch), maintain order on refreshes
          if (!_hasRandomizedOnce) {
            _highScores = List.from(scores)..shuffle(_random);
            _hasRandomizedOnce = true;
          } else {
            // Keep the same order, just update the data
            final Map<String, GlobalHighScore> scoreMap = {
              for (var score in scores) score.gameName: score
            };
            
            // Update existing scores in current order, add new ones at the end
            List<GlobalHighScore> updatedScores = [];
            for (var existingScore in _highScores) {
              if (scoreMap.containsKey(existingScore.gameName)) {
                updatedScores.add(scoreMap[existingScore.gameName]!);
                scoreMap.remove(existingScore.gameName);
              }
            }
            // Add any new games that weren't in the previous list
            updatedScores.addAll(scoreMap.values);
            
            _highScores = updatedScores;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        border: Border(
          top: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          bottom: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _highScores.isEmpty
              ? const Center(child: Text('No high scores available'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  itemCount: _highScores.length,
                  itemBuilder: (context, index) {
                    final score = _highScores[index];
                    return _buildStaticGameCard(score);
                  },
                ),
    );
  }

  Widget _buildStaticGameCard(GlobalHighScore score) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    Color cardColor = Colors.blue;
    if (score.gameName.contains('pac_man')) cardColor = Colors.yellow;
    else if (score.gameName.contains('snake')) cardColor = Colors.green;
    else if (score.gameName.contains('tetris')) cardColor = Colors.purple;
    else if (score.gameName.contains('endless_runner')) cardColor = Colors.orange;

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: cardColor, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: cardColor.withOpacity(0.1),
      ),
      child: Column(
        children: [
          // Game name row
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Center(
                child: Text(
                  score.gameName.split('_').map((word) => 
                    word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase()
                  ).join(' '),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          
          // Divider
          Container(height: 1, color: cardColor),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Center(
                child: Text(
                  score.highestScore.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
                  style: TextStyle(
                    color: cardColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}