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
import 'package:vsync/features/more/presentation/providers/grade_history_provider.dart';
import 'package:vsync/features/more/presentation/widgets/more_color.dart';
import 'package:vsync/src/api/vtop/types.dart';

class GradeHistoryPage extends HookConsumerWidget {
  const GradeHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(gradeHistoryProvider);
    final autoRefreshOnOpen = ref.watch(autoRefreshOnOpenProvider);
    final cs = Theme.of(context).colorScheme;

    useEffect(() {
      if (!autoRefreshOnOpen) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(gradeHistoryProvider.notifier).refresh();
        } catch (_) {}
      });
      return null;
    }, [autoRefreshOnOpen]);

    Future<void> reload() async {
      try {
        await ref.read(gradeHistoryProvider.notifier).refresh();
      } catch (e) {
        if (context.mounted) disCommonToast(context, e);
      }
    }

    return RefreshIndicator(
        onRefresh: reload,
        color: cs.primary,
        backgroundColor: cs.surface,
        displacement: 80,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: dataAsync.when(
            loading: () => _buildLoadingState(context),
            error: (e, _) => _buildErrorState(e, context),
            data: (gradeHistory) {
              return Column(
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
                        "Academic History",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Summary Card
                  _CgpaSummaryCard(cgpa: gradeHistory.cgpa),
                  
                  const SizedBox(height: 32),
                  const Text(
                    "Grade History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  
                  if (gradeHistory.records.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...List.generate(gradeHistory.records.length, (i) {
                      return AnimatedListItem(
                        index: i,
                        child: _HistoryCard(record: gradeHistory.records[i]),
                      );
                    }),
                  
                  if (gradeHistory.updateTime > BigInt.zero)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          "Synced at ${formatUnixTimestamp(gradeHistory.updateTime.toInt())}",
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
        ),
      );
    }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 60),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassSurface(
              child: SizedBox(height: 80, width: double.infinity, child: Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary.withOpacity(0.2)),
              )),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Text("No records available"),
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

class _CgpaSummaryCard extends StatelessWidget {
  final GradeHistoryCgpa cgpa;
  const _CgpaSummaryCard({required this.cgpa});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current CGPA",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                  Text(
                    cgpa.cgpa,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(FIcons.award, color: cs.primary, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatItem(label: "Earned", value: cgpa.creditsEarned, color: const Color(0xFF60A5FA)),
              _StatItem(label: "Registered", value: cgpa.creditsRegistered, color: const Color(0xFFA78BFA)),
              _StatItem(label: "Fails", value: cgpa.fGrades, color: const Color(0xFFF87171)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(0.4)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends HookConsumerWidget {
  final GradeHistoryRecord record;
  const _HistoryCard({required this.record});

  Color _gradeColor(String grade) {
    switch (grade.trim().toUpperCase()) {
      case 'S':
      case 'A': return const Color(0xFF34D399); // Neon Teal
      case 'B':
      case 'C': return const Color(0xFF60A5FA); // Neon Blue
      default: return const Color(0xFFF87171); // Neon Red
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final cs = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => expanded.value = !expanded.value,
            child: GlassSurface(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _gradeColor(record.grade).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      record.grade,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _gradeColor(record.grade),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.courseTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "${record.courseCode} • ${record.credits} Credits",
                          style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded.value ? FIcons.chevronUp : FIcons.chevronDown,
                    size: 16,
                    color: cs.onSurface.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ),
          if (expanded.value)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GlassSurface(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                   _DetailRow(label: "Exam Month", value: record.examMonth),
                   _DetailRow(label: "Result Declared", value: record.resultDeclared),
                   _DetailRow(label: "Type", value: record.courseType),
                   _DetailRow(label: "Distribution", value: record.courseDistribution),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.4))),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
