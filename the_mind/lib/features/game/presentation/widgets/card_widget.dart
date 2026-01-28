import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:the_mind/shared/models/game_card.dart';

class CardWidget extends StatelessWidget {
  final GameCard card;
  final VoidCallback? onTap;
  final bool isPlayable;
  final bool animate;

  const CardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.isPlayable = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: Container(
        width: 60,
        height: 90,
        decoration: BoxDecoration(
          color: isPlayable ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${card.number}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPlayable ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );

    // 애니메이션 적용
    if (!animate) return cardWidget;

    return cardWidget
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }
}
