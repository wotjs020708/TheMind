import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/platform_utils.dart';
import '../../theme/app_theme.dart';

/// 플랫폼에 맞춰 자동으로 스타일이 변경되는 텍스트 입력 필드
/// - iOS: CupertinoTextField
/// - Android/기타: TextField (Material 3)
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? labelText;
  final IconData? prefixIcon;
  final bool enabled;
  final TextAlign textAlign;
  final TextStyle? style;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final String? counterText;

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.labelText,
    this.prefixIcon,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.style,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.counterText,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder ?? labelText,
        enabled: enabled,
        textAlign: textAlign,
        style:
            style ?? const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
        textCapitalization: textCapitalization,
        maxLength: maxLength,
        maxLengthEnforcement:
            maxLength != null
                ? MaxLengthEnforcement.enforced
                : MaxLengthEnforcement.none,
        decoration: BoxDecoration(
          color:
              enabled
                  ? AppTheme.surfaceColor
                  : AppTheme.surfaceColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.3)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal:
              prefixIcon != null ? AppTheme.spacingSm : AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
        prefix:
            prefixIcon != null
                ? Padding(
                  padding: const EdgeInsets.only(left: AppTheme.spacingMd),
                  child: Icon(prefixIcon, color: AppTheme.textMuted, size: 20),
                )
                : null,
      );
    }

    // Material Design (Android, Web, Desktop)
    return TextField(
      controller: controller,
      enabled: enabled,
      textAlign: textAlign,
      style:
          style ?? const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: placeholder,
        counterText: counterText ?? '',
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor:
            enabled
                ? AppTheme.surfaceColor
                : AppTheme.surfaceColor.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: AppTheme.textMuted.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: AppTheme.textMuted.withValues(alpha: 0.2),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
      ),
    );
  }
}
