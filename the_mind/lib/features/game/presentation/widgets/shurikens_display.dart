import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShurikensDisplay extends StatefulWidget {
  final int shurikens;

  const ShurikensDisplay({super.key, required this.shurikens});

  @override
  State<ShurikensDisplay> createState() => _ShurikensDisplayState();
}

class _ShurikensDisplayState extends State<ShurikensDisplay> {
  bool _shouldAnimate = false;
  bool _isIncreasing = false;

  @override
  void didUpdateWidget(ShurikensDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 수리검 수가 변경되었을 때 애니메이션 트리거
    if (widget.shurikens != oldWidget.shurikens) {
      setState(() {
        _shouldAnimate = true;
        _isIncreasing = widget.shurikens > oldWidget.shurikens;
      });

      // 애니메이션 후 상태 초기화
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _shouldAnimate = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 24),
        const SizedBox(width: 8),
        Text(
          '${widget.shurikens}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );

    // 증감 애니메이션 적용
    if (_shouldAnimate) {
      return displayWidget
          .animate(key: ValueKey(widget.shurikens))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.3, 1.3),
            duration: 300.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.3, 1.3),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeIn,
          );
    }

    return displayWidget;
  }
}
