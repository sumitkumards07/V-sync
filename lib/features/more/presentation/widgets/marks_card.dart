import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/utils/extention.dart';
import 'package:vsync/core/utils/weightage_totals.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/features/more/presentation/widgets/marks_table.dart';
import 'package:vsync/features/more/presentation/widgets/more_color.dart';
import 'package:vsync/src/api/vtop/types.dart';

class MarksCard extends HookConsumerWidget {
  final MarksRecord record;

  const MarksCard({super.key, required this.record});

  (double gained, double possible, double percentage) _calculateTotals() {
    final totals = calculateWeightageTotals<MarksRecordEach>(
      record.marks,
      titleOf: (m) => m.markstitle,
      gainedOf: (m) => m.weightagemark,
      possibleOf: (m) => m.weightage,
    );
    return (totals.gained, totals.possible, totals.percentage);
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 85) return const Color(0xFF34D399); // Neon Teal
    if (percentage >= 70) return const Color(0xFF60A5FA); // Neon Blue
    if (percentage >= 50) return const Color(0xFFFBBF24); // Neon Amber
    return const Color(0xFFF87171); // Neon Red
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final totals = _calculateTotals();
    final isLab = record.islab();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => expanded.value = !expanded.value,
            child: GlassSurface(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isLab ? const Color(0xFFA78BFA) : const Color(0xFF60A5FA)).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isLab ? FIcons.flaskConical : FIcons.libraryBig,
                          color: isLab ? const Color(0xFFA78BFA) : const Color(0xFF60A5FA),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.coursetitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              record.coursecode,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${totals.$3.toInt()}%",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: _getPerformanceColor(totals.$3),
                            ),
                          ),
                          Text(
                            "${totals.$1.toInt()}/${totals.$2.toInt()}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Premium Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 6,
                        width: MediaQuery.of(context).size.width * (totals.$1 / totals.$2).clamp(0, 1) * 0.8, // Adjust for padding
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getPerformanceColor(totals.$3).withOpacity(0.6),
                              _getPerformanceColor(totals.$3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: _getPerformanceColor(totals.$3).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Faculty: ${record.faculity.split('-').first.trim()}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Icon(
                        expanded.value ? FIcons.chevronUp : FIcons.chevronDown,
                        size: 16,
                        color: cs.onSurface.withOpacity(0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded.value)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GlassSurface(
                padding: const EdgeInsets.all(4),
                child: MarksTable(marks: record.marks),
              ),
            ),
        ],
      ),
    );
  }
}

