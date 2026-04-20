class CampusHomeData {
  const CampusHomeData({
    required this.menu,
    required this.upcomingExam,
    required this.trips,
    required this.lostFound,
  });

  final List<MessMenuItem> menu;
  final UpcomingExamItem? upcomingExam;
  final List<TravelBuddyTrip> trips;
  final List<LostFoundPost> lostFound;

  bool get isEmpty =>
      menu.isEmpty &&
      upcomingExam == null &&
      trips.isEmpty &&
      lostFound.isEmpty;
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

class TravelBuddyTrip {
  const TravelBuddyTrip({
    required this.id,
    required this.route,
    required this.tripDate,
    required this.availableSeats,
    required this.totalSeats,
    this.contactPhone,
  });

  final String id;
  final String route;
  final DateTime tripDate;
  final int availableSeats;
  final int totalSeats;
  final String? contactPhone;

  factory TravelBuddyTrip.fromMap(Map<String, dynamic> map) {
    return TravelBuddyTrip(
      id: (map['id'] ?? '').toString(),
      route: (map['route'] as String? ?? '').trim(),
      tripDate:
          DateTime.tryParse(map['trip_date'] as String? ?? '') ??
          DateTime.now(),
      availableSeats: (map['available_seats'] as num?)?.toInt() ?? 0,
      totalSeats: (map['total_seats'] as num?)?.toInt() ?? 0,
      contactPhone: (map['contact_phone'] as String?)?.trim(),
    );
  }
}

class LostFoundPost {
  const LostFoundPost({
    required this.id,
    required this.type,
    required this.title,
    required this.location,
    this.imageUrl,
  });

  final String id;
  final String type;
  final String title;
  final String location;
  final String? imageUrl;

  bool get isFound => type.toLowerCase() == 'found';

  factory LostFoundPost.fromMap(Map<String, dynamic> map) {
    return LostFoundPost(
      id: (map['id'] ?? '').toString(),
      type: (map['type'] as String? ?? 'lost').trim(),
      title: (map['title'] as String? ?? '').trim(),
      location: (map['location'] as String? ?? '').trim(),
      imageUrl: (map['image_url'] as String?)?.trim(),
    );
  }
}
