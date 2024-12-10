import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../component/button.dart';
import '../component/squaretitle.dart';
import '../component/textfield.dart';
import '../services/auth.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Error messages for each field
  String emailError = "";
  String passwordError = "";
  String confirmPasswordError = "";

  // 회원가입
  void signUserUp() async {
    setState(() {
      emailError = "";
      passwordError = "";
      confirmPasswordError = "";
    });

    // 비밀번호 확인
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        confirmPasswordError = "비밀번호가 일치하지 않습니다.";
      });
      return;
    }

    try {
      // Firebase Authentication에 계정 생성
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Firestore에 UID를 이름으로 하는 문서 생성
      await FirebaseFirestore.instance
          .collection('UserData')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text,
        'createdAt': DateTime.now(),
        'currentMSG': '',
        'profileImg': 'https://ifh.cc/g/8AckGM.jpg',
        'purchased': [true, false, false, false, false, false],
        'removeAD': false,
        'win': 0,
        'loss': 0,
        'shopPt': 0,
        'rankPt': 100,
        'name': 'Player'
      });

      // 회원가입 완료 후 메시지를 표시하거나 이동
      setState(() {
        emailError = "회원가입이 성공적으로 완료되었습니다!";
      });
    } on FirebaseAuthException catch (e) {
      // 회원가입 실패 시 에러 처리
      setState(() {
        if (e.code == 'email-already-in-use') {
          emailError = "이미 사용 중인 이메일입니다.";
        } else if (e.code == 'invalid-email') {
          emailError = "유효하지 않은 이메일 형식입니다.";
        } else if (e.code == 'weak-password') {
          passwordError = "비밀번호가 너무 약합니다. 최소 6자 이상이어야 합니다.";
        } else if (e.code == 'operation-not-allowed') {
          emailError = "현재 이메일/비밀번호 회원가입이 비활성화되어 있습니다.";
        } else if (e.code == 'network-request-failed') {
          emailError = "네트워크 연결에 문제가 발생했습니다.";
        } else if (e.code == 'unknown') {
          passwordError = "비밀번호에는 대소문자, 특수문자, 숫자가 반드시 포함되어야 합니다.";
        } else {
          emailError = "알 수 없는 오류가 발생했습니다. (${e.code})";
        }
      });
    } catch (e) {
      setState(() {
        emailError = "알 수 없는 오류가 발생했습니다.";
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
                const SizedBox(height: 25),
                const Icon(Icons.auto_stories, size: 100),
                const SizedBox(height: 25),
                Text(
                  '회원가입을 진행하세요.',
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

                // 비밀번호 확인칸
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                if (confirmPasswordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        confirmPasswordError,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                // 회원가입 버튼
                MyButton(
                  text: '회원 가입',
                  onTap: signUserUp,
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
                        onTap: () => AuthService().signInWithGoogle(),
                        imagePath: 'assets/images/google.png'),
                  ],
                ),

                const SizedBox(height: 50),

                Row(
                  children: [
                    Text(
                      '계정이 이미 있나요?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        '지금 로그인 하세요',
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
