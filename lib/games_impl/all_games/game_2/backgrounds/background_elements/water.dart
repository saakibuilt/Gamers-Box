// // lib/water.dart
// import 'dart:math' as math;
// import 'package:flutter/material.dart';

// class WaterPainter {
//   static void drawPond(Canvas canvas, Size size, double progress) {
//     final shift = -(progress * 15); // Remove modulo for continuous motion
//     final time = progress * 0.025;
    
//     // Calculate starting position to ensure ponds enter from right
//     final pondSpacing = 600.0;
//     final startX = ((shift / pondSpacing).floor() - 1) * pondSpacing;
//     final endX = size.width + 600;
    
//     // Draw ponds in a continuous line
//     for (double baseX = startX; baseX < startX + endX + 1200; baseX += pondSpacing) {
//       final x = baseX + shift;
      
//       if (x > -400 && x < size.width + 400) {
//         _drawSmallPond(canvas, size, x, time);
//       }
//     }
//   }

//   static void drawLake(Canvas canvas, Size size, double progress) {
//     final shift = -(progress * 20); // Remove modulo for continuous motion
//     final time = progress * 0.02;
    
//     // Calculate starting position to ensure lakes enter from right
//     final lakeSpacing = 800.0;
//     final startX = ((shift / lakeSpacing).floor() - 1) * lakeSpacing;
//     final endX = size.width + 800;
    
//     // Draw lakes in a continuous line
//     for (double baseX = startX; baseX < startX + endX + 1600; baseX += lakeSpacing) {
//       final x = baseX + shift;
      
//       if (x > -500 && x < size.width + 500) {
//         _drawLargerLake(canvas, size, x, time);
//       }
//     }
//   }

//   static void _drawSmallPond(Canvas canvas, Size size, double x, double time) {
//     final pondY = size.height - 130;
//     final pondWidth = 180.0;
//     final pondHeight = 60.0;
    
//     // Pond bank/shore
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x - 10, pondY - 5, pondWidth + 20, pondHeight + 15),
//         topLeft: const Radius.circular(15),
//         topRight: const Radius.circular(15),
//         bottomLeft: const Radius.circular(12),
//         bottomRight: const Radius.circular(12),
//       ),
//       Paint()..color = const Color(0xff8B7355), // Sandy brown shore
//     );
    
//     // Water surface with gentle ripples
//     final waterPath = Path();
//     waterPath.moveTo(x, pondY);
    
//     for (double px = x; px <= x + pondWidth; px += 8) {
//       final ripple1 = math.sin((px - x) * 0.08 + time * 3) * 2;
//       final ripple2 = math.sin((px - x) * 0.15 + time * 2) * 1;
//       final totalRipple = ripple1 + ripple2;
//       waterPath.lineTo(px, pondY + totalRipple);
//     }
    
//     waterPath.lineTo(x + pondWidth, pondY + pondHeight - 10);
//     waterPath.lineTo(x, pondY + pondHeight - 10);
//     waterPath.close();
    
//     // Water gradient (shallow to deep)
//     final waterPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           const Color(0xff87CEEB).withValues(alpha: 0.8), // Sky blue (shallow)
//           const Color(0xff4682B4).withValues(alpha: 0.9), // Steel blue (deeper)
//           const Color(0xff2F4F4F).withValues(alpha: 0.95), // Dark slate gray (deepest)
//         ],
//         stops: const [0.0, 0.6, 1.0],
//       ).createShader(Rect.fromLTWH(x, pondY, pondWidth, pondHeight));
    
//     canvas.drawPath(waterPath, waterPaint);
    
//     // Water reflections and shimmer
//     _drawWaterReflections(canvas, x, pondY, pondWidth, pondHeight, time, 0.6);
    
//     // Pond wildlife and details
//     _drawPondDetails(canvas, x, pondY, pondWidth, pondHeight, time);
    
//     // Shore vegetation
//     _drawShoreVegetation(canvas, x, pondY, pondWidth);
//   }

//   static void _drawLargerLake(Canvas canvas, Size size, double x, double time) {
//     final lakeY = size.height - 140;
//     final lakeWidth = 350.0;
//     final lakeHeight = 80.0;
    
