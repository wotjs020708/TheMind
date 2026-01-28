import 'package:flutter/material.dart';

class ShurikensDisplay extends StatelessWidget {
  final int shurikens;

  const ShurikensDisplay({super.key, required this.shurikens});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 24),
        const SizedBox(width: 8),
        Text(
          '$shurikens',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
