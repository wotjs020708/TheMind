import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LivesDisplay extends StatefulWidget {
  final int lives;

  const LivesDisplay({super.key, required this.lives});

  @override
  State<LivesDisplay> createState() => _LivesDisplayState();
}

class _LivesDisplayState extends State<LivesDisplay> {
  bool _shouldShake = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(LivesDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 생명이 감소했을 때 shake 효과 트리거
    if (widget.lives < oldWidget.lives) {
      setState(() {
        _shouldShake = true;
      });

      // 애니메이션 후 shake 상태 초기화
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _shouldShake = false;
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
        const Icon(Icons.favorite, color: Colors.red, size: 24),
        const SizedBox(width: 8),
        Text(
          '${widget.lives}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );

    // Shake 효과 적용
    if (_shouldShake) {
      return displayWidget
          .animate(key: ValueKey(widget.lives))
          .shake(duration: 400.ms, hz: 5, curve: Curves.easeInOut);
    }

    return displayWidget;
  }
}
