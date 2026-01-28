import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/platform_utils.dart';
import '../../theme/app_theme.dart';

/// 다이얼로그 액션 버튼 정의
class AdaptiveDialogAction {
  final String text;
  final VoidCallback onPressed;
  final bool isDefaultAction;
  final bool isDestructive;

  const AdaptiveDialogAction({
    required this.text,
    required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructive = false,
  });
}

/// 플랫폼에 맞춰 자동으로 스타일이 변경되는 다이얼로그
/// - iOS: CupertinoAlertDialog (버튼 세로 배치)
/// - Android/기타: AlertDialog (버튼 가로 배치)
class AdaptiveDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<AdaptiveDialogAction> actions;

  const AdaptiveDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: AppTheme.spacingSm),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 14, color: CupertinoColors.label),
            child: content,
          ),
        ),
        actions:
            actions
                .map(
                  (action) => CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      action.onPressed();
                    },
                    isDefaultAction: action.isDefaultAction,
                    isDestructiveAction: action.isDestructive,
                    child: Text(action.text),
                  ),
                )
                .toList(),
      );
    }

    // Material Design (Android, Web, Desktop)
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
      content: DefaultTextStyle(
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        child: content,
      ),
      actions:
          actions
              .map(
                (action) => TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    action.onPressed();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        action.isDestructive
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                    textStyle: TextStyle(
                      fontWeight:
                          action.isDefaultAction
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                  child: Text(action.text),
                ),
              )
              .toList(),
    );
  }
}

/// 플랫폼에 맞는 다이얼로그를 표시하는 헬퍼 함수
Future<void> showAdaptiveDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<AdaptiveDialogAction> actions,
}) {
  if (PlatformUtils.isIOS) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) =>
              AdaptiveDialog(title: title, content: content, actions: actions),
    );
  }

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) =>
            AdaptiveDialog(title: title, content: content, actions: actions),
  );
}
