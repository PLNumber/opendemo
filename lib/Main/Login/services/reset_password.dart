import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordDialog {
  // 비밀번호 재설정 다이얼로그를 보여주는 함수
  static void showResetPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    // 오류 메시지 다이얼로그
    void showErrorMessage(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("오류"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
    }

    // 성공 메시지 다이얼로그
    void showSuccessMessage(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("성공"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 성공 다이얼로그 닫기
                  Navigator.pop(context); // 모달 다이얼로그 닫기
                },
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
    }

    void resetPassword() async {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        showErrorMessage(context, "이메일을 입력하세요.");
        return;
      }

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        showSuccessMessage(context, "비밀번호 재설정 이메일이 전송되었습니다.");
      } on FirebaseAuthException catch (e) {
        showErrorMessage(context, e.message ?? "오류가 발생했습니다.");
      }
    }

    // 모달 다이얼로그 UI
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "비밀번호 재설정",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("비밀번호를 재설정할 이메일을 입력하세요."),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "이메일",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                        child: const Text("취소"),
                      ),
                      const SizedBox(width: 8), // Space between buttons
                      ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("확인",selectionColor: Colors.white,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
