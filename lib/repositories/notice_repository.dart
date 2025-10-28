import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice.dart';

/// 공지사항 Repository
class NoticeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notices';

  /// 공지사항 목록 가져오기 (실시간 스트림)
  Stream<List<Notice>> getNotices({
    String? category,
    String? department,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('publishDate', descending: true)
        .limit(limit * 2); // 더 많이 가져와서 필터링

    return query.snapshots().map((snapshot) {
      List<Notice> notices = snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList();
      
      // 클라이언트 사이드에서 필터링
      if (category != null && category.isNotEmpty) {
        notices = notices.where((notice) => notice.category == category).toList();
      }

      if (department != null && department.isNotEmpty) {
        notices = notices.where((notice) => notice.department == department).toList();
      }

      // 제한된 개수만 반환
      return notices.take(limit).toList();
    });
  }

  /// 중요 공지사항 가져오기
  Stream<List<Notice>> getImportantNotices({int limit = 5}) {
    return _firestore
        .collection(_collection)
        .orderBy('publishDate', descending: true)
        .limit(limit * 5) // 더 많이 가져와서 필터링
        .snapshots()
        .map((snapshot) {
      final allNotices = snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList();
      // 클라이언트 사이드에서 중요 공지만 필터링
      final importantNotices = allNotices.where((notice) => notice.isImportant).toList();
      // 제한된 개수만 반환
      return importantNotices.take(limit).toList();
    });
  }

  /// 특정 공지사항 가져오기
  Future<Notice?> getNoticeById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Notice.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('공지사항 가져오기 오류: $e');
      return null;
    }
  }

  /// 공지사항 추가
  Future<String?> addNotice(Notice notice) async {
    try {
      final docRef = await _firestore.collection(_collection).add(notice.toFirestore());
      return docRef.id;
    } catch (e) {
      print('공지사항 추가 오류: $e');
      return null;
    }
  }

  /// 영남대학교 공지사항 가져오기 (학과 공지 제외)
  Stream<List<Notice>> getUniversityNotices({int limit = 20}) {
    return _firestore
        .collection(_collection)
        .orderBy('publishDate', descending: true)
        .limit(limit * 2) // 더 많이 가져와서 필터링
        .snapshots()
        .map((snapshot) {
      final allNotices = snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList();
      // 클라이언트 사이드에서 학과 공지 제외
      final universityNotices = allNotices.where((notice) => notice.category != '학과').toList();
      // 제한된 개수만 반환
      return universityNotices.take(limit).toList();
    });
  }

  /// 학과 공지사항 가져오기
  Stream<List<Notice>> getDepartmentNotices({String? department, int limit = 20}) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: '학과')
        .orderBy('publishDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final departmentNotices = snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList();
      
      // 특정 학과 필터링 (있는 경우)
      if (department != null && department.isNotEmpty) {
        return departmentNotices.where((notice) => notice.department == department).toList();
      }
      
      return departmentNotices;
    });
  }

  /// 조회수 증가
  Future<void> incrementViewCount(String noticeId) async {
    try {
      await _firestore.collection(_collection).doc(noticeId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('조회수 증가 오류: $e');
    }
  }

  /// 영남대학교 공지사항 샘플 데이터 추가 (공식 소식 포함)
  Future<void> addYeungnamUniversitySampleData() async {
    try {
      final notices = [
        // 영남대학교 공식 소식
        Notice(
          id: 'yu_news_1',
          title: '[영대소식] 영남대학교, 2024 QS 아시아 대학평가 상위권 진입',
          content: '''영남대학교가 2024 QS 아시아 대학평가에서 상위권에 진입했다고 발표했습니다.

주요 성과:
- 아시아 대학 순위 200위권 진입
- 연구 영향력 지표에서 크게 상승
- 국제화 부문에서 높은 점수 획득
- 산학협력 분야에서 우수한 평가

이번 성과는 대학의 지속적인 연구 역량 강화와 국제화 노력의 결실로 평가됩니다.''',
          publishDate: DateTime(2024, 10, 25),
          author: '기획처',
          department: '기획처',
          category: '영대소식',
          isImportant: true,
          viewCount: 567,
          originalUrl: 'https://www.yu.ac.kr/main/index.do',
        ),
        Notice(
          id: 'yu_news_2',
          title: '[영대소식] AI-X 혁신융합대학 선정, 240억원 지원',
          content: '''영남대학교가 교육부 주관 'AI-X 혁신융합대학' 사업에 선정되어 향후 6년간 240억원을 지원받습니다.

사업 개요:
- 사업기간: 2024년 ~ 2029년 (6년)
- 지원금액: 총 240억원
- 참여학과: 컴퓨터공학과, 전자공학과, 기계공학과 등
- 목표: AI 융합인재 양성 및 지역 혁신 선도

이를 통해 AI 분야 최고 수준의 교육 인프라를 구축하고 우수한 인재를 양성할 계획입니다.''',
          publishDate: DateTime(2024, 10, 20),
          author: '기획처',
          department: '기획처',
          category: '영대소식',
          isImportant: true,
          viewCount: 892,
          originalUrl: 'https://www.yu.ac.kr/main/index.do',
        ),
        Notice(
          id: 'yu_info_1',
          title: '[영대정보] 2024년 영남대학교 입학설명회 개최',
          content: '''2024년 영남대학교 입학설명회를 다음과 같이 개최합니다.

일정:
- 서울: 2024년 11월 5일 (화) 14:00, 코엑스 컨벤션센터
- 부산: 2024년 11월 7일 (목) 14:00, 벡스코 제2전시장
- 대구: 2024년 11월 10일 (일) 14:00, 영남대학교 본교

주요 내용:
- 2025학년도 입학전형 안내
- 학과별 특성 및 진로 소개
- 장학제도 및 학생지원 프로그램 안내
- 개별 상담 진행

참가 신청은 입학처 홈페이지에서 가능합니다.''',
          publishDate: DateTime(2024, 10, 15),
          author: '입학처',
          department: '입학처',
          category: '영대정보',
          viewCount: 234,
          originalUrl: 'https://admission.yu.ac.kr',
        ),
        // 기존 대학 공지사항들
        Notice(
          id: 'yu_notice_1',
          title: '[SW중심대학사업단] 산학협력객원 교수 채용 공고',
          content: '''영남대학교 SW중심대학사업단에서 산학협력객원 교수를 다음과 같이 채용합니다.

1. 채용분야: 인공지능, 소프트웨어개발
2. 채용인원: 0명
3. 지원자격: 박사학위 소지자 또는 이에 준하는 자격을 갖춘 자
4. 접수기간: 2024년 10월 01일 ~ 2024년 10월 31일
5. 접수방법: 온라인 접수

자세한 사항은 첨부파일을 참고하시기 바랍니다.''',
          publishDate: DateTime(2024, 10, 17),
          author: 'SW중심대학사업단',
          department: 'SW중심대학사업단',
          category: '채용',
          isImportant: true,
          viewCount: 124,
        ),
        Notice(
          id: 'yu_notice_2',
          title: '[학생처] 2024학년도 2학기 장학금 신청 안내',
          content: '''2024학년도 2학기 장학금 신청을 다음과 같이 안내합니다.

1. 신청기간: 2024년 10월 15일 ~ 2024년 11월 15일
2. 신청방법: 학생포털 온라인 신청
3. 지급기준: 성적 및 소득 기준 충족자
4. 문의: 학생처 장학담당 (053-810-2000)

많은 신청 바랍니다.''',
          publishDate: DateTime(2024, 10, 15),
          author: '학생처',
          department: '학생처',
          category: '장학',
          isImportant: true,
          viewCount: 289,
        ),
        Notice(
          id: 'yu_notice_3',
          title: '[도서관] 도서관 시설 개선 공사로 인한 이용 제한 안내',
          content: '''도서관 시설 개선 공사로 인하여 다음과 같이 이용이 제한됩니다.

1. 공사기간: 2024년 10월 20일 ~ 2024년 11월 30일
2. 제한구역: 3층 열람실
3. 대체시설: 2층 그룹스터디룸 추가 개방
4. 문의: 도서관 관리팀 (053-810-3000)

이용에 불편을 드려 죄송합니다.''',
          publishDate: DateTime(2024, 10, 12),
          author: '도서관',
          department: '도서관',
          category: '시설',
          viewCount: 156,
        ),
        Notice(
          id: 'yu_notice_4',
          title: '[교무처] 2024학년도 2학기 수강정정 기간 안내',
          content: '''2024학년도 2학기 수강정정 기간을 다음과 같이 안내합니다.

1. 수강정정 기간: 2024년 9월 2일 ~ 2024년 9월 6일
2. 정정방법: 학생포털 > 수강신청 > 수강정정
3. 주의사항: 졸업요건 및 선수과목 확인 필수
4. 문의: 교무처 학사담당 (053-810-1500)

수강정정 시 신중히 검토하시기 바랍니다.''',
          publishDate: DateTime(2024, 9, 1),
          author: '교무처',
          department: '교무처',
          category: '학사',
          viewCount: 412,
        ),
        // 학과 공지사항들
        Notice(
          id: 'dept_notice_1',
          title: '[컴퓨터공학과] 2024년 졸업작품 발표회 안내',
          content: '''컴퓨터공학과 2024년 졸업작품 발표회를 다음과 같이 개최합니다.

1. 일시: 2024년 11월 25일 (월) 09:00 ~ 18:00
2. 장소: 정보관 대강당
3. 참석대상: 4학년 전체, 지도교수, 관심있는 학생
4. 발표시간: 팀당 15분 (발표 10분 + 질의응답 5분)

많은 관심과 참여 부탁드립니다.''',
          publishDate: DateTime(2024, 10, 10),
          author: '컴퓨터공학과',
          department: '컴퓨터공학과',
          category: '학과',
          viewCount: 98,
        ),
        Notice(
          id: 'dept_notice_2',
          title: '[전자공학과] 산업체 초청 세미나 개최',
          content: '''전자공학과에서 산업체 초청 세미나를 다음과 같이 개최합니다.

1. 일시: 2024년 11월 15일 (금) 15:00 ~ 17:00
2. 장소: 공학관 201호
3. 초청기업: 삼성전자, LG전자
4. 주제: 반도체 산업 동향 및 취업 전략

전자공학과 재학생 모두 참석 가능합니다.''',
          publishDate: DateTime(2024, 10, 8),
          author: '전자공학과',
          department: '전자공학과',
          category: '학과',
          viewCount: 156,
        ),
        Notice(
          id: 'dept_notice_3',
          title: '[기계공학과] 창의설계 경진대회 참가자 모집',
          content: '''기계공학과 창의설계 경진대회 참가자를 다음과 같이 모집합니다.

1. 신청기간: 2024년 10월 20일 ~ 2024년 11월 5일
2. 참가대상: 기계공학과 1~3학년
3. 팀 구성: 3~4명
4. 주제: 자유 (기계공학 관련)
5. 시상: 대상 100만원, 최우수상 50만원

창의적인 아이디어로 많은 참여 바랍니다.''',
          publishDate: DateTime(2024, 10, 5),
          author: '기계공학과',
          department: '기계공학과',
          category: '학과',
          viewCount: 89,
        ),
      ];

      for (final notice in notices) {
        await _firestore.collection(_collection).doc(notice.id).set(notice.toFirestore());
      }

      print('영남대학교 공지사항 샘플 데이터가 추가되었습니다.');
    } catch (e) {
      print('샘플 데이터 추가 오류: $e');
      throw e;
    }
  }

  /// 검색
  Future<List<Notice>> searchNotices(String keyword) async {
    try {
      // Firestore에서는 전체 텍스트 검색이 제한적이므로 
      // 제목에서 키워드를 포함하는 공지사항을 찾습니다.
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('publishDate', descending: true)
          .get();

      final allNotices = snapshot.docs.map((doc) => Notice.fromFirestore(doc)).toList();
      
      return allNotices.where((notice) {
        return notice.title.toLowerCase().contains(keyword.toLowerCase()) ||
               notice.content.toLowerCase().contains(keyword.toLowerCase()) ||
               notice.department.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    } catch (e) {
      print('공지사항 검색 오류: $e');
      return [];
    }
  }
}
