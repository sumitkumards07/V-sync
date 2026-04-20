import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/settings.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/utils/general_utils.dart';
import 'package:vsync/core/utils/toast/common_toast.dart';
import 'package:vsync/core/widgets/animated_list_item.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/features/more/presentation/providers/exam_schedule.dart';
import 'package:vsync/features/more/presentation/widgets/exam_schedule_card.dart';
import 'package:vsync/features/more/presentation/widgets/more_color.dart';

class ExamSchedulePage extends HookConsumerWidget {
  const ExamSchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoRefreshOnOpen = ref.watch(autoRefreshOnOpenProvider);
    final cs = Theme.of(context).colorScheme;

    Future<void> update() async {
      try {
        await ref.read(examScheduleProvider.notifier).updatexamschedule();
      } catch (e) {
        if (context.mounted) disCommonToast(context, e);
      }
    }

    useEffect(() {
      if (!autoRefreshOnOpen) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(examScheduleProvider.notifier).updatexamschedule();
        } catch (_) {}
      });
      return null;
    }, [autoRefreshOnOpen]);

    final examData = ref.watch(examScheduleProvider);

    return RefreshIndicator(
        onRefresh: update,
        color: cs.primary,
        backgroundColor: cs.surface,
        displacement: 80,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(FIcons.chevronLeft, color: cs.onSurface),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Exam Schedule",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              examData.when(
                loading: () => _buildLoadingState(context),
                error: (e, _) => _buildErrorState(e, context),
                data: (data) {
                  if (data.exams.isEmpty) return _buildEmptyState(context);
                  
                  return Column(
                    children: [
                      ...List.generate(data.exams.length, (i) {
                        return AnimatedListItem(
                          index: i,
                          child: ExamScheduleCard(record: data.exams[i]),
                        );
                      }),
                      
                      if (data.updateTime > BigInt.zero)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Center(
                            child: Text(
                              "Synced at ${formatUnixTimestamp(data.updateTime.toInt())}",
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withOpacity(0.3),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 40),
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassSurface(
              child: SizedBox(height: 120, width: double.infinity, child: Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary.withOpacity(0.2)),
              )),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(FIcons.calendarX, size: 48, color: cs.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              "No examinations scheduled",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Text(commonErrorMessage(error)),
      ),
    );
  }
}

