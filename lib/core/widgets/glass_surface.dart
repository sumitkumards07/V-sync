import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final double radius;
  final BorderRadius? borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;
  final Color? tint;

  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 26,
    this.borderRadius,
    this.blur = 24,
    this.padding = const EdgeInsets.all(16),
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill =
        tint ??
        (isDark
            ? Colors.white.withOpacity(0.10)
            : Colors.white.withOpacity(0.52));
    final stroke = isDark
        ? Colors.white.withOpacity(0.18)
        : Colors.white.withOpacity(0.70);

    final effectiveRadius = borderRadius ?? BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: effectiveRadius,
            border: Border.all(color: stroke, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.18 : 0.08),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
