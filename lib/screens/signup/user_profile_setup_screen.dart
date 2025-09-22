import 'package:flutter/material.dart';

class UserProfileSetupScreen extends StatelessWidget {
  const UserProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: const Center(child: Text('프로필 설정 페이지 내용이 들어갈 곳입니다.')),
    );
  }
}
