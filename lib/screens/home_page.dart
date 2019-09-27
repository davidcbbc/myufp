import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myufp/models/licenciaturas.dart';
import 'package:myufp/models/user.dart';
import 'package:myufp/screens/assiduity.dart';
import 'package:myufp/screens/grades.dart';
import 'package:myufp/screens/login_page.dart';
import 'package:myufp/screens/menu.dart';
import 'package:myufp/screens/schedule.dart';
import 'package:myufp/screens/secretary.dart';
import 'package:myufp/screens/teste.dart';
import 'package:myufp/screens/thecalendar.dart';
import 'package:myufp/services/myfiles.dart';

import './atm.dart';

class HomePage extends StatefulWidget {
  
  User _logged;     //user with valid token
  HomePage(this._logged);

  @override
  _HomePageState createState() => new _HomePageState(_logged);
}

class _HomePageState extends State<HomePage> {
  User _logged;
  bool liked = false;
  int likes = 143;
  _HomePageState(this._logged);

  @override
  Widget build(BuildContext context) {
    bool licenca = true;
   Licenciaturas lp = new Licenciaturas();
   if(_logged.licenciatura == "hey") licenca = false;
   String imagem_licenciatura = lp.lic[_logged.licenciatura];

 return new WillPopScope(    //WillPopScore evita andar para tras em androids e nao volta a pagina de login
      onWillPop: () async => false,
      child: new Scaffold(
      appBar: new AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              //padding: const EdgeInsets.only(left: 20),
              child: Image.asset('assets/logotipinho.png',scale: 15,fit: BoxFit.contain, height: 32)
            ),
            Container(
              padding: const EdgeInsets.only(left: 8,right: 4), 
              child: Text("|", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),)
            ),Container(
              //padding: const EdgeInsets.all(1.0), 
              child: Text("MYUFP", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey),)
            ),
            Container(
              //padding: const EdgeInsets.all(1.0), 
              child: Text("v1.0.3", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey,fontSize: 12),)
            ),
          ],
        ),
       
        backgroundColor: Colors.white,),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text("${_logged.licenciatura}"),
              accountEmail: new Text(_logged.username,style: TextStyle(fontWeight: FontWeight.bold) ,),
              currentAccountPicture: new GestureDetector(
                child: new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: licenca? Image.asset(imagem_licenciatura): null,
                ),
                onTap: () => print("This is your current account."),
              ),
              decoration: new BoxDecoration(
                color: Colors.transparent,
                // image: DecorationImage(
                //   //image: AssetImage('assets/tumb.png'),
                //      fit: BoxFit.cover)
              ),
            ),
            new ListTile(
              title: new Text("ATM Payment"),
              leading: new Icon(Icons.account_balance_wallet),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Atm(_logged.token)));
              }
            ),
            new ListTile(
              title: new Text("Assiduity"),
              leading: new Icon(Icons.assessment),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Assiduity(_logged.token)));
              }
            ),
            new ListTile(
              title: new Text("Grades"),
              leading: new Icon(Icons.assignment),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Grades(_logged.token)));
              }
            ),
            new ListTile(
              title: new Text("Calendar"),
              leading: new Icon(Icons.calendar_today),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new TheCalendar(_logged.token,number: _logged.username,)));
              }
            ),
            new ListTile(
              title: new Text("Secretary Queue"),
              leading: new Icon(Icons.group),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Secretary()));
              }
            ),
            new ListTile(
              title: new Text("Bar Menu"),
              leading: new Icon(Icons.menu),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Menu.init()));
              }
            ),           
            new Divider(),
            new ListTile(
              title: new Text("Logout"),
              leading: new Icon(Icons.cancel),
              onTap: () {
                print("VOU SAIR");
                writeLoggedTxt(false);
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()));
              },
            ),
          ],
        ),
      ),
       body: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Card(

                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: ListTile(
                              onTap: () {
                                debugPrint("ListTile tapped!");
                              },
                              title: Container(
                                child: Stack(
                                  alignment: AlignmentDirectional(0, 1),
                                  children: <Widget>[
                                    Hero(
                                      tag: "ESTA E A TAG",
                                      child:  ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(10),bottom: Radius.circular(10)),
                                        child: Image.asset(
                                                'assets/ufp_imagem.jpg',
                                                colorBlendMode: BlendMode.darken,                                            
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        "News are coming soon ! The app MYUFP will have news in the home page",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    tooltip: "Like this post",
                                    padding: EdgeInsets.only(right: 1),
                                    icon: Icon(Icons.thumb_up),
                                    onPressed: () {
                                      
                                      setState(() {
                                        if(liked) {
                                          print("Menos um like");
                                          liked = false;
                                          likes--;
                                        } else {
                                          print("Mais um like");
                                          liked = true;
                                          likes++;
                                        }
                                      });
                                    },
                                    color: liked? Colors.green[500] : Colors.grey[400],
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 120),
                                    child: Text("$likes", style: TextStyle(color: Colors.green[800]),),
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: FlatButton(
                                      splashColor: Colors.grey,
                                      onPressed: () {
                                        print("dei presse");
                                      },
                                      child: null,
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(),
                      ],
                    )
       
       
       
       
       //new Center(
      //   child: new Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       new Text("${_logged.username}", style: new TextStyle(fontSize: 35.0)),
      //     ],
      //   )
      // )
      ),
    );
    
  }
}