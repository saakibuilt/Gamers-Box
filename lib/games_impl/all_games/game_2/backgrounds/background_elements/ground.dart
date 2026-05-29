import 'dart:math' as math;
import 'package:flutter/material.dart';

class GroundPainter {
  static void draw(Canvas canvas, Size size, double progress, int level) {
    final shift = -(progress * 44); // Keep continuous for fixture positioning
    
    // Draw main platform segments (these need the modulo for tiling)
    _drawPlatformSegments(canvas, size, shift, level);
    
    // Draw platform edges and details (these need the modulo for patterns)
    _drawPlatformEdges(canvas, size, shift, level);
    
    // Draw platform fixtures (these need continuous motion)
    _drawPlatformFixtures(canvas, size, shift, level);
  }

  static void _drawPlatformSegments(Canvas canvas, Size size, double shift, int level) {
    const segmentWidth = 40.0;
    const segmentHeight = 12.0;
    const gap = 4.0;
    final y = size.height - segmentHeight - 6; // FIXED: Increased offset to -6 for more clearance
    final totalWidth = segmentWidth + gap;
    
    // Use modulo for tiling pattern
    final tiledShift = shift % totalWidth;
    
    for (double x = tiledShift - segmentWidth; x < size.width + segmentWidth; x += totalWidth) {
      _drawSingleSegment(canvas, x, y, segmentWidth, segmentHeight, level);
    }
  }

