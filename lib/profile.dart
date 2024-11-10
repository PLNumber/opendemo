import 'package:flutter/material.dart';

/*프로필 페이지*/
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  final int win = 0;
  final int lose = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("프로필 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*프로필 사진*/
              GestureDetector(
                onTap: (){

                },

                onLongPress: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ShopPage())
                  );
                },

                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 20,),

              /*이름 변경*/
              Row(
                children: <Widget>[
                  Text('이름 변경'),
                  SizedBox(width: 20,),

                  SizedBox(
                    width: 250,
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '이름 변경',
                      ),
                    ),
                  )

                ],
              ),
              SizedBox(height: 20,),

            /*전적*/
              Row(
                children: <Widget>[
                  Text('전적'),
                  SizedBox(width: 20,),

                  Text('승리 : '),
                  SizedBox(width: 20,),

                  Text('패배 : '),
                  SizedBox(width: 20,),

                ],
              ),
              SizedBox(height: 20,),

            ],
          ),
        )
    );
  }
}


/*상점 페이지*/
class ShopPage extends StatelessWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("프로필 창"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*상점*/
            Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(30.0),
                  children: <Widget>[
                    Container(
                      height: 100,
                      color: Colors.red,
                    ),
                    Container(
                      height: 100,
                      color: Colors.orange,
                    ),
                    Container(
                      height: 100,
                      color: Colors.yellow,
                    ),
                    Container(
                      height: 100,
                      color: Colors.green,
                    ),
                    Container(
                      height: 100,
                      color: Colors.blue,
                    ),
                    Container(
                      height: 100,
                      color: Colors.indigo,
                    ),
                    Container(
                      height: 100,
                      color: Colors.purple,
                    ),

                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}

