import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/game_event_repository.dart';
import '../../../../shared/providers/supabase_provider.dart';

/// Provider to listen for shuriken proposal events
final shurikenProposalProvider = StreamProvider.family<String?, String>((
  ref,
  roomId,
) {
  final supabase = ref.watch(supabaseProvider);
  final eventRepo = GameEventRepository(supabase);

  return eventRepo
      .subscribeToEvents(roomId)
      .where((event) {
        return event.eventType == GameEventType.shurikenProposed;
      })
      .map((event) {
        return event.data?['proposal_id'] as String?;
      });
});
