import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/di/provider/vtop_user_provider.dart';
import 'package:vsync/core/router/paths.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/features/settings/presentation/providers/semester_id_provider.dart';
import 'package:vsync/features/campus/presentation/providers/campus_selection_provider.dart';
import 'package:vsync/features/timetable/presentation/providers/timetable_selection_provider.dart';

class ShellLayout extends HookConsumerWidget {
  final Widget child;
  const ShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var k = GoRouter.of(context).routeInformationProvider.value.uri.toString();
    final headers = [
      getSidewidget(context, "Timetable", k),
      getSidewidget(context, "Attendance", k),
      getSidewidget(context, "Campus", k),
      getSidewidget(context, "More", k),
      getSidewidget(context, "Settings", k),
    ];
    final selected = useState(0);
    useEffect(() {
      if (k.startsWith("/timetable")) {
        selected.value = 0;
      } else if (k.startsWith("/attendance")) {
        selected.value = 1;
      } else if (k.startsWith("/campus")) {
        selected.value = 2;
      } else if (k.startsWith("/more")) {
        selected.value = 3;
      } else if (k.startsWith("/settings")) {
        selected.value = 4;
      }
      return null;
    }, [k]);

    return FScaffold(
      childPad: false,
      header: headers[selected.value],
      footer: SafeArea(
        top: false,
        right: false,
        left: false,
        bottom: true,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: GlassSurface(
            radius: 30,
            blur: 22,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tint: Colors.white.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.10 : 0.56,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: FIcons.clock,
                  label: 'Timetable',
                  isActive: selected.value == 0,
                  onTap: () {
                    selected.value = 0;
                    ref.read(timetableDaySelectionProvider.notifier).resetToToday();
                    GoRouter.of(context).goNamed(Paths.timetable);
                  },
                ),
                _NavBarItem(
                  icon: FIcons.userCheck,
                  label: 'Attendance',
                  isActive: selected.value == 1,
                  onTap: () {
                    selected.value = 1;
                    GoRouter.of(context).goNamed(Paths.attendance);
                  },
                ),
                _NavBarItem(
                  icon: FIcons.university,
                  label: 'Campus',
                  isActive: selected.value == 2,
                  onTap: () {
                    selected.value = 2;
                    ref.read(campusDateSelectionProvider.notifier).resetToToday();
                    GoRouter.of(context).goNamed(Paths.campus);
                  },
                ),
                _NavBarItem(
                  icon: FIcons.layoutGrid,
                  label: 'More',
                  isActive: selected.value == 3,
                  onTap: () {
                    selected.value = 3;
                    GoRouter.of(context).goNamed(Paths.more);
                  },
                ),
                _NavBarItem(
                  icon: FIcons.user,
                  label: 'Account',
                  isActive: selected.value == 4,
                  onTap: () {
                    selected.value = 4;
                    GoRouter.of(context).goNamed(Paths.settings);
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      child: SafeArea(
        bottom: false, // Footer handles its own safe area
        child: child,
      ),
    );
  }
}

Widget? getSidewidget(
  BuildContext context,
  String data,
  String path,
) {
  // All pages now manage their own headers for Better UI control and "Large Title" support.
  return null;
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.20)
              : Colors.white.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.02 : 0.22,
                ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.18)
                : Colors.white.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.05
                        : 0.42,
                  ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? activeColor : inactiveColor),
            if (isActive) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: activeColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