//     // Lake shore/bank - more extensive
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x - 15, lakeY - 8, lakeWidth + 30, lakeHeight + 20),
//         topLeft: const Radius.circular(20),
//         topRight: const Radius.circular(20),
//         bottomLeft: const Radius.circular(15),
//         bottomRight: const Radius.circular(15),
//       ),
//       Paint()..color = const Color(0xff8B7355), // Sandy shore
//     );
    
//     // Rocky areas along shore
//     _drawRockyShore(canvas, x, lakeY, lakeWidth);
    
//     // Lake water with more complex wave patterns
//     final waterPath = Path();
//     waterPath.moveTo(x, lakeY);
    
//     for (double lx = x; lx <= x + lakeWidth; lx += 6) {
//       final wave1 = math.sin((lx - x) * 0.05 + time * 4) * 3;
//       final wave2 = math.sin((lx - x) * 0.12 + time * 2.5) * 2;
//       final wave3 = math.sin((lx - x) * 0.08 + time * 3.5) * 1.5;
//       final totalWave = wave1 + wave2 + wave3;
//       waterPath.lineTo(lx, lakeY + totalWave);
//     }
    
//     waterPath.lineTo(x + lakeWidth, lakeY + lakeHeight - 15);
//     waterPath.lineTo(x, lakeY + lakeHeight - 15);
//     waterPath.close();
    
//     // Evening lake gradient (darker, more mysterious)
//     final lakePaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [
//           const Color(0xff4169E1).withValues(alpha: 0.8), // Royal blue
//           const Color(0xff191970).withValues(alpha: 0.9), // Midnight blue
//           const Color(0xff000080).withValues(alpha: 0.95), // Navy blue
//           const Color(0xff0F0F23).withValues(alpha: 0.98), // Very dark blue
//         ],
//         stops: const [0.0, 0.4, 0.8, 1.0],
//       ).createShader(Rect.fromLTWH(x, lakeY, lakeWidth, lakeHeight));
    
//     canvas.drawPath(waterPath, lakePaint);
    
//     // More dramatic reflections for evening
//     _drawWaterReflections(canvas, x, lakeY, lakeWidth, lakeHeight, time, 1.0);
    
//     // Lake features
//     _drawLakeDetails(canvas, x, lakeY, lakeWidth, lakeHeight, time);
    
//     // Sunset reflections on water
//     _drawSunsetReflection(canvas, x, lakeY, lakeWidth, lakeHeight, time);
//   }

//   static void _drawWaterReflections(Canvas canvas, double x, double y, double width, double height, double time, double intensity) {
//     // Light shimmer on water surface
//     for (int i = 0; i < 12; i++) {
//       final shimmerX = x + 20 + i * (width - 40) / 11 + math.sin(time * 2 + i.toDouble()) * 15;
//       final shimmerY = y + 8 + math.cos(time * 1.5 + i * 2.0) * 8;
//       final shimmerSize = 1.5 + math.sin(time * 3 + i.toDouble()) * 0.5;
      
//       if (shimmerX > x && shimmerX < x + width) {
//         canvas.drawCircle(
//           Offset(shimmerX, shimmerY),
//           shimmerSize * intensity,
//           Paint()..color = Colors.white.withValues(alpha: 0.4 + 0.3 * intensity),
//         );
//       }
//     }
    
//     // Larger reflection highlights
//     for (int i = 0; i < 6; i++) {
//       final reflectX = x + 30 + i * (width - 60) / 5 + math.cos(time + i * 1.5) * 25;
//       final reflectY = y + 15 + math.sin(time * 0.8 + i.toDouble()) * 12;
//       final reflectSize = 3 + math.cos(time * 2 + i.toDouble()) * 1;
      
//       if (reflectX > x && reflectX < x + width) {
//         canvas.drawCircle(
//           Offset(reflectX, reflectY),
//           reflectSize * intensity,
//           Paint()
//             ..color = Colors.white.withValues(alpha: 0.2 + 0.2 * intensity)
//             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
//         );
//       }
//     }
//   }

