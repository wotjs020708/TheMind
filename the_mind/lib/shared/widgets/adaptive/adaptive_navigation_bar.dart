import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/platform_utils.dart';
import '../../theme/app_theme.dart';

/// 플랫폼에 맞춰 자동으로 스타일이 변경되는 상단 네비게이션 바
/// - iOS: CupertinoNavigationBar
/// - Android/기타: AppBar (Material 3)
class AdaptiveNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const AdaptiveNavigationBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(PlatformUtils.isIOS ? 44.0 : 56.0);

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: leading,
        trailing:
            actions != null && actions!.isNotEmpty
                ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                : null,
        backgroundColor: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      );
    }

    // Material Design (Android, Web, Desktop)
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: leading,
      actions: actions,
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
