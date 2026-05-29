import 'package:firebase_database/firebase_database.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class HighestScoreFirebase {
  static const String _highestScoresPath = 'Highest Scores';
  
  static final HighestScoreFirebase _instance = HighestScoreFirebase._internal();
  factory HighestScoreFirebase() => _instance;
  HighestScoreFirebase._internal();
  
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Check and update highest score if current score is higher for specific game
  Future<HighScoreResult> checkAndUpdateHighScore(int currentScore, String gameName) async {
    try {
      String deviceId = await _getDeviceId();
      
      String cleanGameName = _cleanGameName(gameName);
      
      // Check global high score for this game
      bool isGlobalRecord = await _checkGlobalHighScore(currentScore, deviceId, cleanGameName);
      
      return HighScoreResult(
        isPersonalRecord: isGlobalRecord, // Same as global since we only track global
        isGlobalRecord: isGlobalRecord,
        currentScore: currentScore,
        previousPersonalScore: 0, // Not tracking personal scores
        globalHighScore: await _getGlobalHighScore(cleanGameName),
        gameName: gameName,
      );
      
    } catch (e) {
      print('Error checking/updating high score: $e');
      return HighScoreResult(
        isPersonalRecord: false,
        isGlobalRecord: false,
        currentScore: currentScore,
        previousPersonalScore: 0,
        globalHighScore: 0,
        gameName: gameName,
      );
    }
  }

  /// Clean game name for Firebase path (remove spaces, special chars)
  String _cleanGameName(String gameName) {
    return gameName
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
        .toLowerCase();
  }

  /// Check if this score breaks the global record for specific game
  Future<bool> _checkGlobalHighScore(int currentScore, String deviceId, String cleanGameName) async {
    try {
      DatabaseReference globalRef = _database
          .child(_highestScoresPath)
          .child(cleanGameName);
      
      DataSnapshot snapshot = await globalRef.get();
      
      if (snapshot.exists) {
        final globalData = snapshot.value as Map<dynamic, dynamic>?;
        if (globalData != null) {
          int currentGlobalScore = globalData['highest_score'] ?? 0;
          
          if (currentScore > currentGlobalScore) {
            await _updateGlobalHighScore(globalRef, currentScore, deviceId);
            return true;
          }
        }
      } else {
        // No global record exists, create it
        await _createGlobalHighScore(globalRef, currentScore, deviceId);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error checking global high score: $e');
      return false;
    }
  }

  /// Create new global high score record
  Future<void> _createGlobalHighScore(DatabaseReference globalRef, int score, String deviceId) async {
    String formattedDateTime = _formatDateTime(DateTime.now());
    
    await globalRef.set({
      'highest_score': score,
      'device_id': deviceId,
      'date_time': formattedDateTime,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Update global high score record
  Future<void> _updateGlobalHighScore(DatabaseReference globalRef, int score, String deviceId) async {
    String formattedDateTime = _formatDateTime(DateTime.now());
    
    await globalRef.update({
      'highest_score': score,
      'device_id': deviceId,
      'date_time': formattedDateTime,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Get current global high score for specific game
  Future<int> _getGlobalHighScore(String cleanGameName) async {
    try {
      DatabaseReference globalRef = _database
          .child(_highestScoresPath)
          .child(cleanGameName);
      
      DataSnapshot snapshot = await globalRef.get();
      
      if (snapshot.exists) {
        final globalData = snapshot.value as Map<dynamic, dynamic>?;
        if (globalData != null) {
          return globalData['highest_score'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      print('Error getting global high score: $e');
      return 0;
    }
  }

  /// Watch global high score in real-time for specific game
  Stream<GlobalHighScore?> watchGlobalHighScore(String gameName) {
    String cleanGameName = _cleanGameName(gameName);
    
    return _database
        .child(_highestScoresPath)
        .child(cleanGameName)
        .onValue
        .map((event) {
      final globalData = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (globalData != null) {
        return GlobalHighScore(
          highestScore: globalData['highest_score'] ?? 0,
          deviceId: globalData['device_id'] ?? '',
          dateTime: globalData['date_time'] ?? '',
          updatedAt: globalData['updated_at'] ?? 0,
          gameName: gameName,
        );
      }
      return null;
    });
  }

  /// Get device ID
  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }
    return 'unknown_device';
  }

  /// Format date and time (Feb 22nd, 2025, 5:23pm)
  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    // Day suffix (st, nd, rd, th)
    String getDaySuffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1: return 'st';
        case 2: return 'nd';
        case 3: return 'rd';
        default: return 'th';
      }
    }
    
    // Format time (12-hour format with am/pm)
    int hour12 = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    String amPm = dateTime.hour >= 12 ? 'pm' : 'am';
    String minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '${months[dateTime.month - 1]} ${dateTime.day}${getDaySuffix(dateTime.day)}, ${dateTime.year}, $hour12:$minute$amPm';
  }

  /// Get global high score for specific game
  Future<GlobalHighScore?> getGlobalHighScore(String gameName) async {
    try {
      String cleanGameName = _cleanGameName(gameName);
      
      DataSnapshot snapshot = await _database
          .child(_highestScoresPath)
          .child(cleanGameName)
          .get();
      
      if (snapshot.exists) {
        final globalData = snapshot.value as Map<dynamic, dynamic>?;
        if (globalData != null) {
          return GlobalHighScore(
            highestScore: globalData['highest_score'] ?? 0,
            deviceId: globalData['device_id'] ?? '',
            dateTime: globalData['date_time'] ?? '',
            updatedAt: globalData['updated_at'] ?? 0,
            gameName: gameName,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting global high score: $e');
      return null;
    }
  }

  /// Get all game global high scores - CORRECTED VERSION
  Future<List<GlobalHighScore>> getAllGlobalHighScores() async {
    try {
      DataSnapshot snapshot = await _database.child(_highestScoresPath).get();
      List<GlobalHighScore> scores = [];

      print('Raw Firebase data: ${snapshot.value}'); // Debug

      if (snapshot.exists) {
        final gamesMap = snapshot.value as Map<dynamic, dynamic>?;
        
        if (gamesMap != null) {
          gamesMap.forEach((gameName, gameData) {
            print('Processing: $gameName -> $gameData'); // Debug
            
            if (gameData is Map && gameData['highest_score'] != null) {
              scores.add(GlobalHighScore(
                highestScore: gameData['highest_score'] ?? 0,
                deviceId: gameData['device_id'] ?? '',
                dateTime: gameData['date_time'] ?? '',
                updatedAt: gameData['updated_at'] ?? 0,
                gameName: gameName.toString(), // Keep original format
              ));
            }
          });

          // Sort by highest score (descending)
          scores.sort((a, b) => b.highestScore.compareTo(a.highestScore));
          print('Final scores count: ${scores.length}'); // Debug
        }
      }

      return scores;
    } catch (e) {
      print('Error getting all global high scores: $e');
      return [];
    }
  }

  }

/// Result of score submission with global tracking only
class HighScoreResult {
  final bool isPersonalRecord;
  final bool isGlobalRecord;
  final int currentScore;
  final int previousPersonalScore;
  final int globalHighScore;
  final String gameName;

  HighScoreResult({
    required this.isPersonalRecord,
    required this.isGlobalRecord,
    required this.currentScore,
    required this.previousPersonalScore,
    required this.globalHighScore,
    required this.gameName,
  });

  @override
  String toString() {
    return 'HighScoreResult(game: $gameName, global: $isGlobalRecord, score: $currentScore)';
  }
}

/// Global high score data structure
class GlobalHighScore {
  final int highestScore;
  final String deviceId;
  final String dateTime;
  final int updatedAt;
  final String gameName;

  GlobalHighScore({
    required this.highestScore,
    required this.deviceId,
    required this.dateTime,
    required this.updatedAt,
    required this.gameName,
  });

  @override
  String toString() {
    return 'GlobalHighScore(game: $gameName, score: $highestScore, device: $deviceId, date: $dateTime)';
  }
}

/// Enhanced helper for easy integration with different games
class HighScoreHelper {
  static final HighestScoreFirebase _firebase = HighestScoreFirebase();

  /// Check and update high score for Tetris game
  static Future<HighScoreResult> updateTetrisHighScore(int finalScore) async {
    return await _firebase.checkAndUpdateHighScore(finalScore, 'Tetris Game');
  }

  /// Check and update high score for Pac-Man game
  static Future<HighScoreResult> updatePacManHighScore(int finalScore) async {
    return await _firebase.checkAndUpdateHighScore(finalScore, 'Pac-Man Adventure');
  }

  /// Generic method for any game
  static Future<HighScoreResult> updateGameHighScore(int finalScore, String gameName) async {
    return await _firebase.checkAndUpdateHighScore(finalScore, gameName);
  }

  /// Get global high score for specific game
  static Future<GlobalHighScore?> getGlobalHighScore(String gameName) async {
    return await _firebase.getGlobalHighScore(gameName);
  }

  /// Get all global high scores across all games
  static Future<List<GlobalHighScore>> getAllGlobalHighScores() async {
    return await _firebase.getAllGlobalHighScores();
  }

  /// Watch global high score for specific game in real-time
  static Stream<GlobalHighScore?> watchGlobalHighScore(String gameName) {
    return _firebase.watchGlobalHighScore(gameName);
  }
}