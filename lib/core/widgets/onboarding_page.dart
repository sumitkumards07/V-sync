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
import 'package:vsync/services/gmail_otp_service.dart';

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
    // 0 = Google Login, 1 = credentials, 2 = OTP, 3 = semester
    final step = useState(0);
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
                        _OnboardingHero(step: step.value),
                        const SizedBox(height: 18),
                        Expanded(
                          child: switch (step.value) {
                            0 => GoogleLoginStep(onSignedIn: () => step.value = 1),
                            1 => Step1(onCredentialsVerified: () => step.value = 2),
                            2 => OtpStep(onOtpVerified: () => step.value = 3),
                            _ => const Step2(),
                          },
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
  final int step;

  const _OnboardingHero({required this.step});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titles = [
      "Connect VIT-AP Email",
      "VTOP Credentials",
      "Verify your identity",
      "Choose your semester"
    ];
    final subtitles = [
      "Sign in with Google to enable magic OTP auto-fetching from your inbox.",
      "Enter your VTOP registration number and password to proceed.",
      "An OTP has been sent by info1@vitap.ac.in. It will be auto-filled.",
      "Select the active semester to sync your academic dashboard.",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[step],
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          subtitles[step],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _StepBubble(index: 1, active: step == 0, complete: step > 0),
            _buildBar(context, cs, step > 0),
            _StepBubble(index: 2, active: step == 1, complete: step > 1),
            _buildBar(context, cs, step > 1),
            _StepBubble(index: 3, active: step == 2, complete: step > 2),
            _buildBar(context, cs, step > 2),
            _StepBubble(index: 4, active: step == 3),
          ],
        ),
      ],
    );
  }

  Widget _buildBar(BuildContext context, ColorScheme cs, bool filled) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [
              cs.primary.withOpacity(filled ? 0.75 : 0.30),
              Colors.white.withOpacity(0.12),
            ],
          ),
        ),
      ),
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

// ── Step 0: Google Login ──────────────────────────────────────────────────────

class GoogleLoginStep extends HookConsumerWidget {
  final VoidCallback onSignedIn;
  const GoogleLoginStep({super.key, required this.onSignedIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isloading = useState(false);
    final status = useState<String?>(null);
    final gmailService = useMemoized(() => GmailOtpService());

    Future<void> handleSignIn() async {
      isloading.value = true;
      status.value = "Opening Google Sign-In...";
      try {
        final account = await gmailService.signIn();
        if (account != null) {
          if (account.email.endsWith("@vitap.ac.in")) {
            onSignedIn();
          } else {
            status.value = "Please use your VIT-AP student email.";
            await gmailService.signOut();
          }
        } else {
          status.value = "Sign-in cancelled.";
        }
      } catch (e) {
        status.value = "Error: $e";
      } finally {
        isloading.value = false;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        FAlert(
          icon: const Icon(FIcons.info),
          title: const Text('Why link email?'),
          subtitle: const Text(
            'We use temporary Gmail permissions to automatically read your VTOP OTP verification codes. No data is ever shared.',
          ),
        ),
        const SizedBox(height: 40),
        !isloading.value
            ? FButton(
                onPress: handleSignIn,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FIcons.mail, size: 18),
                    SizedBox(width: 8),
                    Text('Sign in with Google'),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
        if (status.value != null) ...[
          const SizedBox(height: 20),
          Text(
            status.value!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class Step1 extends HookConsumerWidget {
  final VoidCallback onCredentialsVerified;
  const Step1({super.key, required this.onCredentialsVerified});
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
        onCredentialsVerified();
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

// ── Step 1.5: OTP ──────────────────────────────────────────────────────────────

class OtpStep extends HookConsumerWidget {
  final VoidCallback onOtpVerified;
  const OtpStep({super.key, required this.onOtpVerified});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = useTextEditingController();
    final isFetching = useState(false);
    final statusText = useState<String?>('Attempting to auto-fetch OTP…');
    final statusIsError = useState(false);
    final secondsLeft = useState(180);
    final gmailService = useMemoized(() => GmailOtpService());

    // Countdown timer
    useEffect(() {
      final timer = Stream.periodic(const Duration(seconds: 1)).listen((_) {
        if (secondsLeft.value > 0) secondsLeft.value--;
      });
      return timer.cancel;
    }, const []);

    // Auto-fetch on open
    Future<void> fetchOtp() async {
      isFetching.value = true;
      statusText.value = 'Fetching OTP from Gmail…';
      statusIsError.value = false;
      try {
        final account = await gmailService.signInSilently() ?? await gmailService.signIn();
        if (account == null) {
          statusText.value = 'Sign-in cancelled. Enter OTP manually.';
          statusIsError.value = true;
          return;
        }
        final otp = await gmailService.fetchLatestOtp();
        if (otp != null) {
          otpController.text = otp;
          statusText.value = 'OTP fetched successfully ✓';
          statusIsError.value = false;
        } else {
          statusText.value = 'No recent OTP found. Enter manually.';
          statusIsError.value = true;
        }
      } catch (e) {
        statusText.value = 'Could not read email: $e';
        statusIsError.value = true;
      } finally {
        isFetching.value = false;
      }
    }

    useEffect(() {
      Future.delayed(const Duration(seconds: 2), fetchOtp);
      return null;
    }, const []);

    final minutes = (secondsLeft.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft.value % 60).toString().padLeft(2, '0');
    final timerColor = secondsLeft.value < 60 ? Colors.red : Colors.orange;
    final isExpired = secondsLeft.value == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          FAlert(
            icon: const Icon(FIcons.mail),
            title: const Text('Check your VIT-AP email'),
            subtitle: const Text('An OTP was sent by info1@vitap.ac.in. It auto-fills below.'),
          ),
          const SizedBox(height: 20),
          Text(
            '$minutes:$seconds',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: timerColor),
          ),
          const SizedBox(height: 4),
          Text('OTP expires in', style: TextStyle(fontSize: 11, color: timerColor.withOpacity(0.7))),
          const SizedBox(height: 20),
          FTextFormField(
            control: FTextFieldControl.managed(controller: otpController),
            label: const Text('OTP'),
            hint: '• • • • • •',
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 8),
          if (statusText.value != null)
            Text(
              statusText.value!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: statusIsError.value ? Colors.red : Colors.green,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isFetching.value ? null : fetchOtp,
                  icon: isFetching.value
                      ? const SizedBox(
                          height: 16, width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: const Text('Re-fetch'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FButton(
                  onPress: isExpired
                      ? null
                      : () {
                          if (otpController.text.trim().length == 6) {
                            // TODO: Pass otpController.text to Rust VTOP OTP verification
                            onOtpVerified();
                          }
                        },
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        ],
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
