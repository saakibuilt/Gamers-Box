// // lib/trees.dart
// import 'dart:math' as math;
// import 'package:flutter/material.dart';

// class TreesPainter {
//   static void draw(Canvas canvas, Size size, double progress, int level) {
//     final shift = -(progress * 18); // Correct direction: negative for right-to-left
    
//     // Draw realistic city parks after buildings
//     _drawCityParks(canvas, size, shift, level);
    
//     // Draw street trees along sidewalks
//     _drawStreetTrees(canvas, size, shift, level);
//   }

//   static void _drawCityParks(Canvas canvas, Size size, double shift, int level) {
//     final parkSpacing = 800.0;
    
//     // Calculate starting position to ensure parks enter from right
//     final startX = ((shift / parkSpacing).floor() - 2) * parkSpacing;
//     final endX = size.width + 800;
    
//     // Draw complete realistic parks in a continuous line
//     for (double baseX = startX; baseX < startX + endX + 1600; baseX += parkSpacing) {
//       final x = baseX + shift;
      
//       // Larger visibility buffer to prevent hiding
//       if (x > -500 && x < size.width + 500) {
//         _drawRealisticPark(canvas, size, x, level);
//       }
//     }
//   }

//   static void _drawRealisticPark(Canvas canvas, Size size, double x, int level) {
//     final parkY = size.height - 120;
//     final parkWidth = 400.0; // Wider for more realistic park
//     final parkHeight = 80.0;
    
//     // Main park grass area - larger and more realistic
//     final grassPaint = Paint()..color = level == 1 
//         ? const Color(0xff2ECC71) 
//         : const Color(0xff27AE60);
    
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x, parkY, parkWidth, parkHeight),
//         topLeft: const Radius.circular(15),
//         topRight: const Radius.circular(15),
//         bottomLeft: const Radius.circular(8),
//         bottomRight: const Radius.circular(8),
//       ),
//       grassPaint,
//     );
    
//     // Create realistic park sections
    
//     // Section 1: Tree grove (left side)
//     _drawOakTree(canvas, x + 30, parkY - 25, 1.0);
//     _drawMapleTree(canvas, x + 60, parkY - 30, 1.1);
//     _drawBirchTree(canvas, x + 90, parkY - 22, 0.9);
    
//     // Section 2: Central recreational area
//     _drawParkBench(canvas, x + 140, parkY + 55);
//     _drawParkBench(canvas, x + 200, parkY + 50);
//     _drawFlowerBed(canvas, x + 120, parkY + 35, level);
//     _drawFlowerBed(canvas, x + 180, parkY + 38, level);
//     _drawFlowerBed(canvas, x + 240, parkY + 32, level);
    
//     // Section 3: Playground area
//     _drawPlayground(canvas, x + 280, parkY + 30);
    
//     // Section 4: Tree line (right side)
//     _drawPineTree(canvas, x + 320, parkY - 35, 1.2);
//     _drawWillowTree(canvas, x + 360, parkY - 18, 1.0);
    
//     // Decorative bushes throughout park
//     _drawBushes(canvas, x + 25, parkY + 45);
//     _drawBushes(canvas, x + 110, parkY + 48);
//     _drawBushes(canvas, x + 260, parkY + 52);
//     _drawBushes(canvas, x + 350, parkY + 46);
    
//     // Walking paths through park
//     _drawParkPath(canvas, x + 20, parkY + 25, parkWidth - 40);
    
//     // Park entrance sign
//     _drawParkSign(canvas, x + 15, parkY - 10);
//   }

//   static void _drawStreetTrees(Canvas canvas, Size size, double shift, int level) {
//     final treeSpacing = 120.0;
    
//     // Calculate starting position to ensure trees enter from right
//     final startX = ((shift / treeSpacing).floor() - 5) * treeSpacing;
//     final endX = size.width + 600;
    
//     // Fixed Y position for street level
//     final streetY = size.height - 15;
    
//     // Draw street trees in a continuous line with larger buffer
//     for (double baseX = startX; baseX < startX + endX + 1200; baseX += treeSpacing) {
//       final x = baseX + shift;
      
