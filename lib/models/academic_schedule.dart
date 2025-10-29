class AcademicSchedule {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String category; // 예: '시험', '휴강', '개강', ...
  final String color; // hex string, 예: '#FF5722'
  final String type; // 'academic', 'exam', 'vacation', 'event'
  final bool isAllDay;

  AcademicSchedule({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.color,
    required this.type,
    this.isAllDay = false,
  });

  factory AcademicSchedule.fromJson(Map<String, dynamic> json) {
    return AcademicSchedule(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: json['category'] ?? '',
      color: json['color'] ?? '#2196F3',
      type: json['type'] ?? 'event',
      isAllDay: json['isAllDay'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'category': category,
      'color': color,
      'type': type,
      'isAllDay': isAllDay,
    };
  }

  /// 날짜 범위 문자열 반환 (예: '6.10 ~ 6.17')
  String get dateRangeString {
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return '${startDate.month}.${startDate.day}';
    } else {
      return '${startDate.month}.${startDate.day} ~ ${endDate.month}.${endDate.day}';
    }
  }

  /// 해당 날짜가 일정 범위에 포함되는지 여부
  bool isDateInRange(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    return (d.isAtSameMomentAs(s) || d.isAfter(s)) &&
        (d.isAtSameMomentAs(e) || d.isBefore(e));
  }
}
