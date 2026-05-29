import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../games_impl/all_games/all_games.dart';
import '../widgets/live_users.dart';
import 'total_user_points.dart';
import '../widgets/home_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String totalPointsDisplay = '0';
  Map<String, int> gameBreakdown = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTotalPoints();
  }

  Future<void> _loadTotalPoints() async {
    try {
      final formattedTotal = await TotalUserPointsHelper.getFormattedTotalPoints();
      final stats = await TotalUserPointsHelper.getStatistics();
      
      if (mounted) {
        setState(() {
          totalPointsDisplay = formattedTotal;
          gameBreakdown = {};
          
          for (final entry in stats.gameBreakdown.entries) {
            gameBreakdown[entry.key] = entry.value.totalPoints;
          }
          
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          totalPointsDisplay = '0';
          gameBreakdown = {};
          isLoading = false;
        });
      }
    }
  }

  void _toggleTheme() {
    ThemeController().toggle();
    setState(() {});
  }

  Widget _buildPointsDisplay() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)]
            : [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.purple : Colors.blue,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.purple : Colors.blue).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'TOTAL POINTS',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (isLoading)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.purple : Colors.blue,
              ),
            )
          else
            Text(
              totalPointsDisplay,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          
          const SizedBox(height: 16),
          
          if (!isLoading && gameBreakdown.isNotEmpty) ...[
            Text(
              'Game Breakdown',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: gameBreakdown.entries.map((entry) {
                final gameName = entry.key;
                final points = entry.value;
                
                IconData gameIcon = Icons.games;
                Color gameColor = Colors.grey;
                
                if (gameName.contains('Pac-Man')) {
                  gameIcon = Icons.circle;
                  gameColor = Colors.yellow;
                } else if (gameName.contains('Snake')) {
                  gameIcon = Icons.restaurant;
                  gameColor = Colors.green;
                } else if (gameName.contains('Runner') || gameName.contains('Endless')) {
                  gameIcon = Icons.directions_run;
                  gameColor = Colors.orange;
                }
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: gameColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gameColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(gameIcon, size: 16, color: gameColor),
                      const SizedBox(width: 6),
                      Text(
                        gameName.length > 12 
                          ? '${gameName.substring(0, 12)}...' 
                          : gameName,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatPoints(points),
                        style: TextStyle(
                          color: gameColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else if (!isLoading && gameBreakdown.isEmpty) ...[
            Text(
              'No games played yet!',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black45,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12, top: 12),
          child: LiveUsersWidget(), // Show live users in top-left
        ),
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Game',
                style: TextStyle(
                  color: Color(0xFF5DE0E6),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'rs',
                style: TextStyle(
                  color: Color.fromARGB(255, 151, 235, 241),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Box',
                style: TextStyle(
                  color: Color(0xFF004AAD),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
        //   IconButton(
        //     tooltip: 'Refresh Points',
        //     icon: Icon(Icons.refresh),
        //     onPressed: () => _loadTotalPoints(),
        //   ),
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          const HomeBanner(
            message: 'Highest Scores',
            height: 65,
            speed: 90,
            child: Row(), // Provide an empty Row as required by the parameter type
          ),
          _buildPointsDisplay(),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: game.builder),
                  ).then((_) {
                    // Refresh points when returning from any game
                    _loadTotalPoints();
                  }),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(game.icon, size: 48),
                        const SizedBox(height: 12),
                        Text(game.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}