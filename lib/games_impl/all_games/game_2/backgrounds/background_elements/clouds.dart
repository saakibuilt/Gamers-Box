import 'dart:math' as math;
import 'package:flutter/material.dart';

class CloudsPainter {
  static void draw(Canvas canvas, Size size, double progress) {
    final shift = -(progress * 6) % 1000; // Slow cloud movement
    
    // Multiple cloud layers for depth
    _drawCloudLayer(canvas, size, shift, 0.6, 0.15, 0.25); // Far clouds
    _drawCloudLayer(canvas, size, shift * 1.3, 0.8, 0.1, 0.35); // Mid clouds
    _drawCloudLayer(canvas, size, shift * 1.8, 1.0, 0.05, 0.45); // Near clouds
  }

  static void _drawCloudLayer(Canvas canvas, Size size, double shift, double alpha, double minHeight, double maxHeight) {
    final cloudPositions = [
      [80.0, size.height * minHeight + math.Random(80).nextDouble() * size.height * (maxHeight - minHeight), 45.0],
      [280.0, size.height * minHeight + math.Random(280).nextDouble() * size.height * (maxHeight - minHeight), 65.0],
      [480.0, size.height * minHeight + math.Random(480).nextDouble() * size.height * (maxHeight - minHeight), 55.0],
      [680.0, size.height * minHeight + math.Random(680).nextDouble() * size.height * (maxHeight - minHeight), 70.0],
      [880.0, size.height * minHeight + math.Random(880).nextDouble() * size.height * (maxHeight - minHeight), 50.0],
    ];
    
    final cloudSetWidth = 1000.0; // Total width of one complete cloud set
    
    // Calculate how many cloud sets we need to cover screen plus buffers
    final totalWidth = size.width + 400; // Screen width + buffer on both sides
    final numSets = (totalWidth / cloudSetWidth).ceil() + 2;
    
    for (int setIndex = 0; setIndex < numSets; setIndex++) {
      final setBaseX = setIndex * cloudSetWidth;
      
      for (final cloud in cloudPositions) {
        final cloudBaseX = setBaseX + cloud[0];
        final x = cloudBaseX + shift;
        final y = cloud[1];
        final cloudSize = cloud[2];
        
        // Draw cloud if it's visible on screen (with buffer)
        if (x > -cloudSize * 3 && x < size.width + cloudSize * 3) {
          _drawRealisticCloud(canvas, x, y, cloudSize, alpha);
        }
      }
    }
  }

  static void _drawRealisticCloud(Canvas canvas, double x, double y, double size, double alpha) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final shadowPaint = Paint()
      ..color = const Color(0xffE0E0E0).withValues(alpha: alpha * 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    // Main cloud body with multiple overlapping circles for realistic shape
    final cloudParts = [
      [0.0, 0.0, 1.0], // Center
      [-0.4, 0.1, 0.8], // Left
      [0.4, 0.1, 0.7], // Right
      [-0.2, -0.3, 0.6], // Top left
      [0.2, -0.2, 0.5], // Top right
      [-0.6, 0.3, 0.4], // Far left
      [0.6, 0.2, 0.4], // Far right
      [0.0, -0.4, 0.3], // Top center
    ];
    
    // Draw cloud shadow first
    for (final part in cloudParts) {
      canvas.drawCircle(
        Offset(x + part[0] * size + 2, y + part[1] * size + 2),
        size * part[2] * 0.5,
        shadowPaint,
      );
    }
    
    // Draw main cloud
    for (final part in cloudParts) {
      canvas.drawCircle(
        Offset(x + part[0] * size, y + part[1] * size),
        size * part[2] * 0.5,
        cloudPaint,
      );
    }
    
    // Add highlight on top of cloud
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    
    canvas.drawCircle(
      Offset(x - size * 0.1, y - size * 0.2),
      size * 0.3,
      highlightPaint,
    );
  }
}