import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../Main/Login/pages/auth_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Center(
          child: Lottie.asset(
              'assets/animation/Animation - 1732971002218.json',
            width: 500,
            height: 500,
          )
        ),
        nextScreen: const AuthPage(),
      duration: 5000,//5초간 실행 시간 더 늘려도 됨
      backgroundColor: Colors.white,
    );
  }
}
