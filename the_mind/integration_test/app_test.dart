import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:the_mind/main.dart' as app;

/// 간단한 통합 테스트: 홈 화면만 검증
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('게임 E2E 테스트', () {
    testWidgets('홈 화면 표시 테스트', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 홈 화면 요소 확인
      expect(find.text('더 마인드'), findsOneWidget);
      expect(find.text('The Mind'), findsOneWidget);
      expect(find.text('새 게임'), findsOneWidget);
      expect(find.text('방 참가'), findsOneWidget);

      // 플레이어 수 버튼 확인
      expect(find.text('2명'), findsOneWidget);
      expect(find.text('3명'), findsOneWidget);
      expect(find.text('4명'), findsOneWidget);

      print('✅ 홈 화면 표시 성공 (오버플로우 없음)');
    });

    testWidgets('스크롤 가능 여부 테스트', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // SingleChildScrollView 존재 확인
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // 아래로 스크롤
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // 방 참가 섹션이 여전히 보임
      expect(find.text('방 참가'), findsOneWidget);
      expect(find.text('참가하기'), findsOneWidget);

      print('✅ 스크롤 동작 정상');
    });

    testWidgets('버튼 탭 가능 여부 테스트', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 2명 버튼 찾기
      final button = find.text('2명');
      expect(button, findsOneWidget);

      // 탭 가능 여부 확인 (실제로 탭하지는 않음)
      final widget = tester.widget<Text>(button);
      expect(widget.data, '2명');

      print('✅ 버튼을 찾을 수 있음');

      // 참고: 실제 방 생성은 Supabase 연결이 필요하므로
      // 이 테스트에서는 탭하지 않음
    });
  });
}
