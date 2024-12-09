import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:opendemo/Main/Login/services/reset_password.dart';
import '../../main.dart';
import '../component/button.dart';
import '../component/squaretitle.dart';
import '../component/textfield.dart';
import '../services/auth.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Error messages for fields
  String emailError = "";
  String passwordError = "";

  // 로그인 함수
  void signUserIn() async {
    setState(() {
      emailError = "";
      passwordError = "";
    });

    if (emailController.text.isEmpty) {
      setState(() {
        emailError = '이메일을 입력해주세요.';
      });
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = '비밀번호를 입력해주세요.';
      });
    }

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return;
    }

    // 로딩 화면
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // 로그인 성공 후 로딩 다이얼로그 닫기
      Navigator.pop(context);

      // 로그인 성공 후 메인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // 로그인 실패 시 로딩 다이얼로그 닫기

      setState(() {
        if (e.code == 'invalid-email') {
          emailError = '유효하지 않은 이메일 형식입니다.';
        } else if (e.code == 'user-not-found') {
          emailError = '등록되지 않은 이메일입니다.';
        } else if (e.code == 'wrong-password') {
          passwordError = '비밀번호가 잘못되었습니다.';
        } else if (e.code == 'user-disabled') {
          emailError = '사용이 중지된 계정입니다.';
        } else if (e.code == 'network-request-failed') {
          emailError = '네트워크 연결에 문제가 발생했습니다.';
        } else if (e.code == 'too-many-requests') {
          emailError = '요청이 너무 많습니다. 잠시 후 다시 시도하세요.';
        } else {
          emailError = '알 수 없는 오류가 발생했습니다. (${e.code})';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.auto_stories,
                  size: 100,
                ),

                const SizedBox(height: 50),

                Text(
                  '환영합니다.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // 이메일 입력칸
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                if (emailError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        emailError,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // 비밀번호 입력칸
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                if (passwordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        passwordError,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ResetPasswordDialog.showResetPasswordDialog(context);
                        },
                        // child: Text(
                        //   '비밀번호를 잊어버렸나요?',
                        //   style: TextStyle(
                        //     color: Colors.grey[600],
                        //     decoration: TextDecoration.underline,
                        //   ),
                        // ),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 0.5)
                            ),
                          ),
                          child: Text(
                            '비밀번호를 잊어버렸나요?',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          )
                        )
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 로그인 버튼
                MyButton(
                  text: "로그인",
                  onTap: signUserIn,
                ),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTitle(
                      onTap: () async {
                        final userCredential =
                        await AuthService().signInWithGoogle();
                        if (userCredential != null) {
                          print('로그인 성공: ${userCredential.user!.email}');
                        } else {
                          print('로그인 실패');
                        }
                      },
                      imagePath: 'assets/images/google.png',
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                Row(
                  children: [
                    Text(
                      '  회원가입한 적이 없나요?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        '지금 회원가입 하세요',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}