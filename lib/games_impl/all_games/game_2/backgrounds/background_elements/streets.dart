import 'dart:math' as math;
import 'package:flutter/material.dart';

class StreetsPainter {
  static void draw(Canvas canvas, Size size, double progress, int level) {
    final shift = -(progress * 30); // Remove modulo - let it be continuous
    
    // Main street/road
    _drawMainStreet(canvas, size, shift, level);
    
    // Sidewalks
    _drawSidewalks(canvas, size, shift);
    
    _drawStreetElements(canvas, size, shift, level);
    
    _drawTrafficElements(canvas, size, shift, level);
  }

  static void _drawMainStreet(Canvas canvas, Size size, double shift, int level) {
    final streetY = size.height - 40;
    final streetHeight = 25.0;
    
    canvas.drawRect(
      Rect.fromLTWH(0, streetY, size.width, streetHeight),
      Paint()..color = level == 1 
          ? const Color(0xff2F2F2F) 
          : const Color(0xff1A1A1A),
    );
    
    // Street center line (dashed yellow)
    _drawCenterLine(canvas, size, streetY + streetHeight/2, shift);
    
    // Street edge lines (solid white)
    canvas.drawRect(
      Rect.fromLTWH(0, streetY, size.width, 1),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, streetY + streetHeight - 1, size.width, 1),
      Paint()..color = Colors.white,
    );
    
