import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  void _createRoom(int playerCount) {
    // TODO: Phase 4에서 실제 방 생성 로직 구현
    print('방 생성: $playerCount명');
    // 임시로 테스트 방 코드로 이동
    context.push('/lobby/TEST${playerCount}P');
  }

  void _joinRoom() {
    final roomCode = _roomCodeController.text.trim().toUpperCase();
    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('방 코드를 입력해주세요')));
      return;
    }
    // TODO: Phase 4에서 방 존재 여부 확인
    print('방 참가: $roomCode');
    context.push('/lobby/$roomCode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 타이틀
              const Text(
                '더 마인드',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'The Mind',
                style: TextStyle(fontSize: 24, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // 플레이어 수 선택
              const Text(
                '새 게임',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // 2명 버튼
              ElevatedButton(
                onPressed: () => _createRoom(2),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('2명', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 12),

              // 3명 버튼
              ElevatedButton(
                onPressed: () => _createRoom(3),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('3명', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 12),

              // 4명 버튼
              ElevatedButton(
                onPressed: () => _createRoom(4),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('4명', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 24),

              // 방 참가
              const Text(
                '방 참가',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // 방 코드 입력
              TextField(
                controller: _roomCodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '방 코드',
                  hintText: '6자리 코드 입력',
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
              ),
              const SizedBox(height: 16),

              // 참가 버튼
              ElevatedButton(
                onPressed: _joinRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('참가하기', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
