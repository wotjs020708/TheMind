import 'package:go_router/go_router.dart';
import 'package:the_mind/features/home/presentation/screens/home_screen.dart';
import 'package:the_mind/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:the_mind/features/game/presentation/screens/game_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/lobby/:roomCode',
      name: 'lobby',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        return LobbyScreen(roomCode: roomCode);
      },
    ),
    GoRoute(
      path: '/game/:roomCode',
      name: 'game',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        final playerId = state.uri.queryParameters['playerId'];
        return GameScreen(roomCode: roomCode, playerId: playerId);
      },
    ),
  ],
);
