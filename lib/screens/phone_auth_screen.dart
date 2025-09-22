import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yu_connect/screens/signup/user_profile_setup_screen.dart';
import 'package:yu_connect/services/phone_auth_service.dart';
import 'package:yu_connect/screens/main/home_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();

  bool _isCodeSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  // 인증 코드 전송 (최초)
  void _sendVerificationCode() async {
    await _phoneAuthService.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      onVerificationCompleted: (PhoneAuthCredential credential) async {
        if (!mounted) return;
        try {
          await _phoneAuthService.signInWithSmsCode(
            smsCode: credential.smsCode!,
          );
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('자동 인증 실패: ${e.toString()}')));
        }
      },
      onVerificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('인증 실패: ${e.message}')));
      },
      onCodeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() {
          _isCodeSent = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('인증 코드가 전송되었습니다.')));
      },
      onCodeAutoRetrievalTimeout: (String verificationId) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('자동 입력 시간이 초과되었습니다.')));
      },
    );
  }

  // 인증 코드 재전송
  void _resendVerificationCode() async {
    await _phoneAuthService.resendVerificationCode(
      phoneNumber: _phoneController.text,
      onCodeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() {
          _isCodeSent = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('인증 코드가 재전송되었습니다.')));
      },
    );
  }

  // 코드 확인 및 로그인
  void _verifySmsCode() async {
    try {
      await _phoneAuthService.signInWithSmsCode(smsCode: _smsController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const UserProfileSetupScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('인증 코드 오류: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('휴대폰 인증')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '휴대폰 번호 (예: +821012345678)',
              ),
              keyboardType: TextInputType.phone,
            ),
            if (_isCodeSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _smsController,
                decoration: const InputDecoration(labelText: '인증 코드 (6자리)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _verifySmsCode,
                child: const Text('인증 코드 확인'),
              ),
            ] else
              ElevatedButton(
                onPressed: _sendVerificationCode,
                child: const Text('인증 코드 전송'),
              ),
            if (_isCodeSent)
              TextButton(
                onPressed: _resendVerificationCode,
                child: const Text('인증 코드 재전송'),
              ),
          ],
        ),
      ),
    );
  }
}
