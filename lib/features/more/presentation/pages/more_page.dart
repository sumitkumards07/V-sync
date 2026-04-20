import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/di/provider/vtop_user_provider.dart';
import 'package:vsync/core/router/paths.dart';
import 'package:vsync/core/widgets/glass_surface.dart';
import 'package:vsync/core/widgets/animated_list_item.dart';

class MorePage extends HookConsumerWidget {
  const MorePage({super.key});

  static const _generalOutingUrl = 'hostel/StudentGeneralOuting';
  static const _weekendOutingUrl = 'hostel/StudentWeekendOuting';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(vtopUserProvider);
    final cs = Theme.of(context).colorScheme;

    void openVtop([String? menuUrl]) {
      GoRouter.of(context).pushNamed(Paths.vtopweb, extra: menuUrl);
    }

    return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Page Header ──────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "More",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Portal tools & academic history",
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── User Hero Section ──────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: userAsync.when(
                  data: (user) => _UserHero(user: user),
                  loading: () => const _UserHeroPlaceholder(),
                  error: (_, __) => const _UserHeroPlaceholder(),
                ),
              ),
            ),

            // ── Academic Tools Grid ────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: "Academics",
                      icon: FIcons.graduationCap,
                      color: cs.primary,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _QuickCard(
                    title: 'Marks',
                    icon: FIcons.clipboardList,
                    color: const Color(0xFF60A5FA),
                    onTap: () => context.pushNamed(Paths.marks),
                  ),
                  _QuickCard(
                    title: 'Grades',
                    icon: FIcons.award,
                    color: const Color(0xFFA78BFA),
                    onTap: () => context.pushNamed(Paths.grades),
                  ),
                  _QuickCard(
                    title: 'History',
                    icon: FIcons.history,
                    color: const Color(0xFF34D399),
                    onTap: () => context.pushNamed(Paths.gradeHistory),
                  ),
                  _QuickCard(
                    title: 'Exams',
                    icon: FIcons.calendarDays,
                    color: const Color(0xFFFBBF24),
                    onTap: () => context.pushNamed(Paths.examSchedule),
                  ),
                  _QuickCard(
                    title: 'Hub',
                    icon: FIcons.graduationCap,
                    color: const Color(0xFFF472B6),
                    onTap: () => context.pushNamed(Paths.courseHub),
                  ),
                ],
              ),
            ),

            // ── Portal Tools ──────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              sliver: SliverToBoxAdapter(
                child: _SectionHeader(
                  title: "VTOP Portal",
                  icon: FIcons.layoutGrid,
                  color: cs.secondary,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tiles = [
                      _GlassTile(
                        title: "Open VTOP",
                        subtitle: "Portal without auto login",
                        icon: FIcons.externalLink,
                        onTap: openVtop,
                      ),
                      _GlassTile(
                        title: "Course Hub",
                        subtitle: "University-wide records & materials",
                        icon: FIcons.graduationCap,
                        color: const Color(0xFFF472B6),
                        onTap: () => context.pushNamed(Paths.courseHub),
                      ),
                      _GlassTile(
                        title: "Course Materials",
                        subtitle: "Module-wise academic content",
                        icon: FIcons.files,
                        onTap: () => context.pushNamed(Paths.courseMaterials),
                      ),
                      _GlassTile(
                        title: "General Outing",
                        subtitle: "Apply for hostel outing",
                        icon: FIcons.anchor,
                        onTap: () => openVtop(_generalOutingUrl),
                      ),
                      _GlassTile(
                        title: "Weekend Outing",
                        subtitle: "Apply for weekend leave",
                        icon: FIcons.amphora,
                        onTap: () => openVtop(_weekendOutingUrl),
                      ),
                    ];
                    
                    if (index >= tiles.length) return const SizedBox(height: 120);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RepaintBoundary(child: tiles[index]),
                    );
                  },
                  childCount: 6, // 5 tiles + bottom padding
                ),
              ),
            ),
          ],
        );
    }
  }

class _UserHero extends StatelessWidget {
  final dynamic user;
  const _UserHero({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassSurface(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary.withOpacity(0.8), cs.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(FIcons.user, color: Colors.black87, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username ?? "Student",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.username ?? "Registration ID",
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserHeroPlaceholder extends StatelessWidget {
  const _UserHeroPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const GlassSurface(
      padding: EdgeInsets.all(20),
      child: SizedBox(height: 60, width: double.infinity),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: GlassSurface(
          padding: const EdgeInsets.all(16),
          blur: 12, // Reduced blur for performance in grid
          tint: color.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _GlassTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        blur: 16, // Reduced blur for performance in list
        child: Row(
          children: [
            Icon(icon, color: color ?? cs.onSurface.withOpacity(0.7), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.4),
                    ),
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

