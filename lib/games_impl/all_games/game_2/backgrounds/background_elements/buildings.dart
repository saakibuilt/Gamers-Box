import 'package:flutter/material.dart';

class BuildingsPainter {
  static void draw(Canvas canvas, Size size, double progress, int level) {
    final shift = -(progress * 25) % 1500;
    
    // Multiple building layers for parallax depth
    _drawBuildingLayer(canvas, size, shift * 0.2, 0.3, const Color(0xff6B7280), 80.0, level); // Far background
    _drawBuildingLayer(canvas, size, shift * 0.5, 0.6, const Color(0xff4B5563), 140.0, level); // Mid background
    _drawBuildingLayer(canvas, size, shift * 0.8, 0.9, const Color(0xff374151), 200.0, level); // Near background
    _drawBuildingLayer(canvas, size, shift, 1.0, const Color(0xff1F2937), 280.0, level); // Foreground
  }

  static void _drawBuildingLayer(Canvas canvas, Size size, double shift, double scale, Color baseColor, double maxHeight, int level) {
    // Realistic building data: [x, width, height, type, details]
    final buildings = [
      [0.0, 60.0, maxHeight * 0.4, 0], // Residential
      [70.0, 45.0, maxHeight * 0.6, 1], // Office
      [125.0, 80.0, maxHeight * 0.9, 2], // Skyscraper
      [215.0, 55.0, maxHeight * 0.5, 0], // Residential
      [280.0, 90.0, maxHeight * 1.0, 2], // Skyscraper
      [380.0, 40.0, maxHeight * 0.3, 1], // Office
      [430.0, 70.0, maxHeight * 0.7, 0], // Residential
      [510.0, 65.0, maxHeight * 0.8, 1], // Office
      [585.0, 100.0, maxHeight * 0.95, 2], // Skyscraper
      [695.0, 50.0, maxHeight * 0.45, 0], // Residential
      [755.0, 75.0, maxHeight * 0.75, 1], // Office
      [840.0, 85.0, maxHeight * 0.85, 2], // Skyscraper
    ];
    
    // Ensure buildings scroll endlessly - extend loop range
    for (int loop = -1; loop <= 2; loop++) {
      for (final building in buildings) {
        final x = building[0] + shift + (loop * 1500);
        final width = building[1] * scale;
        final height = building[2] * scale;
        final type = building[3].toInt();
        final y = size.height - height - 25;
        
        // Draw building if visible on screen (with larger buffer)
        if (x > -width * 2 && x < size.width + width * 2) {
          _drawRealisticBuilding(canvas, x, y, width, height, baseColor, scale, type, level);
        }
      }
    }
  }