  static void _drawSingleSegment(Canvas canvas, double x, double y, double width, double height, int level) {
    // Main platform color based on level
    final platformColor = level == 1 
        ? const Color(0xff34495E)  // Daytime - darker blue-gray
        : const Color(0xff2C3E50);  // Evening - even darker
    
    // Platform shadow for depth
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x + 2, y + 2, width, height),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    
    // Main platform segment
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, width, height),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      Paint()..color = platformColor,
    );
    
    // Platform surface details
    _drawSegmentDetails(canvas, x, y, width, height, level);
  }

  static void _drawSegmentDetails(Canvas canvas, double x, double y, double width, double height, int level) {
    // Top surface highlight line
    canvas.drawRect(
      Rect.fromLTWH(x + 2, y + 1, width - 4, 1),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    
    // Surface texture lines
    canvas.drawRect(
      Rect.fromLTWH(x + 5, y + 4, width - 10, 0.5),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
    
    canvas.drawRect(
      Rect.fromLTWH(x + 5, y + 7, width - 10, 0.5),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
    
    // Side edge definition
    canvas.drawRect(
      Rect.fromLTWH(x, y + 2, 1, height - 4),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    
    canvas.drawRect(
      Rect.fromLTWH(x + width - 1, y + 2, 1, height - 4),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    
    // Corner bolts/rivets
    _drawBolt(canvas, x + 3, y + 3);
    _drawBolt(canvas, x + width - 6, y + 3);
    _drawBolt(canvas, x + 3, y + height - 6);
    _drawBolt(canvas, x + width - 6, y + height - 6);
    
    // Wear marks (random based on x position for consistency)
    final random = math.Random((x * 100).toInt());
    if (random.nextDouble() > 0.7) {
      final wearX = x + 8 + random.nextDouble() * (width - 16);
      final wearY = y + 2 + random.nextDouble() * (height - 4);
      canvas.drawRect(
        Rect.fromLTWH(wearX, wearY, 3 + random.nextDouble() * 8, 0.5),
        Paint()..color = Colors.black.withValues(alpha: 0.2),
      );
    }
  }

  static void _drawBolt(Canvas canvas, double x, double y) {
    canvas.drawCircle(
      Offset(x, y),
      1.5,
      Paint()..color = Colors.grey.shade600,
    );
    
    canvas.drawRect(
      Rect.fromLTWH(x - 1, y - 0.25, 2, 0.5),
      Paint()..color = Colors.grey.shade800,
    );
  }

  static void _drawPlatformEdges(Canvas canvas, Size size, double shift, int level) {
    final y = size.height - 12 - 6; // FIXED: Increased offset to -6 to match platform position
    
    // Platform edge definition
    canvas.drawRect(
      Rect.fromLTWH(0, y, size.width, 1.0),
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
  }

  static void _drawPlatformFixtures(Canvas canvas, Size size, double shift, int level) {
    final fixtureSpacing = 120.0;
    final y = size.height - 12 - 6; // FIXED: Increased offset to -6 to match platform position
    
    // Calculate starting position to ensure fixtures enter from right
    final startX = ((shift / fixtureSpacing).floor() - 5) * fixtureSpacing;
    final endX = size.width + 600; // Larger buffer
    
    // Draw fixtures in a continuous line
    for (double baseX = startX; baseX < startX + endX + 1200; baseX += fixtureSpacing) {
      final x = baseX + shift;
      
      if (x > -300 && x < size.width + 300) {
        final fixtureIndex = (baseX / fixtureSpacing).abs().floor();
        final fixtureType = fixtureIndex % 4;
        
        switch (fixtureType) {
          case 0:
            _drawPlatformBench(canvas, x, y - 15);
            break;
          case 1:
            _drawPlatformSign(canvas, x + 20, y - 25, level);
            break;
          case 2:
            _drawPlatformLight(canvas, x + 40, y - 30, level);
            break;
          case 3:
            _drawPlatformVending(canvas, x + 60, y - 40);
            break;
        }
      }
    }
    
    // Platform drain grates
    _drawDrainGrates(canvas, size, shift, y);
  }

  static void _drawPlatformBench(Canvas canvas, double x, double y) {
    canvas.drawRect(
      Rect.fromLTWH(x + 5, y + 8, 3, 12),
      Paint()..color = Colors.grey.shade700,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + 32, y + 8, 3, 12),
      Paint()..color = Colors.grey.shade700,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y + 5, 40, 5),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(1),
        bottomRight: const Radius.circular(1),
      ),
      Paint()..color = const Color(0xff8B4513),
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y - 8, 40, 5),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(1),
        bottomRight: const Radius.circular(1),
      ),
      Paint()..color = const Color(0xff8B4513),
    );
    
    // Wood grain texture
    for (double grain = x + 3; grain < x + 37; grain += 8) {
      canvas.drawRect(
        Rect.fromLTWH(grain, y + 6, 5, 1),
        Paint()..color = Colors.brown.shade700,
      );
      canvas.drawRect(
        Rect.fromLTWH(grain, y - 7, 5, 1),
        Paint()..color = Colors.brown.shade700,
      );
    }
    
    // Metal support brackets
    canvas.drawRect(
      Rect.fromLTWH(x + 8, y, 2, 10),
      Paint()..color = Colors.grey.shade600,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + 30, y, 2, 10),
      Paint()..color = Colors.grey.shade600,
    );
  }

  static void _drawPlatformSign(Canvas canvas, double x, double y, int level) {
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y, 4, 25),
      Paint()..color = Colors.grey.shade700,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x + 5, y, 30, 15),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = Colors.blue.shade700,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x + 5, y, 30, 15),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    
    // Sign text simulation (white rectangles)
    canvas.drawRect(Rect.fromLTWH(x + 8, y + 3, 8, 2), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 8, y + 6, 12, 2), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 8, y + 9, 6, 2), Paint()..color = Colors.white);
  }

  static void _drawPlatformLight(Canvas canvas, double x, double y, int level) {
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y, 4, 30),
      Paint()..color = Colors.grey.shade700,
    );
    
    // Light fixture base
    canvas.drawRect(
      Rect.fromLTWH(x - 4, y - 5, 8, 5),
      Paint()..color = Colors.grey.shade600,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 6, y - 12, 12, 7),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = Colors.grey.shade500,
    );
    
    // Light glow (stronger for evening level)
    if (level == 2) {
      canvas.drawCircle(
        Offset(x, y - 8),
        12,
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    
    canvas.drawCircle(
      Offset(x, y - 8),
      3,
      Paint()..color = level == 1 
          ? Colors.yellow.withValues(alpha: 0.7)
          : Colors.yellow.withValues(alpha: 0.95),
    );
  }

  static void _drawPlatformVending(Canvas canvas, double x, double y) {
    // Vending machine body
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 8, y, 16, 40),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
        bottomLeft: const Radius.circular(1),
        bottomRight: const Radius.circular(1),
      ),
      Paint()..color = Colors.red.shade700,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 6, y + 5, 12, 15),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = Colors.black,
    );
    
    // Product display simulation
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawRect(
          Rect.fromLTWH(x - 5 + col * 3, y + 7 + row * 4, 2, 3),
          Paint()..color = [Colors.blue, Colors.green, Colors.orange][col],
        );
      }
    }
    
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y + 25, 4, 1),
      Paint()..color = Colors.black,
    );
    
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(x - 4 + i * 2.5, y + 30),
        1,
        Paint()..color = Colors.grey.shade400,
      );
    }
    
    canvas.drawRect(
      Rect.fromLTWH(x - 4, y + 35, 8, 3),
      Paint()..color = Colors.black,
    );
  }

  static void _drawDrainGrates(Canvas canvas, Size size, double shift, double y) {
    final drainSpacing = 180.0;
    
    // Calculate starting position to ensure drains enter from right
    final startX = ((shift / drainSpacing).floor() - 4) * drainSpacing;
    final endX = size.width + 400; // Larger buffer
    
    // Draw drains in a continuous line
    for (double baseX = startX; baseX < startX + endX + 800; baseX += drainSpacing) {
      final x = baseX + shift;
      
      // Much larger visibility buffer
      if (x > -100 && x < size.width + 100) {
        // Drain grate frame
        canvas.drawRect(
          Rect.fromLTWH(x - 8, y + 8, 16.0, 8.0),
          Paint()..color = Colors.grey.shade800,
        );
        
        // Drain grate bars
        for (int i = 0; i < 5; i++) {
          canvas.drawRect(
            Rect.fromLTWH(x - 6 + i * 3.0, y + 9, 1.0, 6.0),
            Paint()..color = Colors.grey.shade600,
          );
        }
        
        canvas.drawRect(
          Rect.fromLTWH(x - 6, y + 11, 12.0, 1.0),
          Paint()..color = Colors.grey.shade600,
        );
        canvas.drawRect(
          Rect.fromLTWH(x - 6, y + 13, 12.0, 1.0),
          Paint()..color = Colors.grey.shade600,
        );
      }
    }
  }
}