//
// Additional enemy types for the game - flying enemies, spikes, etc.

import 'dart:math' as math;
import 'package:flutter/material.dart';

// Base class for all enemy types
abstract class Enemy {
  const Enemy({
    required this.rect,
    required this.type,
  });
  
  final Rect rect;
  final EnemyType type;
  
  // Each enemy type can define its own drawing method
  void draw(Canvas canvas, Paint paint);
}

enum EnemyType {
  basic,     // The red rectangles you already have
  missile,   // Missiles flying from right to left
  spinningSword, // Spinning swords flying across
  fireball,  // Fireballs with particle trails
  drone, spinner,     // Tech drones with rotating blades
}

// Missile enemy flying from right to left
class MissileEnemy extends Enemy {
  const MissileEnemy({
    required super.rect,
    required this.speed,
  }) : super(type: EnemyType.missile);
  
  final double speed; // Horizontal movement speed
  
  @override
  void draw(Canvas canvas, Paint paint) {
    final originalColor = paint.color;
    
    // Main missile body (dark gray)
    paint.color = const Color(0xff2c3e50);
    final bodyRect = Rect.fromLTWH(
      rect.left + rect.width * 0.2,
      rect.top + rect.height * 0.3,
      rect.width * 0.6,
      rect.height * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      paint,
    );
    
    // Missile nose (red)
    paint.color = const Color(0xffe74c3c);
    final nosePath = Path();
    nosePath.moveTo(rect.left, rect.center.dy);
    nosePath.lineTo(bodyRect.left, bodyRect.top);
    nosePath.lineTo(bodyRect.left, bodyRect.bottom);
    nosePath.close();
    canvas.drawPath(nosePath, paint);
    
    paint.color = const Color(0xff34495e);
    final finWidth = rect.width * 0.15;
    canvas.drawRect(
      Rect.fromLTWH(bodyRect.right - finWidth, rect.top, finWidth, rect.height * 0.3),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(bodyRect.right - finWidth, rect.bottom - rect.height * 0.3, finWidth, rect.height * 0.3),
      paint,
    );
    
    final flamePaint = Paint()
      ..color = const Color(0xfff39c12)
      ..style = PaintingStyle.fill;
    
    final flameLength = rect.width * 0.4;
    final flamePath = Path();
    flamePath.moveTo(bodyRect.right, bodyRect.top + bodyRect.height * 0.3);
    flamePath.lineTo(bodyRect.right + flameLength * 0.7, bodyRect.center.dy);
    flamePath.lineTo(bodyRect.right, bodyRect.bottom - bodyRect.height * 0.3);
    flamePath.quadraticBezierTo(
      bodyRect.right + flameLength,
      bodyRect.center.dy,
      bodyRect.right,
      bodyRect.center.dy,
    );
    canvas.drawPath(flamePath, flamePaint);
    
    paint.color = originalColor;
  }
}

// Spinning sword enemy
class SpinningSwordEnemy extends Enemy {
  const SpinningSwordEnemy({
    required super.rect,
    required this.rotation,
    required this.speed,
  }) : super(type: EnemyType.spinningSword);
  
  final double rotation; // Current rotation angle
  final double speed;    // Movement speed
  
  @override
  void draw(Canvas canvas, Paint paint) {
    final originalColor = paint.color;
    final center = rect.center;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    // Sword blade (silver)
    paint.color = const Color(0xffbdc3c7);
    final bladeLength = rect.width * 0.8;
    final bladeWidth = rect.width * 0.15;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: bladeWidth, height: bladeLength),
        const Radius.circular(2),
      ),
      paint,
    );
    
    final tipPath = Path();
    tipPath.moveTo(-bladeWidth/2, -bladeLength/2);
    tipPath.lineTo(0, -bladeLength/2 - bladeWidth);
    tipPath.lineTo(bladeWidth/2, -bladeLength/2);
    canvas.drawPath(tipPath, paint);
    
    // Sword hilt (brown)
    paint.color = const Color(0xff8b4513);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, bladeLength/2 + bladeWidth), width: bladeWidth * 1.5, height: bladeWidth * 2),
        const Radius.circular(3),
      ),
      paint,
    );
    
    // Sword guard (gold)
    paint.color = const Color(0xfff1c40f);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(0, bladeLength/2), width: bladeWidth * 2.5, height: bladeWidth * 0.5),
      paint,
    );
    
    canvas.restore();
    paint.color = originalColor;
  }
}

// Fireball enemy with particle trail
class FireballEnemy extends Enemy {
  const FireballEnemy({
    required super.rect,
    required this.particles,
    required this.intensity,
  }) : super(type: EnemyType.fireball);
  
  final List<Offset> particles; // Trail particles
  final double intensity;       // Fire animation intensity
  
  @override
  void draw(Canvas canvas, Paint paint) {
    final originalColor = paint.color;
    final center = rect.center;
    final radius = rect.width / 2;
    
    // Draw particle trail
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final opacity = (1.0 - i / particles.length) * 0.7;
      final particleSize = radius * (0.3 + (1.0 - i / particles.length) * 0.4);
      
      paint.color = Color.lerp(
        const Color(0xfff39c12),
        const Color(0xffe74c3c),
        i / particles.length,
      )!.withOpacity(opacity);
      
      canvas.drawCircle(particle, particleSize, paint);
    }
    
