import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/di/provider/clinet_provider.dart';
import 'package:vsync/core/di/provider/vtop_user_provider.dart';
import 'package:vsync/core/router/paths.dart';
import 'package:vsync/core/services/service_layer.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/core/utils/entity/vtop_user_entity.dart';
import 'package:vsync/core/utils/toast/common_toast.dart';
import 'package:vsync/core/utils/users/vtop_users_utils.dart';

import 'package:vsync/src/api/vtop/types.dart';
import 'package:vsync/src/api/vtop/vtop_client.dart';
import 'package:vsync/src/api/vtop_get_client.dart';

late VtopClient _globalClient;
late String _globalUsername;
late String _globalPassword;
PendingSignInResult? _globalPending;

class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepTwo = useState(false);
    return FScaffold(
      resizeToAvoidBottomInset: true,
      header: FHeader.nested(title: const Text("V-Sync"), suffixes: const []),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: GlassSurface(
                  radius: 28,
                  blur: 28,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OnboardingHero(isStepTwo: stepTwo.value),
                        const SizedBox(height: 18),
                        Expanded(
                          child: !stepTwo.value
                              ? Step1(two: stepTwo)
                              : const Step2(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  final bool isStepTwo;

  const _OnboardingHero({required this.isStepTwo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isStepTwo ? "Choose your semester" : "Student portal, refined",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          isStepTwo
              ? "Select the active semester to sync your academic view."
              : "Sign in with your VTOP account using the new floating glass flow.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _StepBubble(index: 1, active: !isStepTwo, complete: isStepTwo),
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withOpacity(isStepTwo ? 0.75 : 0.30),
                      Colors.white.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
            ),
            _StepBubble(index: 2, active: isStepTwo),
          ],
        ),
      ],
    );
  }
}

class _StepBubble extends StatelessWidget {
  final int index;
  final bool active;
  final bool complete;

  const _StepBubble({
    required this.index,
    this.active = false,
    this.complete = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: active || complete
            ? cs.primary.withOpacity(complete ? 0.82 : 0.58)
            : Colors.white.withOpacity(0.08),
        border: Border.all(
          color: active || complete
              ? Colors.white.withOpacity(0.22)
              : Colors.white.withOpacity(0.10),
        ),
      ),
      child: Center(
        child: Text(
          complete ? "✓" : "$index",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: active || complete
                ? Colors.white
                : cs.onSurface.withOpacity(0.72),
          ),
        ),
      ),
    );
  }
}

class Step1 extends HookConsumerWidget {
  final ValueNotifier two;
  const Step1({super.key, required this.two});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isloading = useState(false);
    final username = useTextEditingController();
    final password = useTextEditingController();

    Future<void> handlePress() async {
      isloading.value = true;

      try {
        if (username.text.trim().isEmpty) {
          throw const FormatException('Enter your VTOP username.');
        }
        final pending = await (await ref.read(appServicesProvider.future))
            .authRepository
            .verifyUsernameAndPassword(
              email: null,
              username: username.text.trim(),
              password: password.text,
            );
        VtopClient client = getVtopClient(
          username: pending.registrationNumber,
          password: pending.password,
          cookie: pending.cookie,
        );
        _globalUsername = pending.registrationNumber;
        _globalPassword = pending.password;
        _globalClient = client;
        _globalPending = pending;
        two.value = true;
      } catch (e) {
        if (context.mounted) {
          disOnbardingCommonToast(context, e);
        }
      } finally {
        isloading.value = false;
      }
    }

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FAlert(
                icon: const Icon(FIcons.shieldCheck),
                title: const Text('Sign in with VTOP'),
                subtitle: const Text(
                  'Everything (including your credentials) is stored locally on this device only.',
                ),
              ),
            ),
            const SizedBox(height: 16),
            FTextFormField(
              label: const Text("Registration Number"),
              control: FTextFieldControl.managed(controller: username),
              hint: 'registration number',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => 1 <= (value?.length ?? 0)
                  ? null
                  : 'Enter your VTOP username.',
            ),
            const SizedBox(height: 10),
            FTextFormField.password(
              control: FTextFieldControl.managed(controller: password),
              hint: 'vtop password',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => 1 <= (value?.length ?? 0)
                  ? null
                  : 'Please enter your vtop password.',
            ),
            const SizedBox(height: 20),
            !isloading.value
                ? FButton(
                    child: const Text('Next'),
                    onPress: () {
                      if (formKey.currentState!.validate()) {
                        handlePress();
                        return;
                      }
                    },
                  )
                : SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.theme.colors.primary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class Step2 extends HookConsumerWidget {
  const Step2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetching = useState(true);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final controller = useFRadioMultiValueNotifier<String>();
    final data = useState<SemesterData?>(null);
    Future<void> getSemData() async {
      fetching.value = true;
      try {
        data.value =
            _globalPending?.semesters ??
            await fetchSemesters(client: _globalClient);
      } catch (e) {
        if (context.mounted) {
          disOnbardingCommonToast(context, e);
        }
      } finally {
        fetching.value = false;
      }
    }

    useEffect(() {
      Future.microtask(() async {
        getSemData();
      });
      return null;
    }, []);

    if (!fetching.value && data.value != null) {
      return SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FSelectTileGroup(
                control: FMultiValueControl.managedRadio(
                  controller: controller,
                ),
                label: const Text('Active Semester'),
                description: const Text(
                  'Choose the semester you want V-Sync to show.',
                ),
                validator: (values) =>
                    values?.isEmpty ?? true ? 'Please select a value.' : null,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
                children: [
                  for (final i in data.value!.semesters)
                    FSelectTile(title: Text(i.name), value: i.id),
                ],
              ),
              const SizedBox(height: 20),
              FButton(
                child: const Text('Save'),
                onPress: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final pending = _globalPending;
                      if (pending != null) {
                        await (await ref.read(
                          appServicesProvider.future,
                        )).authRepository.saveVerifiedAccount(
                          pending: pending,
                          selectedSemesterId: controller.value.first,
                        );
                      }
                      var user = VtopUserEntity(
                        username: _globalUsername,
                        password: _globalPassword,
                        semid: controller.value.first,
                        isValid: true,
                      );
                      await ref
                          .read(vtopusersutilsProvider.notifier)
                          .vtopUserInitialData(user);
                      ref.invalidate(vtopUserProvider);
                      await ref.read(vClientProvider.future);
                      if (context.mounted) {
                        GoRouter.of(context).goNamed(Paths.timetable);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        disOnbardingCommonToast(context, e);
                      }
                    }
                    return;
                  }

                  formKey.currentState!.save();
                },
              ),
            ],
          ),
        ),
      );
    } else if (fetching.value && data.value == null) {
      return Center(
        child: CircularProgressIndicator(color: context.theme.colors.primary),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Text("Failed to get semesters data"),
            FButton(
              onPress: () async {
                await getSemData();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
  }
}
