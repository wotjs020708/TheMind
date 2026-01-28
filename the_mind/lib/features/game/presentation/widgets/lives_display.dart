import 'package:flutter/material.dart';

class LivesDisplay extends StatelessWidget {
  final int lives;

  const LivesDisplay({super.key, required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite, color: Colors.red, size: 24),
        const SizedBox(width: 8),
        Text(
          '$lives',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
