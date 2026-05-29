import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TotalUserPoints {
  static const String _totalPointsKey = 'total_user_points';
  static const String _gameHistoryKey = 'game_history';
  
  // Singleton pattern for global access
  static final TotalUserPoints _instance = TotalUserPoints._internal();
  factory TotalUserPoints() => _instance;
  TotalUserPoints._internal();
  
  // Cache for current session
  int? _cachedTotalPoints;
  List<GameSession>? _cachedGameHistory;

  /// Get total points earned across all games
  Future<int> getTotalPoints() async {
    if (_cachedTotalPoints != null) {
      return _cachedTotalPoints!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    _cachedTotalPoints = prefs.getInt(_totalPointsKey) ?? 0;
    return _cachedTotalPoints!;
  }

  /// Add points from a game session
  Future<void> addPoints(int points, String gameName, {Map<String, dynamic>? gameData}) async {
    if (points < 0) return; // Don't allow negative points
    
    final prefs = await SharedPreferences.getInstance();
    final currentTotal = await getTotalPoints();
    final newTotal = currentTotal + points;
    
    // Update total points
    await prefs.setInt(_totalPointsKey, newTotal);
    _cachedTotalPoints = newTotal;
    
    // Add to game history
    await _addGameSession(GameSession(
      gameName: gameName,
      pointsEarned: points,
      timestamp: DateTime.now(),
      gameData: gameData ?? {},
    ));
  }

  /// Get game history with optional filtering
  Future<List<GameSession>> getGameHistory({String? gameName, int? limit}) async {
    if (_cachedGameHistory != null && gameName == null && limit == null) {
      return _cachedGameHistory!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_gameHistoryKey);
    
    if (historyJson == null) {
      _cachedGameHistory = [];
      return _cachedGameHistory!;
    }
    
    final List<dynamic> historyList = jsonDecode(historyJson);
    List<GameSession> sessions = historyList
        .map((json) => GameSession.fromJson(json))
        .toList();
    
    // Sort by timestamp (newest first)
    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (gameName != null) {
      sessions = sessions.where((session) => session.gameName == gameName).toList();
    }
    
    if (limit != null && limit > 0) {
      sessions = sessions.take(limit).toList();
    }
    
    if (gameName == null && limit == null) {
      _cachedGameHistory = sessions;
    }
    
    return sessions;
  }

  /// Get total points for a specific game
  Future<int> getGameTotalPoints(String gameName) async {
    final sessions = await getGameHistory(gameName: gameName);
    return sessions.fold<int>(0, (total, session) => total + session.pointsEarned);
  }

  /// Get statistics summary
  Future<PointsStatistics> getStatistics() async {
    final totalPoints = await getTotalPoints();
    final history = await getGameHistory();
    
    if (history.isEmpty) {
      return PointsStatistics(
        totalPoints: totalPoints,
        totalGames: 0,
        averagePointsPerGame: 0,
        bestGameSession: null,
        gameBreakdown: {},
        lastPlayedDate: null,
      );
    }
    
    final totalGames = history.length;
    final averagePointsPerGame = totalPoints / totalGames;
    final bestGameSession = history.reduce((a, b) => a.pointsEarned > b.pointsEarned ? a : b);
    final lastPlayedDate = history.first.timestamp;
    
    final Map<String, GameStats> gameBreakdown = {};
    for (final session in history) {
      if (!gameBreakdown.containsKey(session.gameName)) {
        gameBreakdown[session.gameName] = GameStats(
          gameName: session.gameName,
          totalPoints: 0,
          gamesPlayed: 0,
          bestScore: 0,
          averageScore: 0,
        );
      }
      
      final stats = gameBreakdown[session.gameName]!;
      stats.totalPoints += session.pointsEarned;
      stats.gamesPlayed++;
      if (session.pointsEarned > stats.bestScore) {
        stats.bestScore = session.pointsEarned;
      }
    }
    
    // Calculate average scores
    gameBreakdown.forEach((key, stats) {
      stats.averageScore = stats.totalPoints / stats.gamesPlayed;
    });
    
    return PointsStatistics(
      totalPoints: totalPoints,
      totalGames: totalGames,
      averagePointsPerGame: averagePointsPerGame,
      bestGameSession: bestGameSession,
      gameBreakdown: gameBreakdown,
      lastPlayedDate: lastPlayedDate,
    );
  }

  /// Reset all points and history (use with caution)
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_totalPointsKey);
    await prefs.remove(_gameHistoryKey);
    _cachedTotalPoints = null;
    _cachedGameHistory = null;
  }

  /// Export data as JSON string (for backup)
  Future<String> exportData() async {
    final totalPoints = await getTotalPoints();
    final history = await getGameHistory();
    
    final exportData = {
      'totalPoints': totalPoints,
      'exportDate': DateTime.now().toIso8601String(),
      'gameHistory': history.map((session) => session.toJson()).toList(),
    };
    
    return jsonEncode(exportData);
  }

  /// Import data from JSON string (for restore)
  Future<bool> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      final prefs = await SharedPreferences.getInstance();
      
      // Validate data structure
      if (!data.containsKey('totalPoints') || !data.containsKey('gameHistory')) {
        return false;
      }
      
      final totalPoints = data['totalPoints'] as int;
      final historyList = data['gameHistory'] as List;
      
      // Save imported data
      await prefs.setInt(_totalPointsKey, totalPoints);
      await prefs.setString(_gameHistoryKey, jsonEncode(historyList));
      
      // Clear cache to force refresh
      _cachedTotalPoints = null;
      _cachedGameHistory = null;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Private method to add game session to history
  Future<void> _addGameSession(GameSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHistory = await getGameHistory();
    currentHistory.insert(0, session); // Add to beginning (newest first)
    
    // Keep only last 1000 games to prevent unlimited growth
    if (currentHistory.length > 1000) {
      currentHistory.removeRange(1000, currentHistory.length);
    }
    
    final historyJson = jsonEncode(currentHistory.map((s) => s.toJson()).toList());
    await prefs.setString(_gameHistoryKey, historyJson);
    _cachedGameHistory = currentHistory;
  }

  /// Clear cache (useful after external changes)
  void clearCache() {
    _cachedTotalPoints = null;
    _cachedGameHistory = null;
  }
}