//   static void _drawPondDetails(Canvas canvas, double x, double y, double width, double height, double time) {
//     // Lily pads
//     for (int i = 0; i < 4; i++) {
//       final padX = x + 25 + i * 35.0 + math.sin(time * 0.5 + i.toDouble()) * 8;
//       final padY = y + 20 + math.cos(time * 0.3 + i.toDouble()) * 6;
      
//       // Lily pad
//       canvas.drawCircle(
//         Offset(padX, padY),
//         8.0,
//         Paint()..color = const Color(0xff228B22),
//       );
      
//       // Lily pad notch
//       final notchPath = Path()
//         ..moveTo(padX, padY - 8)
//         ..lineTo(padX - 3, padY - 2)
//         ..lineTo(padX + 3, padY - 2)
//         ..close();
//       canvas.drawPath(notchPath, Paint()..color = const Color(0xff1E6B1E));
      
//       // Small lily flower (occasionally)
//       if (i % 2 == 0) {
//         canvas.drawCircle(
//           Offset(padX + 6, padY - 4),
//           3.0,
//           Paint()..color = Colors.white,
//         );
//         canvas.drawCircle(
//           Offset(padX + 6, padY - 4),
//           1.5,
//           Paint()..color = Colors.yellow,
//         );
//       }
//     }
    
//     // Small fish creating ripples
//     for (int i = 0; i < 3; i++) {
//       final fishX = x + 40 + i * 50.0 + math.sin(time * 2 + i * 2.0) * 30;
//       final fishY = y + 30 + math.cos(time * 1.5 + i.toDouble()) * 15;
      
//       if (fishX > x + 10 && fishX < x + width - 10) {
//         // Fish ripple
//         canvas.drawCircle(
//           Offset(fishX, fishY),
//           4.0,
//           Paint()
//             ..color = Colors.white.withValues(alpha: 0.3)
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = 1.0,
//         );
//         canvas.drawCircle(
//           Offset(fishX, fishY),
//           2.0,
//           Paint()
//             ..color = Colors.white.withValues(alpha: 0.2)
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = 1.0,
//         );
//       }
//     }
    
//     // Cattails near the shore
//     _drawCattails(canvas, x - 5, y + height - 15);
//     _drawCattails(canvas, x + width + 2, y + height - 12);
//   }

//   static void _drawLakeDetails(Canvas canvas, double x, double y, double width, double height, double time) {
//     // Larger fish movement patterns
//     for (int i = 0; i < 5; i++) {
//       final fishX = x + 50 + i * 60.0 + math.sin(time * 1.5 + i * 3.0) * 40;
//       final fishY = y + 25 + math.cos(time * 1.2 + i * 2.0) * 20;
      
//       if (fishX > x + 15 && fishX < x + width - 15) {
//         // Larger fish ripple
//         canvas.drawCircle(
//           Offset(fishX, fishY),
//           6.0,
//           Paint()
//             ..color = Colors.white.withValues(alpha: 0.4)
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = 1.5,
//         );
//         canvas.drawCircle(
//           Offset(fishX, fishY),
//           3.0,
//           Paint()
//             ..color = Colors.white.withValues(alpha: 0.3)
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = 1.0,
//         );
//       }
//     }
    
//     // Water birds creating wake patterns
//     for (int i = 0; i < 2; i++) {
//       final birdX = x + 80 + i * 120.0 + math.cos(time * 0.8 + i * 4.0) * 60;
//       final birdY = y + 15 + math.sin(time * 0.6 + i * 2.0) * 10;
      
//       if (birdX > x + 20 && birdX < x + width - 20) {
//         // Bird wake pattern
//         for (int wake = 0; wake < 3; wake++) {
//           canvas.drawCircle(
//             Offset(birdX - wake * 8.0, birdY + wake * 2.0),
//             2.0 + wake.toDouble(),
//             Paint()
//               ..color = Colors.white.withValues(alpha: 0.2 - wake * 0.05)
//               ..style = PaintingStyle.stroke
//               ..strokeWidth = 1.0,
//           );
//         }
//       }
//     }
    
