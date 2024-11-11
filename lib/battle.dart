import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Literacy Quiz Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BattlePage(),
    );
  }
}

/*대전 페이지*/
class BattlePage extends StatefulWidget {
  const BattlePage({Key? key}) : super(key: key);

  @override
  _BattlePageState createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  int score = 0;

  void incrementScore() {
    setState(() {
      score += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("대전 페이지"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pinkAccent,
                image: const DecorationImage(
                  image: AssetImage('assets/profile.jpg'), // Add profile picture asset here
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              "$score 점",
              style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /* PVP 버튼 */
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(175, 175),
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PVPPage()),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.people, size: 50),
                      Text("PVP", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                const SizedBox(width: 20.0),
                /* PVE 버튼 */
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(175, 175),
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () {
                    incrementScore();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PVEPage()),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.computer, size: 50),
                      Text("PVE", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* PVP 페이지 */
class PVPPage extends StatelessWidget {
  const PVPPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PVP 창"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(50),
          color: Colors.orange[600],
          width: 300,
          height: 300,
          child: const Text(
            'PVP 매치 대기 중...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/* PVE 페이지 */
class PVEPage extends StatelessWidget {
  const PVEPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PVE 창"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(50),
          color: Colors.orange[600],
          width: 300,
          height: 300,
          child: const Text(
            'AI와 대결 시작!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
