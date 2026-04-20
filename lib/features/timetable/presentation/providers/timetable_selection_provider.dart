import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timetable_selection_provider.g.dart';

@riverpod
class TimetableDaySelection extends _$TimetableDaySelection {
  @override
  int build() {
    final now = DateTime.now();
    return now.weekday == 7 ? 1 : now.weekday;
  }

  void selectDay(int day) {
    state = day;
  }

  void resetToToday() {
    final now = DateTime.now();
    state = now.weekday == 7 ? 1 : now.weekday;
  }
}
