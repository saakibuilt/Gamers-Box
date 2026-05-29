//
// World slides in from the right during the first 2 s (warm-up); everything
// renders each frame. Now includes additional enemy types from enemies.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'enemy/enemies.dart'; // ← Import the new enemies

class PlatformInfo { const PlatformInfo(this.rect); final Rect rect; }
class PointInfo    { const PointInfo(this.id, this.center); final int id; final Offset center; }
class EnemyInfo    { const EnemyInfo(this.rect); final Rect rect; }
class GapInfo      { const GapInfo(this.rect); final Rect rect; }

// ← FIXED: Enhanced enemy info that includes movement data AND speed
class EnhancedEnemyInfo {
  const EnhancedEnemyInfo({
    required this.enemy,
    required this.spawnTime,
    required this.speed, // ← ADDED: Store the actual speed
  });
  final Enemy enemy;
  final double spawnTime; // When this enemy was spawned
  final double speed;     // ← ADDED: The actual movement speed for this enemy
}

class WorldObjects {
  const WorldObjects({
    required this.platforms,
    required this.points,
    required this.enemies,
    required this.gaps,
    required this.enhancedEnemies,
  });
  final List<PlatformInfo> platforms;
  final List<PointInfo>    points;
  final List<EnemyInfo>    enemies;      // Keep for backward compatibility
  final List<GapInfo>      gaps;
  final List<EnhancedEnemyInfo> enhancedEnemies;
}

class Game2Material extends StatelessWidget {
  const Game2Material({
    super.key,
    required this.progress,
    required this.collected,
    required this.currentSpeed,
  });

  final double   progress;            // scroll units
  final Set<int> collected;           // point-IDs already taken
  final double   currentSpeed;        // current game speed

  static const double unitPx      = 120.0;
  static const double chunkW      = 600.0;
  static const double groundH     = 10.0;
  static const double safeSpawnPx = chunkW; // delay first obstacles ≈1 chunk

