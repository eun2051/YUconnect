import 'package:flutter/material.dart';
import 'package:yuconnect/screens/main/notification_screen.dart';
import 'package:yuconnect/components/password_reset_bottom_sheets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showPasswordResetBottomSheet(BuildContext context) {
    // 1. context 진단용 테스트 팝업
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팝업 테스트'),
        content: const Text('이 창이 보이면 context는 정상입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    // 2. 바텀시트 호출을 Future.microtask로 감싸서 타이밍 보장
    Future.microtask(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (context) => const PasswordResetEmailBottomSheet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF2563EB),
            ),
            title: const Text('알림'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Color(0xFF2563EB)),
            title: const Text('비밀번호 변경'),
            onTap: () => _showPasswordResetBottomSheet(context),
          ),
          // ...other profile items...
        ],
      ),
    );
  }
}
