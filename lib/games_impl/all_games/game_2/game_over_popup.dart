
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOverPopup {
  static Future<String?> show({
    required BuildContext context,
    required int score,
    required double scroll,
    required int high,
    required double highDist,
    required String Function(double) miles,
  }) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false, // Prevent back button dismissal
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 24,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF696969).withOpacity(0.95),
                  const Color(0xFF696969).withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 40,
                      color: Color(0xFF696969),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Game Over',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF696969),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Score',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color.fromARGB(255, 250, 250, 250),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$score',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 0, 67, 133),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Distance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${miles(scroll)} mi',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        Divider(color: const Color.fromARGB(255, 114, 141, 183)),
                        const SizedBox(height: 12),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Best Score',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.emoji_events,
                                      size: 16,
                                      color: Colors.amber.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$high',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Best Distance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      size: 16,
                                      color: Colors.purple.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${miles(highDist)} mi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              margin: const EdgeInsets.only(right: 6),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Immediately close dialog with result
                                  Navigator.of(dialogContext).pop('retry');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.refresh, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Retry',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          Expanded(
                            child: Container(
                              height: 48,
                              margin: const EdgeInsets.only(left: 6),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop('restart');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.replay, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Restart',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop('quit');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.home, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Quit to Menu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> saveRecords({
    required int score,
    required double scroll,
    required int currentHigh,
    required double currentHighDist,
  }) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (score > currentHigh) {
        await p.setInt('g2_high', score);
      }
      if (scroll > currentHighDist) {
        await p.setDouble('g2_highDist', scroll);
      }
    } catch (e) {
      debugPrint('Error saving records: $e');
    }
  }
}