//     // Floating debris (twigs, leaves)
//     _drawFloatingDebris(canvas, x, y, width, height, time);
//   }

//   static void _drawSunsetReflection(Canvas canvas, double x, double y, double width, double height, double time) {
//     // Sunset light reflection on water - long vertical streaks
//     final reflectionX = x + width * 0.6 + math.sin(time * 0.5) * 20;
    
//     for (int i = 0; i < 8; i++) {
//       final streakY = y + 10 + i * 8.0;
//       final streakWidth = 3 + math.sin(time * 2 + i * 0.5) * 2;
//       final alpha = 0.6 - i * 0.06;
      
//       canvas.drawRRect(
//         RRect.fromRectAndCorners(
//           Rect.fromLTWH(reflectionX - streakWidth/2, streakY, streakWidth, 6.0),
//           topLeft: const Radius.circular(3),
//           topRight: const Radius.circular(3),
//           bottomLeft: const Radius.circular(3),
//           bottomRight: const Radius.circular(3),
//         ),
//         Paint()..color = Colors.orange.withValues(alpha: alpha),
//       );
//     }
    
//     // Additional warm light reflections
//     for (int i = 0; i < 5; i++) {
//       final warmX = x + 30 + i * 70.0 + math.cos(time * 1.2 + i.toDouble()) * 15;
//       final warmY = y + 20 + math.sin(time * 0.8 + i * 2.0) * 12;
      
//       if (warmX > x && warmX < x + width) {
//         canvas.drawCircle(
//           Offset(warmX, warmY),
//           4 + math.sin(time * 3 + i.toDouble()) * 2,
//           Paint()
//             ..color = Colors.amber.withValues(alpha: 0.4)
//             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
//         );
//       }
//     }
//   }

//   static void _drawRockyShore(Canvas canvas, double x, double y, double width) {
//     // Large rocks along the shore
//     final rockPositions = [
//       [x - 8, y + 5, 12.0, 8.0],
//       [x + 25, y - 2, 15.0, 10.0],
//       [x + width - 30, y + 3, 18.0, 12.0],
//       [x + width + 5, y + 8, 14.0, 9.0],
//     ];
    
//     for (final rock in rockPositions) {
//       final rockX = rock[0];
//       final rockY = rock[1];
//       final rockW = rock[2];
//       final rockH = rock[3];
      
//       // Rock shadow
//       canvas.drawRRect(
//         RRect.fromRectAndCorners(
//           Rect.fromLTWH(rockX + 2, rockY + 2, rockW, rockH),
//           topLeft: const Radius.circular(4),
//           topRight: const Radius.circular(6),
//           bottomLeft: const Radius.circular(3),
//           bottomRight: const Radius.circular(5),
//         ),
//         Paint()..color = Colors.black.withValues(alpha: 0.3),
//       );
      
//       // Main rock
//       canvas.drawRRect(
//         RRect.fromRectAndCorners(
//           Rect.fromLTWH(rockX, rockY, rockW, rockH),
//           topLeft: const Radius.circular(4),
//           topRight: const Radius.circular(6),
//           bottomLeft: const Radius.circular(3),
//           bottomRight: const Radius.circular(5),
//         ),
//         Paint()..color = Colors.grey.shade600,
//       );
      
//       // Rock highlight
//       canvas.drawRRect(
//         RRect.fromRectAndCorners(
//           Rect.fromLTWH(rockX + 1, rockY + 1, rockW * 0.6, rockH * 0.4),
//           topLeft: const Radius.circular(3),
//           topRight: const Radius.circular(4),
//           bottomLeft: const Radius.circular(2),
//           bottomRight: const Radius.circular(3),
//         ),
//         Paint()..color = Colors.grey.shade400.withValues(alpha: 0.7),
//       );
//     }
    
//     // Smaller pebbles scattered around
//     final random = math.Random(42); // Fixed seed for consistency
//     for (int i = 0; i < 15; i++) {
//       final pebbleX = x - 10 + random.nextDouble() * (width + 20);
//       final pebbleY = y - 5 + random.nextDouble() * 20;
//       final pebbleSize = 2 + random.nextDouble() * 4;
      
