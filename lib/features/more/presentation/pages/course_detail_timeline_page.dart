import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/features/more/presentation/providers/course_hub_provider.dart';
import 'package:vsync/src/api/vtop/types.dart';
import 'package:intl/intl.dart';

class CourseDetailTimelinePage extends HookConsumerWidget {
  final CourseClassEntry entry;
  const CourseDetailTimelinePage({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseHubProvider);
    final notifier = ref.read(courseHubProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    useEffect(() {
      Future.microtask(() => notifier.fetchCourseDetail(entry));
      return null;
    }, [entry.classId]);

    final detail = state.selectedCourseDetail;

    return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header with Course Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(FIcons.chevronLeft, color: cs.onSurface),
                      ),
                      if (detail?.downloadAllPath != null)
                        _buildDownloadAllButton(context, detail!.downloadAllPath!),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildHeaderInfo(context, detail ?? _getProxyDetail(entry)),
                ],
              ),
            ),
          ),

          // Content
          if (state.isLoading && detail == null)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (detail == null || detail.lectures.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FIcons.calendar, size: 48, color: cs.onSurface.withOpacity(0.1)),
                    const SizedBox(height: 16),
                    Text(
                      "No lecture records found",
                      style: TextStyle(color: cs.onSurface.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final lecture = detail.lectures[index];
                    final isLast = index == detail.lectures.length - 1;
                    return _LectureTimelineItem(
                      lecture: lecture,
                      isLast: isLast,
                      accentColor: _getAccentForIndex(index),
                    );
                  },
                  childCount: detail.lectures.length,
                ),
              ),
            ),
        ],
      );
    }

  Widget _buildHeaderInfo(BuildContext context, dynamic data) {
    final cs = Theme.of(context).colorScheme;
    final info = data is CoursePageDetail ? data.courseInfo : data as CourseInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          info.courseCode,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          info.courseTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        GlassSurface(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Icon(FIcons.user, size: 16, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  info.faculty,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  info.slot,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: cs.secondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadAllButton(BuildContext context, String path) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        // Handle download all
      },
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FIcons.download, size: 14, color: cs.primary),
            const SizedBox(width: 8),
            const Text(
              "Download All",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  CourseInfo _getProxyDetail(CourseClassEntry entry) {
    return CourseInfo(
      classGroup: entry.classGroup,
      courseCode: entry.courseCode,
      courseTitle: entry.courseTitle,
      courseType: entry.courseType,
      classId: entry.classId,
      slot: entry.slot,
      faculty: entry.faculty,
      courseId: "",
    );
  }

  Color _getAccentForIndex(int index) {
    final colors = [
      const Color(0xFF00F2FE), // Neon Cyan
      const Color(0xFFF761A1), // Neon Pink
      const Color(0xFF8E2DE2), // Purple
      const Color(0xFF21D4FD), // Blue
    ];
    return colors[index % colors.length];
  }
}

class _LectureTimelineItem extends StatelessWidget {
  final LectureEntry lecture;
  final bool isLast;
  final Color accentColor;

  const _LectureTimelineItem({
    required this.lecture,
    required this.isLast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [accentColor, accentColor.withOpacity(0.0)],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lecture.formattedDate,
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.w800, 
                          color: cs.onSurface.withOpacity(0.5)
                        ),
                      ),
                      Text(
                        lecture.day,
                        style: TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.w600, 
                          color: cs.onSurface.withOpacity(0.3)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GlassSurface(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lecture.topic,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
                        ),
                        if (lecture.referenceMaterials.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...lecture.referenceMaterials.map((m) => _MaterialChip(material: m, accent: accentColor)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialChip extends HookConsumerWidget {
  final ReferenceMaterial material;
  final Color accent;

  const _MaterialChip({required this.material, required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDownloading = useState(false);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () async {
          if (isDownloading.value) return;
          isDownloading.value = true;
          try {
            // Handle download logic via notifier
            final bytes = await ref.read(courseHubProvider.notifier).downloadMaterial(material.downloadPath);
            // Save file logic here
          } catch (e) {
            // Handle error
          } finally {
            isDownloading.value = false;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDownloading.value ? FIcons.loader : FIcons.fileText, 
                size: 14, 
                color: accent
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  material.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
