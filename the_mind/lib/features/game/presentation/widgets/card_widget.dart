import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:the_mind/shared/models/game_card.dart';
import 'package:the_mind/shared/theme/app_theme.dart';

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
        width: 70,
        height: 100,
        decoration: BoxDecoration(
          gradient: isPlayable ? AppTheme.cardGradient : null,
          color: isPlayable ? null : Colors.grey[800],
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isPlayable ? AppTheme.accentColor : Colors.grey[700]!,
            width: 3,
          ),
          boxShadow: isPlayable ? AppTheme.cardShadow : AppTheme.elevation1,
        ),
        child: Stack(
          children: [
            // 배경 패턴
            if (isPlayable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd - 2),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      center: Alignment.topLeft,
                      radius: 1.5,
                    ),
                  ),
                ),
              ),
            // 숫자
            Center(
              child: Text(
                '${card.number}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isPlayable ? Colors.black87 : Colors.grey[600],
                  shadows:
                      isPlayable
                          ? [
                            Shadow(
                              color: AppTheme.accentColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                            ),
                          ]
                          : null,
                ),
              ),
            ),
            // 작은 숫자 (왼쪽 위, 오른쪽 아래)
            if (isPlayable) ...[
              Positioned(
                top: 6,
                left: 8,
                child: Text(
                  '${card.number}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 8,
                child: Text(
                  '${card.number}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ],
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
