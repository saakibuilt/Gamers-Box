//
// Slide-support v4: sideways "bed-pose" — one arm extended above head,
// right leg straight, left leg bent with foot on ground.
// Added running pose when speed > 1.5
// Added retry functionality with invincibility

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'materials/game2_material.dart';
import 'materials/enemy/enemies.dart';

class Game2Character extends StatefulWidget {
  final double             speed;
  final bool               gameStart;
  final Set<int>           collectedIds;
  final void Function(int)  onScore;
  final VoidCallback        onGameOver;
  final double             scrollProgress;

  const Game2Character({
    super.key,
    required this.speed,
    required this.gameStart,
    required this.collectedIds,
    required this.onScore,
    required this.onGameOver,
    required this.scrollProgress,
  });

  @override
  State<Game2Character> createState() => Game2CharacterState();
}

class Game2CharacterState extends State<Game2Character>
    with SingleTickerProviderStateMixin {
  static const double _g = 2000;
  static const double _torsoL = 38, _headR = 9, _hitR = 24;

  static const double _slideDur = 0.6;
  bool   _sliding   = false;
  double _slideT    = 0;

  double _y = 0, _vy = 0;
  int _jumpCount = 0;
  bool _longDone = false;

  double _gait = 0;
  double _scrollUnits = 0;
  late final Ticker _ticker;
  Duration _prev = Duration.zero;

  // Retry functionality variables
  bool _isDead = false;
  bool _isInvincible = false;
  Timer? _invincibilityTimer;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_step)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _invincibilityTimer?.cancel(); // Clean up invincibility timer
    super.dispose();
  }

  /// Reset character state for retry functionality
  void resetForRetry() {
    if (!mounted) return;
    
    // Reset death state but maintain position and progress
    _isDead = false;
    
    // Set brief invincibility period after retry
    _setInvincible(1500); // 1.5 seconds of invincibility
    
    // Reset sliding state if active
    if (_sliding) {
      _sliding = false;
      _slideT = 0;
    }
    
    // Reset jump states
    _jumpCount = 0;
    _longDone = false;
    
    // Reset velocity if falling
    if (_vy < 0) {
      _vy = 0;
    }
    
    debugPrint('Character reset for retry - invincible for 1.5s');
  }

  /// Set temporary invincibility
  void _setInvincible(int milliseconds) {
    _isInvincible = true;
    _invincibilityTimer?.cancel();
    _invincibilityTimer = Timer(Duration(milliseconds: milliseconds), () {
      if (mounted) {
        _isInvincible = false;
        setState(() {});
      }
    });
  }

  /// Check if character is currently invincible
  bool get isInvincible => _isInvincible;

  void _step(Duration now) {
    if (!widget.gameStart) {
      _prev = now;
      return;
    }

    final dt = (_prev == Duration.zero)
        ? 0.016
        : (now - _prev).inMicroseconds / 1e6;
    _prev = now;

    if (_sliding) {
      _slideT += dt;
      if (_slideT >= _slideDur) {
        _sliding = false;
        _slideT  = 0;
      }
    }

    if (_sliding) {
      setState(() {});
      return;
    }

    _scrollUnits += widget.speed * dt;
    if (_vy == 0) _gait = (_gait + widget.speed * dt * 1.8) % 1;

    _vy -= _g * dt;
    _y  += _vy * dt;

    final size    = MediaQuery.of(context).size;
    final charX   = size.width / 2;
    final groundY = size.height - Game2Material.groundH;

    final objs = Game2Material.objects(
      scrollPx: widget.scrollProgress * Game2Material.unitPx,
      screen  : size, 
      currentSpeed: widget.speed,
    );

    // Check if materials are active to prevent invisible collisions
    final materialActive = widget.scrollProgress >= 3;

    bool overGap = false;
    if (materialActive) {
      for (final g in objs.gaps) {
        if (charX >= g.rect.left && charX <= g.rect.right) {
          overGap = true;
          break;
        }
      }
    }

    double supportY = overGap ? double.negativeInfinity : 0;
    bool onPlatform = false;
    if (materialActive) {
      for (final p in objs.platforms) {
        if (charX >= p.rect.left && charX <= p.rect.right) {
          final platY = groundY - p.rect.top;
          if (platY > supportY && (platY - _y) < 10) {
            supportY = platY;
            onPlatform = true;
          }
        }
      }
    }

    if (!onPlatform && !overGap && _y > 0) {
      if (_vy == 0) _vy = -50;
    }

    if (_vy <= 0 && _y <= supportY + 2) {
      _y = supportY;
      _vy = 0;
      _jumpCount = 0;
      _longDone  = false;
    }

    // Point collection with material check
    if (materialActive) {
      final foot  = Offset(charX, groundY - _y);
      final torso = Offset(charX, groundY - _y - _torsoL / 2);
      final head  = Offset(charX, groundY - _y - _torsoL - _headR);
      for (final pt in objs.points) {
        if (widget.collectedIds.contains(pt.id)) continue;
        final pc = pt.center;
        if ((foot - pc).distance  < _hitR ||
            (torso - pc).distance < _hitR ||
            (head  - pc).distance < _hitR) {
          widget.collectedIds.add(pt.id);
          widget.onScore(10);
        }
      }
    }
 
    // --- PRECISE ENEMY COLLISION DETECTION - 100% ACCURACY ---
    if (materialActive && !_isInvincible) { // Skip collision if invincible
      // Character collision rectangle - adjusted for different poses
      const double charHalfW = 12; // Slightly smaller for more precise collision
      double charTopY = groundY - _y - (_torsoL + _headR * 2);
      double charWidth = charHalfW * 2;
      double charHeight = (_torsoL + _headR * 2);
      
      // Adjust character hitbox for sliding pose
      if (_sliding) {
        charTopY = groundY - _y - 20; // Sliding character is lower
        charHeight = 20; // Sliding character is shorter
        charWidth = 35; // Sliding character is wider
      }
      
      final charRect = Rect.fromLTWH(
        charX - charWidth / 2,
        charTopY,
        charWidth,
        charHeight,
      );

      // Check collision with original enemies (backward compatibility)
      for (final e in objs.enemies) {
        if (charRect.overlaps(e.rect)) {
          _isDead = true;
          widget.onGameOver();
          return;
        }
      }
      
      // Check collision with enhanced enemies using stored speeds
      if (objs.enhancedEnemies.isNotEmpty) {
        for (final enhancedEnemy in objs.enhancedEnemies) {
          final enemy = enhancedEnemy.enemy;
          final currentTime = widget.scrollProgress;
          
          // Use the stored speed from the enhanced enemy
          final enemySpeed = enhancedEnemy.speed;
          final timeSinceSpawn = currentTime - enhancedEnemy.spawnTime;
          
          final currentX = enemy.rect.left - (enemySpeed * timeSinceSpawn);
          
          // Skip collision check if enemy is completely off-screen
          if (currentX < -enemy.rect.width || currentX > size.width + 50) {
            continue;
          }
          
          // Create precise enemy collision rectangle
          Rect enemyCollisionRect = Rect.fromLTWH(
            currentX,
            enemy.rect.top,
            enemy.rect.width,
            enemy.rect.height,
          );
          
          if (enemy.type == EnemyType.drone) {
            final hoverOffset = math.sin(timeSinceSpawn * 4) * 8;
            enemyCollisionRect = enemyCollisionRect.translate(0, hoverOffset);
          }
          // so no additional offsets needed
          
          if (charRect.overlaps(enemyCollisionRect)) {
            // Double-check with a small tolerance to avoid edge cases
            final overlapRect = charRect.intersect(enemyCollisionRect);
            
            // Only count as collision if there's meaningful overlap (not just edge touching)
            if (overlapRect.width > 1.0 && overlapRect.height > 1.0) {
              _isDead = true;
              widget.onGameOver();
              return;
            }
          }
        }
      }
    }
    // ----------------------------------------------------------------

    if (_y < 0) {
      _y = 0;
      _vy = 0;
      _jumpCount = 0;
      _longDone = false;
    }

    setState(() {});
  }

  bool _onSurface() => _vy == 0 && !_sliding;
  double _hSingle() => MediaQuery.of(context).size.height * 0.35;
  double _hDouble() => MediaQuery.of(context).size.height * 0.50;
  double _hLong()   => MediaQuery.of(context).size.height * 0.575;
  double _velFor(double h) => math.sqrt(2 * _g * h);

  void tap()       { if (widget.gameStart && !_sliding) _jumpNormal(); }
  void doubleTap() { if (widget.gameStart && !_sliding && _jumpCount == 1) _jumpNormal(); }
  void longPress() { if (widget.gameStart && !_sliding) _jumpLong(); }
  void slide()     { if (widget.gameStart && !_sliding && _onSurface()) _startSlide(); }

  void _startSlide() {
    _sliding = true;
    _slideT  = 0;
    _vy = 0;
    _jumpCount = 0;
    _longDone  = false;
    setState(() {});
  }

  void _jumpNormal() {
    if (_jumpCount == 0 && _onSurface()) {
      _vy = _velFor(_hSingle());
      _jumpCount = 1;
    } else if (_jumpCount == 1) {
      final need = _hDouble() - _y;
      if (need > 0) {
        _vy = _velFor(need);
        _jumpCount = 2;
      }
    }
  }

  void _jumpLong() {
    if (_jumpCount == 1 && !_longDone) {
      final need = _hLong() - _y;
      if (need > 0) _vy = _velFor(need);
      _longDone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final airborne = _vy != 0;
    final skyDive  = (_jumpCount >= 2) || _longDone;
    
    // Ensure _y is never negative to prevent padding assertion error
    final safeY = math.max(0.0, _y);
    
    return Padding(
      padding: EdgeInsets.only(bottom: safeY),
      child: SizedBox(
        width: 140,
        height: 90,
        child: CustomPaint(
          painter: _RunnerPainter(
            progress: _gait,
            airborne: airborne,
            skyDive:  skyDive,
            sliding:  _sliding,
            speed:    widget.speed,
            isInvincible: _isInvincible, // Pass invincibility state to painter
          ),
        ),
      ),
    );
  }
}

