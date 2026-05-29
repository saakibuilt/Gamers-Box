import 'package:flutter/material.dart';

class SkyPainter {
  static void draw(Canvas canvas, Size size, int level) {
    if (level == 1) {
      _drawDaytimeSky(canvas, size);
    } else {
      _drawSunsetSky(canvas, size);
    }
  }

  static void _drawDaytimeSky(Canvas canvas, Size size) {
    // Realistic daytime sky gradient
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xff4A90E2), // Deep sky blue
        const Color(0xff7BB3F0), // Medium sky blue
        const Color(0xffA8D5F2), // Light sky blue
        const Color(0xffE6F3FF), // Very light blue near horizon
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
    
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = skyGradient.createShader(Offset.zero & size),
    );
    
    // Add subtle sun glow effect
    _drawSunGlow(canvas, size);
  }

  static void _drawSunsetSky(Canvas canvas, Size size) {
    // Realistic sunset/evening sky
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xff1a1a2e), // Deep purple night
        const Color(0xff16213e), // Dark blue
        const Color(0xff0f3460), // Navy blue
        const Color(0xff533483), // Purple
        const Color(0xff7209b7), // Magenta
        const Color(0xffff6b35), // Orange
        const Color(0xffffa726), // Light orange
      ],
      stops: const [0.0, 0.15, 0.3, 0.5, 0.7, 0.85, 1.0],
    );
    
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = skyGradient.createShader(Offset.zero & size),
    );
    
    // Add sunset glow on horizon
    _drawSunsetGlow(canvas, size);
  }

  static void _drawSunGlow(Canvas canvas, Size size) {
    // Position sun in upper right area
    final sunCenter = Offset(size.width * 0.75, size.height * 0.25);
    
    canvas.drawCircle(
      sunCenter,
      80,
      Paint()
        ..color = Colors.yellow.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    
    canvas.drawCircle(
      sunCenter,
      40,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  static void _drawSunsetGlow(Canvas canvas, Size size) {
    // Horizon glow effect
    final horizonY = size.height * 0.65;
    
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 1.2,
        colors: [
          Colors.orange.withValues(alpha: 0.4),
          Colors.pink.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY));
    
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
      glowPaint,
    );
  }
}