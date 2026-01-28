import 'package:flutter/services.dart';
import 'platform_utils.dart';

/// 플랫폼별 햅틱 피드백 유틸리티
/// iOS와 Android에서만 작동하며, Web/Desktop에서는 아무 동작도 하지 않습니다.
class HapticFeedbackUtils {
  /// 가벼운 터치 피드백 (버튼 탭, 선택)
  static Future<void> light() async {
    if (PlatformUtils.isMobile) {
      await HapticFeedback.lightImpact();
    }
  }

  /// 중간 강도 피드백 (중요한 액션)
  static Future<void> medium() async {
    if (PlatformUtils.isMobile) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// 강한 피드백 (게임 이벤트, 레벨 완료)
  static Future<void> heavy() async {
    if (PlatformUtils.isMobile) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// 선택 피드백 (항목 스크롤, 토글)
  static Future<void> selection() async {
    if (PlatformUtils.isMobile) {
      await HapticFeedback.selectionClick();
    }
  }

  /// 에러 피드백 (잘못된 동작)
  static Future<void> error() async {
    if (PlatformUtils.isMobile) {
      await HapticFeedback.vibrate();
    }
  }
}