class _RunnerPainter extends CustomPainter {
  const _RunnerPainter({
    required this.progress,
    required this.airborne,
    required this.skyDive,
    required this.sliding,
    required this.speed,
    required this.isInvincible,
  });

  final double progress;
  final bool   airborne;
  final bool   skyDive;
  final bool   sliding;
  final double speed;
  final bool   isInvincible;

  static const headR = 9.0,
      torsoL = 38.0,
      thighL = 20.0,
      shinL = 15.0,
      uArmL = 15.0,
      lArmL = 14.0;

  static const hipSwing = math.pi / 6,
      kneeFront = math.pi / 12,
      kneeBack  = math.pi / 18,
      shSwing   = math.pi / 6,
      elSwing   = math.pi / 10;

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = isInvincible ? Colors.blue.withOpacity(0.7) : Colors.black // Visual feedback for invincibility
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    c.translate(s.width / 2, s.height);

    if (sliding) {
      _drawBedSlide(c, p);
      return;
    }

    final isRunning = speed > 1.5 && !airborne;

    if (isRunning) {
      _drawRunningPose(c, p);
    } else {
      c.drawLine(Offset.zero, const Offset(0, -torsoL), p);
      if (skyDive) {
        const neckAng = -math.pi / 2 - math.pi / 6;
        final neckLen = headR * 0.8;
        final neckStart = const Offset(0, -torsoL);
        final neckEnd   = neckStart +
            Offset(neckLen * math.cos(neckAng), neckLen * math.sin(neckAng));
        c.drawLine(neckStart, neckEnd, p);
        final headCenter = neckEnd +
            Offset(headR * math.cos(neckAng), headR * math.sin(neckAng));
        c.drawCircle(headCenter, headR, p);
      } else {
        c.drawCircle(const Offset(0, -torsoL - headR), headR, p);
      }

      final shoulders = const Offset(0, -torsoL + 4);

      if (!airborne) {
        _drawWalkPose(c, p, shoulders);
      } else if (skyDive) {
        _drawSkyPose(c, p, shoulders);
      } else {
        _drawJumpPose(c, p, shoulders);
      }
    }
  }

  void _drawRunningPose(Canvas c, Paint p) {
    final t = progress * 2 * math.pi;
    _runningLeg(c, p, t, 0);
    _runningLeg(c, p, t, math.pi);

    c.save();
    c.rotate(math.pi / 9);
    c.drawLine(Offset.zero, const Offset(0, -torsoL), p);
    c.drawCircle(const Offset(0, -torsoL - headR), headR, p);
    final shoulders = const Offset(0, -torsoL + 4);
    _runningArm(c, p, t, shoulders, math.pi);
    _runningArm(c, p, t, shoulders, 0);
    c.restore();
  }

  void _runningLeg(Canvas c, Paint p, double t, double phase) {
    final hip = math.pi / 2 + (hipSwing * 1.8) * math.sin(t + phase);
    final front = math.sin(t + phase) < 0;
    final bend = front ? (kneeFront * 2) : (kneeBack * 1.5);
    final knee = Offset(thighL * math.cos(hip), thighL * math.sin(hip));
    final foot = knee + Offset(shinL * math.cos(hip + bend), shinL * math.sin(hip + bend));
    c.drawLine(Offset.zero, knee, p);
    c.drawLine(knee, foot, p);
  }

  void _runningArm(Canvas c, Paint p, double t, Offset shoulder, double phase) {
    final shA = math.pi / 2 + (shSwing * 2) * math.sin(t + phase);
    final elA = shA + (elSwing * 1.5) * math.sin(t + phase);
    final elbow = shoulder + Offset(uArmL * math.cos(shA), uArmL * math.sin(shA));
    final hand  = elbow    + Offset(lArmL * math.cos(elA), lArmL * math.sin(elA));
    c.drawLine(shoulder, elbow, p);
    c.drawLine(elbow, hand, p);
  }

  void _drawBedSlide(Canvas c, Paint p) {
    c.save();
    c.rotate(-math.pi / 2);
    c.translate(-torsoL / 2, 0);

    final kneeR = Offset(0, thighL);
    final footR = kneeR + Offset(0, shinL);
    c.drawLine(Offset.zero, kneeR, p);
    c.drawLine(kneeR, footR, p);

    final kneeL = Offset(-thighL * -0.8, -thighL * -0.5);
    final footL = Offset(-shinL * -0.1, thighL + shinL);
    c.drawLine(Offset.zero, kneeL, p);
    c.drawLine(kneeL, footL, p);

    c.save();
    c.rotate(-math.pi / -9);
    c.drawLine(Offset.zero, Offset(0, -torsoL), p);
    c.drawCircle(Offset(0, -torsoL - headR), headR, p);

    final shoulder = Offset(0, -torsoL + 4);
    final hand     = Offset.zero;
    final elbow    = shoulder + Offset(-uArmL, uArmL * 0.5);
    c.drawLine(shoulder, elbow, p);
    c.drawLine(elbow, hand, p);

    c.restore();
    c.restore();
  }

  void _drawSkyPose(Canvas c, Paint p, Offset shoulders) {
    const leftArmA  = math.pi - math.pi / 2.6;
    const rightArmA = math.pi - math.pi / 4;
    const rightElbowB = math.pi / 18;
    const leftElbowB  = math.pi / -11 + math.pi / 36;
    _skyArm(c, p, shoulders, leftArmA,  leftElbowB);
    _skyArm(c, p, shoulders, rightArmA, rightElbowB);
    const leftThighA  = math.pi * 2 / 3;
    const rightThighA = math.pi * 2 / 3 + math.pi / 9;
    const kneeB = math.pi / 30;
    _skyLeg(c, p, leftThighA,  kneeB);
    _skyLeg(c, p, rightThighA, kneeB);
  }
  
  void _skyLeg(Canvas c, Paint p, double thighAng, double bend) {
    final knee = Offset(thighL * math.cos(thighAng), thighL * math.sin(thighAng));
    final foot = knee + Offset(shinL * math.cos(thighAng + bend), shinL * math.sin(thighAng + bend));
    c.drawLine(Offset.zero, knee, p);
    c.drawLine(knee, foot, p);
  }
  
  void _skyArm(Canvas c, Paint p, Offset shoulder, double shoulderAng, double elbowBend) {
    final elbow = shoulder + Offset(uArmL * math.cos(shoulderAng), uArmL * math.sin(shoulderAng));
    final hand  = elbow    + Offset(lArmL * math.cos(shoulderAng + elbowBend), lArmL * math.sin(shoulderAng + elbowBend));
    c.drawLine(shoulder, elbow, p);
    c.drawLine(elbow, hand, p);
  }

  void _drawJumpPose(Canvas c, Paint p, Offset shoulders) {
    final t = progress * 2 * math.pi;
    final leftLeading = math.sin(t) < 0;
    const forwardThigh = math.pi / 2 - math.pi / 4;
    const backThigh    = math.pi / 2 + math.pi / 4;
    const kneeFrontBend = math.pi / 2.2;
    const kneeBackBend  = math.pi / 15;
    const forwardArmA = -math.pi / 3;
    const backArmA    = math.pi / 2 + math.pi / 8;
    const elbowJump   = math.pi / 6;
    _jumpLeg(c, p, leftLeading ? forwardThigh : backThigh,
        leftLeading ? kneeFrontBend : kneeBackBend);
    _jumpArm(c, p, shoulders, leftLeading ? backArmA : forwardArmA, elbowJump);
    _jumpLeg(c, p, leftLeading ? backThigh : forwardThigh,
        leftLeading ? kneeBackBend : kneeFrontBend);
    _jumpArm(c, p, shoulders, leftLeading ? forwardArmA : backArmA, elbowJump);
  }

  void _drawWalkPose(Canvas c, Paint p, Offset shoulders) {
    final t = progress * 2 * math.pi;
    _leg(c, p, t, 0);
    _leg(c, p, t, math.pi);
    _arm(c, p, t, shoulders, math.pi);
    _arm(c, p, t, shoulders, 0);
  }

  void _jumpLeg(Canvas c, Paint p, double thighAng, double bend) {
    final knee = Offset(thighL * math.cos(thighAng), thighL * math.sin(thighAng));
    final foot = knee + Offset(shinL * math.cos(thighAng + bend), shinL * math.sin(thighAng + bend));
    c.drawLine(Offset.zero, knee, p);
    c.drawLine(knee, foot, p);
  }
  
  void _jumpArm(Canvas c, Paint p, Offset shoulder, double shoulderAng, double elbowBend) {
    final elbow = shoulder + Offset(uArmL * math.cos(shoulderAng), uArmL * math.sin(shoulderAng));
    final hand  = elbow    + Offset(lArmL * math.cos(shoulderAng + elbowBend), lArmL * math.sin(shoulderAng + elbowBend));
    c.drawLine(shoulder, elbow, p);
    c.drawLine(elbow, hand, p);
  }
  
  void _leg(Canvas c, Paint p, double t, double phase) {
    final hip = math.pi / 2 + hipSwing * math.sin(t + phase);
    final front = math.sin(t + phase) < 0;
    final bend = front ? kneeFront : kneeBack;
    final knee = Offset(thighL * math.cos(hip), thighL * math.sin(hip));
    final foot = knee + Offset(shinL * math.cos(hip + bend), shinL * math.sin(hip + bend));
    c.drawLine(Offset.zero, knee, p);
    c.drawLine(knee, foot, p);
  }
  
  void _arm(Canvas c, Paint p, double t, Offset shoulder, double phase) {
    final shA = math.pi / 2 + shSwing * math.sin(t + phase);
    final elA = shA + elSwing * math.sin(t + phase);
    final elbow = shoulder + Offset(uArmL * math.cos(shA), uArmL * math.sin(shA));
    final hand  = elbow    + Offset(lArmL * math.cos(elA), lArmL * math.sin(elA));
    c.drawLine(shoulder, elbow, p);
    c.drawLine(elbow, hand, p);
  }

  @override
  bool shouldRepaint(covariant _RunnerPainter old) =>
      old.progress != progress ||
      old.airborne != airborne ||
      old.skyDive != skyDive ||
      old.sliding != sliding ||
      old.speed != speed ||
      old.isInvincible != isInvincible; // Added invincibility state to repaint check
}