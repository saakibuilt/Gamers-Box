import 'package:flutter/material.dart';
import 'background_elements/sky.dart';
import 'background_elements/clouds.dart';
import 'background_elements/buildings.dart';
// import 'background_elements/trees.dart';
import 'background_elements/ground.dart';
import 'background_elements/streets.dart';
// import 'background_elements/water.dart';

class Game2Background extends StatelessWidget {
  final double progress;
  final int currentLevel;
  
  const Game2Background({
    super.key, 
    required this.progress,
    this.currentLevel = 1,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BackgroundPainter(progress, currentLevel)
  );
}

class _BackgroundPainter extends CustomPainter {
  final double progress;
  final int level;
  
  _BackgroundPainter(this.progress, this.level);

  @override
  void paint(Canvas canvas, Size size) {
    final masterShift = -(progress * 30); // Unified scroll speed
    final bufferZone = size.width * 0.5; // 50% screen width buffer on each side
    
    // Override individual script buffers to ensure nothing hides
    canvas.save();
    
    // Draw sky first (background layer) - static, no scrolling
    SkyPainter.draw(canvas, size, level);
    
    // Draw clouds if daytime (level 1) - controlled scrolling
    if (level == 1) {
      CloudsPainter.draw(canvas, size, progress);
    }
    
    // Draw buildings (background to foreground) - controlled scrolling
    BuildingsPainter.draw(canvas, size, progress, level);
    
    // // Draw water features based on level - controlled scrolling
    // if (level == 1) {
    //   // Level 1: Small pond in park area
    //   WaterPainter.drawPond(canvas, size, progress);
    // } else {
    //   // Level 2: Larger lake/river
    //   WaterPainter.drawLake(canvas, size, progress);
    // }
    
    // Draw realistic trees and parks - controlled scrolling
    
    // Draw streets and sidewalks - controlled scrolling with master oversight
    StreetsPainter.draw(canvas, size, progress, level);
    
    // Draw ground segments (foreground) - controlled scrolling
    GroundPainter.draw(canvas, size, progress, level);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) => 
      old.progress != progress || old.level != level;
}