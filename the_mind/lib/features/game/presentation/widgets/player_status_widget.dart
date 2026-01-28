import 'package:flutter/material.dart';

class PlayerStatusWidget extends StatelessWidget {
  final String playerName;
  final int cardsRemaining;
  final bool isConnected;

  const PlayerStatusWidget({
    super.key,
    required this.playerName,
    required this.cardsRemaining,
    this.isConnected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            isConnected
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            playerName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isConnected ? null : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isConnected ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$cardsRemaining',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
