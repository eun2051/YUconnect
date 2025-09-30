import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class UserRepository {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  /// Firestore에 유저 데이터 저장
  Future<void> addUser(app_user.User user) async {
    try {
      await users.doc(user.uid).set(user.toMap());
      print('유저 정보 저장 성공: ${user.uid}');
    } catch (e) {
      print('유저 정보 저장 실패: $e');
      rethrow;
    }
  }

  /// Firestore에서 유저 데이터 조회
  Future<app_user.User?> getUserByUid(String uid) async {
    final doc = await users.doc(uid).get();
    if (doc.exists) {
      return app_user.User.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Firestore에서 이메일로 유저 데이터 조회
  Future<app_user.User?> getUserByEmail(String email) async {
    final query = await users.where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      return app_user.User.fromMap(
        query.docs.first.data() as Map<String, dynamic>,
      );
    }
    return null;
  }
}