  static WorldObjects objects({
    required double scrollPx,
    required Size   screen,
    required double currentSpeed,
  }) {
    final plats = <PlatformInfo>[];
    final pts   = <PointInfo>[];
    final ens   = <EnemyInfo>[];
    final gaps  = <GapInfo>[];
    final enhancedEnemies = <EnhancedEnemyInfo>[];

    final maxJump       = screen.height * 0.575;
    final first         = -scrollPx % chunkW - chunkW;     // keeps world aligned
    final allowObstacle = scrollPx > safeSpawnPx;
    final gameTime      = scrollPx / unitPx; // Convert to time units

    // ← FIXED: Add all previously spawned enemies that are still active
    if (allowObstacle) {
      // Check all possible spawn times in the past and add active enemies
      final currentTime = gameTime;
      final spawnInterval = 2.5;
      
      // Look back about 15 seconds to catch enemies that might still be on screen
      for (double checkTime = math.max(0, currentTime - 15); checkTime <= currentTime; checkTime += spawnInterval) {
        final spawnTime = (checkTime / spawnInterval).floor() * spawnInterval;
        final rnd = math.Random((spawnTime * 1000).floor());
        final enemyTypeRoll = rnd.nextDouble();
        
        EnemyType enemyType;
        const enemyWidth = 40.0;
        const enemyHeight = 25.0;
        final enemyX = screen.width + 50;
        final enemyY = screen.height - 50 - (rnd.nextInt(4) + 1) * 80;
        
        // ← Progressive enemy types based on current game speed
        if (currentSpeed < 2.0) {
          enemyType = EnemyType.missile; // Only missiles when speed < 2
        } else if (currentSpeed < 3.0) {
          // 3 enemy types when speed >= 2 but < 3
          if (enemyTypeRoll < 0.33) {
            enemyType = EnemyType.missile;
          } else if (enemyTypeRoll < 0.66) {
            enemyType = EnemyType.spinningSword;
          } else {
            enemyType = EnemyType.fireball;
          }
        } else {
          // All 4 enemy types when speed >= 3
          if (enemyTypeRoll < 0.25) {
            enemyType = EnemyType.missile;
          } else if (enemyTypeRoll < 0.50) {
            enemyType = EnemyType.spinningSword;
          } else if (enemyTypeRoll < 0.75) {
            enemyType = EnemyType.fireball;
          } else {
            enemyType = EnemyType.drone;
          }
        }
        
        final enemyRect = Rect.fromLTWH(enemyX, enemyY, enemyWidth, enemyHeight);
        final enemy = EnemyFactory.createEnemy(
          type: enemyType,
          rect: enemyRect,
          gameTime: spawnTime,
          random: rnd,
        );
        
        // ← FIXED: Calculate speed exactly the same way as EnemyFactory
        double actualSpeed;
        switch (enemyType) {
          case EnemyType.missile:
            actualSpeed = 300 + rnd.nextDouble() * 150; // 300-450 px/s
            break;
          case EnemyType.spinningSword:
            actualSpeed = 220 + rnd.nextDouble() * 100; // 220-320 px/s
            break;
          case EnemyType.fireball:
            actualSpeed = 250.0; // Fixed speed for fireballs
            break;
          case EnemyType.drone:
            actualSpeed = 180.0; // Fixed speed for drones
            break;
          case EnemyType.basic:
          default:
            actualSpeed = 300.0; // Default speed
            break;
        }
        
        // ← FIXED: Store both enemy and its actual speed
        enhancedEnemies.add(EnhancedEnemyInfo(
          enemy: enemy,
          spawnTime: spawnTime,
          speed: actualSpeed,
        ));
      }
    }

    for (double left = first;
         left < screen.width + chunkW * 2;                 // overscan right side
         left += chunkW) {
      final idx = ((scrollPx + left) / chunkW).floor();
      final rnd = math.Random(idx * 91121);
      final gy  = screen.height - groundH;

      // --- platforms -------------------------------------------------------
      for (int i = 0; i < rnd.nextInt(3) + 1; i++) {
        final w  = 70 + rnd.nextDouble() * 90;
        final px = left + rnd.nextDouble() * (chunkW - w);
        final py = gy - (rnd.nextInt(3) + 2) * 80;
        if (gy - py <= maxJump) {
          plats.add(PlatformInfo(Rect.fromLTWH(px, py, w, 12)));
        }
      }

      // --- enemies & gaps --------------------------------------------------
      if (allowObstacle) {
        // Original basic enemies (keep for compatibility)
        final enemyRoll = rnd.nextDouble();
        if (idx > 0 && enemyRoll < 0.15) { // ← Reduced chance since we're adding more enemy types
          const w = 26.0, h = 44.0;
          final ex = left + rnd.nextDouble() * (chunkW - w);
          ens.add(EnemyInfo(Rect.fromLTWH(ex, gy - h, w, h)));
        }

        // Gaps
        final gapRoll = rnd.nextDouble();
        if (idx > 0 && gapRoll < 0.30) {
          final dw = 100 + rnd.nextDouble() * 140;
          final dx = left + rnd.nextDouble() * (chunkW - dw);
          gaps.add(GapInfo(Rect.fromLTWH(dx, gy, dw, groundH * 4)));
        }
      }

      // --- points ----------------------------------------------------------
      final count = rnd.nextInt(6) + 4;
      for (int i = 0; i < count; i++) {
        final cx = left + rnd.nextDouble() * (chunkW - 14) + 7;
        final cy = gy   - (rnd.nextInt(4) + 2) * 60 - rnd.nextDouble() * 50;
        final id = (idx << 8) | i;
        pts.add(PointInfo(id, Offset(cx, cy)));
      }
    }

    return WorldObjects(
      platforms: plats,
      points:    pts,
      enemies:   ens,
      gaps:      gaps,
      enhancedEnemies: enhancedEnemies,
    );
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _MaterialPainter(progress, collected, currentSpeed));
}

class _MaterialPainter extends CustomPainter {
  const _MaterialPainter(this.v, this.collected, this.currentSpeed);
  final double   v;              // scroll units (≈ seconds when speed ≈ 1)
  final Set<int> collected;
  final double   currentSpeed;   // current game speed