//       // Larger visibility buffer to prevent hiding
//       if (x > -150 && x < size.width + 150) {
//         // Use baseX to determine tree type for consistency
//         final treeIndex = (baseX / treeSpacing).abs().floor();
//         final treeType = treeIndex % 3;
        
//         switch (treeType) {
//           case 0:
//             _drawStreetOak(canvas, x, streetY - 30, 0.6);
//             break;
//           case 1:
//             _drawStreetMaple(canvas, x, streetY - 30, 0.7);
//             break;
//           case 2:
//             _drawStreetLinden(canvas, x, streetY - 30, 0.65);
//             break;
//         }
        
//         // Tree guard/protection ring
//         canvas.drawCircle(
//           Offset(x, streetY - 15),
//           12.0,
//           Paint()
//             ..color = Colors.brown.shade400
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = 2.0,
//         );
//       }
//     }
//   }

//   static void _drawOakTree(Canvas canvas, double x, double y, double scale) {
//     // Oak tree trunk - thick and sturdy
//     final trunkPaint = Paint()..color = const Color(0xff8B4513);
//     canvas.drawPath(
//       Path()
//         ..moveTo(x - 4 * scale, y + 30 * scale)
//         ..lineTo(x - 3 * scale, y)
//         ..lineTo(x + 3 * scale, y)
//         ..lineTo(x + 4 * scale, y + 30 * scale)
//         ..close(),
//       trunkPaint,
//     );
    
//     // Oak tree canopy - broad and rounded
//     final foliagePaint = Paint()..color = const Color(0xff228B22);
//     canvas.drawCircle(Offset(x, y - 5), 22 * scale, foliagePaint);
//     canvas.drawCircle(Offset(x - 15, y - 8), 18 * scale, foliagePaint);
//     canvas.drawCircle(Offset(x + 15, y - 8), 18 * scale, foliagePaint);
//     canvas.drawCircle(Offset(x - 8, y - 18), 15 * scale, foliagePaint);
//     canvas.drawCircle(Offset(x + 8, y - 18), 15 * scale, foliagePaint);
    
//     // Highlight for depth
//     final highlightPaint = Paint()..color = const Color(0xff32CD32).withValues(alpha: 0.7);
//     canvas.drawCircle(Offset(x - 5, y - 15), 12 * scale, highlightPaint);
//   }

//   static void _drawPineTree(Canvas canvas, double x, double y, double scale) {
//     // Pine tree trunk
//     canvas.drawRect(
//       Rect.fromLTWH(x - 2 * scale, y, 4 * scale, 25 * scale),
//       Paint()..color = const Color(0xff654321),
//     );
    
//     // Pine tree layers (triangular)
//     final pinePaint = Paint()..color = const Color(0xff0F5132);
    
//     // Bottom layer
//     final bottomLayer = Path()
//       ..moveTo(x, y - 20 * scale)
//       ..lineTo(x - 18 * scale, y + 5 * scale)
//       ..lineTo(x + 18 * scale, y + 5 * scale)
//       ..close();
//     canvas.drawPath(bottomLayer, pinePaint);
    
//     // Middle layer
//     final middleLayer = Path()
//       ..moveTo(x, y - 30 * scale)
//       ..lineTo(x - 15 * scale, y - 5 * scale)
//       ..lineTo(x + 15 * scale, y - 5 * scale)
//       ..close();
//     canvas.drawPath(middleLayer, pinePaint);
    
//     // Top layer
//     final topLayer = Path()
//       ..moveTo(x, y - 35 * scale)
//       ..lineTo(x - 12 * scale, y - 15 * scale)
//       ..lineTo(x + 12 * scale, y - 15 * scale)
//       ..close();
//     canvas.drawPath(topLayer, pinePaint);
//   }

//   static void _drawMapleTree(Canvas canvas, double x, double y, double scale) {
//     // Maple tree trunk
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x - 3 * scale, y, 6 * scale, 28 * scale),
//         bottomLeft: const Radius.circular(3),
//         bottomRight: const Radius.circular(3),
//       ),
//       Paint()..color = const Color(0xff8B7355),
//     );
    
