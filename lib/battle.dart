import 'package:flutter/material.dart';


/*대전 페이지*/
class BattlePage extends StatelessWidget {
  const BattlePage({Key? key}) : super(key: key);

  final score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("대전 페이지"),
        centerTitle: true,
      ),

      body: Center(
          child : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              Container(
                width: 400.0,
                height: 400.0,
                color: Colors.pinkAccent,
                child: Text('프로필 사진'),
              ),
              SizedBox(height: 30.0),

              Text("$score 점",
                style: TextStyle(fontSize: 30.0),),
              SizedBox(height: 30.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  /*pvp 버튼*/
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(175,175),
                      backgroundColor: Colors.greenAccent,
                      padding: EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      )
                    ),

                    onPressed: (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => PVPPage())
                      );
                    },

                    child: Text("PVP")),
                  SizedBox(width: 30.0),

                  /*pve버튼*/
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(175,175),
                        backgroundColor: Colors.greenAccent,
                        padding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                        )
                    ),
                    onPressed: (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => PVEPage())
                      );
                    },
                    child: Text("PVE")
                  ),
                ],
              )
            ],
          )
      ),
    );
  }
}

/*pvp 페이지*/
class PVPPage extends StatelessWidget {
  const PVPPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("pvp 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('어쩌구'),
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
            color: Colors.orange[600],
            width: 400,
            height: 400,
          ),
        )
    );

  }
}

/*pve 페이지*/
class PVEPage extends StatelessWidget {
  const PVEPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("pve 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('어쩌구'),
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
            color: Colors.orange[600],
            width: 400,
            height: 400,
          ),
        )
    );
  }
}

