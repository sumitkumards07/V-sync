import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vsync/core/theme/app_theme.dart';

class AppBackdrop extends StatelessWidget {
  final Widget child;

  const AppBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF020816),
                        Color(0xFF08142A),
                        Color(0xFF120C29),
                      ]
                    : const [
                        Color(0xFFF6FBFF),
                        Color(0xFFEAF4FF),
                        Color(0xFFF4EEFF),
                      ],
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Stack(
            children: [
              _MeshOrb(
                alignment: const Alignment(-1.15, -0.95),
                size: 320,
                color: kGlassCyan.withOpacity(isDark ? 0.34 : 0.24),
              ),
              _MeshOrb(
                alignment: const Alignment(1.1, -0.7),
                size: 360,
                color: kGlassBlue.withOpacity(isDark ? 0.30 : 0.22),
              ),
              _MeshOrb(
                alignment: const Alignment(0.85, 1.0),
                size: 340,
                color: kGlassPurple.withOpacity(isDark ? 0.26 : 0.18),
              ),
              _MeshOrb(
                alignment: const Alignment(-0.8, 0.85),
                size: 280,
                color: kGlassBlueDeep.withOpacity(isDark ? 0.20 : 0.14),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -1.2),
                      radius: 1.8,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.08 : 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _MeshOrb extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;

  const _MeshOrb({
    required this.alignment,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
          ),
        ),
      ),
    );
  }
}