//     // Maple tree foliage - more irregular shape
//     final maplePaint = Paint()..color = const Color(0xff228B22);
//     canvas.drawCircle(Offset(x, y - 8), 20 * scale, maplePaint);
//     canvas.drawCircle(Offset(x - 12, y - 5), 16 * scale, maplePaint);
//     canvas.drawCircle(Offset(x + 12, y - 5), 16 * scale, maplePaint);
//     canvas.drawCircle(Offset(x - 6, y - 20), 14 * scale, maplePaint);
//     canvas.drawCircle(Offset(x + 6, y - 20), 14 * scale, maplePaint);
//     canvas.drawCircle(Offset(x, y - 25), 12 * scale, maplePaint);
    
//     // Add some autumn colors if level 2
//     if (scale > 1.0) {
//       final autumnPaint = Paint()..color = Colors.orange.withValues(alpha: 0.6);
//       canvas.drawCircle(Offset(x + 8, y - 12), 10 * scale, autumnPaint);
//       canvas.drawCircle(Offset(x - 5, y - 18), 8 * scale, autumnPaint);
//     }
//   }

//   static void _drawBirchTree(Canvas canvas, double x, double y, double scale) {
//     // Birch tree trunk - white with black marks
//     canvas.drawRect(
//       Rect.fromLTWH(x - 2.5 * scale, y, 5 * scale, 30 * scale),
//       Paint()..color = const Color(0xffF5F5DC), // Beige white
//     );
    
//     // Black birch marks
//     final markPaint = Paint()..color = Colors.black;
//     for (double markY = y + 5; markY < y + 25; markY += 8) {
//       canvas.drawRect(
//         Rect.fromLTWH(x - 2.5 * scale, markY, 5 * scale, 2.0),
//         markPaint,
//       );
//     }
    
//     // Birch foliage - light and airy
//     final birchFoliage = Paint()..color = const Color(0xff90EE90);
//     canvas.drawCircle(Offset(x, y - 5), 16 * scale, birchFoliage);
//     canvas.drawCircle(Offset(x - 10, y - 8), 12 * scale, birchFoliage);
//     canvas.drawCircle(Offset(x + 10, y - 8), 12 * scale, birchFoliage);
//     canvas.drawCircle(Offset(x, y - 18), 10 * scale, birchFoliage);
//   }

//   static void _drawWillowTree(Canvas canvas, double x, double y, double scale) {
//     // Willow trunk
//     canvas.drawRect(
//       Rect.fromLTWH(x - 3 * scale, y, 6 * scale, 25 * scale),
//       Paint()..color = const Color(0xff8B7D6B),
//     );
    
//     // Willow drooping branches
//     final willowPaint = Paint()
//       ..color = const Color(0xff9ACD32)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2 * scale;
    
//     // Main canopy
//     canvas.drawCircle(
//       Offset(x, y - 10),
//       18 * scale,
//       Paint()..color = const Color(0xff9ACD32),
//     );
    
//     // Drooping branches
//     for (int i = 0; i < 8; i++) {
//       final angle = i * math.pi / 4;
//       final startX = x + 15 * scale * math.cos(angle);
//       final startY = y - 10 + 15 * scale * math.sin(angle);
      
//       final path = Path()
//         ..moveTo(startX, startY)
//         ..quadraticBezierTo(
//           startX + 5 * math.cos(angle + math.pi/6),
//           startY + 20 * scale,
//           startX + 10 * math.cos(angle + math.pi/4),
//           startY + 35 * scale,
//         );
//       canvas.drawPath(path, willowPaint);
//     }
//   }

//   static void _drawStreetOak(Canvas canvas, double x, double y, double scale) {
//     // Smaller version of oak for street
//     canvas.drawRect(
//       Rect.fromLTWH(x - 2, y, 4.0, 20.0),
//       Paint()..color = const Color(0xff8B4513),
//     );
    
