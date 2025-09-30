import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import '../../models/user.dart' as app_user;

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({Key? key}) : super(key: key);

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  bool _isLoading = false;
  bool _emailVerified = false;
  String? _email;
  String? _password;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _email = args?['email'];
    _password = args?['password'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> sendEmailVerification() async {
    if (_email == null || _password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 또는 비밀번호 정보가 없습니다. 처음부터 다시 시도해 주세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final authService = AuthService();
    try {
      final user = await authService.registerWithEmail(_email!, _password!);
      if (user != null) {
        await authService.sendEmailVerification(user);
        _uid = user.uid;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 메일이 발송되었습니다. 메일을 확인하세요.')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('회원가입에 실패했습니다.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이메일 인증 메일 발송 실패: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> checkEmailVerified() async {
    setState(() => _isLoading = true);
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      setState(() => _emailVerified = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일 인증이 완료되었습니다.')));
    } else {
      setState(() => _emailVerified = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아직 이메일 인증이 완료되지 않았습니다.')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate() || !_emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 정보를 입력하고 이메일 인증을 완료하세요.')),
      );
      return;
    }
    // 인증 완료 후 _uid가 null이면 currentUser에서 uid를 가져옴
    if (_uid == null) {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        _uid = user.uid;
      }
    }
    if (_uid == null || _email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보가 올바르지 않습니다. 처음부터 다시 시도해 주세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final userRepo = UserRepository();
    final user = app_user.User(
      uid: _uid!,
      name: _nameController.text.trim(),
      email: _email!,
      phone: _phoneController.text.trim(),
      department: _departmentController.text.trim(),
      grade: int.tryParse(_gradeController.text.trim()) ?? 0,
    );
    try {
      await userRepo
          .addUser(user)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('저장 시간이 너무 오래 걸립니다. 네트워크 상태를 확인해 주세요.'),
          );
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인 해주세요.')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('프로필 저장 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입 2단계')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '이름'),
                validator: (v) => v == null || v.isEmpty ? '이름을 입력하세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '전화번호'),
                validator: (v) =>
                    v == null || v.isEmpty ? '전화번호를 입력하세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: '학과'),
                validator: (v) => v == null || v.isEmpty ? '학과를 입력하세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(labelText: '학년'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? '학년을 입력하세요.' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : sendEmailVerification,
                      child: const Text('이메일 인증 메일 발송'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : checkEmailVerified,
                      child: Text(_emailVerified ? '인증 완료' : '인증 확인'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _emailVerified ? handleRegister : null,
                      child: const Text('회원가입 완료'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
