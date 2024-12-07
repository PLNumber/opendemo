import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../Main/Login/pages/auth_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset(
          'assets/animation/Animation - 1732971002218.json',
          fit: BoxFit.contain
      ),
      splashIconSize: MediaQuery.of(context).size.width * 0.3,//애니매이션 크기 동적 지정
      nextScreen: const AuthPage(),
      duration: 3000,//3초간 실행
      backgroundColor: Colors.white,//배경색
    );
  }
}
