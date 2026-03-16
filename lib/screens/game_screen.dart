import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../widgets/status_bar.dart';
import '../widgets/workstation_tabs.dart';
import '../widgets/battle_panel.dart';
import '../widgets/mission_panel.dart';
import '../widgets/bottom_nav.dart';
import 'egg_tab.dart';
import 'team_tab.dart';
import 'cooking_tab.dart';
import 'upgrade_tab.dart';
import 'codex_tab.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentTab = 0;
  Timer? _gameTimer;
  Timer? _saveTimer;
  DateTime _lastTick = DateTime.now();
  GameEngine? _engine;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _lastTick = DateTime.now();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now();
      final dt = (now.difference(_lastTick).inMicroseconds) / 1000000.0;
      _lastTick = now;
      if (_engine == null) {
        final gs = Provider.of<GameState>(context, listen: false);
        _engine = GameEngine(gs);
      }
      // Load save on first tick
      if (!_loaded) {
        _loaded = true;
        _engine!.loadGame();
      }
      _engine!.update(dt);
    });
    // Auto-save every 10 seconds
    _saveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _engine?.saveGame();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _saveTimer?.cancel();
    _engine?.saveGame(); // save on dispose
    super.dispose();
  }

  Widget _buildTabOverlay() {
    switch (_currentTab) {
      case 1:
        return EggTab(engine: _engine!);
      case 2:
        return TeamTab(engine: _engine!);
      case 3:
        return CookingTab(engine: _engine!);
      case 4:
        return UpgradeTab(engine: _engine!);
      case 5:
        return const CodexTab();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_engine == null) {
      final gs = Provider.of<GameState>(context, listen: false);
      _engine = GameEngine(gs);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const StatusBar(),
                // Main content area
                Expanded(
                  child: Stack(
                    children: [
                      // Farm tab: farm + battle + missions stacked
                      if (_currentTab == 0)
                        Column(
                          children: [
                              // Farm
                            const Expanded(flex: 4, child: WorkstationTabs()),
                            // Battle
                            Expanded(flex: 3, child: BattlePanel(engine: _engine!)),
                            // Missions
                            SizedBox(height: 100, child: MissionPanel(engine: _engine!)),
                          ],
                        ),
                      // Other tabs: full overlay
                      if (_currentTab != 0)
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFF1a1a2e),
                            child: _buildTabOverlay(),
                          ),
                        ),
                    ],
                  ),
                ),
                BottomNav(
                  currentTab: _currentTab,
                  onTabChanged: (index) {
                    setState(() {
                      _currentTab = index;
                    });
                  },
                ),
              ],
            ),
            // Notification toast
            Consumer<GameState>(
              builder: (context, gs, _) {
                if (gs.notification == null || gs.notificationTimer <= 0) {
                  return const SizedBox.shrink();
                }
                final opacity = gs.notificationTimer.clamp(0.0, 1.0);
                return Positioned(
                  top: 50,
                  left: 24,
                  right: 24,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xDD222244),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          gs.notification!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