/// Represents a single game session
class GameSession {
  final String gameName;
  final int pointsEarned;
  final DateTime timestamp;
  final Map<String, dynamic> gameData; // Additional game-specific data

  GameSession({
    required this.gameName,
    required this.pointsEarned,
    required this.timestamp,
    required this.gameData,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      gameName: json['gameName'] as String,
      pointsEarned: json['pointsEarned'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameName': gameName,
      'pointsEarned': pointsEarned,
      'timestamp': timestamp.toIso8601String(),
      'gameData': gameData,
    };
  }

  @override
  String toString() {
    return 'GameSession(gameName: $gameName, points: $pointsEarned, date: ${timestamp.toString().split(' ')[0]})';
  }
}

/// Statistics about user's gaming performance
class PointsStatistics {
  final int totalPoints;
  final int totalGames;
  final double averagePointsPerGame;
  final GameSession? bestGameSession;
  final Map<String, GameStats> gameBreakdown;
  final DateTime? lastPlayedDate;

  PointsStatistics({
    required this.totalPoints,
    required this.totalGames,
    required this.averagePointsPerGame,
    required this.bestGameSession,
    required this.gameBreakdown,
    required this.lastPlayedDate,
  });
}

/// Statistics for a specific game
class GameStats {
  final String gameName;
  int totalPoints;
  int gamesPlayed;
  int bestScore;
  double averageScore;

  GameStats({
    required this.gameName,
    required this.totalPoints,
    required this.gamesPlayed,
    required this.bestScore,
    required this.averageScore,
  });
}

// Example usage and utility functions
class TotalUserPointsHelper {
  static final TotalUserPoints _pointsManager = TotalUserPoints();

  /// Quick method to add points from Snake game
  static Future<void> addSnakeGamePoints(int score, int level, int foodEaten) async {
    await _pointsManager.addPoints(
      score,
      'Snake Game',
      gameData: {
        'level': level,
        'foodEaten': foodEaten,
        'finalScore': score,
      },
    );
  }

  /// Quick method to add points from any game
  static Future<void> addGamePoints(String gameName, int points, [Map<String, dynamic>? gameData]) async {
    await _pointsManager.addPoints(points, gameName, gameData: gameData);
  }

  /// Get formatted total points string
  static Future<String> getFormattedTotalPoints() async {
    final total = await _pointsManager.getTotalPoints();
    return _formatPoints(total);
  }

  /// Get recent games summary
  static Future<String> getRecentGamesSummary({int limit = 5}) async {
    final recentGames = await _pointsManager.getGameHistory(limit: limit);
    if (recentGames.isEmpty) {
      return 'No games played yet';
    }

    final StringBuffer summary = StringBuffer();
    summary.writeln('Recent Games:');
    for (final game in recentGames) {
      final date = '${game.timestamp.day}/${game.timestamp.month}';
      summary.writeln('• ${game.gameName}: ${_formatPoints(game.pointsEarned)} ($date)');
    }
    return summary.toString();
  }

  /// Format points with commas for better readability
  static String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Get total points (direct access)
  static Future<int> getTotalPoints() => _pointsManager.getTotalPoints();

  /// Get statistics
  static Future<PointsStatistics> getStatistics() => _pointsManager.getStatistics();
}