import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0a1628),
        border: Border(bottom: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(
        children: [
          // Gold display
          const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 18),
          const SizedBox(width: 4),
          Text(
            '${gs.gold}',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          // Materials
          _materialIcon(context, '\u2694', 'attackCrystal', gs.materials['attackCrystal'] ?? 0, '\uACF5\uACA9 \uD06C\uB9AC\uC2A4\uD0C8'),
          const SizedBox(width: 8),
          _materialIcon(context, '\uD83D\uDEE1', 'defenseCore', gs.materials['defenseCore'] ?? 0, '\uBC29\uC5B4 \uCF54\uC5B4'),
          const SizedBox(width: 8),
          _materialIcon(context, '\u26A1', 'speedChip', gs.materials['speedChip'] ?? 0, '\uC18D\uB3C4 \uCE69'),
          const SizedBox(width: 8),
          _materialIcon(context, '\uD83E\uDD5A', 'eggFragment', gs.materials['eggFragment'] ?? 0, '\uC54C \uC870\uAC01'),
          const SizedBox(width: 8),
          _materialIcon(context, '\uD83E\uDDEC', 'mutagen', gs.materials['mutagen'] ?? 0, '\uBBA4\uD0C0\uC820'),
          const Spacer(),
          // Weather with tooltip
          Tooltip(
            richMessage: TextSpan(
              children: [
                TextSpan(text: '${_weatherName(gs.currentWeather)}\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                TextSpan(text: _weatherEffect(gs.currentWeather), style: const TextStyle(fontSize: 11)),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_weatherIcon(gs.currentWeather), style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(_weatherName(gs.currentWeather), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _materialIcon(BuildContext context, String emoji, String key, int count, String tooltip) {
    return Tooltip(
      message: '$tooltip: $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _weatherName(String weather) {
    switch (weather) {
      case 'sunny': return '맑음';
      case 'rain': return '비';
      case 'storm': return '폭풍';
      case 'night': return '밤';
      case 'heatwave': return '폭염';
      case 'frost': return '서리';
      default: return weather;
    }
  }

  String _weatherEffect(String weather) {
    switch (weather) {
      case 'sunny': return '작물 성장 +30%';
      case 'rain': return '자동 물주기, 성장 +10%';
      case 'storm': return '희귀 드롭 +100%\n로봇 체력소모 +50%';
      case 'night': return '돌연변이 확률 +50%';
      case 'heatwave': return '불/사막 작물 2배 성장\n다른 작물 -20%';
      case 'frost': return '크리스탈 작물 2배 성장\n다른 작물 -20%';
      default: return '';
    }
  }

  String _weatherIcon(String weather) {
    switch (weather) {
      case 'sunny':
        return '\u2600\uFE0F';
      case 'rain':
        return '\uD83C\uDF27\uFE0F';
      case 'storm':
        return '\u26C8\uFE0F';
      case 'night':
        return '\uD83C\uDF19';
      case 'heatwave':
        return '\uD83D\uDD25';
      case 'frost':
        return '\u2744\uFE0F';
      default:
        return '\u2600\uFE0F';
    }
  }
}
