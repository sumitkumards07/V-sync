import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vsync/core/di/provider/clinet_provider.dart';
import 'package:vsync/core/di/provider/vtop_user_provider.dart';
import 'package:vsync/core/providers/settings.dart';
import 'package:vsync/core/services/service_layer.dart';
import 'package:vsync/core/utils/entity/vtop_user_entity.dart';
import 'package:vsync/core/utils/toast/common_toast.dart';
import 'package:vsync/core/utils/users/vtop_users_utils.dart';
import 'package:vsync/features/more/presentation/providers/exam_schedule.dart';
import 'package:vsync/features/settings/presentation/providers/semester_id_provider.dart';
import 'package:vsync/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:vsync/src/api/vtop_get_client.dart';

part 'user_management.g.dart';

@Riverpod(keepAlive: true)
class IsLoadingSems extends _$IsLoadingSems {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}

class UserSemChangeDialog extends HookConsumerWidget {
  final VtopUserEntity user;
  const UserSemChangeDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useFRadioMultiValueNotifier<String>(value: user.semid);
    final outercontext = context;

    Future<void> refreshSemesters() async {
      try {
        ref.read(isLoadingSemsProvider.notifier).setLoading(true);
        await ref.read(semesterIdProvider.notifier).updatesemids();
        ref.invalidate(semesterIdProvider);
      } finally {
        ref.read(isLoadingSemsProvider.notifier).setLoading(false);
      }
    }

    var semester = ref.watch(semesterIdProvider);

    return semester.when(
      data: (data) => FDialog(
        body: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: FSelectTileGroup(
              control: FMultiValueControl.managedRadio(
                controller: controller,
                onChange: (value) async {
                  final selected = value.firstOrNull;
                  if (selected == null) return;
                  await ref
                      .read(vtopusersutilsProvider.notifier)
                      .vtopUserSave(user.copyWith(semid: selected));
                  ref.invalidate(vtopUserProvider);
                  ref.invalidate(vClientProvider);
                  
                  // Refresh timetable/exams if notifs are on
                  if (ref.read(classReminderSettingsProvider).enabled) {
                    await ref.read(timetableProvider.notifier).updateTimetable();
                  }
                  if (ref.read(examReminderSettingsProvider).enabled) {
                    await ref.read(examScheduleProvider.notifier).updatexamschedule();
                  }
                  
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              label: Row(
                children: [
                  const Expanded(child: Text('Available Semesters')),
                  Consumer(builder: (context, ref, _) {
                    final isLoading = ref.watch(isLoadingSemsProvider);
                    return isLoading 
                      ? FCircularProgress.pinwheel()
                      : FTappable(
                          onPress: () async {
                            try {
                              await refreshSemesters();
                            } catch (e) {
                              if (context.mounted) Navigator.of(context).pop();
                              if (outercontext.mounted) disCommonToast(outercontext, e);
                            }
                          },
                          child: const Icon(FIcons.rotateCcw),
                        );
                  }),
                ],
              ),
              description: const Text('Pick a semester to switch your active view.'),
              children: [
                for (final i in data.semesters)
                  FSelectTile(title: Text(i.name, maxLines: 2), value: i.id),
              ],
            ),
          ),
        ),
        title: const Text('Switch Semester'),
        actions: [
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
      error: (e, _) => FDialog(
        title: const Text("Error"),
        body: Text("$e"),
        actions: [FButton(onPress: () => Navigator.pop(context), child: const Text("Close"))],
      ),
      loading: () => FDialog(
        body: const SizedBox(height: 100, child: Center(child: FCircularProgress())),
        actions: const [],
      ),
    );
  }
}

// UserPassChange, UserSemChange removed as they were container buttons. 
// Dialogs are now used directly.

class UserPassChangeDialog extends HookConsumerWidget {
  final VtopUserEntity user;
  const UserPassChangeDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController(text: user.username);
    final passwordController = useTextEditingController(text: user.password);
    final isLoading = useState(false);

    return FDialog(
      title: const Text('Edit Details'),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          FTextField(
            control: FTextFieldControl.managed(controller: usernameController),
            label: const Text("VTOP Username"),
            hint: "registration number",
          ),
          FTextField.password(
            control: FTextFieldControl.managed(controller: passwordController),
            obscuringCharacter: '*',
            label: const Text("VTOP Password"),
            clearable: (k) => k.text.isNotEmpty,
          ),
        ],
      ),
      actions: [
        if (!isLoading.value)
          FButton(
            onPress: () async {
              final newUsername = usernameController.text.trim();
              final newPassword = passwordController.text.trim();
              if (newUsername.isEmpty || newPassword.isEmpty) return;

              isLoading.value = true;
              try {
                var client = getVtopClient(
                  username: newUsername,
                  password: newPassword,
                );
                await vtopClientLogin(client: client);
                final services = await ref.read(appServicesProvider.future);
                await ref
                    .read(vtopusersutilsProvider.notifier)
                    .vtopUserSave(
                      user.copyWith(
                        username: newUsername,
                        password: newPassword,
                        isValid: true,
                      ),
                    );
                await services.preferenceStore.writeCookie(null);
                services.sessionCoordinator.clearClient();
                ref.invalidate(vtopUserProvider);
                ref.invalidate(vClientProvider);
                ref.invalidate(activeAccountProvider);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  disOnbardingCommonToast(context, e);
                }
              } finally {
                isLoading.value = false;
              }
            },
            child: const Text('Save'),
          )
        else
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.theme.colors.primary,
            ),
          ),
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
