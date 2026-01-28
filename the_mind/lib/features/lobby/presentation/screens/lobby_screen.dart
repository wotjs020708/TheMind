import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_mind/features/game/domain/models/player.dart';
import 'package:the_mind/shared/models/game_card.dart';

class LobbyScreen extends StatefulWidget {
  final String roomCode;

  const LobbyScreen({super.key, required this.roomCode});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  // TODO: Phase 4에서 실제 Supabase 데이터로 교체
  final List<Player> _mockPlayers = [
    const Player(
      id: '1',
      name: '플레이어 1',
      position: 0,
      cards: [],
      isReady: true,
      isConnected: true,
    ),
    const Player(
      id: '2',
      name: '플레이어 2',
      position: 1,
      cards: [],
      isReady: false,
      isConnected: true,
    ),
  ];

  bool _isReady = false;

  void _toggleReady() {
    setState(() {
      _isReady = !_isReady;
    });
    // TODO: Phase 4에서 Supabase에 준비 상태 전송
    print('준비 상태 변경: $_isReady');
  }

  void _startGame() {
    // TODO: Phase 4에서 모든 플레이어 준비 상태 확인
    print('게임 시작');
    context.go('/game/${widget.roomCode}');
  }

  void _leaveLobby() {
    // TODO: Phase 4에서 방 나가기 로직
    context.go('/');
  }

  bool get _allPlayersReady {
    // TODO: Phase 4에서 실제 플레이어 준비 상태 확인
    return _mockPlayers.where((p) => p.isReady).length == _mockPlayers.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대기실'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaveLobby,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 방 코드 표시
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '방 코드',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.roomCode,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 플레이어 목록
              const Text(
                '플레이어',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: _mockPlayers.length,
                  itemBuilder: (context, index) {
                    final player = _mockPlayers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(
                          player.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing:
                            player.isReady
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                                : const Icon(
                                  Icons.schedule,
                                  color: Colors.grey,
                                ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 준비 버튼
              ElevatedButton(
                onPressed: _toggleReady,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isReady ? Colors.grey : null,
                ),
                child: Text(
                  _isReady ? '준비 취소' : '준비',
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 12),

              // 게임 시작 버튼 (방장만)
              ElevatedButton(
                onPressed: _allPlayersReady ? _startGame : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('게임 시작', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
