import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'campus_selection_provider.g.dart';

@riverpod
class CampusDateSelection extends _$CampusDateSelection {
  @override
  DateTime build() => DateTime.now();

  void selectDate(DateTime date) {
    state = date;
  }

  void resetToToday() {
    state = DateTime.now();
  }
}
