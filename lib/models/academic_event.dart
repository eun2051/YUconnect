import 'package:cloud_firestore/cloud_firestore.dart';

/// 학사일정 카테고리 열거형
enum AcademicEventCategory {
  regular('일반'),
  exam('시험'),
  holiday('휴일'),
  registration('등록'),
  special('특별');

  const AcademicEventCategory(this.displayName);
  final String displayName;

  String get value => name;
}

/// 학사일정 모델
class AcademicEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final AcademicEventCategory category;
  final bool isAllDay;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AcademicEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    required this.category,
    this.isAllDay = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Firestore에서 AcademicEvent 객체로 변환
  factory AcademicEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AcademicEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      category: AcademicEventCategory.values.firstWhere(
        (e) => e.value == data['category'],
        orElse: () => AcademicEventCategory.regular,
      ),
      isAllDay: data['isAllDay'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// AcademicEvent 객체를 Firestore 형식으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'category': category.value,
      'isAllDay': isAllDay,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// 복사본 생성
  AcademicEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    AcademicEventCategory? category,
    bool? isAllDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademicEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      isAllDay: isAllDay ?? this.isAllDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 날짜 범위 체크 (특정 날짜가 이벤트 기간에 포함되는지)
  bool containsDate(DateTime date) {
    final eventStart = DateTime(startDate.year, startDate.month, startDate.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (endDate == null) {
      return eventStart.isAtSameMomentAs(checkDate);
    }

    final eventEnd = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return checkDate.isAtSameMomentAs(eventStart) ||
        checkDate.isAtSameMomentAs(eventEnd) ||
        (checkDate.isAfter(eventStart) && checkDate.isBefore(eventEnd));
  }

  @override
  String toString() {
    return 'AcademicEvent(id: $id, title: $title, startDate: $startDate, endDate: $endDate, category: ${category.displayName})';
  }
}
