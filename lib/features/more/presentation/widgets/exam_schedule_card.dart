import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/utils/general_utils.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/src/api/vtop/types.dart';

class ExamScheduleCard extends HookConsumerWidget {
  final PerExamScheduleRecord record;
  const ExamScheduleCard({super.key, required this.record});

  bool _isUpcoming(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return date.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(true);
    final cs = Theme.of(context).colorScheme;
    final accent = const Color(0xFFFBBF24); // Neon Amber

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => expanded.value = !expanded.value,
            child: GlassSurface(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(FIcons.calendarDays, color: accent, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.examType,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        Text(
                          "${record.records.length} Courses Scheduled",
                          style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded.value ? FIcons.chevronUp : FIcons.chevronDown,
                    size: 16,
                    color: cs.onSurface.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ),
          if (expanded.value) ...[
            const SizedBox(height: 12),
            ...record.records.map((exam) {
              final upcoming = _isUpcoming(exam.examDate);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassSurface(
                  padding: const EdgeInsets.all(16),
                  tint: upcoming ? accent.withOpacity(0.02) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              exam.courseName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (upcoming)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "UPCOMING",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accent),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${exam.courseCode} • ${exam.courseType}",
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _MiniStat(icon: FIcons.calendar, label: "Date", value: exam.examDate, color: accent),
                          _MiniStat(icon: FIcons.clock, label: "Time", value: exam.examTime, color: accent),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MiniStat(icon: FIcons.mapPin, label: "Venue", value: exam.venue, color: cs.primary),
                          _MiniStat(icon: FIcons.armchair, label: "Seat", value: "${exam.seatLocation} (${exam.seatNo})", color: cs.primary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MiniStat(icon: FIcons.hash, label: "Slot", value: exam.slot, color: cs.secondary),
                          _MiniStat(icon: FIcons.info, label: "Reporting", value: exam.reportingTime, color: cs.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: cs.onSurface.withOpacity(0.3), fontWeight: FontWeight.w600)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

