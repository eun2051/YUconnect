import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/inquiry.dart';
import '../services/user_profile_service.dart';

/// 민원 데이터 관리 Repository
class InquiryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileService _userProfileService = UserProfileService();
  final String _collection = 'inquiries';

  /// 모든 민원 조회 (관리자용)
  Stream<List<Inquiry>> getAllInquiries() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
          final inquiries = snapshot.docs
              .map((doc) => Inquiry.fromFirestore(doc))
              .toList();
          // 클라이언트 측에서 정렬
          inquiries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return inquiries;
        });
  }

  /// 현재 사용자의 민원 조회 (사용자 모드용)
  Stream<List<Inquiry>> getCurrentUserInquiries() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final inquiries = snapshot.docs
              .map((doc) => Inquiry.fromFirestore(doc))
              .toList();
          // 클라이언트 측에서 정렬
          inquiries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return inquiries;
        });
  }

  /// 특정 사용자의 민원 조회
  Stream<List<Inquiry>> getInquiriesByUserId(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Inquiry.fromFirestore(doc))
            .toList());
  }

  /// 사용자 이름 조회
  Future<String> getUserName(String userId) async {
    return await _userProfileService.getUserName(userId);
  }

  /// 민원 등록
  Future<void> addInquiry(Inquiry inquiry) async {
    await _firestore.collection(_collection).add(inquiry.toFirestore());
  }

  /// 민원 상태 업데이트
  Future<void> updateInquiryStatus(String inquiryId, InquiryStatus status) async {
    await _firestore
        .collection(_collection)
        .doc(inquiryId)
        .update({'status': status.value});
  }

  /// 민원에 답변 추가
  Future<void> addResponse(String inquiryId, String response) async {
    await _firestore
        .collection(_collection)
        .doc(inquiryId)
        .update({
      'adminResponse': response,
      'status': InquiryStatus.completed.value,
      'responseAt': Timestamp.now(),
    });
  }

  /// 특정 민원 조회
  Future<Inquiry?> getInquiryById(String inquiryId) async {
    final doc = await _firestore.collection(_collection).doc(inquiryId).get();
    if (doc.exists) {
      return Inquiry.fromFirestore(doc);
    }
    return null;
  }

  /// 민원 삭제
  Future<void> deleteInquiry(String inquiryId) async {
    await _firestore.collection(_collection).doc(inquiryId).delete();
  }

  /// 상태별 민원 조회 (관리자용)
  Stream<List<Inquiry>> getInquiriesByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Inquiry.fromFirestore(doc))
            .toList());
  }

  /// 특정 사용자의 상태별 민원 조회
  Stream<List<Inquiry>> getInquiriesByUserAndStatus(String userId, String status) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          final inquiries = snapshot.docs
              .map((doc) => Inquiry.fromFirestore(doc))
              .toList();
          inquiries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return inquiries;
        });
  }

  /// 민원 답변 업데이트
  Future<void> updateInquiryResponse(String inquiryId, String response) async {
    await _firestore
        .collection(_collection)
        .doc(inquiryId)
        .update({
      'adminResponse': response,
      'responseAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// 이메일 형태의 userName을 실제 이름으로 수정 (일회성 실행)
  Future<void> fixEmailUserNames() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userName = data['userName'] as String?;
        final userId = data['userId'] as String?;
        
        if (userName != null && userId != null && userName.contains('@')) {
          // 실제 사용자 이름 조회
          final actualUserName = await getUserName(userId);
          
          // 민원 문서 업데이트
          await doc.reference.update({
            'userName': actualUserName,
            'updatedAt': Timestamp.now(),
          });
          
          print('Updated inquiry ${doc.id}: $userName -> $actualUserName');
        }
      }
    } catch (e) {
      print('Error fixing email usernames: $e');
    }
  }
}
