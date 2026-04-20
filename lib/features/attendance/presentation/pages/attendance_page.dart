import 'package:vsync/core/utils/extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/settings.dart';
import 'package:vsync/core/utils/general_utils.dart';
import 'package:vsync/core/utils/toast/common_toast.dart';
import 'package:vsync/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:vsync/features/attendance/presentation/providers/filter.dart';
import 'package:vsync/features/attendance/presentation/widgets/attendance.dart';
import 'package:vsync/core/widgets/glass_surface.dart';

class AttendancePage extends HookConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(attendanceFilterProvider);
    final autoRefreshOnOpen = ref.watch(autoRefreshOnOpenProvider);

    Future<void> update() async {
      try {
        await ref.read(attendanceProvider.notifier).updateAttendance();
      } catch (e) {
        if (context.mounted) {
          try {
            disCommonToast(context, e);
          } catch (_) {}
        }
      }
    }

    useEffect(() {
      if (!autoRefreshOnOpen) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(attendanceProvider.notifier).updateAttendance();
        } catch (_) {}
      });
      return null;
    }, [autoRefreshOnOpen]);

    final attendanceData = ref.watch(attendanceProvider);

    return RefreshIndicator(
      onRefresh: update,
      backgroundColor: context.theme.colors.primary,
      color: context.theme.colors.primaryForeground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Attendance",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Track your academic presence",
              style: TextStyle(
                fontSize: 14,
                color: context.theme.colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            attendanceData.when(
          data: (data) {
              if (data.records.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: FAlert(
                      icon: Icon(FIcons.info),
                      title: Text("No attendance yet"),
                      subtitle: Text(
                        "Pull to refresh once attendance is available.",
                      ),
                    ),
                  ),
                );
              }

              final filteredRecords = switch (filter) {
                AttendanceFilter.all => data.records,
                AttendanceFilter.labs =>
                  data.records.where((r) => r.islab()).toList(),
              };

              final grouped = groupRecords(filteredRecords);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 4),
                const AttendanceFilterTabs(),
                const SizedBox(height: 12),
                if (grouped.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: FAlert(
                      icon: const Icon(FIcons.info),
                      title: Text(
                        filter == AttendanceFilter.labs
                            ? "No Lab records"
                            : "No attendance records",
                      ),
                      subtitle: const Text(
                        "Everything looks clean here.",
                      ),
                    ),
                  )
                else
                  ...grouped.asMap().entries.map((e) {
                    return AttendanceCard(
                      group: e.value,
                      index: e.key,
                    );
                  }),
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Text(
                    "Data updated on ${formatUnixTimestamp(data.updateTime.toInt())}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
          },
          error: (e, _) {
            final msg = commonErrorMessage(e);
            // try {
            //   disCommonToast(context, e);
            // } catch (_) {}
            return Center(child: Text(msg));
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _LoadingBar(
                label: "Loading attendance...",
                color: context.theme.colors.primary,
              ),
            ),
          ),
          ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  final String label;
  final Color color;

  const _LoadingBar({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            minHeight: 3,
            color: color,
            backgroundColor: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

class AttendanceFilterTabs extends HookConsumerWidget {
  const AttendanceFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(attendanceFilterProvider);
    final notifier = ref.read(attendanceFilterProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: GlassSurface(
        padding: const EdgeInsets.all(4),
        radius: 16,
        child: SizedBox(
          height: 48,
          child: Stack(
            children: [
              // Sliding Background Pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                alignment: switch (filter) {
                  AttendanceFilter.all => Alignment.centerLeft,
                  AttendanceFilter.labs => Alignment.centerRight,
                },
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Tabs Text and Icons
              Positioned.fill(
                child: Row(
                  children: [
                    _TabItem(
                      selected: filter == AttendanceFilter.all,
                      label: "All",
                      icon: FIcons.listFilter,
                      onTap: () => notifier.setFilter(AttendanceFilter.all),
                    ),
                    _TabItem(
                      selected: filter == AttendanceFilter.labs,
                      label: "Lab",
                      icon: FIcons.flaskConical,
                      onTap: () => notifier.setFilter(AttendanceFilter.labs),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TabItem({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black87 : Colors.white.withOpacity(0.6);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
