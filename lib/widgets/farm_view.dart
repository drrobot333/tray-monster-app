import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/models.dart';
import 'crop_picker_dialog.dart';
import 'robot_name_dialog.dart';
import 'sprite_widget.dart';

class FarmView extends StatefulWidget {
  const FarmView({super.key});
  @override
  State<FarmView> createState() => _FarmViewState();
}

class _FarmViewState extends State<FarmView> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  String _robotSprite(String state) {
    switch (state) {
      case 'resting': return 'robot_rest';
      case 'harvesting': return 'robot_harvest';
      case 'watering': return 'robot_water';
      case 'planting': return 'robot_plant';
      case 'walking': return (_anim.value * 4).floor() % 2 == 0 ? 'robot_walk1' : 'robot_walk2';
      default: return 'robot_idle';
    }
  }

  Color _soilColor(FarmTile t) {
    if (t.golden && t.growthProgress >= 1.0) return const Color(0xFF6B5A10);
    if (t.growthProgress >= 1.0) return const Color(0xFF2E5A1E);
    if (t.watered && t.crop != null) return const Color(0xFF1E3A2E);
    if (t.crop != null) return const Color(0xFF4A3520);
    return const Color(0xFF2A1E10);
  }

  Color _borderColor(FarmTile t) {
    if (t.golden && t.growthProgress >= 1.0) return const Color(0xFFFFD700);
    if (t.growthProgress >= 1.0) return const Color(0xFF4CAF50);
    if (t.watered) return const Color(0xFF2196F3);
    if (t.crop != null) return const Color(0xFF8D6E63);
    return const Color(0xFF444444);
  }

  String _stateLabel(String s) {
    const m = {'idle':'대기','walking':'이동','planting':'파종','watering':'물주기','harvesting':'수확','resting':'휴식'};
    return m[s] ?? s;
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final tiles = gs.farmTiles;
    final robot = gs.robot;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Available height for the farm row
          final availH = constraints.maxHeight;

          // Grid is square, sized to fit available height
          const double gap = 3;
          final gridSide = availH;
          final cell = (gridSide - gap * 2) / 3;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Farm grid (square, height-based) ──
              SizedBox(
                width: gridSide,
                height: gridSide,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (int r = 0; r < 3; r++)
                      for (int c = 0; c < 3; c++)
                        Positioned(
                          left: c * (cell + gap),
                          top: r * (cell + gap),
                          child: _tile(context, tiles[r][c], r, c, cell),
                        ),
                    // Robot
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (context, _) {
                        final step = cell + gap;
                        double rx, ry;
                        if (robot.state == 'walking') {
                          rx = (robot.pixelX / 48 - 0.5).clamp(0.0, 2.0);
                          ry = (robot.pixelY / 48 - 0.5).clamp(0.0, 2.0);
                        } else {
                          rx = robot.x.toDouble();
                          ry = robot.y.toDouble();
                        }
                        final x = rx * step + cell / 2 - 18;
                        final y = ry * step + cell / 2 - 22;
                        final bounce = robot.state == 'walking' ? sin(_anim.value * pi * 4) * 2 : 0.0;

                        return Positioned(
                          left: x, top: y + bounce,
                          child: IgnorePointer(
                            child: PixelSprite(spriteId: _robotSprite(robot.state), size: min(cell * 0.7, 36), animPhase: _anim.value),
                          ),
                        );
                      },
                    ),
                    // Floating texts
                    ...gs.floatingTexts.map((ft) {
                      final step = cell + gap;
                      final fx = ft.col * step + cell / 2 - 16;
                      final progress = 1.0 - (ft.timer / 1.5).clamp(0.0, 1.0);
                      final fy = ft.row * step - progress * 24;
                      return Positioned(
                        left: fx, top: fy,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: (ft.timer / 0.5).clamp(0.0, 1.0),
                            child: Text(ft.text, style: TextStyle(
                              color: Color(ft.color), fontSize: 11, fontWeight: FontWeight.bold,
                              shadows: const [Shadow(color: Colors.black, blurRadius: 3)])),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // ── Robot status (fills remaining width, same height as grid) ──
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d1117),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (robot.sleepwalking || robot.pendingGold > 0) {
                            // Find engine and wake up
                            try {
                              // Collect pending rewards directly
                              if (robot.pendingGold > 0 || robot.pendingItems > 0) {
                                gs.gold += robot.pendingGold;
                                final mats = ['attackCrystal', 'defenseCore', 'speedChip'];
                                for (int i = 0; i < robot.pendingItems; i++) {
                                  final key = mats[i % mats.length];
                                  gs.materials[key] = (gs.materials[key] ?? 0) + 1;
                                }
                                gs.notification = '${robot.name} 기상! +${robot.pendingGold}G +${robot.pendingItems}재료';
                                gs.notificationTimer = 3;
                                gs.floatingTexts.add(FloatingText(
                                  text: '+${robot.pendingGold}G',
                                  col: robot.x, row: robot.y, color: 0xFFFFD700));
                              }
                              robot.pendingGold = 0;
                              robot.pendingItems = 0;
                              robot.sleepwalking = false;
                              robot.awakeSince = gs.time;
                              gs.notify();
                            } catch (_) {}
                          } else {
                            showDialog(context: context,
                              builder: (_) => RobotNameDialog(robot: robot, onChanged: () => gs.notify()));
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PixelSprite(
                              spriteId: robot.sleepwalking ? 'robot_rest' : _robotSprite(robot.state),
                              size: min(gridSide * 0.25, 40), animPhase: _anim.value),
                            if (robot.sleepwalking)
                              Text('💤 ${robot.pendingGold}G 쌓임',
                                style: const TextStyle(color: Color(0xFFFF9800), fontSize: 8, fontWeight: FontWeight.bold))
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => showDialog(context: context,
                          builder: (_) => RobotNameDialog(robot: robot, onChanged: () => gs.notify())),
                        child: Text(robot.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                      // Stamina
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('스태미나', style: TextStyle(color: Colors.white54, fontSize: 8)),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: robot.maxStamina > 0 ? (robot.stamina / robot.maxStamina).clamp(0.0, 1.0) : 0,
                            minHeight: 6,
                            backgroundColor: const Color(0xFF333333),
                            valueColor: AlwaysStoppedAnimation(
                              robot.stamina > robot.maxStamina * 0.3 ? const Color(0xFF4CAF50) : const Color(0xFFFF5252)),
                          ),
                        ),
                        Text('${robot.stamina.toInt()}/${robot.maxStamina.toInt()}',
                          style: const TextStyle(color: Colors.white54, fontSize: 8)),
                      ]),
                      // State
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF88CCFF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_stateLabel(robot.state),
                          style: const TextStyle(color: Color(0xFF88CCFF), fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      // Stage
                      Text('Stage ${gs.currentStage}',
                        style: const TextStyle(color: Color(0xFF2196F3), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext ctx, FarmTile tile, int r, int c, double size) {
    return GestureDetector(
      onTap: () => showDialog(context: ctx, builder: (_) => CropPickerDialog(tileRow: r, tileCol: c)),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: _soilColor(tile),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _borderColor(tile), width: tile.golden && tile.growthProgress >= 1.0 ? 2 : 1),
        ),
        child: Stack(
          children: [
            if (tile.crop != null)
              Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                PixelSprite(spriteId: cropSpriteId(tile.crop, tile.growthProgress), size: min(size * 0.55, 28)),
                SizedBox(width: size - 8, child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: tile.growthProgress.clamp(0.0, 1.0), minHeight: 3,
                    backgroundColor: const Color(0xFF333333),
                    valueColor: AlwaysStoppedAnimation(
                      tile.growthProgress >= 1.0 ? const Color(0xFFFFD700) : const Color(0xFF4CAF50))),
                )),
              ])),
            if (tile.crop == null)
              Center(child: Text(tile.assignedCrop != null ? '📌' : '+',
                style: TextStyle(color: tile.assignedCrop != null ? Colors.white54 : Colors.white24, fontSize: 14))),
            if (tile.watered) const Positioned(left: 1, top: 1, child: Text('💧', style: TextStyle(fontSize: 7))),
            if (tile.growthProgress >= 1.0) const Positioned(right: 1, bottom: 1, child: Text('✅', style: TextStyle(fontSize: 7))),
          ],
        ),
      ),
    );
  }
}