  @override
  void paint(Canvas c, Size s) {
    if (v < 3) return;

    final world = Game2Material.objects(
      scrollPx: v * Game2Material.unitPx,
      screen  : s,
      currentSpeed: currentSpeed,
    );

    final platP  = Paint()..color = const Color(0xffffffff);
    final enemyP = Paint()..color = const Color(0xffe74c3c);
    final gapP   = Paint()..color = Colors.black;
    final starP  = Paint()..color = const Color(0xffffd600);

    for (final p in world.platforms) {
      c.drawRRect(RRect.fromRectAndRadius(p.rect, const Radius.circular(4)), platP);
    }
    
    // Draw original enemies (for backward compatibility)
    for (final e in world.enemies) {
      c.drawRRect(RRect.fromRectAndRadius(e.rect, const Radius.circular(6)), enemyP);
    }
    
    // ← FIXED: Draw enhanced enemies using stored speeds
    for (final enhancedEnemy in world.enhancedEnemies) {
      final enemy = enhancedEnemy.enemy;
      final currentTime = v;
      final timeSinceSpawn = currentTime - enhancedEnemy.spawnTime;
      
      // ← FIXED: Use the stored speed instead of calculating it again
      final enemySpeed = enhancedEnemy.speed;
      
      // ← FIXED: Calculate position using the same formula as collision detection
      final finalX = enemy.rect.left - (enemySpeed * timeSinceSpawn);
      
      // Skip if moved too far left
      if (finalX < -100) continue;
      
      // ← FIXED: Create adjusted rect (this MUST match collision detection exactly)
      final adjustedRect = Rect.fromLTWH(
        finalX,
        enemy.rect.top,
        enemy.rect.width,
        enemy.rect.height,
      );
      
      // ← FIXED: Apply animation offsets that match collision detection
      var finalRect = adjustedRect;
      if (enemy.type == EnemyType.drone) {
        // ← FIXED: Hover animation must match collision detection exactly
        final hoverOffset = math.sin(timeSinceSpawn * 4) * 8;
        finalRect = adjustedRect.translate(0, hoverOffset);
      }
      
      // Draw based on enemy type with updated animations
      if (enemy is MissileEnemy) {
        final missile = MissileEnemy(rect: finalRect, speed: enemySpeed);
        missile.draw(c, enemyP);
      }
      else if (enemy is SpinningSwordEnemy) {
        final sword = SpinningSwordEnemy(
          rect: finalRect,
          rotation: timeSinceSpawn * 15, // Fast spinning
          speed: enemySpeed,
        );
        sword.draw(c, enemyP);
      }
      else if (enemy is FireballEnemy) {
        // Update particle trail
        final updatedParticles = <Offset>[];
        for (int i = 0; i < 8; i++) {
          updatedParticles.add(Offset(
            finalX + (i * 20), // Trail behind fireball
            finalRect.center.dy + (math.sin(timeSinceSpawn * 8 + i) * 4),
          ));
        }
        final fireball = FireballEnemy(
          rect: finalRect,
          particles: updatedParticles,
          intensity: 0.7 + math.sin(timeSinceSpawn * 10) * 0.3,
        );
        fireball.draw(c, enemyP);
      }
      else if (enemy is DroneEnemy) {
        final drone = DroneEnemy(
          rect: finalRect, // ← FIXED: Use finalRect which includes hover offset
          bladeRotation: timeSinceSpawn * 25, // Very fast blade rotation
          hoverOffset: 0, // ← FIXED: Set to 0 since offset already applied to rect
        );
        drone.draw(c, enemyP);
      }
      else {
        // Fallback basic enemy
        final basicEnemy = BasicEnemy(rect: finalRect);
        basicEnemy.draw(c, enemyP);
      }
    }
    
    for (final g in world.gaps) {
      c.drawRect(g.rect, gapP);
    }
    
    for (final pt in world.points) {
      if (collected.contains(pt.id)) continue;
      _drawStar(c, pt.center, starP);
    }
  }

  void _drawStar(Canvas c, Offset ctr, Paint p) {
    const rO = 8.0, rI = 4.0;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final ang = -math.pi / 2 + i * math.pi / 5;
      final r   = i.isEven ? rO : rI;
      final x   = ctr.dx + r * math.cos(ang);
      final y   = ctr.dy + r * math.sin(ang);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _MaterialPainter old) =>
      old.v != v || old.collected.length != collected.length || old.currentSpeed != currentSpeed;
}