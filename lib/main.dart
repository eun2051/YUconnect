import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/register_profile_intro_screen.dart';
import 'screens/auth/register_step2_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/password_reset_email_screen.dart';
import 'screens/auth/password_reset_new_password_screen.dart';
import 'screens/auth/password_reset_success_screen.dart';
import 'screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YUconnect',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      locale: const Locale('ko', 'KR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const MainScreen(),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register1': (context) => const SignupScreen(),
        '/register-profile-intro': (context) =>
            const RegisterProfileIntroScreen(),
        '/register2': (context) => const RegisterStep2Screen(),
        '/reset-password': (context) => const PasswordResetEmailScreen(),
        '/reset-password-new': (context) =>
            const PasswordResetNewPasswordScreen(email: ''),
        '/reset-password-success': (context) =>
            const PasswordResetSuccessScreen(),
        '/main': (context) => const MainScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
