import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import 'egg_tab.dart';
import 'chest_shop.dart';
import '../screens/skill_shop.dart';

class ShopTab extends StatefulWidget {
  final GameEngine engine;
  const ShopTab({super.key, required this.engine});

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  int _subTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Row(children: [
            _subTabButton(0, '🥚 알'),
            _subTabButton(1, '📦 상자'),
            _subTabButton(2, '🔓 스킬'),
          ]),
        ),
        Expanded(
          child: _subTab == 0
            ? EggTab(engine: widget.engine)
            : _subTab == 1
              ? ChestShop(engine: widget.engine)
              : SkillShop(engine: widget.engine),
        ),
      ],
    );
  }

  Widget _subTabButton(int index, String label) {
    final isActive = _subTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _subTab = index; }),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isActive ? Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5)) : null,
          ),
          child: Text(label, style: TextStyle(
            color: isActive ? const Color(0xFF4CAF50) : Colors.white54,
            fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }
}
