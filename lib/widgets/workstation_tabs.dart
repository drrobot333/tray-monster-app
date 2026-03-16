import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import 'farm_view.dart';
import 'fishing_view.dart';
import 'mining_view.dart';

class WorkstationTabs extends StatelessWidget {
  const WorkstationTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final tabIndex = gs.workstationTab;

    return Column(
      children: [
        // Mini tab bar (28px)
        SizedBox(
          height: 28,
          child: Row(
            children: [
              _tab(context, gs, 0, '\uD83C\uDF3E', '\uB18D\uC7A5', tabIndex == 0),
              _tab(context, gs, 1, '\uD83C\uDFA3', '\uB09A\uC2DC', tabIndex == 1),
              _tab(context, gs, 2, '\u26CF', '\uCC44\uAD11', tabIndex == 2),
            ],
          ),
        ),
        // Content
        Expanded(
          child: IndexedStack(
            index: tabIndex,
            children: const [
              FarmView(),
              FishingView(),
              MiningView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tab(BuildContext context, GameState gs, int index, String emoji, String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          gs.workstationTab = index;
          gs.notify();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1a2a3e) : const Color(0xFF0d1117),
            border: Border(
              bottom: BorderSide(
                color: active ? const Color(0xFF4CAF50) : const Color(0xFF333333),
                width: active ? 2 : 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: 12, color: active ? Colors.white : Colors.white54)),
              const SizedBox(width: 3),
              Text(label, style: TextStyle(
                fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? Colors.white : Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}