//     canvas.drawCircle(Offset(x, y - 5), 15 * scale, Paint()..color = const Color(0xff228B22));
//     canvas.drawCircle(Offset(x - 8, y - 3), 12 * scale, Paint()..color = const Color(0xff228B22));
//     canvas.drawCircle(Offset(x + 8, y - 3), 12 * scale, Paint()..color = const Color(0xff228B22));
//   }

//   static void _drawStreetMaple(Canvas canvas, double x, double y, double scale) {
//     canvas.drawRect(
//       Rect.fromLTWH(x - 2, y, 4.0, 22.0),
//       Paint()..color = const Color(0xff8B7355),
//     );
    
//     canvas.drawCircle(Offset(x, y - 6), 14 * scale, Paint()..color = const Color(0xff32CD32));
//     canvas.drawCircle(Offset(x - 7, y - 4), 11 * scale, Paint()..color = const Color(0xff32CD32));
//     canvas.drawCircle(Offset(x + 7, y - 4), 11 * scale, Paint()..color = const Color(0xff32CD32));
//   }

//   static void _drawStreetLinden(Canvas canvas, double x, double y, double scale) {
//     canvas.drawRect(
//       Rect.fromLTWH(x - 2, y, 4.0, 24.0),
//       Paint()..color = const Color(0xff8B6F47),
//     );
    
//     // Heart-shaped linden leaves
//     canvas.drawCircle(Offset(x, y - 8), 16 * scale, Paint()..color = const Color(0xff90EE90));
//     canvas.drawCircle(Offset(x - 6, y - 2), 10 * scale, Paint()..color = const Color(0xff90EE90));
//     canvas.drawCircle(Offset(x + 6, y - 2), 10 * scale, Paint()..color = const Color(0xff90EE90));
//   }

//   static void _drawBushes(Canvas canvas, double x, double y) {
//     final bushPaint = Paint()..color = const Color(0xff228B22);
    
//     // Multiple small bushes clustered together
//     canvas.drawCircle(Offset(x, y), 8.0, bushPaint);
//     canvas.drawCircle(Offset(x + 12, y + 2), 6.0, bushPaint);
//     canvas.drawCircle(Offset(x + 6, y - 3), 7.0, bushPaint);
//     canvas.drawCircle(Offset(x + 18, y - 1), 5.0, bushPaint);
//   }

//   static void _drawFlowerBed(Canvas canvas, double x, double y, int level) {
//     // Flower bed base
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x, y, 40.0, 8.0),
//         topLeft: const Radius.circular(4),
//         topRight: const Radius.circular(4),
//         bottomLeft: const Radius.circular(4),
//         bottomRight: const Radius.circular(4),
//       ),
//       Paint()..color = const Color(0xff8B4513),
//     );
    
//     // Flowers
//     final flowerColors = level == 1 
//         ? [Colors.red, Colors.yellow, Colors.pink, Colors.purple, Colors.blue]
//         : [Colors.orange, Colors.red, Colors.yellow, Colors.pink];
    
//     for (int i = 0; i < 8; i++) {
//       canvas.drawCircle(
//         Offset(x + 5 + i * 4.0, y - 2),
//         2.0,
//         Paint()..color = flowerColors[i % flowerColors.length],
//       );
//     }
//   }

//   static void _drawParkBench(Canvas canvas, double x, double y) {
//     final benchPaint = Paint()..color = const Color(0xff8B4513);
//     final metalPaint = Paint()..color = Colors.grey.shade600;
    
//     // Bench legs (metal)
//     canvas.drawRect(Rect.fromLTWH(x + 3, y, 2.0, 12.0), metalPaint);
//     canvas.drawRect(Rect.fromLTWH(x + 25, y, 2.0, 12.0), metalPaint);
    
//     // Bench seat (wood)
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x, y - 2, 30.0, 5.0),
//         topLeft: const Radius.circular(2),
//         topRight: const Radius.circular(2),
//         bottomLeft: const Radius.circular(2),
//         bottomRight: const Radius.circular(2),
//       ),
//       benchPaint,
//     );
    
//     // Bench back (wood)
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x, y - 12, 30.0, 5.0),
//         topLeft: const Radius.circular(2),
//         topRight: const Radius.circular(2),
//         bottomLeft: const Radius.circular(2),
//         bottomRight: const Radius.circular(2),
//       ),
//       benchPaint,
//     );
    
