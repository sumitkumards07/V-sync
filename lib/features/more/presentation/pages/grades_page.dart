import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/settings.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/utils/general_utils.dart';
import 'package:vsync/core/utils/toast/common_toast.dart';
import 'package:vsync/core/utils/weightage_totals.dart';
import 'package:vsync/core/widgets/animated_list_item.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/features/more/presentation/providers/grades_provider.dart';
import 'package:vsync/features/more/presentation/widgets/more_color.dart';
import 'package:vsync/features/settings/presentation/providers/semester_id_provider.dart';
import 'package:vsync/src/api/vtop/types.dart';

class GradesPage extends HookConsumerWidget {
  const GradesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradesProvider);
    final semAsync = ref.watch(semesterIdProvider);
    final semData = semAsync.value;
    final stateValue = state.value;
    final stateSems = stateValue?.semesters ?? const <SemesterInfo>[];
    final semesters =
        stateSems.isNotEmpty ? stateSems : (semData?.semesters ?? const []);
    final selectedSemesterId =
        stateValue?.selectedSemesterId ??
        (semesters.isNotEmpty ? semesters.first.id : "");
    final autoRefreshOnOpen = ref.watch(autoRefreshOnOpenProvider);
    final cs = Theme.of(context).colorScheme;

    useEffect(() {
      if (!autoRefreshOnOpen) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(gradesProvider.notifier).refresh();
        } catch (_) {}
      });
      return null;
    }, [autoRefreshOnOpen]);

    Future<void> refresh() async {
      try {
        await ref.read(semesterIdProvider.future);
        await ref.read(gradesProvider.notifier).refresh();
      } catch (e) {
        if (context.mounted) disCommonToast(context, e);
      }
    }

    return RefreshIndicator(
        onRefresh: refresh,
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
                    "Course Grades",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Semester Selector
              GlassSurface(
                padding: EdgeInsets.zero,
                child: FSelectMenuTile<String>(
                  prefix: const Icon(FIcons.calendarDays, size: 18),
                  title: const Text("Current Semester", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  details: Text(
                    _semesterNameFromList(semesters, selectedSemesterId),
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
                  ),
                  selectControl: FMultiValueControl.managedRadio(
                    initial: selectedSemesterId.isEmpty ? null : selectedSemesterId,
                    onChange: (value) async {
                      final selected = value.firstOrNull;
                      if (selected == null) return;
                      try {
                        await ref.read(gradesProvider.notifier).selectSemester(selected);
                      } catch (e) {
                        if (context.mounted) disCommonToast(context, e);
                      }
                    },
                  ),
                  menu: [
                    for (final sem in semesters)
                      FSelectTile<String>(
                        title: Text(sem.name),
                        value: sem.id,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              state.when(
                loading: () => _buildLoadingState(context),
                error: (e, _) => _buildErrorState(e, context),
                data: (data) {
                  final sorted = [...data.gradeView.courses]..sort(
                    (a, b) => (int.tryParse(a.serial) ?? 0).compareTo(int.tryParse(b.serial) ?? 0),
                  );

                  if (sorted.isEmpty) return _buildEmptyState(context);

                  return Column(
                    children: [
                      ...List.generate(sorted.length, (i) {
                        return AnimatedListItem(
                          index: i,
                          child: _GradeCard(course: sorted[i]),
                        );
                      }),
                      if (data.gradeView.updateTime > BigInt.zero)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Center(
                            child: Text(
                              "Synced at ${formatUnixTimestamp(data.gradeView.updateTime.toInt())}",
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

  String _semesterNameFromList(List<SemesterInfo> sems, String selectedSemesterId) {
    final selected = sems.where((e) => e.id == selectedSemesterId);
    if (selected.isNotEmpty) return selected.first.name;
    return "Choose Semester";
  }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 20),
        for (int i = 0; i < 3; i++)
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
    return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Text("No grades found for this semester")));
  }

  Widget _buildErrorState(Object error, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Text(
          commonErrorMessage(error),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class _GradeCard extends HookConsumerWidget {
  final GradeCourseRecord course;
  const _GradeCard({required this.course});

  Color _gradeColor(String grade) {
    switch (grade.trim().toUpperCase()) {
      case 'S':
      case 'A': return const Color(0xFF34D399); // Neon Teal
      case 'B':
      case 'C': return const Color(0xFF60A5FA); // Neon Blue
      case 'F': return const Color(0xFFF87171); // Neon Red
      default: return const Color(0xFFFBBF24); // Neon Amber
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(gradesProvider).value;
    final detail = state?.detailsByCourseId[course.courseId];
    final loading = state?.loadingDetailsFor.contains(course.courseId) ?? false;

    Future<void> toggle() async {
      expanded.value = !expanded.value;
      if (expanded.value) {
        if (detail == null && !loading) {
          try {
            await ref.read(gradesProvider.notifier).loadDetails(course.courseId);
          } catch (e) {
            if (context.mounted) disCommonToast(context, e);
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: toggle,
            child: GlassSurface(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _gradeColor(course.grade).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      course.grade,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _gradeColor(course.grade),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.courseTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                        Text(
                          "${course.courseCode} • ${course.courseType}",
                          style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
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
              child: _GradeDetailsPanel(
                detail: detail,
                loading: loading,
                gradingType: course.gradingType,
              ),
            ),
        ],
      ),
    );
  }
}


class _MarksTable extends StatelessWidget {
  final List<GradeDetailMark> marks;
  const _MarksTable({required this.marks});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Row(
          items: const ["Title", "Mark", "Max", "Weightage", "Mark"],
          isHeader: true,
        ),
        Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.1)),
        const SizedBox(height: 8),
        for (final m in marks)
          _Row(
            items: [
              m.markTitle.split('•').last.trim(),
              m.scoredMark,
              m.maxMark,
              m.weightage,
              m.weightageMark,
            ],
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final List<String> items;
  final bool isHeader;
  const _Row({required this.items, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _Cell(items[0], 120, isHeader),
          _Cell(items[1], 50, isHeader, textAlign: TextAlign.center),
          _Cell(items[2], 50, isHeader, textAlign: TextAlign.center),
          _Cell(items[3], 80, isHeader, textAlign: TextAlign.center),
          _Cell(items[4], 60, isHeader, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final double width;
  final bool isHeader;
  final TextAlign textAlign;
  const _Cell(this.text, this.width, this.isHeader, {this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
          color: context.theme.colors.foreground.withValues(alpha: isHeader ? 1.0 : 0.7),
        ),
      ),
    );
  }
}


class _CardReloadAction extends StatelessWidget {
  final bool loading;
  final Future<void> Function() onPress;

  const _CardReloadAction({required this.loading, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: loading ? null : onPress,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: context.theme.colors.primaryForeground.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.theme.colors.border),
        ),
        child: Icon(
          loading ? FIcons.loaderCircle : FIcons.rotateCw,
          size: 14,
          color: context.theme.colors.primary,
        ),
      ),
    );
  }
}

class _GradeDetailsPanel extends StatelessWidget {
  final GradeDetailsData? detail;
  final bool loading;
  final String gradingType;
  const _GradeDetailsPanel({
    required this.detail,
    required this.loading,
    required this.gradingType,
  });

  @override
  Widget build(BuildContext context) {
    if (detail == null && loading) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Icon(
            FIcons.loaderCircle,
            size: 22,
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }
    if (detail == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Text(
          "Tap card to load detailed marks",
          style: TextStyle(color: context.theme.colors.mutedForeground),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.theme.colors.primaryForeground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.theme.colors.border),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.theme.colors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.theme.colors.border),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                Text(
                  "Grading Type: $gradingType",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.theme.colors.primary,
                  ),
                ),
                Text(
                  _formatGradeRanges(detail!.gradeRanges),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.theme.colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._buildMarkSectionTables(context, detail!),
        ],
      ),
    );
  }

  List<Widget> _buildMarkSectionTables(
    BuildContext context,
    GradeDetailsData detail,
  ) {
    final sections = _groupMarksBySection(detail);
    final out = <Widget>[];
    for (int idx = 0; idx < sections.length; idx++) {
      final section = sections[idx];
      out.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.theme.colors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.theme.colors.border),
          ),
          child: Text(
            _sectionHeader(section),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.theme.colors.primary,
            ),
          ),
        ),
      );
      out.add(const SizedBox(height: 8));
      out.add(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.theme.colors.primaryForeground.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: _row(
                  context,
                  "Serial Number",
                  "Mark Title",
                  "Scored Mark",
                  "Maximum Mark",
                  "Weightage (%)",
                  "Weightage Mark",
                  true,
                ),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < section.marks.length; i++) ...[
                _row(
                  context,
                  section.marks[i].serial,
                  section.marks[i].markTitle,
                  section.marks[i].scoredMark,
                  section.marks[i].maxMark,
                  section.marks[i].weightage,
                  section.marks[i].weightageMark,
                  false,
                ),
                if (i != section.marks.length - 1)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    height: 1,
                    width: 760,
                    color: context.theme.colors.border.withValues(alpha: 0.7),
                  ),
              ],
            ],
          ),
        ),
      );
      if (idx != sections.length - 1) {
        out.add(const SizedBox(height: 10));
      }
    }
    return out;
  }

  List<_MarkSection> _groupMarksBySection(GradeDetailsData detail) {
    final classTypes =
        detail.classCourseType
            .split('|')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final classNumbers =
        detail.classNumber
            .split('|')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final classNumberByType = <String, String>{};
    for (int i = 0; i < classTypes.length; i++) {
      classNumberByType[classTypes[i]] =
          i < classNumbers.length ? classNumbers[i] : "";
    }

    final grouped = <String, List<GradeDetailMark>>{};
    final order = <String>[];
    for (final mark in detail.marks) {
      String section = detail.classCourseType;
      String title = mark.markTitle;
      if (mark.markTitle.contains("•")) {
        final parts = mark.markTitle.split("•");
        if (parts.length >= 2) {
          section = parts.first.trim();
          title = parts.sublist(1).join("•").trim();
        }
      }
      if (!grouped.containsKey(section)) {
        order.add(section);
      }
      grouped.putIfAbsent(section, () => []);
      grouped[section]!.add(mark.copyWith(markTitle: title));
    }

    return [
      for (final section in order)
        _MarkSection(
          sectionTitle: section,
          classNumber: classNumberByType[section] ?? "",
          total: _sumWeightageMarks(grouped[section] ?? const []),
          marks: grouped[section] ?? const [],
        ),
    ];
  }

  String _sumWeightageMarks(List<GradeDetailMark> marks) {
    final totals = calculateWeightageTotals<GradeDetailMark>(
      marks,
      titleOf: (m) => m.markTitle,
      gainedOf: (m) => m.weightageMark,
      possibleOf: (m) => m.weightage,
    );
    final sum = totals.gained;
    if (sum == 0) return "";
    if (sum == sum.truncateToDouble()) {
      return sum.toStringAsFixed(0);
    }
    return sum.toStringAsFixed(1);
  }

  String _sectionHeader(_MarkSection section) {
    final parts = <String>[section.sectionTitle];
    if (section.total.isNotEmpty) {
      parts.add("Total: ${section.total}");
    }
    return parts.join(" • ");
  }

  Widget _row(
    BuildContext context,
    String a,
    String b,
    String c,
    String d,
    String e,
    String f,
    bool header,
  ) {
    final style = TextStyle(
      fontSize: header ? 13 : 12,
      fontWeight: header ? FontWeight.w700 : FontWeight.w400,
      color:
          header
              ? context.theme.colors.primary
              : context.theme.colors.foreground,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          _cell(a, 110, style),
          _cell(b, 220, style),
          _cell(c, 110, style),
          _cell(d, 120, style),
          _cell(e, 120, style),
          _cell(f, 120, style),
        ],
      ),
    );
  }

  Widget _cell(String txt, double width, TextStyle style) => SizedBox(
    width: width,
    child: Text(
      txt,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style.copyWith(height: 1.25),
    ),
  );

  String _formatGradeRanges(List<GradeRange> ranges) {
    if (ranges.isEmpty) return "Grade ranges unavailable";
    final normalized =
        ranges
            .map(
              (r) => GradeRange(
                grade: r.grade,
                range: r.range.replaceAll('#', '').trim(),
              ),
            )
            .where((r) => r.range.isNotEmpty)
            .toList();
    if (normalized.isEmpty) return "Grade ranges unavailable";
    return normalized.map((r) => "${r.grade}: ${r.range}").join("   ");
  }
}

class _MarkSection {
  final String sectionTitle;
  final String classNumber;
  final String total;
  final List<GradeDetailMark> marks;

  const _MarkSection({
    required this.sectionTitle,
    required this.classNumber,
    required this.total,
    required this.marks,
  });
}

class _CenterInfo extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool loading;
  const _CenterInfo({
    required this.title,
    this.subtitle,
    required this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!loading) ...[
            Icon(icon, size: 36, color: context.theme.colors.mutedForeground),
            const SizedBox(height: 10),
          ],
          Text(
            title,
            style: TextStyle(
              color: context.theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.theme.colors.mutedForeground),
            ),
          ],
          if (loading) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: LinearProgressIndicator(
                minHeight: 3,
                color: context.theme.colors.primary,
                backgroundColor: context.theme.colors.primary.withValues(
                  alpha: 0.18,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
