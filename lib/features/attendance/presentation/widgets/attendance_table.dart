import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/settings.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/utils/general_utils.dart';
import 'package:vsync/core/utils/toast/common_toast.dart';
import 'package:vsync/features/attendance/presentation/providers/full_attendance_provider.dart';
import 'package:vsync/features/attendance/presentation/widgets/attendance_cal.dart';
import 'package:vsync/features/attendance/presentation/widgets/attendance_colors.dart';

class AttendanceTable extends HookConsumerWidget {
  final String courseId;
  final String courseType;
  final bool exp;
  final String facultyName;

  const AttendanceTable({
    super.key,
    required this.courseId,
    required this.courseType,
    required this.exp,
    required this.facultyName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(fullAttendanceProvider(courseType, courseId));
    final darkMode = isDarkAppTheme(ref.watch(themeControllerProvider));
    final autoRefreshOnOpen = ref.watch(autoRefreshOnOpenProvider);
    final isLoading = useState(false);
    final selectedTab = useState(0);

    useEffect(() {
      if (!autoRefreshOnOpen) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref
              .read(fullAttendanceProvider(courseType, courseId).notifier)
              .updateAttendance();
        } catch (e, _) {
          ();
        }
      });
      return null;
    }, [autoRefreshOnOpen]);

    void handelClick() async {
      isLoading.value = true;
      try {
        await ref
            .read(fullAttendanceProvider(courseType, courseId).notifier)
            .updateAttendance();
      } catch (e, _) {
        if (context.mounted) disCommonToast(context, e);
      } finally {
        isLoading.value = false;
      }
    }

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0E14),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(darkMode, context, facultyName, isLoading, handelClick),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF151922),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    context: context,
                    label: "History",
                    icon: Icons.history_rounded,
                    isSelected: selectedTab.value == 0,
                    onTap: () => selectedTab.value = 0,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    context: context,
                    label: "Calculator",
                    icon: Icons.calculate_rounded,
                    isSelected: selectedTab.value == 1,
                    onTap: () => selectedTab.value = 1,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    context: context,
                    label: "Calendar",
                    icon: Icons.calendar_month_rounded,
                    isSelected: selectedTab.value == 2,
                    onTap: () => selectedTab.value = 2,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: dataAsync.when(
              data: (data) {
                if (selectedTab.value == 0) {
                  return _buildTableContent(darkMode, context, data);
                } else if (selectedTab.value == 1) {
                  return AttendanceCalculator(
                    currentAttended: data.records.where((r) {
                      final val = r.status.toLowerCase().replaceAll(' ', '');
                      return ['present', 'onduty'].contains(val);
                    }).length,
                    currentTotal: data.records.length,
                  );
                } else {
                  return AttendanceCalendarView(records: data.records);
                }
              },
              error: (e, se) => _buildErrorState(e),
              loading: () => _buildLoadingState(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FTappable(
      onPress: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    bool isDark,
    BuildContext context,
    String name,
    ValueNotifier<bool> isLoading,
    VoidCallback callback,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(bottom: BorderSide(color: context.theme.colors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AttendanceColors.theoryIcon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AttendanceColors.theoryIcon,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                    isDark
                        ? context.theme.colors.primary
                        : AttendanceColors.primaryText,
              ),
            ),
          ),
          if (!isLoading.value)
            FTappable(
              onPress: callback,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? context.theme.colors.primaryForeground
                          : AttendanceColors.tableRowAlternate,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FIcons.rotateCcw,
                  size: 16,
                  color:
                      isDark
                          ? context.theme.colors.primary
                          : AttendanceColors.secondaryText,
                ),
              ),
            ),
          if (isLoading.value)
            const SizedBox(
              width: 20,
              height: 20,
              child: FCircularProgress.pinwheel(),
            ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildTableContent(bool isDark, BuildContext context, dynamic data) {
    if (data.records.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: data.records.length,
            separatorBuilder: (context, index) => Divider(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final record = data.records[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    // Date and Time stacked
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDateShort(record.date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE2E8F0), // off-white
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${record.dayTime} • ${record.slot}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    _buildStatusBadge(record.status),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "Data updated on ${formatUnixTimestamp(data.updateTime.toInt())}",
            style: const TextStyle(
              fontSize: 12,
              color: AttendanceColors.tertiaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildStatusBadge(String status) {
    final statusLower = status.toLowerCase();

    Color color;
    IconData icon;

    const kMint = Color(0xFF34D399);
    const kRose = Color(0xFFFB7185);

    switch (statusLower) {
      case 'absent':
        color = kRose;
        icon = Icons.close_rounded;
        break;
      case 'present':
        color = kMint;
        icon = Icons.check_rounded;
        break;
      case 'on duty':
        color = Colors.amber;
        icon = Icons.work_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AttendanceColors.tableRowAlternate,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: AttendanceColors.tertiaryText,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No attendance data available",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AttendanceColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Check back later for updates",
            style: TextStyle(
              fontSize: 14,
              color: AttendanceColors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    final message = commonErrorMessage(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AttendanceColors.criticalBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AttendanceColors.criticalText,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Unable to load data",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AttendanceColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AttendanceColors.tertiaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: AttendanceColors.theoryIcon,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Loading attendance data...",
            style: TextStyle(
              fontSize: 14,
              color: AttendanceColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateShort(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final day = parts[0];
        final monthIdx = int.tryParse(parts[1]) ?? 0;
        const months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        if (monthIdx >= 1 && monthIdx <= 12) {
          return "$day ${months[monthIdx]}";
        }
      }
    } catch (_) {}
    return date;
  }
}

// ── Mini-Calendar view ─────────────────────────────────────────────────────
class AttendanceCalendarView extends HookWidget {
  final List<dynamic> records;
  const AttendanceCalendarView({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Parse dates: record.date is 'DD-MM-YYYY'
    final Map<String, String> dateStatusMap = {};
    for (final r in records) {
      final parts = (r.date as String).split('-');
      if (parts.length == 3) {
        final key = '${parts[2]}-${parts[1]}-${parts[0]}'; // YYYY-MM-DD
        dateStatusMap[key] = (r.status as String).toLowerCase().replaceAll(' ', '');
      }
    }

    final sortedKeys = dateStatusMap.keys.toList()..sort();
    if (sortedKeys.isEmpty) {
      return Center(
        child: Text('No attendance records',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
      );
    }

    // Group by "YYYY-MM"
    final Map<String, Map<int, String>> byMonth = {};
    for (final key in sortedKeys) {
      final p = key.split('-');
      final mk = '${p[0]}-${p[1]}';
      final day = int.tryParse(p[2]) ?? 0;
      byMonth.putIfAbsent(mk, () => {});
      byMonth[mk]![day] = dateStatusMap[key]!;
    }

    final monthKeys = byMonth.keys.toList()..sort();
    final selectedIdx = useState(monthKeys.length - 1);

    final mk = monthKeys[selectedIdx.value];
    final mp = mk.split('-');
    final year = int.parse(mp[0]);
    final month = int.parse(mp[1]);
    final dayMap = byMonth[mk]!;

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // 0=Sun

    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const dayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    const kMint  = Color(0xFF34D399);
    const kRose  = Color(0xFFFB7185);
    const kAmber = Color(0xFFFBBF24);

    Color dotColor(String status) {
      if (['present', 'onduty'].contains(status)) return kMint;
      return kRose;
    }

    return Column(
      children: [
        // Month-navigation header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: selectedIdx.value > 0
                    ? () => selectedIdx.value--
                    : null,
                icon: Icon(Icons.chevron_left_rounded,
                    color: selectedIdx.value > 0
                        ? cs.primary
                        : cs.onSurface.withOpacity(0.2)),
              ),
              Text(
                '${monthNames[month]} $year',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              IconButton(
                onPressed: selectedIdx.value < monthKeys.length - 1
                    ? () => selectedIdx.value++
                    : null,
                icon: Icon(Icons.chevron_right_rounded,
                    color: selectedIdx.value < monthKeys.length - 1
                        ? cs.primary
                        : cs.onSurface.withOpacity(0.2)),
              ),
            ],
          ),
        ),

        // Day-of-week header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface.withOpacity(0.35),
                              letterSpacing: 0.5,
                            )),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startOffset + daysInMonth,
              itemBuilder: (ctx, i) {
                if (i < startOffset) return const SizedBox();
                final day = i - startOffset + 1;
                final status = dayMap[day];
                final dot = status != null ? dotColor(status) : null;
                final isToday = DateTime.now().year == year &&
                    DateTime.now().month == month &&
                    DateTime.now().day == day;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isToday
                        ? cs.primary.withOpacity(0.15)
                        : dot != null
                            ? dot.withOpacity(0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: cs.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isToday
                              ? cs.primary
                              : dot ?? cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                      if (dot != null) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: dot,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: dot.withOpacity(0.5),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Legend
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: kMint, label: 'Present / OD'),
              const SizedBox(width: 20),
              _LegendDot(color: kRose, label: 'Absent'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
