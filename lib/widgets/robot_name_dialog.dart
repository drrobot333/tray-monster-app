import 'package:flutter/material.dart';
import '../models/models.dart';

class RobotNameDialog extends StatefulWidget {
  final RobotState robot;
  final VoidCallback onChanged;

  const RobotNameDialog({super.key, required this.robot, required this.onChanged});

  @override
  State<RobotNameDialog> createState() => _RobotNameDialogState();
}

class _RobotNameDialogState extends State<RobotNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.robot.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1a1a2e),
      title: const Text('로봇 이름 변경', style: TextStyle(color: Colors.white, fontSize: 16)),
      content: TextField(
        controller: _controller,
        maxLength: 8,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '이름 입력 (최대 8자)',
          hintStyle: const TextStyle(color: Colors.white38),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF333333)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            borderRadius: BorderRadius.circular(8),
          ),
          counterStyle: const TextStyle(color: Colors.white38),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty && name.length <= 8) {
              widget.robot.name = name;
              widget.onChanged();
              Navigator.pop(context);
            }
          },
          child: const Text('확인', style: TextStyle(color: Color(0xFF4CAF50))),
        ),
      ],
    );
  }
}
