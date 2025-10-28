import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_profile_service.dart';

/// 데이터 마이그레이션 도우미 클래스
class DataMigrationHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserProfileService _userProfileService = UserProfileService();

  /// 이메일 형태의 userName을 실제 이름으로 변경
  Future<void> fixUserNamesInInquiries() async {
    try {
      print('Starting data migration to fix user names...');

      // 모든 민원 조회
      final snapshot = await _firestore.collection('inquiries').get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userName = data['userName'] as String?;
        final userId = data['userId'] as String?;

        if (userName != null && userId != null) {
          // 이메일 형태인지 확인 (@가 포함되어 있으면 이메일)
          if (userName.contains('@')) {
            print(
              'Found inquiry with email as userName: $userName for userId: $userId',
            );

            // 실제 사용자 이름 조회
            final actualUserName = await _userProfileService.getUserName(
              userId,
            );

            // Firestore 업데이트
            await doc.reference.update({
              'userName': actualUserName,
              'updatedAt': Timestamp.now(),
            });

            print('Updated inquiry ${doc.id}: $userName -> $actualUserName');
          }
        }
      }

      print('Data migration completed successfully!');
    } catch (e) {
      print('Error during data migration: $e');
    }
  }

  /// 모든 사용자의 프로필이 user_profiles에 있는지 확인하고 없으면 생성
  Future<void> ensureAllUserProfiles() async {
    try {
      print('Ensuring all user profiles exist...');

      // users 컬렉션에서 모든 사용자 조회
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final name = userData['name'] as String?;
        final userId = userDoc.id;

        if (name != null) {
          // user_profiles에 프로필이 있는지 확인
          final profileDoc = await _firestore
              .collection('user_profiles')
              .doc(userId)
              .get();

          if (!profileDoc.exists) {
            print(
              'Creating missing profile for user: $userId with name: $name',
            );

            // 임시로 Firebase Auth 사용자 생성하여 saveUserProfile 호출
            // 실제로는 각 사용자가 로그인할 때 자동으로 생성됩니다
            await _firestore.collection('user_profiles').doc(userId).set({
              'email': userData['email'] ?? '',
              'name': name,
              'createdAt': Timestamp.now(),
            });
          }
        }
      }

      print('User profiles check completed!');
    } catch (e) {
      print('Error ensuring user profiles: $e');
    }
  }
}
