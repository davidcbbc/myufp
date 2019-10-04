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
import 'package:firebase_admob/firebase_admob.dart';

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
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAdMob.instance.initialize(appId: "ca-app-pub-7599976903549248~3408543611");
    myBanner
    ..load()
    ..show(
      anchorOffset: 60.0,
      horizontalCenterOffset: 10.0,
      anchorType: AnchorType.bottom,
    );
  }

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
      body: ListView(
        children: <Widget>[
          Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListTile(
            onTap: () {
             
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
           
            title: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: Column(
                children: <Widget>[
                  Text("Gym Bar Party"),
                  Image.asset('assets/sky_news.jpg'),
                  Row(
                    children: <Widget>[
                      Icon(Icons.thumb_up, color: Colors.grey,),
                      Text("123")
                    ],
                  )
                
                ],

              )
            ),
            
          ),
        ),
      ),
      Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListTile(
            onTap: () {
             
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
           
            title: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: Column(
                children: <Widget>[
                  Text("VR Festa Caloiro"),
                  Image.asset('assets/tumb.png'),
                  Row(
                    children: <Widget>[
                      Icon(Icons.thumb_up, color: Colors.grey,),
                      Text("123")
                    ],
                  )
                
                ],

              )
            ),
            
          ),
        ),
      ),
      Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListTile(
            onTap: () {
             
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
           
            title: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: Column(
                children: <Widget>[
                  Text("Praxe"),
                  Image.asset('assets/tumb.png' ,),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.thumb_up, color: Colors.grey,),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text("123"),
                          )
                        ],
                      ),
                      Text("See more")
                    ],
                  )
                
                ],

              )
            ),
            
          ),
        ),
      ),
      
        ],
      ),
      ),
    );
    
  }

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutterio', 'beautiful apps'],
    contentUrl: 'https://flutter.io',
    birthday: DateTime.now(),
    childDirected: false,
    designedForFamilies: false,
    gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
    testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd myBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: 'ca-app-pub-7599976903549248/7233960754',
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

}