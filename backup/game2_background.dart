// lib/game2_background.dart

//working backup with basic generic background motion


import 'dart:math' as math;
import 'package:flutter/material.dart';

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
    if (level == 1) {
      _drawLevel1Background(canvas, size);
    } else {
      _drawLevel2Background(canvas, size);
    }
    _drawGround(canvas, size);
  }

  void _drawLevel1Background(Canvas canvas, Size size) {
    // Daytime sky gradient
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xff87CEEB), // Sky blue
        const Color(0xffB0E0E6), // Powder blue
        const Color(0xffE0F6FF), // Alice blue
      ],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = skyGradient.createShader(Offset.zero & size),
    );
    
    _drawClouds(canvas, size);
    _drawFullCityscape(canvas, size);
    _drawPark(canvas, size);
  }

  void _drawLevel2Background(Canvas canvas, Size size) {
    // Sunset/evening sky
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xff4a148c), // Deep purple
        const Color(0xff7b1fa2), // Purple
        const Color(0xffe91e63), // Pink
        const Color(0xffff9800), // Orange
      ],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = skyGradient.createShader(Offset.zero & size),
    );
    
    _drawFullCityscape(canvas, size);
    _drawLake(canvas, size);
    _drawParkDecorations(canvas, size);
  }

  void _drawClouds(Canvas canvas, Size size) {
    final shift = -(progress * 8) % 800; // Slow cloud movement
    
    final clouds = [
      [100.0, size.height * 0.15, 60.0],
      [300.0, size.height * 0.1, 80.0],
      [500.0, size.height * 0.2, 70.0],
      [700.0, size.height * 0.12, 90.0],
    ];
    
    for (int loop = 0; loop < 2; loop++) {
      for (final cloud in clouds) {
        final x = cloud[0] + shift + (loop * 800);
        final y = cloud[1];
        final cloudSize = cloud[2];
        
        if (x > -cloudSize && x < size.width + cloudSize) {
          _drawCloud(canvas, x, y, cloudSize);
        }
      }
    }
  }

  void _drawCloud(Canvas canvas, double x, double y, double cloudSize) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    // Multiple circles to form cloud shape
    canvas.drawCircle(Offset(x, y), cloudSize * 0.5, cloudPaint);
    canvas.drawCircle(Offset(x - cloudSize * 0.3, y + cloudSize * 0.1), cloudSize * 0.4, cloudPaint);
    canvas.drawCircle(Offset(x + cloudSize * 0.3, y + cloudSize * 0.1), cloudSize * 0.45, cloudPaint);
    canvas.drawCircle(Offset(x - cloudSize * 0.1, y - cloudSize * 0.2), cloudSize * 0.35, cloudPaint);
    canvas.drawCircle(Offset(x + cloudSize * 0.1, y - cloudSize * 0.1), cloudSize * 0.3, cloudPaint);
  }

  void _drawFullCityscape(Canvas canvas, Size size) {
    final shift = -(progress * 30) % 1200;
    
    // Background buildings (far)
    _drawBuildingLayer(canvas, size, shift * 0.3, 0.4, const Color(0xff5D6D7E), 120.0);
    
    // Middle buildings
    _drawBuildingLayer(canvas, size, shift * 0.6, 0.6, const Color(0xff34495E), 180.0);
    
    // Foreground buildings (close)
    _drawBuildingLayer(canvas, size, shift, 1.0, const Color(0xff2C3E50), 250.0);
  }

  void _drawBuildingLayer(Canvas canvas, Size size, double shift, double scale, Color baseColor, double maxHeight) {
    final buildings = [
      [0.0, 80.0, maxHeight * 0.6],
      [100.0, 90.0, maxHeight * 0.8],
      [220.0, 70.0, maxHeight * 0.5],
      [320.0, 110.0, maxHeight * 0.9],
      [450.0, 85.0, maxHeight * 0.7],
      [570.0, 95.0, maxHeight * 0.6],
      [690.0, 75.0, maxHeight * 0.8],
      [810.0, 105.0, maxHeight],
      [930.0, 80.0, maxHeight * 0.7],
      [1050.0, 90.0, maxHeight * 0.85],
    ];
    
    for (int loop = 0; loop < 3; loop++) {
      for (int i = 0; i < buildings.length; i++) {
        final building = buildings[i];
        final x = building[0] + shift + (loop * 1200);
        final w = building[1] * scale;
        final h = building[2] * scale;
        final y = size.height - h - 20;
        
        if (x > -w && x < size.width + w) {
          // Building shadow for depth
          if (scale == 1.0) {
            canvas.drawRRect(
              RRect.fromRectAndCorners(
                Rect.fromLTWH(x + 3, y + 3, w, h),
                topLeft: const Radius.circular(4),
                topRight: const Radius.circular(4),
              ),
              Paint()..color = Colors.black.withValues(alpha: 0.2),
            );
          }
          
          // Main building
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(x, y, w, h),
              topLeft: const Radius.circular(4),
              topRight: const Radius.circular(4),
            ),
            Paint()..color = baseColor.withValues(alpha: 0.7 + scale * 0.3),
          );
          
          // Building details
          if (scale >= 0.6) {
            _drawBuildingDetails(canvas, x, y, w, h, baseColor, scale);
          }
        }
      }
    }
  }

  void _drawBuildingDetails(Canvas canvas, double x, double y, double w, double h, Color baseColor, double scale) {
    // Windows
    final windowSize = 8.0 * scale;
    final windowSpacing = 16.0 * scale;
    
    for (double wx = x + windowSpacing * 0.5; wx < x + w - windowSize; wx += windowSpacing) {
      for (double wy = y + 15 * scale; wy < y + h - 15 * scale; wy += 20 * scale) {
        final windowColor = level == 1 
            ? const Color(0xff3498DB).withValues(alpha: 0.8)
            : Colors.orange.withValues(alpha: 0.9);
        
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(wx, wy, windowSize, windowSize * 1.5),
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
            bottomLeft: const Radius.circular(2),
            bottomRight: const Radius.circular(2),
          ),
          Paint()..color = windowColor,
        );
      }
    }
    
    // Rooftop details for foreground buildings
    if (scale == 1.0) {
      // Antenna
      if (w > 80) {
        canvas.drawRect(
          Rect.fromLTWH(x + w * 0.5 - 1, y - 15, 2, 15),
          Paint()..color = Colors.grey.shade600,
        );
      }
      
      // Rooftop equipment
      if (w > 60) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x + w * 0.2, y, w * 0.15, 8),
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
          ),
          Paint()..color = Colors.grey.shade700,
        );
      }
    }
  }

  void _drawPark(Canvas canvas, Size size) {
    final parkY = size.height - 80;
    final shift = -(progress * 25) % 600;
    
    // Park ground
    final parkPaint = Paint()..color = const Color(0xff2ECC71); // Green
    
    for (double x = shift - 100; x < size.width + 100; x += 600) {
      // Grass areas
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, parkY, 150, 60),
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(8),
        ),
        parkPaint,
      );
      
      // Trees
      _drawTree(canvas, x + 30, parkY - 20);
      _drawTree(canvas, x + 80, parkY - 15);
      _drawTree(canvas, x + 120, parkY - 25);
      
      // Park benches
      _drawBench(canvas, x + 50, parkY + 40);
      
      // Flowers
      _drawFlowers(canvas, x + 20, parkY + 30);
      _drawFlowers(canvas, x + 100, parkY + 35);
    }
  }

  void _drawTree(Canvas canvas, double x, double y) {
    // Tree trunk
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x - 3, y, 6, 25),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      Paint()..color = const Color(0xff8B4513), // Brown
    );
    
    // Tree foliage
    canvas.drawCircle(
      Offset(x, y - 5),
      15,
      Paint()..color = const Color(0xff228B22), // Forest green
    );
    canvas.drawCircle(
      Offset(x - 8, y - 10),
      12,
      Paint()..color = const Color(0xff32CD32), // Lime green
    );
    canvas.drawCircle(
      Offset(x + 8, y - 8),
      10,
      Paint()..color = const Color(0xff228B22),
    );
  }

  void _drawBench(Canvas canvas, double x, double y) {
    final benchPaint = Paint()..color = const Color(0xff8B4513); // Brown
    
    // Bench seat
    canvas.drawRect(Rect.fromLTWH(x, y, 30, 4), benchPaint);
    // Bench back
    canvas.drawRect(Rect.fromLTWH(x, y - 8, 30, 4), benchPaint);
    // Bench legs
    canvas.drawRect(Rect.fromLTWH(x + 2, y, 2, 8), benchPaint);
    canvas.drawRect(Rect.fromLTWH(x + 26, y, 2, 8), benchPaint);
  }

  void _drawFlowers(Canvas canvas, double x, double y) {
    final colors = [Colors.red, Colors.yellow, Colors.pink, Colors.purple];
    
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(x + i * 6, y),
        3,
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  void _drawLake(Canvas canvas, Size size) {
    final lakeY = size.height - 100;
    final shift = -(progress * 20) % 800;
    final time = progress * 0.02;
    
    for (double x = shift - 200; x < size.width + 200; x += 800) {
      // Lake water with gentle waves
      final path = Path();
      path.moveTo(x, lakeY);
      
      for (double lx = x; lx <= x + 300; lx += 10) {
        final wave = math.sin((lx - x) * 0.02 + time) * 3;
        path.lineTo(lx, lakeY + wave);
      }
      path.lineTo(x + 300, size.height - 20);
      path.lineTo(x, size.height - 20);
      path.close();
      
      // Lake gradient
      final lakePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xff1E90FF).withValues(alpha: 0.8), // Dodger blue
            const Color(0xff4169E1).withValues(alpha: 0.6), // Royal blue
          ],
        ).createShader(Rect.fromLTWH(x, lakeY, 300, 80));
      
      canvas.drawPath(path, lakePaint);
      
      // Reflection shimmer
      for (int i = 0; i < 5; i++) {
        final shimmerX = x + 50 + i * 50 + math.sin(time + i) * 20;
        final shimmerY = lakeY + 20 + math.cos(time + i * 2) * 10;
        
        canvas.drawCircle(
          Offset(shimmerX, shimmerY),
          2,
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
      }
    }
  }

  void _drawParkDecorations(Canvas canvas, Size size) {
    final shift = -(progress * 35) % 600;
    final time = progress * 0.03;
    
    for (double x = shift - 100; x < size.width + 100; x += 600) {
      // Lamp posts
      _drawLampPost(canvas, x + 100, size.height - 120);
      _drawLampPost(canvas, x + 200, size.height - 120);
      
      // Fountain
      _drawFountain(canvas, x + 150, size.height - 140, time);
      
      // Walking paths
      _drawPath(canvas, x, size.height - 60);
    }
  }

  void _drawLampPost(Canvas canvas, double x, double y) {
    // Post
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y, 4, 40),
      Paint()..color = Colors.grey.shade700,
    );
    
    // Light
    canvas.drawCircle(
      Offset(x, y - 5),
      8,
      Paint()
        ..color = Colors.yellow.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    
    canvas.drawCircle(
      Offset(x, y - 5),
      6,
      Paint()..color = Colors.orange.withValues(alpha: 0.9),
    );
  }

  void _drawFountain(Canvas canvas, double x, double y, double time) {
    // Fountain base
    canvas.drawCircle(
      Offset(x, y + 20),
      25,
      Paint()..color = Colors.grey.shade600,
    );
    
    // Water jets
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + time;
      final jetX = x + 15 * math.cos(angle);
      final jetY = y + 15 * math.sin(angle);
      final height = 20 + math.sin(time + i) * 10;
      
      canvas.drawRect(
        Rect.fromLTWH(jetX - 1, jetY - height, 2, height),
        Paint()..color = const Color(0xff87CEEB).withValues(alpha: 0.7),
      );
    }
    
    // Central water spout
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y - 30, 4, 30),
      Paint()..color = const Color(0xff1E90FF).withValues(alpha: 0.8),
    );
  }

  void _drawPath(Canvas canvas, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, 600, 15),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ),
      Paint()..color = Colors.grey.shade400,
    );
    
    // Path lines
    for (double px = x; px < x + 600; px += 30) {
      canvas.drawRect(
        Rect.fromLTWH(px, y + 7, 15, 1),
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  void _drawGround(Canvas canvas, Size size) {
    const segW = 40.0, segH = 12.0, gap = 4.0;
    final y = size.height - segH;
    final shift = -(progress * 44) % (segW + gap);
    
    for (double x = shift - segW; x < size.width + segW; x += segW + gap) {
      final groundColor = level == 1 
          ? const Color(0xff34495E) 
          : const Color(0xff2C3E50);
      
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, segW, segH),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        Paint()..color = groundColor,
      );
      
      // Ground texture lines
      canvas.drawRect(
        Rect.fromLTWH(x + 5, y + 5, segW - 10, 1),
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) => 
      old.progress != progress || old.level != level;
}