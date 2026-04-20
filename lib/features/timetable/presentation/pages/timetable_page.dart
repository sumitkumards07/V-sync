import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/settings.dart';
import 'package:vsync/core/theme/app_theme.dart';
import 'package:vsync/core/utils/general_utils.dart';
import 'package:vsync/core/utils/toast/common_toast.dart';
import 'package:vsync/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:vsync/features/timetable/presentation/providers/timetable_selection_provider.dart';
import 'package:vsync/features/timetable/presentation/utils/timetable_slot_merge.dart';
import 'package:vsync/src/api/vtop/types.dart';
import 'package:vsync/core/widgets/animated_list_item.dart';

// ── UTILITIES ───────────────────────────────────────────────────────
String _to12H(String time) {
  final list = time.split(":");
  int hours = int.parse(list[0]);
  String period;
  if (hours >= 12) {
    if (hours > 12) hours -= 12;
    period = "PM";
  } else {
    if (hours == 0) hours = 12;
    period = "AM";
  }
  final mins = list.length > 1 ? list[1] : "00";
  return "$hours:$mins $period";
}

List<int> getDayList(TimetableData? data) {
  if (data == null) return [];
  const map = {"MON": 1, "TUE": 2, "WED": 3, "THU": 4, "FRI": 5, "SAT": 6, "SUN": 7};
  final found = <String>{};
  for (final i in data.slots) { found.add(i.day); }
  return found.map((k) => map[k]!).toList()..sort();
}

List<TimetableSlot> getDaySlotList(TimetableData data, int i) {
  const map = {1: "MON", 2: "TUE", 3: "WED", 4: "THU", 5: "FRI", 6: "SAT", 7: "SUN"};
  final day = map[i];
  if (day == null) return [];
  return data.slots.where((s) => s.day == day).toList();
}

Duration _parseTime(String t) {
  final parts = t.split(":");
  return Duration(hours: int.parse(parts[0]), minutes: parts.length > 1 ? int.parse(parts[1]) : 0);
}

int _timeDiffMinutes(String a, String b) {
  final d1 = _parseTime(a);
  final d2 = _parseTime(b);
  return d2.inMinutes - d1.inMinutes;
}

List<TimetableSlot> addFreeSlots(List<TimetableSlot> t) {
  if (t.isEmpty) return t;
  List<TimetableSlot> r = [];
  for (int i = 0; i < t.length - 1; i++) {
    r.add(t[i]);
    final diff = _timeDiffMinutes(t[i].endTime, t[i + 1].startTime);
    final mod = diff ~/ 60;
    if (mod > 0) {
      r.add(TimetableSlot(
        serial: "-1", day: t[i].day, slot: "$mod", courseCode: "-", courseType: "-",
        roomNo: "-", block: "-", startTime: t[i].endTime, endTime: t[i + 1].startTime,
        name: "-", isLab: false, faculty: '',
      ));
    }
  }
  r.add(t.last);
  return r;
}

// ── CUSTOM HOOK FOR TIMER ───────────────────────────────────────────
DateTime useCurrentTime() {
  final time = useState(DateTime.now());
  useEffect(() {
    final timer = Timer.periodic(const Duration(minutes: 1), (_) {
      time.value = DateTime.now();
    });
    return timer.cancel;
  }, []);
  return time.value;
}

// ── MAIN TIMETABLE PAGE ──────────────────────────────────────────────
class TimetablePage extends HookConsumerWidget {
  const TimetablePage({super.key});

