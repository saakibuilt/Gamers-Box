import 'package:flutter/material.dart';
import 'core/init_user.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

const String _projectAuthor = 'SakshamNirula';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initUser();
  await ThemeController().load();
  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = ThemeController();
    return AnimatedBuilder(
      animation: tc,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appLightTheme,
        darkTheme: appDarkTheme,
        themeMode: tc.mode,
        home: const SplashScreen(),
      ),
    );
  }
}
