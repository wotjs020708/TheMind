import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_provider.dart';
import '../../data/repositories/shuriken_vote_repository.dart';
import '../../../../shared/providers/supabase_provider.dart';

/// 수리검 투표 다이얼로그
class ShurikenVoteDialog extends ConsumerStatefulWidget {
  final String roomId;
  final String proposalId;
  final String currentPlayerId;
  final int playerCount;

  const ShurikenVoteDialog({
    super.key,
    required this.roomId,
    required this.proposalId,
    required this.currentPlayerId,
    required this.playerCount,
  });

  @override
  ConsumerState<ShurikenVoteDialog> createState() => _ShurikenVoteDialogState();
}

class _ShurikenVoteDialogState extends ConsumerState<ShurikenVoteDialog> {
  bool? _myVote;
  bool _hasVoted = false;

  @override
  Widget build(BuildContext context) {
    final supabase = ref.watch(supabaseProvider);
    final voteRepo = ShurikenVoteRepository(supabase);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: voteRepo.subscribeToVotes(widget.proposalId),
      builder: (context, snapshot) {
        final votes = snapshot.data ?? [];
        final yesCount = votes.where((v) => v['vote'] == true).length;
        final noCount = votes.where((v) => v['vote'] == false).length;
        final totalVotes = votes.length;

        // 투표 완료 확인
        if (totalVotes == widget.playerCount) {
          // 만장일치 여부에 따라 결과 표시
          final isUnanimous = votes.every((v) => v['vote'] == true);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final navigator = Navigator.of(context);
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) navigator.pop();
              });
            }
          });

          return AlertDialog(
            title: Text(
              isUnanimous ? '✅ 수리검 사용!' : '❌ 거부됨',
              style: TextStyle(color: isUnanimous ? Colors.green : Colors.red),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUnanimous
                      ? '모든 플레이어가 동의했습니다.\n수리검을 사용합니다.'
                      : '한 명 이상이 거부했습니다.\n수리검을 사용할 수 없습니다.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '찬성: $yesCount / 반대: $noCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        return AlertDialog(
          title: const Text('수리검 사용 투표'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '수리검 사용에 동의하시나요?\n모든 플레이어가 동의해야 사용됩니다.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 투표 현황
              LinearProgressIndicator(
                value: totalVotes / widget.playerCount,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 8),
              Text(
                '투표 진행: $totalVotes / ${widget.playerCount}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // 현재 투표 상황
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(height: 4),
                      Text('찬성: $yesCount'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.cancel, color: Colors.red),
                      const SizedBox(height: 4),
                      Text('반대: $noCount'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions:
              _hasVoted
                  ? [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        _myVote == true ? '✅ 찬성함' : '❌ 반대함',
                        style: TextStyle(
                          color: _myVote == true ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ]
                  : [
                    TextButton(
                      onPressed: () => _vote(false),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('반대'),
                    ),
                    ElevatedButton(
                      onPressed: () => _vote(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('찬성'),
                    ),
                  ],
        );
      },
    );
  }

  Future<void> _vote(bool vote) async {
    if (_hasVoted) return;

    setState(() {
      _myVote = vote;
      _hasVoted = true;
    });

    await ref
        .read(
          gameStateProvider(
            GameStateParams(
              roomId: widget.roomId,
              currentPlayerId: widget.currentPlayerId,
            ),
          ).notifier,
        )
        .voteShurikenUse(
          proposalId: widget.proposalId,
          playerId: widget.currentPlayerId,
          vote: vote,
        );
  }
}
