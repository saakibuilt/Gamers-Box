import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LiveUsersWidget extends StatefulWidget {
  const LiveUsersWidget({super.key});

  @override
  State<LiveUsersWidget> createState() => _LiveUsersWidgetState();
}

class _LiveUsersWidgetState extends State<LiveUsersWidget> {
  int _totalUsers = 0;
  int _activeUsers = 0;

  @override
  void initState() {
    super.initState();
    _listenToUsers();
  }

  void _listenToUsers() {
    FirebaseDatabase.instance.ref('online_users').onValue.listen((event) {
      final usersMap = event.snapshot.value as Map<dynamic, dynamic>?;

      int total = 0;
      int active = 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (usersMap != null) {
        total = usersMap.length;

        for (var user in usersMap.values) {
          if (user is Map && user['timestamp'] != null) {
            final int lastSeen = user['timestamp'];
            if (now - lastSeen <= 60000) {
              active++;
            }
          }
        }
      }

      setState(() {
        _totalUsers = total;
        _activeUsers = active;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🟢 $_totalUsers', style: TextStyle(fontSize: 12)),
          Text('⚡ $_activeUsers', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
