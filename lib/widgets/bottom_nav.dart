import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  const BottomNav({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      ('\uD83C\uDF3E', '\uB18D\uC7A5'),
      ('\uD83D\uDECD', '\uC0C1\uC810'),
      ('\uD83D\uDC65', '\uD300'),
      ('\uD83C\uDF73', '\uC694\uB9AC'),
      ('\uD83D\uDCCA', '\uAC15\uD654'),
      ('\uD83D\uDCD6', '\uB3C4\uAC10'),
    ];

    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF0d1117),
        border: Border(top: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = currentTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isActive
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  color: isActive
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tabs[i].$1,
                      style: TextStyle(
                        fontSize: 18,
                        color: isActive ? Colors.white : Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tabs[i].$2,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? Colors.white : Colors.white54,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
