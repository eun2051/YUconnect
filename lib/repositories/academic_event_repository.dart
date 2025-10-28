import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academic_event.dart';

/// 학사일정 데이터 관리 Repository
class AcademicEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'academic_events';

  /// 모든 학사일정 조회
  Stream<List<AcademicEvent>> getAllEvents() {
    return _firestore
        .collection(_collection)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AcademicEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 특정 연도의 학사일정 조회
  Stream<List<AcademicEvent>> getEventsByYear(int year) {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year + 1, 1, 1);

    return _firestore
        .collection(_collection)
        .where(
          'startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear),
        )
        .where('startDate', isLessThan: Timestamp.fromDate(endOfYear))
        .orderBy('startDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AcademicEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 특정 월의 학사일정 조회
  Stream<List<AcademicEvent>> getEventsByMonth(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    return _firestore
        .collection(_collection)
        .where(
          'startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('startDate', isLessThan: Timestamp.fromDate(endOfMonth))
        .orderBy('startDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AcademicEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 특정 날짜의 학사일정 조회
  Stream<List<AcademicEvent>> getEventsByDate(DateTime date) {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final events = snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .where((event) => event.containsDate(date))
          .toList();

      events.sort((a, b) => a.startDate.compareTo(b.startDate));
      return events;
    });
  }

  /// 카테고리별 학사일정 조회
  Stream<List<AcademicEvent>> getEventsByCategory(
    AcademicEventCategory category,
  ) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category.value)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AcademicEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 특정 기간의 학사일정 조회
  Stream<List<AcademicEvent>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(_collection)
        .where(
          'startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('startDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AcademicEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 학사일정 추가
  Future<void> addEvent(AcademicEvent event) async {
    await _firestore.collection(_collection).add(event.toFirestore());
  }

  /// 학사일정 수정
  Future<void> updateEvent(String eventId, AcademicEvent event) async {
    await _firestore
        .collection(_collection)
        .doc(eventId)
        .update(event.copyWith(updatedAt: DateTime.now()).toFirestore());
  }

  /// 학사일정 삭제
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collection).doc(eventId).delete();
  }

  /// 특정 학사일정 조회
  Future<AcademicEvent?> getEventById(String eventId) async {
    final doc = await _firestore.collection(_collection).doc(eventId).get();
    if (doc.exists) {
      return AcademicEvent.fromFirestore(doc);
    }
    return null;
  }

  /// 샘플 데이터 추가 (개발용)
  Future<void> addSampleData() async {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // 기존 데이터 먼저 삭제
    try {
      final snapshot = await _firestore.collection(_collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('기존 데이터 삭제 오류: $e');
    }

    final sampleEvents = [
      // 현재 달의 이벤트들
      AcademicEvent(
        id: '',
        title: '오늘 테스트 이벤트',
        description: '오늘 날짜의 테스트 이벤트입니다.',
        startDate: now,
        category: AcademicEventCategory.special,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '내일 수업',
        description: '내일 정규 수업이 있습니다.',
        startDate: now.add(const Duration(days: 1)),
        category: AcademicEventCategory.regular,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '중간고사 기간',
        description: '중간고사 기간입니다.',
        startDate: DateTime(currentYear, currentMonth, 15),
        endDate: DateTime(currentYear, currentMonth, 20),
        category: AcademicEventCategory.exam,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '개천절',
        description: '개천절 공휴일',
        startDate: DateTime(2024, 10, 3),
        category: AcademicEventCategory.holiday,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '한글날',
        description: '한글날 공휴일',
        startDate: DateTime(2024, 10, 9),
        category: AcademicEventCategory.holiday,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '기말고사',
        description: '기말고사 기간입니다.',
        startDate: DateTime(currentYear, 12, 14),
        endDate: DateTime(currentYear, 12, 20),
        category: AcademicEventCategory.exam,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '겨울방학',
        description: '겨울방학이 시작됩니다.',
        startDate: DateTime(currentYear, 12, 21),
        endDate: DateTime(currentYear + 1, 2, 28),
        category: AcademicEventCategory.holiday,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '2025학년도 1학기 개강',
        description: '2025학년도 1학기가 시작됩니다.',
        startDate: DateTime(2025, 3, 2),
        category: AcademicEventCategory.regular,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '어린이날',
        description: '어린이날 공휴일입니다.',
        startDate: DateTime(2025, 5, 5),
        category: AcademicEventCategory.holiday,
        createdAt: DateTime.now(),
      ),
      AcademicEvent(
        id: '',
        title: '현충일',
        description: '현충일 공휴일입니다.',
        startDate: DateTime(2025, 6, 6),
        category: AcademicEventCategory.holiday,
        createdAt: DateTime.now(),
      ),
    ];

    for (final event in sampleEvents) {
      await addEvent(event);
    }

    print('샘플 데이터 ${sampleEvents.length}개가 추가되었습니다.');
  }
}
