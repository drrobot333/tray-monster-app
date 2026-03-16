import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrayMonsterApp());
}

class TrayMonsterApp extends StatelessWidget {
  const TrayMonsterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'TrayMonster',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1a1a2e),
          cardColor: const Color(0xFF0d1117),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4CAF50),
            secondary: Color(0xFF2196F3),
            surface: Color(0xFF0d1117),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF333333),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF0d1117),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF333333)),
            ),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white70),
            bodySmall: TextStyle(color: Colors.white54),
          ),
        ),
        home: const GameScreen(),
      ),
    );
  }
}
