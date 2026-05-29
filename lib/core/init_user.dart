import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

const String _devSignature = 'SakshamNirula_v1';

class UserData {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      };
}

UserData? currentUser;

const _spKey = 'user_data';
const _fileName = 'user.json';

Future<void> initUser() async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized

  final prefs = await SharedPreferences.getInstance();
  final spRaw = prefs.getString(_spKey);

  if (spRaw != null) {
    try {
      currentUser = UserData.fromJson(jsonDecode(spRaw));
    } catch (_) {}
  }

  if (currentUser == null) {
    final file = await _userFile;
    if (await file.exists()) {
      try {
        currentUser = UserData.fromJson(jsonDecode(await file.readAsString()));
        await prefs.setString(_spKey, jsonEncode(currentUser!.toJson()));
      } catch (_) {}
    }
  }

  if (currentUser == null) {
    currentUser = UserData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Guest',
      email: '',
    );
    await saveUser(currentUser!);
  }

  final db = FirebaseDatabase.instance;
  final uid = currentUser!.id;
  final ref = db.ref('online_users/$uid');

  await ref.set({
    'name': currentUser!.name,
    'timestamp': ServerValue.timestamp,
  });

  ref.onDisconnect().remove();

  // Heartbeat every 30 seconds
  Timer.periodic(const Duration(seconds: 30), (_) {
    ref.update({'timestamp': ServerValue.timestamp});
  });
}

Future<void> saveUser(UserData user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_spKey, jsonEncode(user.toJson()));

  final file = await _userFile;
  await file.writeAsString(jsonEncode(user.toJson()));
}

Future<File> get _userFile async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/$_fileName');
}
