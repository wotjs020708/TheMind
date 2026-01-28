import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connection_manager_provider.dart';

/// 연결 상태 배너 위젯
class ConnectionStatusBanner extends ConsumerWidget {
  const ConnectionStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionManagerProvider);

    if (connectionState.isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color:
          connectionState.isReconnecting ? Colors.orange.shade700 : Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (connectionState.isReconnecting)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          if (connectionState.isReconnecting) const SizedBox(width: 12),
          Flexible(
            child: Text(
              connectionState.isReconnecting
                  ? '재접속 중... (${connectionState.reconnectAttempts}/${ConnectionManager.maxReconnectAttempts})'
                  : '연결이 끊겼습니다',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (connectionState.isDisconnected) const SizedBox(width: 12),
          if (connectionState.isDisconnected)
            TextButton(
              onPressed: () {
                ref.read(connectionManagerProvider.notifier).manualReconnect();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              child: const Text('재시도'),
            ),
        ],
      ),
    );
  }
}
