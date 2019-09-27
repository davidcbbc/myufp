
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myufp/services/api.dart';



class Atm extends StatefulWidget {
  final String title = "ATM Payment";
  String message;
  String _token;
  String entidade;
  String referencia;
  String total;
  String inicio;
  String termo;
  bool validated = true;

  Map toMap() {
    var map = new Map<String,String>();
    map = {
      'token' : _token
    };
    return map;
  }
  Atm(this._token);
  Atm.validated(this.entidade,this.referencia,this.total,this.inicio,this.termo);
  Atm.notValid({this.message,this.validated});
  factory Atm.fromJson(Map<String, dynamic> json) {
    var message = json['message'];
    return new Atm.validated(message['Entidade'].toString(), 
    message['Referencia'].toString(), 
    message['Total'], message['Inicio'].toString(),
     message['Termo'].toString());
  }

  @override
  _AtmState createState() => new _AtmState(this);
}

class _AtmState extends State<Atm> {
Atm actual;
Atm original;
_AtmState(this.actual) {
  original = actual;
}
bool refreshed = false;
bool connected = true;

Future<Atm> refreshValores(Map<String,String> apiMap) async {
  //da refresh aos valores de atm fazendo pedidos
  try {
    Atm valor = await valores_atm(body: apiMap);
    return valor;
  }on Exception catch(e) {
    print(e.toString());
    return new Atm.notValid(message: "a", validated: false);
  }
}



Future<bool> isConnected() async{
  try{
    var result =  await InternetAddress.lookup('siws.ufp.pt');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print("connectado!");
      return true;
    }
  }on SocketException {
    print("desconnectado!");
    return false;
  }
}



  @override
  Widget build(BuildContext context){
  if(refreshed == false) {
    var net = isConnected();
    net.then((isOn) {
    if(isOn) {
      var bode = refreshValores(original.toMap());
      bode.then((inst) {
        actual = inst;
        setState(() {
          refreshed = true;
          connected = true;
        });
      });
    } else {
      //nao tem internet ligada
      setState(() {
        connected = false;
        refreshed = true;
      });
    }
    });
  }
 




  if(connected == false){
    //pagina de erro de net 
     return new Scaffold(
      appBar: new AppBar(title: new Text("ATM Payment"), backgroundColor: Colors.white, 
      actions: <Widget>[
        IconButton(icon: Icon(Icons.refresh, color: Colors.grey[600],),
            onPressed: () {
              setState(() {
                refreshed = false;
              });
            },)
      ],),
      body: new Center(
        child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/no_wifi.png',scale: 2.8,color: Colors.grey[400],),
          Text("Please check your connection\n \t\t\t\t\t\t\t\t\t\t\tand refresh",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
        
        ],
      ),
      )
    );
  }
  else if(refreshed == false){
    // pagina de carregamento
  return new Scaffold(
      appBar: new AppBar(title: new Text("ATM Payment"), backgroundColor: Colors.white),
      body: new Center(
        child: new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)), 
      ),
    );
  }else 
    //pagina com os valores
    return new Scaffold(
      appBar: new AppBar(title: new Text("ATM Payment"), backgroundColor: Colors.white, 
      actions: <Widget>[ IconButton(icon: Icon(Icons.refresh, color: Colors.grey[600],),
            onPressed: () {
              setState(() {
                refreshed = false;
              });
            },)],),
      body: RefreshIndicator(
        color: Colors.green,
        child: 
            new Center(
        child: actual.validated == false? Center(child: Text("There are no payment values", 
        style:TextStyle(fontSize: 25)),) : Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Entity  ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                Text(actual.entidade,style: TextStyle(fontSize: 25),)
              ]
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Reference  ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                Text(actual.referencia,style: TextStyle(fontSize: 25),)
              ]
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Total  ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                Text("€ ${actual.total}",style: TextStyle(fontSize: 25),)
              ]
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Start  ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                Text(actual.inicio,style: TextStyle(fontSize: 25),)
              ]
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("End  ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
                Text(actual.termo,style: TextStyle(fontSize: 25),)
              ]
            ),
          ],
        ) ,
        )
      )
        ,
         onRefresh: () async => setState(() {
                refreshed = false;
              }),

      ),
    );
  }
}