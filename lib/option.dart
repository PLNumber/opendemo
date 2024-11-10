import 'package:flutter/material.dart';

/*옵션 페이지*/
class OptionPage extends StatefulWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  _OptionPageState createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  bool soundMuted = false;  // Initial sound state (false means sound is on)
  bool darked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("옵션 창"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,  // 2 columns in the grid
            crossAxisSpacing: 30.0,  // Space between columns
            mainAxisSpacing: 30.0,  // Space between rows
            children: <Widget>[
              /*소리 on/off */
              IconButton(
                icon: Icon(
                  soundMuted ? Icons.volume_off : Icons.volume_up,
                  size: 100.0,
                ),
                onPressed: () {
                  setState(() {
                    soundMuted = !soundMuted;  // Toggle soundMuted state
                  });
                },
              ),

              /*다크 모드 on/off */
              IconButton(
                icon: Icon(
                  darked ? Icons.wb_sunny : Icons.dark_mode,
                  size: 100.0,
                ),
                onPressed: (){
                  setState(() {
                    darked = !darked;
                  });
                },
              ),

              /*광고 차단 */
              IconButton(
                icon: const Icon(Icons.not_interested),
                iconSize: 100.0,
                onPressed: () {},
              ),

              /*제작자들 */
              IconButton(
                icon: const Icon(Icons.hail),
                iconSize: 100.0,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
