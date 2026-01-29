import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:the_mind/core/router/app_router.dart';
import 'package:the_mind/shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web에서는 환경 변수를 직접 사용, 모바일에서는 .env 파일 로드
  String supabaseUrl;
  String supabaseAnonKey;

  if (kIsWeb) {
    // Web 빌드: 빌드 타임에 주입된 환경 변수 사용
    supabaseUrl = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://cxdlxrxmszaomeroosnh.supabase.co',
    );
    supabaseAnonKey = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4ZGx4cnhtc3phb21lcm9vc25oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1NzUwMjAsImV4cCI6MjA4NTE1MTAyMH0.6lp1AN8dSTPjtcbw3enQvJC5eFsFD93UfDSWux6HBz4',
    );
  } else {
    // 모바일 빌드: .env 파일에서 로드
    await dotenv.load(fileName: '.env');
    supabaseUrl = dotenv.env['SUPABASE_URL']!;
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '더 마인드',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
