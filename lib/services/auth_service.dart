import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final logger = Logger();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPhoneNumberVerified = false;

  // 휴대폰 번호 인증
  void setPhoneNumberVerified(bool isVerified) {
    _isPhoneNumberVerified = isVerified;
    logger.i('휴대폰 인증 상태 변경: $_isPhoneNumberVerified');
  }

  Future<void> sendVerificationEmail(String email) async {
    if (!email.endsWith('@yu.ac.kr')) {
      throw Exception('학교 이메일(@yu.ac.kr)만 사용 가능합니다.');
    }

    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://your-app-domain.page.link',
          handleCodeInApp: true,
          iOSBundleId: 'com.example.yourApp',
          androidPackageName: 'com.example.yourApp',
        ),
      );
      logger.i('이메일 인증 링크 전송 성공');
    } catch (e) {
      logger.e('인증 이메일 전송 실패: $e');
      rethrow;
    }
  }

  // 비밀번호 조건 설정 및 회원가입
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    if (!_isPhoneNumberVerified) {
      throw Exception('휴대폰 번호 인증을 먼저 완료해주세요.');
    }

    if (password.length < 8 ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[!@#\$%^&*]').hasMatch(password)) {
      throw Exception('비밀번호는 8자 이상, 숫자와 특수문자를 포함해야 합니다.');
    }

    try {
      // Firebase에 계정 생성
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Firestore에 사용자 추가 정보 저장
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': email,
            'name': name,
            'phoneNumber': phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
          });

      logger.i('회원가입 및 사용자 정보 저장 성공: ${userCredential.user!.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      logger.e('회원가입 실패: ${e.message}');
      rethrow;
    }
  }

  // 3. 이메일/비밀번호로 로그인
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('이메일과 비밀번호를 모두 입력해주세요.');
    }
    UserCredential userCredential;

    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await signOut();
        throw Exception('데이터베이스에 사용자 정보가 없습니다. 회원가입을 완료해주세요.');
      }
      logger.i('로그인 성공: ${userCredential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('등록되지 않은 이메일입니다.');
      } else if (e.code == 'wrong-password') {
        throw Exception('잘못된 비밀번호입니다.');
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. 비밀번호 변경 (재설정 이메일 전송)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      logger.i('비밀번호 재설정 이메일 전송 성공');
    } catch (e) {
      logger.e('비밀번호 재설정 이메일 전송 실패: $e');
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
