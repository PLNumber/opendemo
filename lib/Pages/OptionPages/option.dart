import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Function/Ads/ads_provider.dart';
import '../../Function/Option/option_func.dart';
import '../../Main/Login/pages/home_page.dart';
import '../../Main/Login/pages/auth_page.dart';
import '../../Function/Ads/ads.dart'; // AdManager를 임포트합니다.

class OptionPage extends StatefulWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  _OptionPageState createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  bool soundMuted = false;
  bool lighted = false;

  @override
  Widget build(BuildContext context) {
    final adVisibilityProvider = Provider.of<AdVisibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
            children: <Widget>[
              // 소리 on/off 버튼
              _buildOptionItem(
                icon: soundMuted ? Icons.volume_off : Icons.volume_up,
                label: soundMuted ? "소리 끄기" : "소리 켜기",
                onPressed: () {
                  setState(() {
                    soundMuted = !soundMuted;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(soundMuted ? "소리가 꺼졌습니다." : "소리가 켜졌습니다."),
                      duration: const Duration(milliseconds: 100),
                    ),
                  );
                },
              ),

              // 다크 모드 on/off 버튼
              _buildOptionItem(
                icon: lighted ? Icons.wb_sunny : Icons.dark_mode,
                label: lighted ? "라이트 모드" : "다크 모드",
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                  setState(() {
                    lighted = !lighted;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          lighted ? "라이트 모드가 활성화되었습니다." : "다크 모드가 활성화되었습니다."),
                      duration: const Duration(milliseconds: 100),
                    ),
                  );
                },
              ),

              // 광고 차단 버튼
              _buildOptionItem(
                icon: adVisibilityProvider.isAdVisible
                    ? Icons.not_interested
                    : Icons.check_circle,
                label: adVisibilityProvider.isAdVisible ? "광고 차단" : "광고 표시",
                onPressed: () async {
                  await adVisibilityProvider
                      .setAdVisibility(!adVisibilityProvider.isAdVisible);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(adVisibilityProvider.isAdVisible
                          ? "광고가 표시됩니다."
                          : "광고가 차단되었습니다."),
                      duration: const Duration(milliseconds: 100),
                    ),
                  );
                  // 옵션 페이지를 닫지 않고 광고 표시 여부가 변경된 상태를 적용합니다.
                  setState(() {}); // 상태를 업데이트하여 UI를 재구성
                },
              ),

              // 제작자 정보 버튼
              _buildOptionItem(
                icon: Icons.hail,
                label: "제작자 정보",
                onPressed: () {
                  showCreatorInfoDialog(context);
                },
              ),

              // 업데이트 히스토리 버튼 추가
              _buildOptionItem(
                icon: Icons.update,
                label: "업데이트 히스토리",
                onPressed: () async {
                  await launchURL(
                      'https://www.notion.so/12ab86c285be806d9db9c133beecc318');
                },
              ),

              // 로그아웃 버튼
              _buildOptionItem(
                icon: Icons.output,
                label: "로그아웃",
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // 옵션 아이템을 생성하는 함수
  Widget _buildOptionItem(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(icon, size: 80.0),
          onPressed: onPressed,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
