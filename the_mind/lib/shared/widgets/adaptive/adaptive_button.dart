import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/platform_utils.dart';
import '../../theme/app_theme.dart';

/// 플랫폼에 맞춰 자동으로 스타일이 변경되는 버튼
/// - iOS: CupertinoButton
/// - Android/기타: ElevatedButton (Material 3)
class AdaptiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final bool isDestructive;

  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        isDestructive ? AppTheme.errorColor : (color ?? AppTheme.primaryColor);

    if (PlatformUtils.isIOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        disabledColor: CupertinoColors.quaternarySystemFill,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          child: child,
        ),
      );
    }

    // Material Design (Android, Web, Desktop)
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: AppTheme.textPrimary,
        disabledBackgroundColor: AppTheme.textMuted.withValues(alpha: 0.3),
        disabledForegroundColor: AppTheme.textMuted,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        elevation: 4,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: child,
    );
  }
}

/// 아이콘이 있는 플랫폼 적응형 버튼
class AdaptiveButtonIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final Color? color;
  final bool isDestructive;

  const AdaptiveButtonIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        isDestructive ? AppTheme.errorColor : (color ?? AppTheme.primaryColor);

    if (PlatformUtils.isIOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        disabledColor: CupertinoColors.quaternarySystemFill,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: const IconThemeData(color: AppTheme.textPrimary, size: 20),
              child: icon,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              child: label,
            ),
          ],
        ),
      );
    }

    // Material Design
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: AppTheme.textPrimary,
        disabledBackgroundColor: AppTheme.textMuted.withValues(alpha: 0.3),
        disabledForegroundColor: AppTheme.textMuted,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        elevation: 4,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
