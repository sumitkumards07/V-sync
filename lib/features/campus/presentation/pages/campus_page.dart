import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/widgets/animated_list_item.dart';
import 'package:vsync/features/campus/data/april_mess_menu.dart';
import 'package:vsync/features/campus/presentation/providers/campus_selection_provider.dart';

// ── Current-meal helper ──────────────────────────────────────────────
String _currentMealLabel() {
  final h = DateTime.now().hour;
  if (h >= 7 && h < 10) return 'Breakfast';
  if (h >= 12 && h < 15) return 'Lunch';
  if (h >= 16 && h < 18) return 'Snacks';
  if (h >= 19 && h < 22) return 'Dinner';
  return '';
}

String _nextMealLabel() {
  final h = DateTime.now().hour;
  if (h < 7) return 'Breakfast at 7:30 AM';
  if (h >= 10 && h < 12) return 'Lunch at 12:00 PM';
  if (h >= 15 && h < 16) return 'Snacks at 4:30 PM';
  if (h >= 18 && h < 19) return 'Dinner at 7:00 PM';
  if (h >= 22) return 'Breakfast tomorrow';
  return '';
}

// ── Hook for live clock ─────────────────────────────────────────────
DateTime _useCurrentTime() {
  final time = useState(DateTime.now());
  useEffect(() {
    final timer = Timer.periodic(const Duration(minutes: 1), (_) {
      time.value = DateTime.now();
    });
    return timer.cancel;
  }, []);
  return time.value;
}

// ── Meal colors ─────────────────────────────────────────────────────
const _mealColors = {
  'Breakfast': Color(0xFFFBBF24), // Warm amber
  'Lunch':     Color(0xFF60A5FA), // Calm blue
  'Snacks':    Color(0xFF34D399), // Fresh mint
  'Dinner':    Color(0xFFA78BFA), // Soft purple
};

const _mealIcons = {
  'Breakfast': Icons.wb_sunny_rounded,
  'Lunch':     Icons.wb_cloudy_rounded,
  'Snacks':    Icons.local_cafe_rounded,
  'Dinner':    Icons.dark_mode_rounded,
};

// ═══════════════════════════════════════════════════════════════════
//  CAMPUS PAGE — Mess Menu Only
// ═══════════════════════════════════════════════════════════════════
class CampusPage extends HookConsumerWidget {
  const CampusPage({super.key});

  static const _dayLabels = {
    1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = _useCurrentTime();
    final selectedDate = ref.watch(campusDateSelectionProvider);
    final scrollController = useScrollController();
    final cs = Theme.of(context).colorScheme;
    final dayMenu = aprilMessMenu[selectedDate.day];

    // Auto-scroll to current meal
    useEffect(() {
      if (dayMenu == null) return;
      final currentMeal = _currentMealLabel();
      if (currentMeal.isEmpty) return;
      
      final index = dayMenu.meals.indexWhere((m) => m.type == currentMeal);
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            // Rough estimate of card heights for jumping/scrolling
            // Scroll to roughly the index * 160.0 (card + margin)
            scrollController.animateTo(
              index * 160.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
      return null;
    }, [selectedDate.day]);

    // Build summary text
    final currentMeal = _currentMealLabel();
    final nextMeal = _nextMealLabel();
    String summaryText;
    if (selectedDate.day == now.day && selectedDate.month == now.month) {
      if (currentMeal.isNotEmpty) {
        summaryText = '$currentMeal is being served now';
      } else if (nextMeal.isNotEmpty) {
        summaryText = 'Next: $nextMeal';
      } else {
        summaryText = 'Mess closed';
      }
    } else {
      summaryText = '${_dayLabels[selectedDate.weekday]} Menu · April ${selectedDate.day}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mess Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summaryText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  if (selectedDate.day != now.day || selectedDate.month != now.month)
                    GestureDetector(
                      onTap: () => ref.read(campusDateSelectionProvider.notifier).resetToToday(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

        // ── Day Selector with Dates (same as timetable DaysStack) ──
        Builder(builder: (_) {
              // Compute current week dates (Mon=index0 … Sun=index6)
              final refDate = now.weekday == DateTime.sunday
                  ? now.add(const Duration(days: 1))
                  : now;
              final startOfWeek = refDate.subtract(
                Duration(days: refDate.weekday - 1),
              );
              final weekDates = List.generate(
                7,
                (i) => startOfWeek.add(Duration(days: i)),
              );

              return Container(
                height: 64,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (i) {
                    final dayNum = i + 1; // 1=Mon … 7=Sun
                    final date = weekDates[i];
                    final isActive = date.day == selectedDate.day && date.month == selectedDate.month;
                    final isToday = date.day == now.day && date.month == now.month;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: GestureDetector(
                        onTap: () => ref.read(campusDateSelectionProvider.notifier).selectDate(date),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          decoration: BoxDecoration(
                            color: isActive ? cs.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive
                                  ? Colors.transparent
                                  : isToday
                                      ? cs.primary.withOpacity(0.5)
                                      : cs.outline.withOpacity(0.5),
                              width: isToday && !isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: isActive
                                            ? cs.onPrimary
                                            : cs.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      _dayLabels[dayNum] ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isActive
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isActive
                                            ? cs.onPrimary
                                            : cs.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Today indicator dot
                              if (isToday && !isActive)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),

        // ── Meal Cards ─────────────────────────────────────────
        Expanded(
          child: dayMenu == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restaurant_rounded,
                          size: 48,
                          color: cs.onSurface.withOpacity(0.12)),
                      const SizedBox(height: 12),
                      Text(
                        'No menu available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  itemCount: dayMenu.meals.length,
                  itemBuilder: (_, i) {
                    final meal = dayMenu.meals[i];
                    final isCurrentMeal =
                        selectedDate.day == now.day &&
                        selectedDate.month == now.month &&
                        meal.type == currentMeal;

                    return AnimatedListItem(
                      index: i,
                      child: _MealCard(
                        meal: meal,
                        isCurrentMeal: isCurrentMeal,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  MEAL CARD
// ═══════════════════════════════════════════════════════════════════
class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.isCurrentMeal});

  final MealData meal;
  final bool isCurrentMeal;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = _mealColors[meal.type] ?? cs.primary;
    final icon = _mealIcons[meal.type] ?? Icons.restaurant_rounded;
    final timing = MealTimings.data[meal.type] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentMeal
            ? Border.all(color: accentColor.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: isCurrentMeal
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row with stripe ─────────────────────────────
          Row(
            children: [
              // Left accent stripe
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Row(
                    children: [
                      // Meal type icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 18, color: accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  meal.type,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                                if (isCurrentMeal) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'NOW',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0B0E14),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timing,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface.withOpacity(0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Item count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '${meal.items.length} items',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Food items ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 14, 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: meal.items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withOpacity(0.15),
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withOpacity(0.85),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
