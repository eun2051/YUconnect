import 'package:flutter/material.dart';

class RegisterStep1Screen extends StatelessWidget {
  const RegisterStep1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입 1단계')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: 이메일(@yu.ac.kr), 비밀번호, 비밀번호 확인 입력, 다음 버튼
            Text('회원가입 1단계'),
          ],
        ),
      ),
    );
  }
}
