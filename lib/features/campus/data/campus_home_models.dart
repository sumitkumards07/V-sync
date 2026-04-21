class CampusHomeData {
  const CampusHomeData({
    required this.menu,
    required this.upcomingExam,
  });

  final List<MessMenuItem> menu;
  final UpcomingExamItem? upcomingExam;

  bool get isEmpty =>
      menu.isEmpty &&
      upcomingExam == null;
}

class MessMenuItem {
  const MessMenuItem({
    required this.mealType,
    required this.title,
    required this.items,
    required this.servedOn,
    this.rating,
  });

  final String mealType;
  final String title;
  final List<String> items;
  final DateTime servedOn;
  final int? rating;

  factory MessMenuItem.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    return MessMenuItem(
      mealType: (map['meal_type'] as String? ?? '').trim(),
      title: (map['title'] as String? ?? '').trim(),
      items: rawItems is List
          ? rawItems.whereType<String>().toList()
          : (rawItems as String? ?? '')
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
      servedOn:
          DateTime.tryParse(map['served_on'] as String? ?? '') ??
          DateTime.now(),
      rating: map['rating'] as int?,
    );
  }
}

class UpcomingExamItem {
  const UpcomingExamItem({
    required this.courseName,
    required this.examType,
    required this.examDate,
    required this.venue,
    required this.seatLocation,
    required this.seatNo,
    required this.examTime,
    required this.reportingTime,
  });

  final String courseName;
  final String examType;
  final DateTime examDate;
  final String venue;
  final String seatLocation;
  final String seatNo;
  final String examTime;
  final String reportingTime;
}


