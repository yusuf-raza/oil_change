import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

class StatusPill extends StatefulWidget {
  const StatusPill({
    super.key,
    required this.isDue,
    required this.isWarning,
  });

  final bool isDue;
  final bool isWarning;

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant StatusPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDue != widget.isDue ||
        oldWidget.isWarning != widget.isWarning) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isDue || widget.isWarning) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.isDue
        ? const Color(AppColors.pillDueBackground)
        : widget.isWarning
            ? const Color(AppColors.pillWarningBackground)
            : const Color(AppColors.pillOkBackground);
    final foreground = widget.isDue
        ? const Color(AppColors.danger)
        : widget.isWarning
            ? const Color(AppColors.warning)
            : const Color(AppColors.success);
    final label = widget.isDue
        ? AppStrings.statusDue
        : widget.isWarning
            ? AppStrings.statusSoon
            : AppStrings.statusOk;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scale = 1.0 + (0.1 * t);
        final opacity = 1.0 - (0.12 * t);
        final baseColor = background;
        final flickerStrength = widget.isDue || widget.isWarning ? 0.25 : 0.0;
        final flickerColor = Color.lerp(
          baseColor,
          const Color(AppColors.textOnPrimary),
          flickerStrength * t,
        );
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: flickerColor ?? background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
