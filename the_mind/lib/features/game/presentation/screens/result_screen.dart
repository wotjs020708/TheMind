import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../../lobby/data/repositories/room_repository.dart';
import '../../../lobby/domain/models/room.dart';
import '../../../../core/utils/haptic_feedback_utils.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String roomCode;

  const ResultScreen({super.key, required this.roomCode});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  Room? _room;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    try {
      final supabase = ref.read(supabaseProvider);
      final roomRepo = RoomRepository(supabase);
      final room = await roomRepo.findRoomByCode(widget.roomCode);

      if (mounted) {
        setState(() {
          _room = room;
          _isLoading = false;
        });

        // 햅틱 피드백
        if (room != null) {
          if (room.status == 'completed') {
            await HapticFeedbackUtils.heavy();
          } else {
            await HapticFeedbackUtils.error();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_room == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '게임 정보를 찾을 수 없습니다',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('홈으로'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isVictory = _room!.status == 'completed';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 결과 아이콘 및 메시지
                  _buildResultHeader(isVictory),

                  const SizedBox(height: AppTheme.spacingXl),

                  // 통계 카드
                  _buildStatisticsCard(isVictory),

                  const SizedBox(height: AppTheme.spacingXl),

                  // 버튼들
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(bool isVictory) {
    return Column(
      children: [
        // 아이콘
        Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isVictory ? AppTheme.primaryGradient : null,
                color:
                    isVictory
                        ? null
                        : AppTheme.errorColor.withValues(alpha: 0.3),
                boxShadow: isVictory ? AppTheme.glowEffect : null,
              ),
              child: Center(
                child: Icon(
                  isVictory ? Icons.emoji_events : Icons.heart_broken,
                  size: 60,
                  color: isVictory ? AppTheme.accentColor : AppTheme.errorColor,
                ),
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 400.ms),

        const SizedBox(height: AppTheme.spacingLg),

        // 메시지
        Text(
              isVictory ? '🎉 승리!' : '💔 패배...',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: isVictory ? AppTheme.successColor : AppTheme.errorColor,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(
              begin: 0.3,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOut,
            ),

        const SizedBox(height: AppTheme.spacingSm),

        Text(
              isVictory ? '모든 레벨을 클리어했습니다!' : '다음에 다시 도전해보세요',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(
              begin: 0.3,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOut,
            ),
      ],
    );
  }

  Widget _buildStatisticsCard(bool isVictory) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.elevation2,
          ),
          child: Column(
            children: [
              Text('게임 통계', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppTheme.spacingLg),
              _buildStatRow('도달 레벨', '레벨 ${_room!.currentLevel}'),
              if (isVictory) ...[
                const SizedBox(height: AppTheme.spacingMd),
                _buildStatRow('남은 생명', '❤️ ${_room!.lives}'),
                const SizedBox(height: AppTheme.spacingMd),
                _buildStatRow('남은 수리검', '⭐ ${_room!.shurikens}'),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 홈으로 버튼
        SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await HapticFeedbackUtils.light();
                  if (mounted) context.go('/');
                },
                icon: const Icon(Icons.home),
                label: const Text('홈으로'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOut,
            ),

        const SizedBox(height: AppTheme.spacingMd),

        // 다시 하기 버튼
        SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await HapticFeedbackUtils.medium();
                  if (mounted) context.go('/');
                },
                icon: const Icon(Icons.refresh),
                label: Text(_room!.status == 'completed' ? '다시 하기' : '다시 도전'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 600.ms)
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOut,
            ),
      ],
    );
  }
}
