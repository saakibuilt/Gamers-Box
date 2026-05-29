//

import 'dart:async';

class Game2Levels {
  final void Function(double) onSpeedChange;
  final void Function() onStateUpdate;
  final String Function(double) miles;

  int _currentLevel = 1;
  bool _showLevelBanner = false;
  String _bannerText = '';
  String _bannerColor = 'orange'; // orange, red, purple, gold
  
  // Track which levels have been triggered
  final Set<int> _triggeredLevels = {1};

  Game2Levels({
    required this.onSpeedChange,
    required this.onStateUpdate,
    required this.miles,
  });

  // Getters for banner states
  bool get showLevel2Banner => _showLevelBanner && _bannerColor == 'orange';
  bool get showLevel3Banner => _showLevelBanner && _bannerColor == 'red';
  bool get showLevelBanner => _showLevelBanner;
  String get bannerText => _bannerText;
  String get bannerColor => _bannerColor;

  String getCurrentLevel() => _currentLevel.toString();
  int getCurrentLevelInt() => _currentLevel; // Added this method

  // Calculate distance threshold for each level (progressive difficulty)
  double _getLevelThreshold(int level) {
    if (level <= 1) return 0.0;
    
    // Progressive distance requirements
    // Then increasing by 0.12 miles per level up to level 10
    // Then increasing by 0.16 miles per level up to level 25
    // Then increasing by 0.2 miles per level up to level 50
    
    if (level == 2) return 0.10;
    if (level == 3) return 0.22;
    
    double threshold = 0.22; // Start level 4 logic from level 3 threshold, when 0.22 miles is reached
    
    // Levels 4-10: +0.05 miles each
    for (int i = 4; i <= level && i <= 10; i++) {
      threshold += 0.12;
    }
    
    // Levels 11-25: +0.1 miles each
    for (int i = 11; i <= level && i <= 25; i++) {
      threshold += 0.16;
    }
    
    // Levels 26-50: +0.2 miles each
    for (int i = 26; i <= level && i <= 50; i++) {
      threshold += 0.2;
    }
    
    return threshold;
  }

  // Calculate speed for each level
  double _getLevelSpeed(int level) {
    // Base speed progression:
    // Then progressive increase
    
    if (level <= 1) return 1.0;
    if (level == 2) return 1.4;
    if (level == 3) return 1.8;
    
    // Levels 4-10: +0.3 speed each
    double speed = 1.8;
    for (int i = 4; i <= level && i <= 10; i++) {
      speed += 0.3;
    }
    
    // Levels 11-25: +0.2 speed each
    for (int i = 11; i <= level && i <= 25; i++) {
      speed += 0.4;
    }
    
    // Levels 26-50: +0.1 speed each (getting very fast!)
    for (int i = 26; i <= level && i <= 50; i++) {
      speed += 0.7;
    }
    
    return speed;
  }

  String _getBannerColor(int level) {
    if (level <= 10) return 'orange';
    if (level <= 25) return 'red';
    if (level <= 40) return 'purple';
    return 'gold'; // Levels 41-50
  }

  String _getBannerText(int level) {
    if (level <= 3) {
      return 'Level $level';
    } else if (level <= 10) {
      return 'Level $level\nSpeed boost incoming!';
    } else if (level <= 25) {
      return 'Level $level\nIntense speed ahead!';
    } else if (level <= 40) {
      return 'Level $level\nExtreme velocity!';
    } else if (level < 50) {
      return 'Level $level\nInsane speed zone!';
    } else {
      return 'LEVEL 50\nMAXIMUM OVERDRIVE!';
    }
  }

  void update(double scroll) {
    double currentDistance = double.parse(miles(scroll));
    
    // Check for level progression (up to level 50)
    for (int level = 2; level <= 50; level++) {
      if (!_triggeredLevels.contains(level) && 
          currentDistance >= _getLevelThreshold(level)) {
        
        _triggeredLevels.add(level);
        _currentLevel = level;
        _showLevelBanner = true;
        _bannerColor = _getBannerColor(level);
        _bannerText = _getBannerText(level);
        onStateUpdate();
        
        // Start 3-second timer for speed increase
        Timer(const Duration(seconds: 3), () {
          onSpeedChange(_getLevelSpeed(level));
          _showLevelBanner = false;
          onStateUpdate();
        });
        
        break; // Only trigger one level at a time
      }
    }
  }

  void dispose() {
    // Cancel any pending timers if needed
    // (Timers are automatically disposed when they complete)
  }
}