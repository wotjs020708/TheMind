import 'package:flutter/material.dart';

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
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 축하 아이콘
                const Icon(Icons.check_circle, size: 80, color: Colors.green),

                const SizedBox(height: 24),

                // 레벨 클리어 메시지
                Text(
                  '레벨 $level 클리어!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // 보상 표시 (있을 경우)
                if (rewardText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
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
                  ),
                  const SizedBox(height: 24),
                ],

                // 다음 레벨 버튼
                ElevatedButton(
                  onPressed: onNextLevel,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('다음 레벨', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
