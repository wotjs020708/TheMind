import 'dart:io';
import 'package:flutter/foundation.dart';

/// 플랫폼 감지 유틸리티
class PlatformUtils {
  /// 현재 플랫폼이 iOS인지 확인
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// 현재 플랫폼이 Android인지 확인
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// 현재 플랫폼이 Web인지 확인
  static bool get isWeb => kIsWeb;

  /// 현재 플랫폼이 데스크톱인지 확인 (macOS, Windows, Linux)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// 현재 플랫폼이 모바일인지 확인 (iOS, Android)
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }
}