//     // Wood grain lines
//     for (double line = x + 2; line < x + 28; line += 6) {
//       canvas.drawRect(Rect.fromLTWH(line, y - 1, 3.0, 1.0), Paint()..color = Colors.brown.shade700);
//       canvas.drawRect(Rect.fromLTWH(line, y - 11, 3.0, 1.0), Paint()..color = Colors.brown.shade700);
//     }
//   }

//   static void _drawParkPath(Canvas canvas, double x, double y, double width) {
//     // Main path
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x, y, width, 12.0),
//         topLeft: const Radius.circular(6),
//         topRight: const Radius.circular(6),
//         bottomLeft: const Radius.circular(6),
//         bottomRight: const Radius.circular(6),
//       ),
//       Paint()..color = const Color(0xffD2B48C), // Tan/sand color
//     );
    
//     // Path texture - small stones/gravel effect
//     final random = math.Random(42); // Fixed seed for consistency
//     for (int i = 0; i < 20; i++) {
//       final stoneX = x + random.nextDouble() * width;
//       final stoneY = y + random.nextDouble() * 12;
//       canvas.drawCircle(
//         Offset(stoneX, stoneY),
//         0.5 + random.nextDouble(),
//         Paint()..color = Colors.grey.shade500.withValues(alpha: 0.6),
//       );
//     }
    
//     // Path borders
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x, y, width, 12.0),
//         topLeft: const Radius.circular(6),
//         topRight: const Radius.circular(6),
//         bottomLeft: const Radius.circular(6),
//         bottomRight: const Radius.circular(6),
//       ),
//       Paint()
//         ..color = Colors.brown.shade600
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.0,
//     );
//   }

//   static void _drawPlayground(Canvas canvas, double x, double y) {
//     // Playground swing set
//     canvas.drawRect(
//       Rect.fromLTWH(x, y - 5, 2.0, 15.0),
//       Paint()..color = Colors.grey.shade700,
//     );
//     canvas.drawRect(
//       Rect.fromLTWH(x + 15, y - 5, 2.0, 15.0),
//       Paint()..color = Colors.grey.shade700,
//     );
//     // Top bar
//     canvas.drawRect(
//       Rect.fromLTWH(x, y - 5, 17.0, 2.0),
//       Paint()..color = Colors.grey.shade700,
//     );
//     // Swing
//     canvas.drawRect(
//       Rect.fromLTWH(x + 6, y + 8, 6.0, 2.0),
//       Paint()..color = Colors.blue.shade600,
//     );
    
//     // Small slide
//     canvas.drawRect(
//       Rect.fromLTWH(x + 25, y, 12.0, 8.0),
//       Paint()..color = Colors.red.shade600,
//     );
//     canvas.drawRect(
//       Rect.fromLTWH(x + 20, y + 8, 22.0, 3.0),
//       Paint()..color = Colors.yellow.shade600,
//     );
//   }

//   static void _drawParkSign(Canvas canvas, double x, double y) {
//     // Sign post
//     canvas.drawRect(
//       Rect.fromLTWH(x - 1, y, 2.0, 20.0),
//       Paint()..color = Colors.brown.shade700,
//     );
    
//     // Sign board
//     canvas.drawRRect(
//       RRect.fromRectAndCorners(
//         Rect.fromLTWH(x + 3, y, 25.0, 12.0),
//         topLeft: const Radius.circular(2),
//         topRight: const Radius.circular(2),
//         bottomLeft: const Radius.circular(2),
//         bottomRight: const Radius.circular(2),
//       ),
//       Paint()..color = Colors.green.shade700,
//     );
    
//     // "PARK" text simulation
//     canvas.drawRect(Rect.fromLTWH(x + 6, y + 3, 6.0, 2.0), Paint()..color = Colors.white);
//     canvas.drawRect(Rect.fromLTWH(x + 6, y + 6, 8.0, 2.0), Paint()..color = Colors.white);
//   }
// }