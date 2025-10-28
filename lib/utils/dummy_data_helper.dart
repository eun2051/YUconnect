import 'package:cloud_firestore/cloud_firestore.dart';

/// 더미 데이터 생성 헬퍼 클래스
class DummyDataHelper {
  /// 여러 개의 더미 민원 생성 (다양한 상태)
  static Future<void> createMultipleDummyInquiries({String? userId}) async {
    try {
      final db = FirebaseFirestore.instance;
      final currentUserId = userId ?? 'dummy_user_default';

      print('🔄 더미 데이터 생성 시작... (사용자: $currentUserId)');

      // 1. 답변 완료된 민원
      final doc1 = await db.collection('inquiries').add({
        'userId': currentUserId,
        'userName': '김영희',
        'content': '시험기간에 도서관 24시간 개방이 가능한지 문의드립니다.',
        'category': 'academic',
        'status': 'completed',
        'imageUrls': [],
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 5)),
        ),
        'updatedAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        'adminResponse':
            '시험기간 중에는 도서관을 24시간 개방하고 있습니다. 자세한 일정은 도서관 홈페이지를 확인해주세요.',
        'responseAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
      });

      print('✅ 답변 완료된 민원 생성됨 - ID: ${doc1.id}');

      // 2. 또 다른 답변 완료된 민원
      final doc2 = await db.collection('inquiries').add({
        'userId': currentUserId,
        'userName': '홍길동',
        'content': '기숙사 1층 세탁실의 세탁기가 고장나서 사용할 수 없습니다. 빠른 수리를 요청드립니다.',
        'category': 'living',
        'status': 'completed',
        'imageUrls': [],
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 3)),
        ),
        'updatedAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        'adminResponse':
            '신고해주신 세탁기 고장 건에 대해 확인했습니다. 수리 업체에 연락하여 내일까지 수리 완료 예정입니다.',
        'responseAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      });

      print('✅ 두 번째 답변 완료된 민원 생성됨 - ID: ${doc2.id}');

      // 3. 진행 중인 민원
      await db.collection('inquiries').add({
        'userId': currentUserId,
        'userName': '박철수',
        'content': '학생식당의 메뉴가 너무 단조롭습니다. 더 다양한 메뉴를 제공해주세요.',
        'category': 'living',
        'status': 'in_progress',
        'imageUrls': [],
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        'updatedAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
      });

      print('✅ 진행 중인 민원 생성됨');

      // 4. 등록된 민원
      await db.collection('inquiries').add({
        'userId': currentUserId,
        'userName': '이민수',
        'content': '공과대학 301호 강의실 에어컨이 작동하지 않습니다.',
        'category': 'facility',
        'status': 'registered',
        'imageUrls': [],
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 6)),
        ),
        'updatedAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 6)),
        ),
      });

      print('✅ 등록된 민원 생성됨');

      print('🎉 모든 더미 민원이 성공적으로 생성되었습니다!');
    } catch (e) {
      print('❌ 더미 데이터 생성 중 오류 발생: $e');
      rethrow;
    }
  }
}
