import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/room_repository.dart';
import '../../../../shared/providers/supabase_provider.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return RoomRepository(supabase);
});