//       canvas.drawCircle(
//         Offset(pebbleX, pebbleY),
//         pebbleSize,
//         Paint()..color = Colors.grey.shade500.withValues(alpha: 0.8),
//       );
//     }
//   }

//   static void _drawShoreVegetation(Canvas canvas, double x, double y, double width) {
//     // Reeds and marsh grass
//     for (int i = 0; i < 8; i++) {
//       final grassX = x - 5 + i * (width + 10) / 7;
//       final grassY = y + 5;
      
//       _drawReed(canvas, grassX, grassY, 15 + i % 3 * 5);
//     }
    
//     // Shore bushes
//     canvas.drawCircle(
//       Offset(x - 12, y + 15),
//       8,
//       Paint()..color = const Color(0xff228B22),
//     );
//     canvas.drawCircle(
//       Offset(x + width + 8, y + 18),
//       10,
//       Paint()..color = const Color(0xff228B22),
//     );
//   }

//   static void _drawCattails(Canvas canvas, double x, double y) {
//     for (int i = 0; i < 3; i++) {
//       final cattailX = x + i * 4;
//       final cattailY = y;
      
//       // Cattail stem
//       canvas.drawRect(
//         Rect.fromLTWH(cattailX, cattailY, 1, 25),
//         Paint()..color = const Color(0xff228B22),
//       );
      
//       // Cattail head (brown sausage-like top)
//       canvas.drawRRect(
//         RRect.fromRectAndCorners(
//           Rect.fromLTWH(cattailX - 1, cattailY - 8, 3, 8),
//           topLeft: const Radius.circular(1.5),
//           topRight: const Radius.circular(1.5),
//           bottomLeft: const Radius.circular(0.5),
//           bottomRight: const Radius.circular(0.5),
//         ),
//         Paint()..color = const Color(0xff8B4513),
//       );
//     }
//   }

//   static void _drawReed(Canvas canvas, double x, double y, double height) {
//     // Reed stem - slightly curved
//     final reedPath = Path();
//     reedPath.moveTo(x, y);
//     reedPath.quadraticBezierTo(
//       x + 2, y - height * 0.6,
//       x + 1, y - height,
//     );
    
//     canvas.drawPath(
//       reedPath,
//       Paint()
//         ..color = const Color(0xff228B22)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 2,
//     );
    
//     // Reed seed head
//     canvas.drawCircle(
//       Offset(x + 1, y - height),
//       2,
//       Paint()..color = const Color(0xff8B7355),
//     );
//   }

//   static void _drawFloatingDebris(Canvas canvas, double x, double y, double width, double height, double time) {
//     // Floating leaves
//     for (int i = 0; i < 6; i++) {
//       final leafX = x + 20 + i * 50.0 + math.sin(time * 0.3 + i * 2.0) * 20;
//       final leafY = y + 12 + math.cos(time * 0.4 + i.toDouble()) * 8;
      
//       if (leafX > x && leafX < x + width) {
//         // Leaf shape
//         canvas.drawCircle(
//           Offset(leafX, leafY),
//           3.0,
//           Paint()..color = const Color(0xff8B4513).withValues(alpha: 0.8),
//         );
        
//         // Leaf vein
//         canvas.drawRect(
//           Rect.fromLTWH(leafX - 1, leafY - 2, 2.0, 4.0),
//           Paint()..color = const Color(0xff654321).withValues(alpha: 0.6),
//         );
//       }
//     }
    
//     // Small twigs
//     for (int i = 0; i < 4; i++) {
//       final twigX = x + 40 + i * 80.0 + math.cos(time * 0.2 + i * 3.0) * 30;
//       final twigY = y + 18 + math.sin(time * 0.25 + i * 2.0) * 12;
      
//       if (twigX > x && twigX < x + width) {
//         canvas.drawRect(
//           Rect.fromLTWH(twigX, twigY, 8.0, 1.5),
//           Paint()..color = const Color(0xff8B4513).withValues(alpha: 0.7),
//         );
//       }
//     }
//   }
// }