    // Main fireball core
    final gradient = RadialGradient(
      colors: [
        const Color(0xfffff700),
        const Color(0xffff6b00),
        const Color(0xffe74c3c),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    
    paint.color = const Color(0xffe74c3c);
    canvas.drawCircle(center, radius, paint);
    
    paint.color = const Color(0xffff6b00);
    canvas.drawCircle(center, radius * 0.7, paint);
    
    // Core
    paint.color = const Color(0xfffff700);
    canvas.drawCircle(center, radius * 0.4, paint);
    
    final flickerPaint = Paint()
      ..color = Colors.white.withOpacity(intensity * 0.3);
    canvas.drawCircle(center, radius * 0.2, flickerPaint);
    
    paint.color = originalColor;
  }
}

// Drone enemy with rotating blades
class DroneEnemy extends Enemy {
  const DroneEnemy({
    required super.rect,
    required this.bladeRotation,
    required this.hoverOffset,
  }) : super(type: EnemyType.drone);
  
  final double bladeRotation; // Propeller rotation
  final double hoverOffset;   // Vertical hover movement
  
  @override
  void draw(Canvas canvas, Paint paint) {
    final originalColor = paint.color;
    final center = rect.center.translate(0, hoverOffset);
    
    // Drone body (dark metal)
    paint.color = const Color(0xff34495e);
    final bodySize = rect.width * 0.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: bodySize, height: bodySize * 0.4),
        const Radius.circular(6),
      ),
      paint,
    );
    
    // Camera/sensor (red)
    paint.color = const Color(0xffe74c3c);
    canvas.drawCircle(
      Offset(center.dx - bodySize * 0.2, center.dy),
      bodySize * 0.08,
      paint,
    );
    
    // Draw 4 propellers
    final propellerPositions = [
      Offset(center.dx - bodySize * 0.4, center.dy - bodySize * 0.3),
      Offset(center.dx + bodySize * 0.4, center.dy - bodySize * 0.3),
      Offset(center.dx - bodySize * 0.4, center.dy + bodySize * 0.3),
      Offset(center.dx + bodySize * 0.4, center.dy + bodySize * 0.3),
    ];
    
    for (final propPos in propellerPositions) {
      paint.color = const Color(0xff2c3e50);
      canvas.drawCircle(propPos, bodySize * 0.06, paint);
      
      canvas.save();
      canvas.translate(propPos.dx, propPos.dy);
      canvas.rotate(bladeRotation);
      
      paint.color = const Color(0xff95a5a6).withOpacity(0.6);
      final bladeLength = bodySize * 0.25;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: bladeLength, height: bodySize * 0.02),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: bodySize * 0.02, height: bladeLength),
          const Radius.circular(1),
        ),
        paint,
      );
      
      canvas.restore();
    }
    
    paint.color = originalColor;
  }
}

// Factory class to create enemies
class EnemyFactory {
  static Enemy createEnemy({
    required EnemyType type,
    required Rect rect,
    required double gameTime,
    required math.Random random,
  }) {
    switch (type) {
      case EnemyType.missile:
        return MissileEnemy(
          rect: rect,
          speed: 300 + random.nextDouble() * 150, // Fast missiles: 300-450 px/s
        );
      
      case EnemyType.spinningSword:
        return SpinningSwordEnemy(
          rect: rect,
          rotation: gameTime * 8 + random.nextDouble() * math.pi * 2,
          speed: 220 + random.nextDouble() * 100, // Medium speed: 220-320 px/s
        );
      
      case EnemyType.fireball:
        // Generate particle trail
        final particles = <Offset>[];
        for (int i = 0; i < 8; i++) {
          particles.add(Offset(
            rect.center.dx + (i * 15) + random.nextDouble() * 10,
            rect.center.dy + (random.nextDouble() - 0.5) * 20,
          ));
        }
        return FireballEnemy(
          rect: rect,
          particles: particles,
          intensity: 0.5 + math.sin(gameTime * 6) * 0.5,
          // Fireball speed handled in game2_material.dart (250 px/s)
        );
      
      case EnemyType.drone:
        return DroneEnemy(
          rect: rect,
          bladeRotation: gameTime * 15, // Fast rotation
          hoverOffset: math.sin(gameTime * 4 + random.nextDouble() * math.pi) * 8,
          // Drone speed handled in game2_material.dart (180 px/s)
        );
      
      case EnemyType.basic:
      default:
        return BasicEnemy(rect: rect);
    }
  }
}

// Basic enemy class for compatibility
class BasicEnemy extends Enemy {
  const BasicEnemy({required super.rect}) : super(type: EnemyType.basic);
  
  @override
  void draw(Canvas canvas, Paint paint) {
    // This will be handled by the existing material painter
    final originalColor = paint.color;
    paint.color = const Color(0xffe74c3c); // Red
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
    paint.color = originalColor;
  }
}