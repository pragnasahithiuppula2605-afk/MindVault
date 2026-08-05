import 'package:flutter/material.dart';

class PinKeyboard extends StatelessWidget {
  final Function(String) onPressed;
  final VoidCallback onDelete;

  const PinKeyboard({
    super.key,
    required this.onPressed,
    required this.onDelete,
  });

  Widget _number(String value) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () => onPressed(value),
      child: SizedBox(
        width: 75,
        height: 75,
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row in const [
          ["1", "2", "3"],
          ["4", "5", "6"],
          ["7", "8", "9"],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map(_number).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 75),
            _number("0"),
            InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: onDelete,
              child: const SizedBox(
                width: 75,
                height: 75,
                child: Icon(
                  Icons.backspace_outlined,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}