import 'package:flutter/material.dart';

class PinIndicator extends StatelessWidget {
  final int length;
  final int filled;

  const PinIndicator({
    super.key,
    required this.length,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < filled
                ? Colors.deepPurple
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}