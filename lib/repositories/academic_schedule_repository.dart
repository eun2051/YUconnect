import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academic_schedule.dart';

class AcademicScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'academic_schedules';

  // 더미 데이터 리스트
  final List<AcademicSchedule> _schedules = [
    AcademicSchedule(
      id: '2',
      title: '겨울방학',
      description: '2024년 겨울방학 기간입니다.',
      startDate: DateTime(2024, 12, 23),
      endDate: DateTime(2025, 2, 28),
      category: '휴강',
      color: '#2196F3',
      type: 'vacation',
    ),
    AcademicSchedule(
      id: '3',
      title: '1학기 개강',
      description: '2025년 1학기가 시작됩니다.',
      startDate: DateTime(2025, 3, 3),
      endDate: DateTime(2025, 3, 3),
      category: '개강',
      color: '#4CAF50',
      type: 'academic',
    ),
    AcademicSchedule(
      id: '4',
      title: '1학기 중간고사',
      description: '2025년 1학기 중간고사 기간입니다.',
      startDate: DateTime(2025, 4, 15),
      endDate: DateTime(2025, 4, 22),
      category: '시험',
      color: '#FF5722',
      type: 'exam',
    ),
    AcademicSchedule(
      id: '5',
      title: '어린이날',
      description: '어린이날 휴강입니다.',
      startDate: DateTime(2025, 5, 5),
      endDate: DateTime(2025, 5, 5),
      category: '휴강',
      color: '#9C27B0',
      type: 'vacation',
    ),
    AcademicSchedule(
      id: '6',
      title: '1학기 기말고사',
      description: '2025년 1학기 기말고사 기간입니다.',
      startDate: DateTime(2025, 6, 10),
      endDate: DateTime(2025, 6, 17),
      category: '시험',
      color: '#FF5722',
      type: 'exam',
    ),
    AcademicSchedule(
      id: '7',
      title: '여름방학',
      description: '2025년 여름방학 기간입니다.',
      startDate: DateTime(2025, 6, 23),
      endDate: DateTime(2025, 8, 31),
      category: '휴강',
      color: '#FF9800',
      type: 'vacation',
    ),
    AcademicSchedule(
      id: '8',
      title: '2학기 개강',
      description: '2025년 2학기가 시작됩니다.',
      startDate: DateTime(2025, 9, 2),
      endDate: DateTime(2025, 9, 2),
      category: '개강',
      color: '#4CAF50',
      type: 'academic',
    ),
    AcademicSchedule(
      id: '9',
      title: '추석 연휴',
      description: '추석 연휴로 인한 휴강입니다.',
      startDate: DateTime(2025, 10, 6),
      endDate: DateTime(2025, 10, 8),
      category: '휴강',
      color: '#9C27B0',
      type: 'vacation',
    ),
    AcademicSchedule(
      id: '10',
      title: '2학기 중간고사',
      description: '2025년 2학기 중간고사 기간입니다.',
      startDate: DateTime(2025, 10, 20),
      endDate: DateTime(2025, 10, 27),
      category: '시험',
      color: '#FF5722',
      type: 'exam',
    ),
  ];

  // 학사일정 목록 가져오기
  Future<List<AcademicSchedule>> getAcademicSchedules() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .orderBy('startDate', descending: false)
          .get();

      return snapshot.docs
          .map(
            (doc) => AcademicSchedule.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      print('Error fetching academic schedules: $e');
      return [];
    }
  }

  // 특정 날짜 범위의 학사일정 가져오기
  Future<List<AcademicSchedule>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where(
            'startDate',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'startDate',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('startDate')
          .get();

      return snapshot.docs
          .map(
            (doc) => AcademicSchedule.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      print('Error fetching schedules by date range: $e');
      return [];
    }
  }

  // 특정 월의 학사일정 가져오기
  Future<List<AcademicSchedule>> getSchedulesByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return await getSchedulesByDateRange(startOfMonth, endOfMonth);
  }

  // 학사일정 추가 (관리자용)
  Future<String?> addSchedule(AcademicSchedule schedule) async {
    try {
      final docRef = await _firestore
          .collection(collectionName)
          .add(schedule.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding academic schedule: $e');
      return null;
    }
  }

  // 학사일정 수정 (관리자용)
  Future<bool> updateSchedule(AcademicSchedule schedule) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(schedule.id)
          .update(schedule.toJson());
      return true;
    } catch (e) {
      print('Error updating academic schedule: $e');
      return false;
    }
  }

  // 학사일정 삭제 (관리자용)
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection(collectionName).doc(scheduleId).delete();
      return true;
    } catch (e) {
      print('Error deleting academic schedule: $e');
      return false;
    }
  }

  /// 모든 학사일정 조회
  List<AcademicSchedule> getAllSchedules() {
    return List.unmodifiable(_schedules);
  }

  /// 특정 날짜의 학사일정 조회 (더미 데이터용)
  List<AcademicSchedule> getSchedulesForDate(DateTime date) {
    return _schedules
        .where((schedule) => schedule.isDateInRange(date))
        .toList();
  }

  /// 특정 월의 학사일정 조회
  List<AcademicSchedule> getSchedulesForMonth(int year, int month) {
    return _schedules.where((schedule) {
      return (schedule.startDate.year == year &&
              schedule.startDate.month == month) ||
          (schedule.endDate.year == year && schedule.endDate.month == month) ||
          (schedule.startDate.year <= year &&
              schedule.startDate.month <= month &&
              schedule.endDate.year >= year &&
              schedule.endDate.month >= month);
    }).toList();
  }

  /// 특정 카테고리의 학사일정 조회
  List<AcademicSchedule> getSchedulesByCategory(String category) {
    return _schedules
        .where((schedule) => schedule.category == category)
        .toList();
  }

  /// 학사일정 추가 (향후 Firebase 연동용)
  void addScheduleDummy(AcademicSchedule schedule) {
    _schedules.add(schedule);
  }

  /// 학사일정 삭제 (향후 Firebase 연동용)
  void removeSchedule(String id) {
    _schedules.removeWhere((schedule) => schedule.id == id);
  }
}
