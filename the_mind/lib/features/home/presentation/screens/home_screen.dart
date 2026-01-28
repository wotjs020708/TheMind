import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../lobby/data/repositories/room_repository.dart';
import '../../../../shared/providers/supabase_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _roomCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom(int playerCount) async {
    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final roomRepo = RoomRepository(supabase);

      // 방 생성
      final room = await roomRepo.createRoom(playerCount);

      if (!mounted) return;

      // 로비 화면으로 이동
      context.push('/lobby/${room.code}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('방 생성 실패: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim().toUpperCase();
    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('방 코드를 입력해주세요')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final roomRepo = RoomRepository(supabase);

      // 방 존재 여부 확인
      final room = await roomRepo.findRoomByCode(roomCode);

      if (!mounted) return;

      if (room == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('존재하지 않는 방입니다')));
        return;
      }

      if (room.status != 'waiting') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미 시작된 게임입니다')));
        return;
      }

      // 로비 화면으로 이동
      context.push('/lobby/${room.code}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('방 참가 실패: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                onPressed: _isLoading ? null : () => _createRoom(2),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('2명', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 12),

              // 3명 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : () => _createRoom(3),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('3명', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 12),

              // 4명 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : () => _createRoom(4),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('4명', style: TextStyle(fontSize: 18)),
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
                enabled: !_isLoading,
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
                onPressed: _isLoading ? null : _joinRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('참가하기', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
