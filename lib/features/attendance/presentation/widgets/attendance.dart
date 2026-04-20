import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/settings.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/theme/app_theme.dart';
import 'package:vsync/core/utils/extention.dart';
import 'package:vsync/features/attendance/presentation/widgets/attendance_colors.dart';
import 'package:vsync/features/attendance/presentation/widgets/attendance_table.dart';
import 'package:vsync/src/api/vtop/types.dart';

/// Groups attendance records so theory + lab of same subject appear in one card.
class GroupedAttendance {
  final AttendanceRecord theory;
  final AttendanceRecord? lab;
  GroupedAttendance({required this.theory, this.lab});
}

List<GroupedAttendance> groupRecords(List<AttendanceRecord> records) {
  // Extract base course code (before the dash in courseName, or courseCode prefix)
  String baseCode(AttendanceRecord r) {
    final parts = r.courseName.split('-');
    return parts.isNotEmpty ? parts[0].trim() : r.courseCode;
  }

  final Map<String, List<AttendanceRecord>> grouped = {};
  for (final r in records) {
    final key = baseCode(r);
    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(r);
  }

  final List<GroupedAttendance> result = [];
  for (final entry in grouped.entries) {
    final items = entry.value;
    AttendanceRecord? theory;
    AttendanceRecord? lab;

    for (final item in items) {
      if (item.islab()) {
        lab = item;
      } else {
        theory = item;
      }
    }

    if (theory != null) {
      result.add(GroupedAttendance(theory: theory, lab: lab));
    } else if (lab != null) {
      // Lab-only subject
      result.add(GroupedAttendance(theory: lab, lab: null));
    }
  }
  return result;
}

class AttendanceCard extends HookConsumerWidget {
  final GroupedAttendance group;
  final int index;

  const AttendanceCard({super.key, required this.group, required this.index});

  Color _statusColor(int present, int total) {
    if (total == 0) return kSafe;
    return (present / total) >= 0.75 ? kSafe : kDanger;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final record = group.theory;
    final labRecord = group.lab;
    
    final (courseCode, courseName) = _formatName(record.courseName);
    final displayName = courseName.isNotEmpty ? courseName : record.courseName;
    final displayCode = courseCode.isNotEmpty ? courseCode : 'SUBJECT';

    final tTotal = int.tryParse(record.totalClasses) ?? 0;
    final tPresent = int.tryParse(record.classesAttended) ?? 0;
    final tPct = tTotal == 0 ? 0.0 : tPresent / tTotal;
    final tColor = _statusColor(tPresent, tTotal);

    int? lTotal, lPresent;
    double? lPct;
    Color? lColor;
    if (labRecord != null) {
      lTotal = int.tryParse(labRecord.totalClasses) ?? 0;
      lPresent = int.tryParse(labRecord.classesAttended) ?? 0;
      lPct = lTotal == 0 ? 0.0 : lPresent / lTotal;
      lColor = _statusColor(lPresent, lTotal);
    }

    return GestureDetector(
      onTap: () => _showDetails(context, record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Color dot
                Container(
                  width: 10, height: 10,
                  margin: const EdgeInsets.only(top: 4, right: 10),
                  decoration: BoxDecoration(
                    color: tColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: tColor.withOpacity(0.4), blurRadius: 6)],
                  ),
                ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(displayCode, style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: cs.onSurface.withOpacity(0.35), letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text(displayName, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: cs.onSurface, height: 1.3)),
                  ]),
                ),
                // Circular percentage
                _CircularPct(pct: tPct, color: tColor, size: 44),
              ]),
            ),

            if (record.attendancePercentage != "-") ...[
              const SizedBox(height: 12),
              // Theory row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProgressRow(
                  label: record.islab() ? 'Practical' : 'Theory',
                  present: tPresent, total: tTotal, color: tColor,
                ),
              ),

              // Lab row (if exists)
              if (labRecord != null && lTotal != null && lPresent != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ProgressRow(
                    label: 'Practical',
                    present: lPresent, total: lTotal, color: lColor!,
                  ),
                ),
              ],
              const SizedBox(height: 14),
            ] else
              const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, AttendanceRecord record) {
    showFSheet(
      mainAxisMaxRatio: 5 / 6,
      context: context,
      side: FLayout.btt,
      builder: (context) => AttendanceTable(
        courseId: record.courseId,
        courseType: record.courseType,
        exp: true,
        facultyName: record.facultyDetail,
      ),
    );
  }
}

class _CircularPct extends StatelessWidget {
  final double pct;
  final Color color;
  final double size;
  const _CircularPct({required this.pct, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: size, height: size,
          child: CircularProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            strokeWidth: 3.5,
            strokeCap: StrokeCap.round,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Text('${(pct * 100).round()}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int present, total;
  final Color color;
  const _ProgressRow({required this.label, required this.present,
    required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = total == 0 ? 0.0 : present / total;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: cs.onSurface.withOpacity(0.5))),
        Text('$present / $total', style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.w700, color: color)),
      ]),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          FractionallySizedBox(widthFactor: pct.clamp(0.0, 1.0),
            child: Container(height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // 75% marker
          FractionallySizedBox(widthFactor: 0.75,
            child: Align(alignment: Alignment.centerRight,
              child: Container(width: 2, height: 4,
                color: cs.onSurface.withOpacity(0.2)))),
        ]),
      ),
    ]);
  }
}

(String, String) _formatName(String name) {
  final splitName = name.split("-");
  if (splitName.length < 2) return ("", name);
  var nName = splitName[1];
  if (splitName.length > 3) {
    nName += "-${splitName[2]}";
  }
  return (splitName[0], nName);
}
