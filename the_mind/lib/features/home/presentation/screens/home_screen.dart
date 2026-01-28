import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../lobby/data/repositories/room_repository.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 타이틀
                Column(
                  children: [
                    ShaderMask(
                      shaderCallback:
                          (bounds) =>
                              AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        '더 마인드',
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(duration: 600.ms).scale(delay: 100.ms),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'The Mind',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXxl),

                // 새 게임 섹션
                _buildSection(
                  context,
                  title: '새 게임',
                  icon: Icons.add_circle_outline,
                  children: [
                    _buildPlayerCountButton(
                      context,
                      2,
                      '2명',
                      Icons.people_outline,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildPlayerCountButton(context, 3, '3명', Icons.people),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildPlayerCountButton(context, 4, '4명', Icons.groups),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppTheme.spacingXl),

                // 구분선
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.textMuted.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                      ),
                      child: Text(
                        '또는',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.textMuted.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // 방 참가 섹션
                _buildSection(
                  context,
                  title: '방 참가',
                  icon: Icons.login,
                  children: [
                    TextField(
                      controller: _roomCodeController,
                      enabled: !_isLoading,
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: '방 코드',
                        hintText: 'ABC123',
                        counterText: '',
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        filled: true,
                        fillColor: AppTheme.surfaceColor,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _joinRoom,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.arrow_forward),
                        label: Text(_isLoading ? '참가 중...' : '참가하기'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: AppTheme.spacingSm),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPlayerCountButton(
    BuildContext context,
    int count,
    String label,
    IconData icon,
  ) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _createRoom(count),
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
      ),
    );
  }
}