  static const _dayLabels = {
    1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = useCurrentTime();
    final selectedDay = ref.watch(timetableDaySelectionProvider);
    final finalDay = useState<List<int>>([]);
    final scrollController = useScrollController();
    final timetableData = ref.watch(timetableProvider);
    final autoRefreshOnOpen = ref.watch(autoRefreshOnOpenProvider);
    final mergeLabs = ref.watch(mergeTTProvider);
    final cs = Theme.of(context).colorScheme;

    useEffect(() {
      if (!autoRefreshOnOpen) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try { await ref.read(timetableProvider.notifier).updateTimetable(); } catch (_) {}
      });
      return null;
    }, [autoRefreshOnOpen]);

    Future<void> update() async {
      try { await ref.read(timetableProvider.notifier).updateTimetable(); } 
      catch (e) { if (context.mounted) disCommonToast(context, e); }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: update,
          color: cs.primary,
          backgroundColor: cs.surface,
          child: timetableData.when(
            data: (data) {
              // Always show Mon-Sat (no Sunday in Timetable) to match Mess Menu structure
              const tempList = [1, 2, 3, 4, 5, 6];
              if (!tempList.contains(selectedDay) && finalDay.value.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(timetableDaySelectionProvider.notifier).resetToToday();
                });
              }
              finalDay.value = tempList;

              var tempdays = getDaySlotList(data, selectedDay);
              if (mergeLabs) tempdays = mergeLabsSloths(tempdays);
              final daySlots = addFreeSlots(tempdays);
              daySlots.sort((a, b) => _parseTime(a.startTime).compareTo(_parseTime(b.startTime)));

              // Auto-scroll logic
              useEffect(() {
                if (daySlots.isEmpty) return null;
                if (selectedDay != now.weekday) return null;

                final nowMin = now.hour * 60 + now.minute;
                int targetIndex = -1;

                // Find the first slot that is currently active or upcoming
                for (int i = 0; i < daySlots.length; i++) {
                  final s = daySlots[i];
                  final endMin = _parseTime(s.endTime).inMinutes;
                  if (endMin > nowMin) {
                    targetIndex = i;
                    break;
                  }
                }

                if (targetIndex != -1) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scrollController.hasClients) {
                      scrollController.animateTo(
                        targetIndex * 120.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  });
                }
                return null;
              }, [selectedDay, daySlots.length]);

              // Calculate dynamic summary
              String summaryText = "No classes today";
              if (selectedDay == now.weekday && daySlots.isNotEmpty) {
                final nowMin = now.hour * 60 + now.minute;
                int remaining = 0;
                TimetableSlot? nextSlot;
                
                for (final s in daySlots) {
                  if (s.serial == "-1") continue;
                  final endMin = _parseTime(s.endTime).inMinutes;
                  final startMin = _parseTime(s.startTime).inMinutes;
                  
                  if (endMin > nowMin) remaining++;
                  if (startMin > nowMin && nextSlot == null) nextSlot = s;
                }
                
                if (remaining == 0) {
                  summaryText = "All classes done for today";
                } else if (nextSlot != null) {
                  final startMin = _parseTime(nextSlot.startTime).inMinutes;
                  final diff = startMin - nowMin;
                  if (diff < 60) {
                    summaryText = "Next class in $diff mins";
                  } else {
                    summaryText = "Next class at ${_to12H(nextSlot.startTime)}";
                  }
                } else {
                  summaryText = "$remaining class${remaining > 1 ? 'es' : ''} remaining";
                }
              } else if (daySlots.isNotEmpty) {
                final count = daySlots.where((s) => s.serial != "-1").length;
                summaryText = "$count Classes Scheduled";
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                              "Timetable",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              summaryText,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary),
                            ),
                          ],
                        ),
                        if (selectedDay != now.weekday)
                          GestureDetector(
                            onTap: () {
                              ref.read(timetableDaySelectionProvider.notifier).resetToToday();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text("Today", style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                          )
                      ],
                    ),
                  ),

                  // Date Selector - Centered Row (Monday-Saturday)
                  Builder(builder: (_) {
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
                        children: List.generate(6, (i) {
                          final dayNum = i + 1; // 1=Mon … 6=Sat
                          final isActive = dayNum == selectedDay;
                          final isToday = dayNum == now.weekday;
                          final date = weekDates[i];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => ref.read(timetableDaySelectionProvider.notifier).selectDay(dayNum),
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

                  // Timeline & Class Cards
                  Expanded(
                    child: daySlots.isEmpty
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.wb_sunny_rounded, size: 48, color: cs.onSurface.withOpacity(0.12)),
                          const SizedBox(height: 12),
                          Text('No classes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface.withOpacity(0.3))),
                        ]))
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: daySlots.length,
                          itemBuilder: (_, i) {
                            final slot = daySlots[i];
                            final isNow = false; // We calculate this inside the card
                            
                            if (slot.serial == "-1") {
                              return AnimatedListItem(index: i, child: _BreakCard(slot: slot, now: now, selectedDay: selectedDay));
                            }
                            return AnimatedListItem(index: i, child: _ClassCard(slot: slot, now: now, selectedDay: selectedDay));
                          },
                        ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: cs.primary),
            ),
            error: (e, _) {
              disCommonToast(context, e);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FAlert(
                    variant: FAlertVariant.destructive,
                    icon: const Icon(FIcons.triangleAlert),
                    title: const Text("Unable to load timetable"),
                    subtitle: Text(commonErrorMessage(e)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── CLASS CARD ────────────────────────────────────────────────────────
class _ClassCard extends StatelessWidget {
  final TimetableSlot slot;
  final DateTime now;
  final int selectedDay;

  const _ClassCard({required this.slot, required this.now, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLab = slot.isLab;
    
    // Semantic Colors
    final stripeColor = isLab ? kLab : kLec;
    
    // Calculate if it's currently happening
    final startMin = _parseTime(slot.startTime).inMinutes;
    final endMin = _parseTime(slot.endTime).inMinutes;
    final nowMin = now.hour * 60 + now.minute;
    final isActiveNow = selectedDay == now.weekday && nowMin >= startMin && nowMin < endMin;
    
    // Calculate fraction for the glowing line (0.0 to 1.0)
    double progress = 0;
    if (isActiveNow) {
      progress = (nowMin - startMin) / (endMin - startMin);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Base Card
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: isActiveNow ? Border.all(color: stripeColor.withOpacity(0.3), width: 1.5) : null,
              boxShadow: isActiveNow ? [
                BoxShadow(color: stripeColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
              ] : [],
            ),
            child: Row(
              children: [
                // Semantic Left Stripe
                Container(
                  width: 4,
                  height: 96,
                  decoration: BoxDecoration(
                    color: stripeColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  ),
                ),
                // Card Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFF8FAFC)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: stripeColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isLab ? 'LAB' : 'LEC',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0B0E14), letterSpacing: 0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: cs.outline.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      slot.slot,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 14, color: cs.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${slot.block} - ${slot.roomNo}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF8FAFC)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${slot.faculty} • ${slot.courseCode}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Right Side Time Stack
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _to12H(slot.startTime),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActiveNow ? cs.onSurface : const Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 4),
                              Icon(Icons.arrow_downward_rounded, size: 14, color: cs.primary.withOpacity(0.5)),
                              const SizedBox(height: 4),
                              Text(
                                _to12H(slot.endTime),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8).withOpacity(0.7)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Glowing "Now" Indicator Line intersecting the card
          if (isActiveNow)
            Positioned(
              left: -8,
              right: -8,
              top: 16 + (progress * 64), // Dynamic vertical offset based on progress
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: cs.secondary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: cs.secondary.withOpacity(0.8), blurRadius: 8)]),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: cs.secondary,
                        boxShadow: [BoxShadow(color: cs.secondary.withOpacity(0.8), blurRadius: 6)],
                      ),
                    ),
                  ),
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: cs.secondary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: cs.secondary.withOpacity(0.8), blurRadius: 8)]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── BREAK CARD ───────────────────────────────────────────────────────
class _BreakCard extends StatelessWidget {
  final TimetableSlot slot;
  final DateTime now;
  final int selectedDay;

  const _BreakCard({required this.slot, required this.now, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    final startMin = _parseTime(slot.startTime).inMinutes;
    final endMin = _parseTime(slot.endTime).inMinutes;
    final nowMin = now.hour * 60 + now.minute;
    final isActiveNow = selectedDay == now.weekday && nowMin >= startMin && nowMin < endMin;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isActiveNow ? kBrk.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActiveNow ? kBrk.withOpacity(0.5) : cs.outline,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.coffee_rounded, size: 20, color: isActiveNow ? kBrk : const Color(0xFF94A3B8).withOpacity(0.6)),
          const SizedBox(width: 12),
          Text(
            'Break • ${slot.slot} hr',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isActiveNow ? kBrk : const Color(0xFF94A3B8)),
          ),
          const Spacer(),
          Text(
            '${_to12H(slot.startTime)} – ${_to12H(slot.endTime)}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8).withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
