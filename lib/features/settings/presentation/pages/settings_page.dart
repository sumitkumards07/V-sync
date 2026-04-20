import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/settings.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/router/paths.dart';
import 'package:vsync/core/services/service_layer.dart';
import 'package:vsync/features/background/controller.dart';
import 'package:vsync/features/settings/presentation/pages/user_management.dart';
import 'package:vsync/features/settings/presentation/providers/semester_id_provider.dart';
import 'package:vsync/core/di/provider/vtop_user_provider.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show15 = useState(false);
    final field15e = useTextEditingController();

    final backgroundSync = [
      FSelectTile(title: Text("Disable"), value: Duration(seconds: 0)),
      if (show15.value)
        FSelectTile(title: Text("15 Minutes"), value: Duration(minutes: 15)),
      if (show15.value)
        FSelectTile(title: Text("1 hour"), value: Duration(hours: 1)),
      FSelectTile(title: Text("3 hours"), value: Duration(hours: 3)),
      FSelectTile(title: Text("6 hours"), value: Duration(hours: 6)),
      FSelectTile(title: Text("12 hours"), value: Duration(hours: 12)),
      FSelectTile(title: Text("24 hours"), value: Duration(hours: 24)),
    ];
    final initialValSync =
        ref.watch(backgroundSyncProvider).value?.freq ?? Duration(seconds: 0);
    final autoRefreshOnOpen = ref.watch(autoRefreshOnOpenProvider);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (initialValSync == Duration(minutes: 15) ||
            initialValSync == Duration(hours: 1)) {
          show15.value = true;
        } else {
          show15.value = false;
        }
      });
      return null;
    }, [initialValSync]);

    final user = ref.watch(vtopUserProvider);
    final semesterData = ref.watch(semesterIdProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const Text(
              "Settings",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "App preferences & account management",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // 1. Hero Identity Block
              user.when(
                data: (userData) => _ProfileHeader(
                  userData: userData,
                  semesterName: semesterData.when(
                    data: (data) => data.semesters
                        .firstWhere(
                          (s) => s.id == userData.semid,
                          orElse: () => data.semesters.first,
                        )
                        .name,
                    loading: () => "Loading...",
                    error: (_, __) => "Unknown Sem",
                  ),
                ),
                loading: () => const Center(child: FCircularProgress()),
                error: (_, __) => const Text("Error loading user info"),
              ),
              const SizedBox(height: 32),

              // 2. VTOP ACCOUNT Group
              FTileGroup(
                label: Text(
                  'VTOP ACCOUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                divider: FItemDivider.indented,
                children: [
                  user.when(
                    data: (userData) => FTile(
                      prefix: _IconBadge(
                        icon: FIcons.shieldCheck,
                        color: Colors.blueAccent,
                      ),
                      title: const Text('Manage Credentials'),
                      subtitle: const Text('Update VTOP login details'),
                      suffix: Icon(
                        FIcons.chevronRight,
                        size: 16,
                        color: context.theme.colors.mutedForeground,
                      ),
                      onPress: () => showAdaptiveDialog(
                        context: context,
                        builder: (context) =>
                            UserPassChangeDialog(user: userData),
                      ),
                    ),
                    loading: () => FTile(title: const Text("Loading...")),
                    error: (_, __) => FTile(title: const Text("Error")),
                  ),
                  FSelectMenuTile(
                    prefix: _IconBadge(
                      icon: FIcons.folderSync,
                      color: Colors.indigoAccent,
                    ),
                    title: const Text('Background Sync'),
                    subtitle: Text(
                      initialValSync.inMinutes == 0
                          ? "Disabled"
                          : "Every ${_formatDuration(initialValSync)}",
                    ),
                    selectControl: FMultiValueControl.managedRadio(
                      initial: initialValSync,
                      onChange: (value) => {
                        ref
                            .read(backgroundSyncProvider.notifier)
                            .updateFreq(value.first),
                      },
                    ),
                    menu: backgroundSync,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. PREFERENCES Group
              FTileGroup(
                label: Text(
                  'PREFERENCES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                divider: FItemDivider.indented,
                children: [
                  FTile(
                    prefix: _IconBadge(
                      icon: FIcons.calendarDays,
                      color: Colors.cyanAccent,
                    ),
                    title: const Text('Merge Labs'),
                    suffix: FSwitch(
                      value: ref.watch(mergeTTProvider),
                      onChange: (value) => ref.read(toggleMergeTTProvider),
                    ),
                  ),
                  FTile(
                    prefix: _IconBadge(
                      icon: FIcons.userCheck,
                      color: Colors.greenAccent,
                    ),
                    title: const Text('Show b/w Exams'),
                    suffix: FSwitch(
                      value: ref.watch(btwExamsProvider),
                      onChange: (value) => ref.read(toggleBTWExamsProvider),
                    ),
                  ),
                  FTile(
                    prefix: _IconBadge(
                      icon: FIcons.refreshCw,
                      color: Colors.orangeAccent,
                    ),
                    title: const Text('Auto Refresh on Open'),
                    subtitle: const Text('Background refresh after opening'),
                    suffix: FSwitch(
                      value: autoRefreshOnOpen,
                      onChange: (value) => setAutoRefreshOnOpen(ref, value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. APP SETTINGS Group
              FTileGroup(
                label: Text(
                  'APP SETTINGS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
                divider: FItemDivider.indented,
                children: [
                  FTile(
                    prefix: _IconBadge(
                      icon: FIcons.palette,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('App Theme'),
                    subtitle: Text(
                      _themeName(ref.watch(themeControllerProvider)),
                    ),
                    onPress: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => _ThemePicker(
                        notifier: ref.read(themeControllerProvider.notifier),
                        current: ref.watch(themeControllerProvider),
                      ),
                    ),
                  ),
                  FTile(
                    prefix: _IconBadge(
                      icon: FIcons.bell,
                      color: Colors.pinkAccent,
                    ),
                    title: const Text("Notifications"),
                    suffix: Icon(
                      FIcons.chevronRight,
                      size: 16,
                      color: context.theme.colors.mutedForeground,
                    ),
                    onPress: () => GoRouter.of(
                      context,
                    ).pushNamed(Paths.notificationManagement),
                  ),
                  FTile(
                    prefix: _IconBadge(icon: FIcons.logs, color: Colors.grey),
                    title: const Text("System Logs"),
                    suffix: Icon(
                      FIcons.chevronRight,
                      size: 16,
                      color: context.theme.colors.mutedForeground,
                    ),
                    onPress: () => GoRouter.of(context).pushNamed(Paths.logs),
                  ),
                  FTile(
                    prefix: _IconBadge(
                      icon: FIcons.shieldCheck,
                      color: Colors.greenAccent,
                    ),
                    title: const Text("Privacy & Transparency"),
                    subtitle: const Text("Data locality & security portal"),
                    suffix: Icon(
                      FIcons.chevronRight,
                      size: 16,
                      color: context.theme.colors.mutedForeground,
                    ),
                    onPress: () => GoRouter.of(context).pushNamed(Paths.privacy),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 5. Logout & Footer
              FButton(
                variant: FButtonVariant.outline,
                onPress: () async {
                  final router = GoRouter.of(context);
                  final services = await ref.read(appServicesProvider.future);
                  await services.authRepository.signOut();
                  ref.invalidate(activeAccountProvider);
                  if (context.mounted) router.go('/onboarding');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FIcons.logOut,
                      size: 16,
                      color: const Color(0xFFFB7185),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Color(0xFFFB7185),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
    }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return "${d.inHours} hour${d.inHours > 1 ? 's' : ''}";
    return "${d.inMinutes} minutes";
  }
}

class _ProfileHeader extends HookConsumerWidget {
  final dynamic userData;
  final String semesterName;

  const _ProfileHeader({required this.userData, required this.semesterName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regNo = userData.username ?? "Unknown";
    final initial = regNo.isNotEmpty ? regNo[0].toUpperCase() : "V";

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                regNo.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE2E8F0),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              FTappable(
                onPress: () => showAdaptiveDialog(
                  context: context,
                  builder: (context) => UserSemChangeDialog(user: userData),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.theme.colors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        semesterName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        FIcons.chevronDown,
                        size: 10,
                        color: context.theme.colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}


class _ThemePicker extends StatelessWidget {
  final ThemeController notifier;
  final AppThemeMode current;
  const _ThemePicker({required this.notifier, required this.current});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            for (final mode in AppThemeMode.values)
              ListTile(
                title: Text(_themeName(mode)),
                subtitle: Text(_themeDesc(mode)),
                leading: Radio<AppThemeMode>(
                  value: mode,
                  groupValue: current,
                  onChanged: (v) {
                    notifier.setThemeMode(v!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  notifier.setThemeMode(mode);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

String _themeName(AppThemeMode m) {
  switch (m) {
    case AppThemeMode.navy:
      return 'Spatial Glass';
    case AppThemeMode.campus:
      return 'Daylight Glass';
    case AppThemeMode.mono:
      return 'Monochrome Frost';
  }
}

String _themeDesc(AppThemeMode m) {
  switch (m) {
    case AppThemeMode.navy:
      return 'Dark glass surfaces over a premium mesh backdrop';
    case AppThemeMode.campus:
      return 'Bright frosted surfaces for daytime viewing';
    case AppThemeMode.mono:
      return 'Muted frosted neutrals for a quieter study mode';
  }
}
