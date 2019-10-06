import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myufp/models/evento.dart';
import 'package:myufp/models/licenciaturas.dart';
import 'package:myufp/models/user.dart';
import 'package:myufp/screens/assiduity.dart';
import 'package:myufp/screens/grades.dart';
import 'package:myufp/screens/login_page.dart';
import 'package:myufp/screens/menu.dart';
import 'package:myufp/screens/schedule.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
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
  bool refreshed = false;
  _HomePageState(this._logged);
  Widget actual;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // FirebaseAdMob.instance.initialize(appId: "ca-app-pub-7599976903549248~3408543611");
    // myBanner
    // ..load()
    // ..show(
    //   anchorOffset: 60.0,
    //   horizontalCenterOffset: 10.0,
    //   anchorType: AnchorType.bottom,
    // );
  }



Future<List<Event>> buscarEventos() async {
   print("A ir buscar eventos da bd");
    List<Event> eventosLista = new List<Event>();
    return fb.FirebaseDatabase.instance.reference().child('eventos').once().then((eventos) {
      fb.DataSnapshot ds = eventos;
      Map mapa = ds.value;
      print(mapa.toString());
      if(mapa != null) {
        // Caso hajam realmente eventos
        mapa.forEach((nome , resto) {
          String nomezito = nome;
          Map restito = resto;
          String photo = restito['photoUrl'].toString();
          String descricao = restito['desc'].toString();
          Map likes = restito['likes'];
          Map interesses = restito['interesse'];
          int numeroInteresse = int.parse(interesses['total'].toString());
          int numeroLikes = int.parse(likes['total'].toString());
          Event novoEvento = new Event("EVENT", nomezito, photoUrl: photo, descricao: descricao , likes: numeroLikes, interesse: numeroInteresse );
          //print(novoEvento.toString());
          eventosLista.add(novoEvento);
        });
        return eventosLista;
      }
    });

}

  void buscarCards() {
    // Esta funcao encarrega-se de ir buscar eventos a database e formata em cards
    List<Widget> listita = new List<Widget>();
   var eventos = buscarEventos();
    eventos.then((eventitos) {

     List<Event> aux = eventitos;

     for(int i = 0 ; i < aux.length ; i++) {
       // Cria uma card para cada envento que exista
        listita.add(Card(
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
                  Text(aux[i].nome),
                  Image.network(aux[i].photoUrl),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.done_outline, color: Colors.grey,),
                            onPressed: () {

                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(aux[i].likes.toString()),
                          ),
                          IconButton(
                            icon: Icon(Icons.tag_faces, color: Colors.grey,),
                            onPressed: () {

                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(aux[i].interesse.toString()),
                          )
                        ],
                      ),
                      Container(
                        color: Colors.grey[300],
                        height: 30,
                        width: 100,

                        child: FlatButton(
                          child: Text("See more"), 
                          onPressed: () {
                            // Caso carregue no bota para ver mais
                            
                          },

                        ),
                      )
                    ],
                  )
                
                ],

              )
            ),
            
          ),
        ),
      ));

     }
     setState(() {
       actual = Center(
      child: Column(
        children: listita,
      ),
    );
    refreshed = true;
     });
    
   });
   //return CircularProgressIndicator();
    
  }




  @override
  Widget build(BuildContext context) {
    bool licenca = true;
   Licenciaturas lp = new Licenciaturas();
   if(_logged.licenciatura == "hey") licenca = false;
   String imagem_licenciatura = lp.lic[_logged.licenciatura];
   if (!refreshed) buscarCards();
   

 return new WillPopScope(    //WillPopScore evita andar para tras em androids e nao volta a pagina de login
      onWillPop: () async => false,
      child: new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                refreshed = false;
              });
            },
          )
        ],
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
          actual != null? actual : Text("")
      
      
      
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
  adUnitId: 'ca-app-pub-7599976903549248/5691431332',
  size: AdSize.banner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

}