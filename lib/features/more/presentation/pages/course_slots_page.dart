import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/router/paths.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/features/more/presentation/providers/course_hub_provider.dart';
import 'package:vsync/src/api/vtop/types.dart';

class CourseSlotsPage extends HookConsumerWidget {
  final CourseOption course;
  const CourseSlotsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseHubProvider);
    final notifier = ref.read(courseHubProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    useEffect(() {
      Future.microtask(() => notifier.selectCourse(course.value));
      return null;
    }, [course.value]);

    return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(FIcons.chevronLeft, color: cs.onSurface),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    course.courseCode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.courseTitle,
                    style: const TextStyle(
                      fontSize: 28, // Slightly smaller than lookup for title
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatsRow(context, state),
                ],
              ),
            ),
          ),

          // Loading or results
          if (state.isLoading && state.classEntries.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.classEntries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FIcons.users, size: 48, color: cs.onSurface.withOpacity(0.1)),
                    const SizedBox(height: 16),
                    Text(
                      "No faculty/slots available",
                      style: TextStyle(color: cs.onSurface.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = state.classEntries[index];
                    return FacultySlotCard(entry: entry);
                  },
                  childCount: state.classEntries.length,
                ),
              ),
            ),
        ],
      );
    }

  Widget _buildStatsRow(BuildContext context, CourseHubState state) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _buildStatChip(context, "${state.classEntries.length} Options", cs.secondary),
        const SizedBox(width: 8),
        _buildStatChip(context, course.courseType, cs.primary),
      ],
    );
  }

  Widget _buildStatChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11, 
          fontWeight: FontWeight.w800, 
          color: color
        ),
      ),
    );
  }
}

class FacultySlotCard extends StatelessWidget {
  final CourseClassEntry entry;
  const FacultySlotCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    // Aesthetic accent based on faculty name
    final accent = Colors.primaries[entry.faculty.hashCode % Colors.primaries.length];
    
    final formattedFaculty = entry.faculty.split(' ')
        .map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join(' ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FTappable(
        onPress: () {
          context.pushNamed(Paths.courseTimeline, extra: entry);
        },
        child: GlassSurface(
          padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      entry.faculty.isNotEmpty ? entry.faculty[0] : "?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedFaculty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.classGroup,
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ),
                _buildNeonBadge(context, entry.slot, accent),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(context, FIcons.monitor, "Class ID", entry.classId),
                _buildInfoItem(context, FIcons.layers, "Group", entry.classGroup.split(' ').first),
              ],
            ),
          ],
        ),
      ),
     ),
    );
  }

  Widget _buildNeonBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w900, 
          color: color,
          letterSpacing: 0.5
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: cs.onSurface.withOpacity(0.3)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}