    // Asphalt texture/wear marks
    _drawAsphaltTexture(canvas, size, streetY, streetHeight, shift);
  }

  static void _drawCenterLine(Canvas canvas, Size size, double y, double shift) {
    final dashLength = 15.0;
    final gapLength = 10.0;
    final totalLength = dashLength + gapLength;
    
    // Calculate starting position to ensure dashes enter from right
    final startX = ((shift / totalLength).floor() - 5) * totalLength;
    final endX = size.width + 200;
    
    // Draw dashes in a continuous line with larger buffer
    for (double baseX = startX; baseX < startX + endX + 400; baseX += totalLength) {
      final x = baseX + shift;
      
      if (x > -dashLength * 2 && x < size.width + dashLength * 2) {
        canvas.drawRect(
          Rect.fromLTWH(x, y - 1, dashLength, 2.0),
          Paint()..color = Colors.yellow.shade600,
        );
      }
    }
  }

  static void _drawAsphaltTexture(Canvas canvas, Size size, double streetY, double streetHeight, double shift) {
    // Random cracks and wear patterns with fixed positions
    final crackSpacing = 50.0;
    final startX = ((shift / crackSpacing).floor() - 5) * crackSpacing;
    final endX = size.width + 200;
    
    // Draw cracks in continuous line
    for (double baseX = startX; baseX < startX + endX + 400; baseX += crackSpacing) {
      final random = math.Random(12345 + (baseX / crackSpacing).floor()); // Fixed seed per crack
      final x = baseX + shift + random.nextDouble() * 30;
      final y = streetY + random.nextDouble() * streetHeight;
      final length = 20 + random.nextDouble() * 40;
      
      if (x > -100 && x < size.width + 100) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, length, 0.5),
          Paint()..color = Colors.grey.shade800.withValues(alpha: 0.6),
        );
      }
    }
    
    // Tire marks with continuous positioning
    final tireSpacing = 80.0;
    final tireStartX = ((shift / tireSpacing).floor() - 3) * tireSpacing;
    
    for (double baseX = tireStartX; baseX < tireStartX + endX + 240; baseX += tireSpacing) {
      final x = baseX + shift;
      
      if (x > -40 && x < size.width + 40) {
        canvas.drawRect(
          Rect.fromLTWH(x, streetY + 8, 2.0, streetHeight - 16),
          Paint()..color = Colors.black.withValues(alpha: 0.3),
        );
        canvas.drawRect(
          Rect.fromLTWH(x + 15, streetY + 8, 2.0, streetHeight - 16),
          Paint()..color = Colors.black.withValues(alpha: 0.3),
        );
      }
    }
  }

  static void _drawSidewalks(Canvas canvas, Size size, double shift) {
    final streetY = size.height - 40;
    final sidewalkHeight = 8.0;
    
    canvas.drawRect(
      Rect.fromLTWH(0, streetY - sidewalkHeight, size.width, sidewalkHeight),
      Paint()..color = const Color(0xffC0C0C0), // Light gray concrete
    );
    
    // Lower sidewalk (player running area)
    canvas.drawRect(
      Rect.fromLTWH(0, streetY + 25, size.width, sidewalkHeight),
      Paint()..color = const Color(0xffC0C0C0),
    );
    
    // Sidewalk texture (concrete panels)
    _drawSidewalkPanels(canvas, size, streetY - sidewalkHeight, shift);
    _drawSidewalkPanels(canvas, size, streetY + 25, shift);
    
    // Curb
    canvas.drawRect(
      Rect.fromLTWH(0, streetY - 2, size.width, 2.0),
      Paint()..color = Colors.grey.shade600,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, streetY + 25, size.width, 2.0),
      Paint()..color = Colors.grey.shade600,
    );
  }

  static void _drawSidewalkPanels(Canvas canvas, Size size, double y, double shift) {
    final panelWidth = 60.0;
    
    // Calculate starting position to ensure panels enter from right
    final startX = ((shift / panelWidth).floor() - 5) * panelWidth;
    final endX = size.width + 300;
    
    // Draw panels in a continuous line with larger buffer
    for (double baseX = startX; baseX < startX + endX + 600; baseX += panelWidth) {
      final x = baseX + shift;
      
      if (x > -panelWidth * 2 && x < size.width + panelWidth * 2) {
        // Panel separation lines
        canvas.drawRect(
          Rect.fromLTWH(x + panelWidth - 1, y, 1.0, 8.0),
          Paint()..color = Colors.grey.shade500,
        );
        
        // Panel texture dots
        for (int dot = 0; dot < 3; dot++) {
          canvas.drawCircle(
            Offset(x + 15 + dot * 15.0, y + 4),
            0.5,
            Paint()..color = Colors.grey.shade400,
          );
        }
      }
    }
  }

  static void _drawStreetElements(Canvas canvas, Size size, double shift, int level) {
    final elementSpacing = 150.0;
    
    // Calculate starting position to ensure elements enter from right
    final startX = ((shift / elementSpacing).floor() - 5) * elementSpacing;
    final endX = size.width + 600;
    
    // Draw elements in a continuous line
    for (double baseX = startX; baseX < startX + endX + 1200; baseX += elementSpacing) {
      final x = baseX + shift;
      
      // Larger buffer zone to prevent hiding
      if (x > -300 && x < size.width + 300) {
        final elementIndex = (baseX / elementSpacing).abs().floor();
        final elementType = elementIndex % 4;
        final frontY = size.height - 15;
        
        switch (elementType) {
          case 0:
            _drawStreetLight(canvas, x, frontY - 33, level);
            break;
          case 1:
            _drawFireHydrant(canvas, x + 20, frontY - 25);
            break;
          case 2:
            _drawTrashCan(canvas, x + 40, frontY - 30);
            break;
          case 3:
            _drawBusStop(canvas, x + 60, frontY - 40);
            break;
        }
      }
    }
    
    // Manholes in the street
    _drawManholes(canvas, size, shift);
  }

  static void _drawStreetLight(Canvas canvas, double x, double y, int level) {
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y - 35, 4.0, 35.0),
      Paint()..color = Colors.grey.shade700,
    );
    
    canvas.drawRect(
      Rect.fromLTWH(x - 4, y - 3, 8.0, 3.0),
      Paint()..color = Colors.grey.shade800,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 6, y - 45, 12.0, 8.0),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = Colors.grey.shade600,
    );
    
    // Light glow (more intense for night level)
    if (level == 2) {
      canvas.drawCircle(
        Offset(x, y - 41),
        15.0,
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    
    canvas.drawCircle(
      Offset(x, y - 41),
      4.0,
      Paint()..color = level == 1 
          ? Colors.yellow.withValues(alpha: 0.6)
          : Colors.yellow.withValues(alpha: 0.9),
    );
  }

  static void _drawFireHydrant(Canvas canvas, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 4, y - 15, 8.0, 15.0),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ),
      Paint()..color = Colors.red.shade700,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 5, y - 18, 10.0, 3.0),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      ),
      Paint()..color = Colors.red.shade800,
    );
    
    canvas.drawRect(
      Rect.fromLTWH(x - 8, y - 12, 3.0, 3.0),
      Paint()..color = Colors.red.shade600,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + 5, y - 12, 3.0, 3.0),
      Paint()..color = Colors.red.shade600,
    );
    
    // Yellow safety stripe
    canvas.drawRect(
      Rect.fromLTWH(x - 4, y - 10, 8.0, 2.0),
      Paint()..color = Colors.yellow.shade600,
    );
  }

  static void _drawTrashCan(Canvas canvas, double x, double y) {
    // Trash can body
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 5, y - 18, 10.0, 18.0),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      Paint()..color = Colors.green.shade700,
    );
    
    // Trash can lid
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 6, y - 22, 12.0, 4.0),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = Colors.green.shade800,
    );
    
    // Handle
    canvas.drawRect(
      Rect.fromLTWH(x - 1, y - 24, 2.0, 2.0),
      Paint()..color = Colors.grey.shade600,
    );
    
    canvas.drawCircle(
      Offset(x, y - 10),
      3.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  static void _drawBusStop(Canvas canvas, double x, double y) {
    // Bus stop pole
    canvas.drawRect(
      Rect.fromLTWH(x - 1, y - 25, 2.0, 25.0),
      Paint()..color = Colors.grey.shade700,
    );
    
    // Bus stop sign
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x + 2, y - 30, 20.0, 12.0),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      ),
      Paint()..color = Colors.blue.shade600,
    );
    
    // "BUS" text simulation with white rectangles
    canvas.drawRect(Rect.fromLTWH(x + 4, y - 28, 2.0, 6.0), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 4, y - 26, 3.0, 1.0), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 4, y - 24, 3.0, 1.0), Paint()..color = Colors.white);
    
    canvas.drawRect(Rect.fromLTWH(x + 9, y - 28, 2.0, 6.0), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 9, y - 25, 3.0, 1.0), Paint()..color = Colors.white);
    
    canvas.drawRect(Rect.fromLTWH(x + 14, y - 28, 3.0, 1.0), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 14, y - 26, 2.0, 1.0), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 14, y - 24, 3.0, 1.0), Paint()..color = Colors.white);
    
    canvas.drawRect(
      Rect.fromLTWH(x + 25, y - 8, 15.0, 3.0),
      Paint()..color = Colors.brown.shade600,
    );
    canvas.drawRect(Rect.fromLTWH(x + 27, y - 5, 2.0, 5.0), Paint()..color = Colors.grey.shade600);
    canvas.drawRect(Rect.fromLTWH(x + 36, y - 5, 2.0, 5.0), Paint()..color = Colors.grey.shade600);
  }

  static void _drawManholes(Canvas canvas, Size size, double shift) {
    final manholeSpacing = 200.0;
    final streetY = size.height - 27;
    
    // Calculate starting position to ensure manholes enter from right
    final startX = ((shift / manholeSpacing).floor() - 4) * manholeSpacing;
    final endX = size.width + 400;
    
    // Draw manholes in a continuous line
    for (double baseX = startX; baseX < startX + endX + 800; baseX += manholeSpacing) {
      final x = baseX + shift;
      
      // Larger buffer zone
      if (x > -100 && x < size.width + 100) {
        canvas.drawCircle(
          Offset(x, streetY),
          12.0,
          Paint()..color = Colors.grey.shade800,
        );
        
        // Manhole pattern rings
        for (double radius in [12.0, 8.0, 4.0]) {
          canvas.drawCircle(
            Offset(x, streetY),
            radius,
            Paint()
              ..color = Colors.grey.shade600
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
        }
        
        // Dots pattern around manhole
        for (int j = 0; j < 8; j++) {
          final angle = j * math.pi / 4;
          canvas.drawCircle(
            Offset(x + 6 * math.cos(angle), streetY + 6 * math.sin(angle)),
            1.0,
            Paint()..color = Colors.grey.shade500,
          );
        }
      }
    }
  }

  static void _drawTrafficElements(Canvas canvas, Size size, double shift, int level) {
    final coneSpacing = 300.0;
    final startX = ((shift / coneSpacing).floor() - 2) * coneSpacing;
    final endX = size.width + 300;
    
    // Draw cones in a continuous line
    for (double baseX = startX; baseX < startX + endX + 600; baseX += coneSpacing) {
      final x = baseX + shift;
      
      if (x > -100 && x < size.width + 100) {
        // Place cone every third position for spacing
        final coneIndex = (baseX / coneSpacing).abs().floor();
        if (coneIndex % 3 == 0) {
          _drawTrafficCone(canvas, x + 50, size.height - 20);
        }
      }
    }
    
    final crosswalkSpacing = 400.0;
    final crosswalkStartX = ((shift / crosswalkSpacing).floor() - 2) * crosswalkSpacing;
    
    // Draw crosswalks in a continuous line
    for (double baseX = crosswalkStartX; baseX < crosswalkStartX + endX + 800; baseX += crosswalkSpacing) {
      final x = baseX + shift;
      
      if (x > -100 && x < size.width + 100) {
        // Place crosswalk every other position
        final crosswalkIndex = (baseX / crosswalkSpacing).abs().floor();
        if (crosswalkIndex % 2 == 0) {
          _drawCrosswalk(canvas, x, size.height - 40);
        }
      }
    }
  }

  static void _drawTrafficCone(Canvas canvas, double x, double y) {
    canvas.drawCircle(
      Offset(x, y),
      6.0,
      Paint()..color = Colors.black,
    );
    
    final conePath = Path()
      ..moveTo(x, y - 15)
      ..lineTo(x - 5, y)
      ..lineTo(x + 5, y)
      ..close();
    
    canvas.drawPath(conePath, Paint()..color = Colors.orange.shade600);
    
    canvas.drawRect(
      Rect.fromLTWH(x - 4, y - 12, 8.0, 2.0),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(x - 3, y - 8, 6.0, 1.0),
      Paint()..color = Colors.white,
    );
  }

  static void _drawCrosswalk(Canvas canvas, double x, double y) {
    final stripeWidth = 8.0;
    final stripeSpacing = 12.0;
    
    for (int i = 0; i < 6; i++) {
      canvas.drawRect(
        Rect.fromLTWH(x + i * stripeSpacing, y, stripeWidth, 25.0),
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }
}