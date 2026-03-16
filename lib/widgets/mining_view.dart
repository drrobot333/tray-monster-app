import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/models.dart';
import '../data/game_data.dart';
import 'robot_name_dialog.dart';
import 'sprite_widget.dart';

class MiningView extends StatefulWidget {
  const MiningView({super.key});
  @override
  State<MiningView> createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with SingleTickerProviderStateMixin {
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
      case 'collecting': return 'robot_harvest';
      case 'digging': return 'robot_plant';
      case 'extracting': return 'robot_water';
      case 'walking': return (_anim.value * 4).floor() % 2 == 0 ? 'robot_walk1' : 'robot_walk2';
      default: return 'robot_idle';
    }
  }

  String _stateLabel(String s) {
    const m = {'idle':'대기','walking':'이동','digging':'채굴','extracting':'추출','collecting':'수집','resting':'휴식'};
    return m[s] ?? s;
  }

  Color _tileColor(MiningTile t) {
    if (t.depleted) return const Color(0xFF2A2A2A);
    if (t.currentOreId == null) return const Color(0xFF3A3020);
    return const Color(0xFF4A3828);
  }

  String _oreName(MiningTile t) {
    if (t.depleted) return '고갈';
    if (t.currentOreId == null) return '';
    final ore = GameData.ores.where((o) => o.id == t.currentOreId).firstOrNull;
    return ore?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final tiles = gs.miningTiles;
    final robot = gs.miningRobot;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availH = constraints.maxHeight;
          const double gap = 3;
          final gridSide = availH;
          final cell = (gridSide - gap * 2) / 3;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                          child: _tile(tiles[r][c], cell),
                        ),
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
                  ],
                ),
              ),
              const SizedBox(width: 6),
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
                      PixelSprite(spriteId: _robotSprite(robot.state), size: min(gridSide * 0.25, 40), animPhase: _anim.value),
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => RobotNameDialog(robot: robot, onChanged: () => gs.notify()),
                        ),
                        child: Text(robot.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
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
                              robot.stamina > robot.maxStamina * 0.3 ? const Color(0xFFFF9800) : const Color(0xFFFF5252)),
                          ),
                        ),
                        Text('${robot.stamina.toInt()}/${robot.maxStamina.toInt()}',
                          style: const TextStyle(color: Colors.white54, fontSize: 8)),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_stateLabel(robot.state),
                          style: const TextStyle(color: Color(0xFFFF9800), fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _tile(MiningTile tile, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: _tileColor(tile),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: tile.depleted ? const Color(0xFF555555) : const Color(0xFFFF9800),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!tile.depleted && tile.currentOreId != null)
            PixelSprite(spriteId: oreSpriteId(tile.currentOreId), size: min(size * 0.6, 32))
          else
            Text(tile.depleted ? '💨' : '🪨', style: TextStyle(fontSize: min(size * 0.3, 16))),
          Text(_oreName(tile), style: TextStyle(color: Colors.white70, fontSize: min(size * 0.15, 7))),
          if (!tile.depleted && tile.durability > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(tile.durability, (_) =>
                Icon(Icons.circle, size: min(size * 0.08, 4), color: const Color(0xFFFF9800))),
            ),
          if (tile.depleted)
            SizedBox(
              width: size - 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: tile.respawnTimer > 0 ? (1.0 - tile.respawnTimer / 60).clamp(0.0, 1.0) : 0,
                  minHeight: 2,
                  backgroundColor: const Color(0xFF333333),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF555555)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
