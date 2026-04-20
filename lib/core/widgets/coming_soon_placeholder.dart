import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:vsync/core/widgets/glass_surface.dart';

class ComingSoonPlaceholder extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const ComingSoonPlaceholder({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = FIcons.rocket,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glass Icon Container with Glow
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                GlassSurface(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(30),
                  child: Icon(
                    icon,
                    size: 40,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Text Content
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle ?? "We are working hard to bring this feature to you soon.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 48),
            
            // "Stay Tuned" Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "COMING SOON",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
