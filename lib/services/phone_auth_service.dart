import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  int? _resendToken;

  // 1. 휴대폰 번호로 인증 코드 전송 요청 (최초 요청)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId, resendToken);
        logger.i('인증 코드 전송 완료: $verificationId');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        onCodeAutoRetrievalTimeout(verificationId);
        logger.i('인증 타임아웃: $verificationId');
      },
    );
  }

  // 2. 인증 코드 재전송 요청
  Future<void> resendVerificationCode({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
  }) async {
    if (_resendToken == null) {
      throw Exception('재전송 토큰이 유효하지 않습니다.');
    }
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId, resendToken);
        logger.i('인증 코드 재전송 완료: $verificationId');
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: _resendToken,
    );
  }

  // 3. 사용자가 입력한 코드로 인증 및 로그인
  Future<UserCredential> signInWithSmsCode({required String smsCode}) async {
    if (_verificationId.isEmpty) {
      throw Exception('인증 코드를 먼저 요청해주세요.');
    }
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // 4. 기존 사용자의 계정에 휴대폰 번호 연결
  Future<void> linkPhoneNumberToUser({required String smsCode}) async {
    if (_verificationId.isEmpty) {
      throw Exception('인증 코드를 먼저 요청해주세요.');
    }
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('사용자가 로그인되어 있지 않습니다.');
    }
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
    await user.linkWithCredential(credential);
    logger.i('계정에 휴대폰 번호 연결 성공');
  }
}
