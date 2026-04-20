import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/utils/entity/faculty_record.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/features/more/presentation/providers/faculty_search_provider.dart';

class CourseFacultyPage extends HookConsumerWidget {
  const CourseFacultyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(facultySearchProvider);
    final notifier = ref.read(facultySearchProvider.notifier);
    final searchController = useTextEditingController(text: state.searchQuery);
    final cs = Theme.of(context).colorScheme;

    if (state.allFaculty.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentCourse = state.allFaculty.firstWhere(
      (f) => f.courseCode == state.selectedCourseCode,
      orElse: () => state.allFaculty.first,
    );

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(FIcons.chevronLeft, color: cs.onSurface),
                      ),
                      _buildCoursePill(context, state, notifier),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    currentCourse.courseCode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentCourse.courseName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyGlassSearchDelegate(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassSurface(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: searchController,
                    onChanged: (v) => notifier.updateSearch(v),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Search faculty name or code...",
                      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 14),
                      border: InputBorder.none,
                      icon: Icon(FIcons.search, size: 18, color: cs.onSurface.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Faculty List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final faculty = state.filteredFaculty[index];
                  return _FacultyCard(faculty: faculty);
                },
                childCount: state.filteredFaculty.length,
              ),
            ),
          ),
        ],
      );
    }

  Widget _buildCoursePill(BuildContext context, FacultySearchState state, FacultySearch notifier) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showCoursePicker(context, state, notifier),
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Switch Subject",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Icon(FIcons.chevronDown, size: 12, color: cs.primary),
          ],
        ),
      ),
    );
  }

  void _showCoursePicker(BuildContext context, FacultySearchState state, FacultySearch notifier) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassSurface(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Course", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: state.availableCourses.map((c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c, style: TextStyle(
                    fontWeight: state.selectedCourseCode == c ? FontWeight.w800 : FontWeight.w500,
                    color: state.selectedCourseCode == c ? cs.primary : null,
                  )),
                  trailing: state.selectedCourseCode == c ? Icon(FIcons.check, color: cs.primary) : null,
                  onTap: () {
                    notifier.selectCourse(c);
                    Navigator.pop(context);
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacultyCard extends StatelessWidget {
  final FacultyRecord faculty;
  const _FacultyCard({required this.faculty});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = Color(faculty.colorHex);
    
    final displayName = faculty.facultyName.split(' ')
        .map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join(' ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassSurface(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  faculty.initials,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        faculty.courseCode,
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.4)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: accent.withOpacity(0.2)),
                        ),
                        child: Text(
                          faculty.slot,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(FIcons.chevronRight, size: 16, color: cs.onSurface.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}

class _StickyGlassSearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyGlassSearchDelegate({required this.child});

  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 80;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
