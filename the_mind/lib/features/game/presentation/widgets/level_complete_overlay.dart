import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final int level;
  final String? rewardText;
  final VoidCallback onNextLevel;

  const LevelCompleteOverlay({
    super.key,
    required this.level,
    this.rewardText,
    required this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Card(
              margin: const EdgeInsets.all(32),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 축하 아이콘 (펄스 + 스케일 애니메이션)
                    const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green,
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.2, 1.2),
                          duration: 800.ms,
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.2, 1.2),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(height: 24),

                    // 레벨 클리어 메시지 (페이드인 + 슬라이드)
                    Text(
                          '레벨 $level 클리어!',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideY(
                          begin: -0.3,
                          end: 0,
                          duration: 500.ms,
                          delay: 200.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 16),

                    // 보상 표시 (있을 경우) - 스케일 애니메이션
                    if (rewardText != null) ...[
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: Text(
                              rewardText!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 600.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 400.ms,
                            delay: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 24),
                    ],

                    // 다음 레벨 버튼 - 페이드인
                    ElevatedButton(
                          onPressed: onNextLevel,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            '다음 레벨',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 800.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 400.ms,
                          delay: 800.ms,
                          curve: Curves.easeOut,
                        ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
