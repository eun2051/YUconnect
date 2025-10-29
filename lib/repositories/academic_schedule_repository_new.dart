import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academic_schedule.dart';

class AcademicScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'academic_schedules';

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
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .where('startDate', isLessThanOrEqualTo: endDate.toIso8601String())
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
}
