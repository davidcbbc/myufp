import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myufp/models/user.dart';
import 'package:myufp/screens/home_page.dart';
import 'package:myufp/services/myfiles.dart';
import 'screens/login_page.dart';

Future<void> main() async{
    WidgetsFlutterBinding.ensureInitialized();
    bool log = await isKeepLogged();
    User aux;
    print('na main $log');
    if(log) {
      String rawText =  await readFile("token.txt");
      Map mapa = json.decode(rawText);
      String username = mapa['username'].toString();
      String token = mapa['token'].toString();
      String licenciatura = mapa['licenciatura'].toString();
      aux = new User.authenticatedUser(username: username, token: token);
      aux.licenciatura = licenciatura;
    }
      
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp,DeviceOrientation.portraitDown])
      .then((_) {
    runApp(MyApp(log,aux));
  });
  
}

class MyApp extends StatelessWidget {
  bool siga;
  User logado;
  MyApp(this.siga,this.logado);
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    return MaterialApp(
      title: 'MYUFP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: siga? HomePage(logado): LoginPage(),
      navigatorObservers: [
      FirebaseAnalyticsObserver(analytics: analytics),
  ],
    );

  }
}
