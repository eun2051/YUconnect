/// 총학생회 행사 모델
class StudentEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final String category;
  final String organizer;
  final int participantCount;
  final int maxParticipants;
  final bool isRegistrationRequired;
  final DateTime? registrationDeadline;
  final String status; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final List<String> tags;

  StudentEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.category,
    required this.organizer,
    this.participantCount = 0,
    this.maxParticipants = 0,
    this.isRegistrationRequired = false,
    this.registrationDeadline,
    required this.status,
    this.tags = const [],
  });

  /// Firestore 문서에서 StudentEvent 객체 생성
  factory StudentEvent.fromMap(Map<String, dynamic> map, String id) {
    return StudentEvent(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      organizer: map['organizer'] ?? '',
      participantCount: map['participantCount'] ?? 0,
      maxParticipants: map['maxParticipants'] ?? 0,
      isRegistrationRequired: map['isRegistrationRequired'] ?? false,
      registrationDeadline: map['registrationDeadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['registrationDeadline'])
          : null,
      status: map['status'] ?? 'upcoming',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  /// JSON에서 StudentEvent 객체 생성 (fromMap과 동일)
  factory StudentEvent.fromJson(Map<String, dynamic> json) {
    return StudentEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate'] ?? 0),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      organizer: json['organizer'] ?? '',
      participantCount: json['participantCount'] ?? 0,
      maxParticipants: json['maxParticipants'] ?? 0,
      isRegistrationRequired: json['isRegistrationRequired'] ?? false,
      registrationDeadline: json['registrationDeadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['registrationDeadline'])
          : null,
      status: json['status'] ?? 'upcoming',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// StudentEvent 객체를 Firestore 문서로 변환
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'category': category,
      'organizer': organizer,
      'participantCount': participantCount,
      'maxParticipants': maxParticipants,
      'isRegistrationRequired': isRegistrationRequired,
      'registrationDeadline': registrationDeadline?.millisecondsSinceEpoch,
      'status': status,
      'tags': tags,
    };
  }

  /// JSON으로 변환 (toMap과 동일)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'category': category,
      'organizer': organizer,
      'participantCount': participantCount,
      'maxParticipants': maxParticipants,
      'isRegistrationRequired': isRegistrationRequired,
      'registrationDeadline': registrationDeadline?.millisecondsSinceEpoch,
      'status': status,
      'tags': tags,
    };
  }

  /// 행사 상태 판별
  String getEventStatus() {
    final now = DateTime.now();

    if (status == 'cancelled') return 'cancelled';
    if (now.isBefore(startDate)) return 'upcoming';
    if (now.isAfter(endDate)) return 'completed';
    return 'ongoing';
  }

  /// 등록 가능 여부 확인
  bool get canRegister {
    if (!isRegistrationRequired) return false;
    if (registrationDeadline != null &&
        DateTime.now().isAfter(registrationDeadline!)) {
      return false;
    }
    if (maxParticipants > 0 && participantCount >= maxParticipants) {
      return false;
    }
    return getEventStatus() == 'upcoming';
  }

  /// 행사 기간 포맷팅
  String get formattedDuration {
    final startStr =
        '${startDate.year}.${startDate.month.toString().padLeft(2, '0')}.${startDate.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDate.year}.${endDate.month.toString().padLeft(2, '0')}.${endDate.day.toString().padLeft(2, '0')}';

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return startStr;
    }

    return '$startStr ~ $endStr';
  }

  /// 상태에 따른 색상 반환 (UI에서 처리해야 함)
  // String get statusColorHex {
  //   switch (getEventStatus()) {
  //     case 'upcoming':
  //       return '#006FFD'; // 파란색
  //     case 'ongoing':
  //       return '#10B981'; // 녹색
  //     case 'completed':
  //       return '#6B7280'; // 회색
  //     case 'cancelled':
  //       return '#EF4444'; // 빨간색
  //     default:
  //       return '#6B7280';
  //   }
  // }

  /// 상태 텍스트 반환
  String get statusText {
    switch (getEventStatus()) {
      case 'upcoming':
        return '예정';
      case 'ongoing':
        return '진행중';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소';
      default:
        return '알 수 없음';
    }
  }
}
