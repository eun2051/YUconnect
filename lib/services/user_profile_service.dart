import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 사용자 프로필 정보 모델
class UserProfile {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });

  /// Firestore에서 생성
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestore에 저장할 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// 복사본 생성
  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 사용자 프로필 관리 서비스
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'user_profiles';

  /// 사용자 프로필 저장 또는 업데이트
  Future<void> saveUserProfile(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('사용자가 로그인되어 있지 않습니다.');

    // 이메일 형태의 이름은 저장하지 않음
    if (name.contains('@')) {
      throw Exception('유효하지 않은 사용자 이름입니다.');
    }

    final profile = UserProfile(
      id: user.uid,
      email: user.email ?? '',
      name: name,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(_collection)
        .doc(user.uid)
        .set(profile.toFirestore(), SetOptions(merge: true));
  }

  /// 사용자 프로필 조회
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('사용자 프로필 조회 오류: $e');
      return null;
    }
  }

  /// 현재 사용자 프로필 조회
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUserProfile(user.uid);
  }

  /// 사용자 이름 조회 (캐시된 방식)
  Future<String> getUserName(String userId) async {
    try {
      // 먼저 user_profiles에서 찾기
      final profile = await getUserProfile(userId);
      if (profile?.name != null &&
          profile!.name.isNotEmpty &&
          !profile.name.contains('@')) {
        return profile.name;
      }

      // user_profiles에 없으면 기존 users 컬렉션에서 찾기 (기존 사용자용)
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final name = userData['name'] as String?;

          if (name != null && name.isNotEmpty && !name.contains('@')) {
            // user_profiles에도 저장
            await saveUserProfile(name);
            return name;
          }
        }
      } catch (e) {
        print('기존 사용자 정보 조회 오류: $e');
      }

      // 둘 다 없거나 이메일 형태면 기본 이름 생성 및 저장
      final defaultName = '사용자${userId.substring(0, 6)}';
      await saveUserProfile(defaultName);
      return defaultName;
    } catch (e) {
      print('사용자 이름 조회 오류: $e');
      return '사용자${userId.substring(0, 6)}';
    }
  }
}
