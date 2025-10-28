import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 이메일/비밀번호 로그인
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint('Login failed: $e');
      return null;
    }
  }

  /// 이메일/비밀번호 회원가입
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint('Register failed: $e');
      return null;
    }
  }

  /// 이메일 인증 메일 전송
  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      debugPrint('이메일 인증 메일 발송 실패: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('비밀번호 재설정 이메일 전송 실패: $e');
      rethrow;
    }
  }

  /// 현재 로그인된 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  /// 사용자 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
