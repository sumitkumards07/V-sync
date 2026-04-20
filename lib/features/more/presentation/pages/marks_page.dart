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
import 'package:vsync/features/more/presentation/providers/marks_provider.dart';
import 'package:vsync/features/more/presentation/widgets/marks_card.dart';
import 'package:vsync/src/api/vtop/types.dart';

class MarksPage extends HookConsumerWidget {
  const MarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoRefreshOnOpen = ref.watch(autoRefreshOnOpenProvider);
    final cs = Theme.of(context).colorScheme;

    useEffect(() {
      if (!autoRefreshOnOpen) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(marksProvider.notifier).updatemarks();
        } catch (_) {}
      });
      return null;
    }, [autoRefreshOnOpen]);

    Future<void> update() async {
      try {
        await ref.read(marksProvider.notifier).updatemarks();
      } catch (e) {
        if (context.mounted) disCommonToast(context, e);
      }
    }

    final marksData = ref.watch(marksProvider);

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(FIcons.chevronLeft, color: cs.onSurface),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Internal Marks",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Detailed weightage and performance",
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              marksData.when(
                data: (data) {
                  if (data.records.isEmpty) return _buildEmptyState(context);
                  return Column(
                    children: [
                      for (int i = 0; i < data.records.length; i++)
                        AnimatedListItem(
                          index: i,
                          child: MarksCard(
                            record: data.records[i].copyWith(
                              marks: sortedMarks(data.records[i]),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Last updated: ${formatUnixTimestamp(data.updateTime.toInt())}",
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.3),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                error: (e, _) => _buildErrorState(e, context),
                loading: () => _buildLoadingState(context),
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          GlassSurface(
            padding: const EdgeInsets.all(24),
            child: Icon(FIcons.clipboardList, size: 48, color: cs.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          const Text("No data available", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text("Pull down to refresh", style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          GlassSurface(
            padding: const EdgeInsets.all(24),
            child: Icon(FIcons.circleAlert, size: 48, color: cs.error),
          ),
          const SizedBox(height: 24),
          Text(commonErrorMessage(error), textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
          const SizedBox(height: 16),
          FButton(onPress: () {}, child: const Text("Retry")), // Logic handled by RefreshIndicator
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassSurface(
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary.withOpacity(0.2)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

List<MarksRecordEach> sortedMarks(MarksRecord record) {
  final cloned = [...record.marks];
  cloned.sort((a, b) => int.parse(a.serial).compareTo(int.parse(b.serial)));
  return cloned;
}
