import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myufp/models/secretaria.dart';
import 'package:myufp/services/api.dart';






class Secretary extends StatefulWidget {
List<Secretaria> secretarias;
bool validated = true;
Secretary();
Secretary.validated(this.secretarias);
Secretary.notValidated(this.validated);
factory Secretary.fromJson(Map<String, dynamic> json) {
  if(json['message'].toString() == '[]') return new Secretary.notValidated(false);
  Map message = json['message'];
  List<Secretaria> listita = new List<Secretaria>();
  message.forEach((tipo,_) { 
    listita.add(new Secretaria(
    tipo.toString(), 
    message[tipo]['desc'].toString(), 
    message[tipo]['last_update'].toString(), 
    message[tipo]['number'].toString(), 
    message[tipo]['waiting'].toString()));
  });
  return new Secretary.validated(listita);
}
  @override
  State<StatefulWidget> createState() => new _SecretaryState();
}


class _SecretaryState extends State<Secretary>{
  Secretary secs;
  bool refreshed = false;
  bool connected = true;
  _SecretaryState();

   Widget show_values() {
    List<Widget> list = new List<Widget>();
    for(int i = 0;  i < secs.secretarias.length; i ++) {
      list.add(Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: new Text("${secs.secretarias[i].type}",style: TextStyle(color: Colors.grey[400] , fontWeight: FontWeight.bold,fontSize: 40)),
            ),
            title: Text(secs.secretarias[i].desc, style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),),
            subtitle: new Text("Waiting: ${secs.secretarias[i].waiting} \nLast Update: ${secs.secretarias[i].last_update}"),
            trailing: new Text("${secs.secretarias[i].number}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: Colors.grey[800])),
          ),
        ),
      )
      );
    }
    return new Center(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: list,
      ),
    );
  }


  Future<Secretary> refresh_queue() async{
    try {
     Secretary valor = await valores_queue();
      return valor;
    }on Exception catch(e) {
      print(e.toString());
   }
   return null;
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
  Widget build(BuildContext context) {

 if(refreshed == false) {
    var net = isConnected();
    net.then((isOn) {
    if(isOn) {
      var bode = refresh_queue();
      bode.then((inst) {
        this.secs = inst;
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
      appBar: new AppBar(title: new Text("Secretary"), backgroundColor: Colors.white,
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
  } else if(refreshed == false){
  return new Scaffold(
      appBar: new AppBar(title: new Text("Queue"), backgroundColor: Colors.white),
      body: new Center(
        child: new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)), 
      ),
    );
  }else return Scaffold(
      appBar: new AppBar(
        title: new Text("Queue"), 
        backgroundColor: Colors.white, 
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh, color: Colors.grey[600],),
            onPressed: () {
              setState(() {
                refreshed = false;
              });
            },)
        ],),
        body: Center(
          child: !secs.validated? 
              new Text("No values to display",style: TextStyle(fontSize: 25,color: Colors.black))
              : ListView(
                children: <Widget>[
                  show_values()
                ],
              ),
        ),
            );
  }

}