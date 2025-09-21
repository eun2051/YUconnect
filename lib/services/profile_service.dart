import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserProfile({
    required String phoneNumber,
    required String major,
    required String studentYear,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 'users' 컬렉션에서 현재 사용자의 UID에 해당하는 문서 업데이트
      await _db.collection('users').doc(user.uid).update({
        'phoneNumber': phoneNumber,
        'major': major,
        'studentYear': studentYear,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      logger.e('사용자가 로그인되어 있지 않아 프로필을 저장할 수 없습니다.');
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }
  }
}