  static void _drawRealisticBuilding(Canvas canvas, double x, double y, double width, double height, Color baseColor, double scale, int type, int level) {
    // Building shadow for depth
    if (scale >= 0.8) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x + 3, y + 3, width, height),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.25),
      );
    }
    
    // Main building structure
    final buildingRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(x, y, width, height),
      topLeft: Radius.circular(type == 2 ? 4 : 2), // Skyscrapers more rounded
      topRight: Radius.circular(type == 2 ? 4 : 2),
    );
    
    canvas.drawRRect(
      buildingRect,
      Paint()..color = baseColor.withValues(alpha: 0.8 + scale * 0.2),
    );
    
    // Building details based on scale and type
    if (scale >= 0.5) {
      _drawBuildingDetails(canvas, x, y, width, height, baseColor, scale, type, level);
    }
    
    // Rooftop elements for foreground buildings
    if (scale >= 0.9) {
      _drawRooftopDetails(canvas, x, y, width, type);
    }
  }

  static void _drawBuildingDetails(Canvas canvas, double x, double y, double width, double height, Color baseColor, double scale, int type, int level) {
    // Window patterns based on building type
    switch (type) {
      case 0: // Residential
        _drawResidentialWindows(canvas, x, y, width, height, scale, level);
        break;
      case 1: // Office
        _drawOfficeWindows(canvas, x, y, width, height, scale, level);
        break;
      case 2: // Skyscraper
        _drawSkyscraperWindows(canvas, x, y, width, height, scale, level);
        break;
    }
    
    // Building entrance for foreground buildings
    if (scale >= 0.8) {
      _drawBuildingEntrance(canvas, x, y, width, height, type);
    }
  }

  static void _drawResidentialWindows(Canvas canvas, double x, double y, double width, double height, double scale, int level) {
    final windowWidth = 6.0 * scale;
    final windowHeight = 8.0 * scale;
    final spacingX = 12.0 * scale;
    final spacingY = 15.0 * scale;
    
    final windowColor = level == 1 
        ? const Color(0xff3498DB).withValues(alpha: 0.7)
        : Colors.orange.withValues(alpha: 0.8);
    
    for (double wx = x + spacingX; wx < x + width - windowWidth; wx += spacingX) {
      for (double wy = y + spacingY; wy < y + height - spacingY; wy += spacingY) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(wx - 1, wy - 1, windowWidth + 2, windowHeight + 2),
            topLeft: const Radius.circular(1),
            topRight: const Radius.circular(1),
            bottomLeft: const Radius.circular(1),
            bottomRight: const Radius.circular(1),
          ),
          Paint()..color = Colors.grey.shade600,
        );
        
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(wx, wy, windowWidth, windowHeight),
            topLeft: const Radius.circular(1),
            topRight: const Radius.circular(1),
            bottomLeft: const Radius.circular(1),
            bottomRight: const Radius.circular(1),
          ),
          Paint()..color = windowColor,
        );
        
        // Window cross divider
        canvas.drawRect(
          Rect.fromLTWH(wx + windowWidth/2 - 0.5, wy, 1, windowHeight),
          Paint()..color = Colors.grey.shade700,
        );
      }
    }
  }

  static void _drawOfficeWindows(Canvas canvas, double x, double y, double width, double height, double scale, int level) {
    final windowWidth = 8.0 * scale;
    final windowHeight = 12.0 * scale;
    final spacingX = 10.0 * scale;
    final spacingY = 16.0 * scale;
    
    final windowColor = level == 1 
        ? const Color(0xff2980B9).withValues(alpha: 0.8)
        : Colors.orange.withValues(alpha: 0.9);
    
    for (double wx = x + spacingX * 0.5; wx < x + width - windowWidth; wx += spacingX) {
      for (double wy = y + spacingY; wy < y + height - spacingY; wy += spacingY) {
        canvas.drawRect(
          Rect.fromLTWH(wx, wy, windowWidth, windowHeight),
          Paint()..color = windowColor,
        );
        
        // Office window blinds effect
        for (double blind = wy + 2; blind < wy + windowHeight - 2; blind += 3) {
          canvas.drawRect(
            Rect.fromLTWH(wx + 1, blind, windowWidth - 2, 1),
            Paint()..color = Colors.white.withValues(alpha: 0.3),
          );
        }
      }
    }
  }

  static void _drawSkyscraperWindows(Canvas canvas, double x, double y, double width, double height, double scale, int level) {
    final windowWidth = 4.0 * scale;
    final windowHeight = 6.0 * scale;
    final spacingX = 6.0 * scale;
    final spacingY = 8.0 * scale;
    
    final windowColor = level == 1 
        ? const Color(0xff1E88E5).withValues(alpha: 0.9)
        : Colors.amber.withValues(alpha: 0.95);
    
    for (double wx = x + spacingX; wx < x + width - windowWidth; wx += spacingX) {
      for (double wy = y + spacingY; wy < y + height - spacingY; wy += spacingY) {
        canvas.drawRect(
          Rect.fromLTWH(wx, wy, windowWidth, windowHeight),
          Paint()..color = windowColor,
        );
      }
    }
  }

  static void _drawBuildingEntrance(Canvas canvas, double x, double y, double width, double height, int type) {
    final entranceWidth = width * 0.3;
    final entranceHeight = 25.0;
    final entranceX = x + (width - entranceWidth) * 0.5;
    final entranceY = y + height - entranceHeight;
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(entranceX, entranceY, entranceWidth, entranceHeight),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      Paint()..color = const Color(0xff8B4513),
    );
    
    canvas.drawCircle(
      Offset(entranceX + entranceWidth * 0.8, entranceY + entranceHeight * 0.5),
      1.5,
      Paint()..color = Colors.yellow.shade700,
    );
    
    if (type >= 1) {
      canvas.drawRect(
        Rect.fromLTWH(entranceX - 5, entranceY + entranceHeight, entranceWidth + 10, 3),
        Paint()..color = Colors.grey.shade500,
      );
    }
  }

  static void _drawRooftopDetails(Canvas canvas, double x, double y, double width, int type) {
    switch (type) {
      case 0: // Residential rooftop
        // Chimney
        canvas.drawRect(
          Rect.fromLTWH(x + width * 0.7, y - 12, 6, 12),
          Paint()..color = Colors.brown.shade600,
        );
        break;
        
      case 1: // Office rooftop
        // Air conditioning unit
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x + width * 0.3, y - 8, width * 0.4, 8),
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
          ),
          Paint()..color = Colors.grey.shade600,
        );
        break;
        
      case 2: // Skyscraper rooftop
        canvas.drawRect(
          Rect.fromLTWH(x + width * 0.5 - 1, y - 25, 2, 25),
          Paint()..color = Colors.grey.shade700,
        );
        
        // Helipad
        canvas.drawCircle(
          Offset(x + width * 0.3, y - 5),
          8,
          Paint()
            ..color = Colors.grey.shade500
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        break;
    }
  }
}