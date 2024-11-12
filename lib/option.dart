import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'option_func.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("옵션 창"),
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
                      duration: const Duration(milliseconds: 100),),

                  );
                },
              ),

              // 다크 모드 on/off 버튼
              _buildOptionItem(
                icon: lighted ? Icons.wb_sunny : Icons.dark_mode,
                label: lighted ? "라이트 모드" : "다크 모드",
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  setState(() {
                    lighted = !lighted;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(lighted ? "다크 모드가 활성화되었습니다." : "라이트 모드가 활성화되었습니다."),
                      duration: const Duration(milliseconds: 100),),
                  );
                },
              ),

              // 광고 차단 버튼
              _buildOptionItem(
                icon: Icons.not_interested,
                label: "광고 차단",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("광고 차단 기능이 활성화되었습니다."),
                      duration: const Duration(milliseconds: 100),),
                  );
                },
              ),

              // 제작자 정보 버튼
              _buildOptionItem(
                icon: Icons.hail,
                label: "제작자 정보",
                onPressed: () {
                  showCreatorInfoDialog(context);
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //       content: Text("제작자 정보 페이지입니다."),
                  //     duration: const Duration(milliseconds: 500),),
                  // );
                },
              ),

              // 고객 지원 버튼 추가
              _buildOptionItem(
                icon: Icons.support_agent,
                label: "고객 지원",
                onPressed: () /*async*/ {
                  //await launchURL("tel:+82-10-3212-1034");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("고객 지원 페이지로 이동합니다."),
                      duration: const Duration(milliseconds: 100),),
                  );
                },
              ),

              // 업데이트 히스토리 버튼 추가
              _buildOptionItem(
                icon: Icons.update,
                label: "업데이트 히스토리",
                onPressed: () async {
                  // 업데이트 히스토리 웹페이지 링크 여는 예시
                  await launchURL('https://www.notion.so/12ab86c285be806d9db9c133beecc318');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 옵션 아이템을 생성하는 함수
  Widget _buildOptionItem({required IconData icon, required String label, required VoidCallback onPressed}) {
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
