import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/services/campus_supabase.dart';
import 'package:vsync/core/services/providers.dart';
import 'package:vsync/features/campus/data/campus_home_models.dart';
import 'package:vsync/src/api/vtop/types.dart';

final campusRepositoryProvider = Provider<CampusRepository>((ref) {
  return CampusRepository(ref);
});

final campusHomeProvider = FutureProvider<CampusHomeData>((ref) async {
  final repository = ref.watch(campusRepositoryProvider);
  return repository.fetchHome();
});

class CampusRepository {
  CampusRepository(this.ref);

  final Ref ref;

  bool get isConfigured => CampusSupabase.isConfigured;

  Future<CampusHomeData> fetchHome() async {
    if (!isConfigured || CampusSupabase.client == null) {
      return const CampusHomeData(
        menu: [],
        upcomingExam: null,
      );
    }

    final services = await ref.read(appServicesProvider.future);
    final client = CampusSupabase.client!;
    final today = DateTime.now();
    final todayIso = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String().split('T').first;

    Future<List<Map<String, dynamic>>> safeList(
      Future<dynamic> Function() action,
    ) async {
      try {
        final result = await action();
        if (result is List) {
          return result
              .whereType<Map>()
              .map((row) => row.map((k, v) => MapEntry(k.toString(), v)))
              .toList();
        }
      } catch (_) {}
      return const [];
    }

    UpcomingExamItem? nextExamFromVtop(ExamScheduleData schedule) {
      final flattened = <(ExamScheduleRecord, String)>[];
      for (final examGroup in schedule.exams) {
        for (final record in examGroup.records) {
          flattened.add((record, examGroup.examType));
        }
      }
      if (flattened.isEmpty) return null;

      DateTime parseExamDate(String value) {
        return DateTime.tryParse(value) ?? DateTime(2100);
      }

      flattened.sort((a, b) {
        return parseExamDate(
          a.$1.examDate,
        ).compareTo(parseExamDate(b.$1.examDate));
      });

      final next = flattened.firstWhere(
        (entry) => parseExamDate(
          entry.$1.examDate,
        ).isAfter(DateTime.now().subtract(const Duration(days: 1))),
        orElse: () => flattened.first,
      );

      return UpcomingExamItem(
        courseName: next.$1.courseName,
        examType: next.$2,
        examDate: parseExamDate(next.$1.examDate),
        venue: next.$1.venue,
        seatLocation: next.$1.seatLocation,
        seatNo: next.$1.seatNo,
        examTime: next.$1.examTime,
        reportingTime: next.$1.reportingTime,
      );
    }

    final menus = await safeList(
      () => client
          .from('mess_menus')
          .select()
          .eq('served_on', todayIso)
          .order('meal_order'),
    );

    final examSchedule = await services.vtopDataRepository.loadExamSchedule();



    return CampusHomeData(
      menu: menus.map(MessMenuItem.fromMap).toList(),
      upcomingExam: nextExamFromVtop(examSchedule),
    );
  }
}
