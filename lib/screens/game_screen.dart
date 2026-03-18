import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../widgets/status_bar.dart';
import '../widgets/workstation_tabs.dart';
import '../widgets/battle_panel.dart';
import '../widgets/mission_panel.dart';
import '../widgets/bottom_nav.dart';
import 'team_tab.dart';
import 'cooking_tab.dart';
import 'shop_tab.dart';
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
  double _opacity = 1.0; // 0.15 ~ 1.0
  bool _showOpacitySlider = false;

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
        return ShopTab(engine: _engine!);
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
                  Expanded(
                    child: Stack(
                      children: [
                        if (_currentTab == 0)
                          Column(
                            children: [
                              const Expanded(flex: 4, child: WorkstationTabs()),
                              Expanded(flex: 3, child: BattlePanel(engine: _engine!)),
                              SizedBox(height: 100, child: MissionPanel(engine: _engine!)),
                            ],
                          ),
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
                  // Bottom nav + opacity toggle
                  Row(
                    children: [
                      Expanded(
                        child: BottomNav(
                          currentTab: _currentTab,
                          onTabChanged: (index) {
                            setState(() { _currentTab = index; });
                          },
                        ),
                      ),
                      // Opacity toggle button
                      GestureDetector(
                        onTap: () => setState(() { _showOpacitySlider = !_showOpacitySlider; }),
                        child: Container(
                          width: 36, height: 48,
                          decoration: BoxDecoration(
                            color: _showOpacitySlider ? const Color(0xFF333355) : const Color(0xFF0d1117),
                            border: Border.all(color: const Color(0xFF444444)),
                          ),
                          child: Icon(Icons.opacity, size: 18,
                            color: _showOpacitySlider ? const Color(0xFF4CAF50) : Colors.white38),
                        ),
                      ),
                    ],
                  ),
                  // Opacity slider (expandable)
                  if (_showOpacitySlider)
                    Container(
                      height: 36,
                      color: const Color(0xFF0d1117),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility_off, size: 14, color: Colors.white38),
                          Expanded(
                            child: Slider(
                              value: _opacity,
                              min: 0.15,
                              max: 1.0,
                              divisions: 17,
                              activeColor: const Color(0xFF4CAF50),
                              inactiveColor: const Color(0xFF333333),
                              onChanged: _setWindowOpacity,
                            ),
                          ),
                          const Icon(Icons.visibility, size: 14, color: Colors.white38),
                          const SizedBox(width: 4),
                          Text('${(_opacity * 100).round()}%',
                            style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ),
                ],
              ),
              // Notification toast
              Consumer<GameState>(
                builder: (context, gs, _) {
                  if (gs.notification == null || gs.notificationTimer <= 0) {
                    return const SizedBox.shrink();
                  }
                  final notifOpacity = gs.notificationTimer.clamp(0.0, 1.0);
                  return Positioned(
                    top: 50, left: 24, right: 24,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: notifOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xDD222244),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8, offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(gs.notification!, textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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

  void _setWindowOpacity(double value) {
    setState(() { _opacity = value; });
    if (!kIsWeb) {
      windowManager.setOpacity(value);
    }
  }
}
