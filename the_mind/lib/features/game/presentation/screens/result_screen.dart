import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultScreen extends StatelessWidget {
  final String roomCode;

  const ResultScreen({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    // TODO: Phase 4에서 실제 게임 결과 데이터로 교체
    final bool isVictory = true; // Mock 데이터
    final int finalLevel = 5; // Mock 데이터

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 결과 이미지/아이콘
              Icon(
                isVictory ? Icons.celebration : Icons.mood_bad,
                size: 120,
                color: isVictory ? Colors.amber : Colors.grey,
              ),

              const SizedBox(height: 32),

              // 결과 메시지
              Text(
                isVictory ? '승리!' : '패배...',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isVictory ? Colors.amber : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 최종 레벨
              Text(
                isVictory ? '모든 레벨 클리어!' : '레벨 $finalLevel 도달',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 64),

              // 다시 하기 버튼
              ElevatedButton(
                onPressed: () {
                  // TODO: Phase 4에서 같은 방으로 다시 시작 로직
                  context.go('/lobby/$roomCode');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('다시 하기', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 12),

              // 홈으로 버튼
              OutlinedButton(
                onPressed: () {
                  context.go('/');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('홈으로', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
