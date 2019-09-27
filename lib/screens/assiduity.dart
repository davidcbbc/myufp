import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myufp/models/disciplina.dart';
import 'package:myufp/charts/horizontal_bar_label_custom.dart';
import 'package:myufp/services/api.dart';



class Assiduity extends StatefulWidget {
  String _token;
  String message;       
  bool validated;         //for 404 errors
  List<Disciplina> disciplinas;

  Assiduity(this._token);
  Assiduity.validated(this.disciplinas,this.validated);
  Assiduity.notValidated(this.message,this.validated);

  factory Assiduity.fromJson(Map<String, dynamic> json) {
    //PARSING DO JSON E CRIACAO DE OBJETOS COM AS RESPETIVAS STRINGS
    var arr = [];
    arr = json['message'];
    int numeroCadeiras = arr.length;
    List<Disciplina> dis = [];
    for(int i = 0 ; i < numeroCadeiras ; i++) {
      Map mapita =  arr[i];
      mapita.forEach((disciplina , value) {
      String nome = disciplina.toString();
      var posicao = [];
      posicao = value;
      Disciplina dp;
      if( posicao.length == 1 ) {
        //apenas tem um tipo , ou tem TP ou PL
        String tipo =  posicao[0]['tipo'].toString();
        String assiduidade = posicao[0]['assiduidade'].toString();
        if( tipo == 'PL') dp = new Disciplina.assiduidade_validada(nome,assiduidade_pl: assiduidade);
         else dp = new Disciplina.assiduidade_validada(nome,assiduidade_tp: assiduidade);  
      } else {
      String pl = posicao[0]['assiduidade'].toString();
      String tp = posicao[1]['assiduidade'].toString();
      dp = new Disciplina.assiduidade_validada(nome,assiduidade_pl: pl,assiduidade_tp: tp);
      }
      //print("nome ${dp.nome} pl ${dp.assiduidade_pl} tp ${dp.assiduidade_tp}");
      dis.add(dp);
      });
    }
    return Assiduity.validated(dis,true);
  }

  Map toMap() {
    var map = Map<String,String>();
    map = {
      "token" : "$_token"
    };
    return map;
  }

  @override
  State<StatefulWidget> createState() => new _AssiduityState(this);
}



class _AssiduityState extends State<Assiduity> {
  Assiduity actual;
  bool refreshed = false;
  bool connected = true;

  _AssiduityState(this.actual);

  Future<Assiduity> refreshValores(Map<String,String> apiMap) async {
    //da refresh aos valores de assiduidade fazendo pedidos
    try {
     Assiduity valor = await valores_assiduidade(apiMap);
      return valor;
    }on Exception catch(e) {
      print(e.toString());
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
  Widget build(BuildContext context) {

  if(refreshed == false) {
    var net = isConnected();
    net.then((isOn) {
    if(isOn) {
      var bode = refreshValores(actual.toMap());
      bode.then((inst) {
        actual = inst;
        print(actual.message);
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
      appBar: new AppBar(title: new Text("Assiduity"), backgroundColor: Colors.white,
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
      appBar: new AppBar(title: new Text("Assiduity"), backgroundColor: Colors.white),
      body: new Center(
        child: new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)), 
      ),
    );
  }else 
  return new Scaffold(
      appBar: new AppBar(title: new Text("Assiduity"), backgroundColor: Colors.white, actions: <Widget>[
                  IconButton(icon: Icon(Icons.refresh, color: Colors.grey[600],),
            onPressed: () {
              setState(() {
                refreshed = false;
              });
            },)
      ],),
      body: new Center(
        child: ListView(
          children: <Widget>[
            Container(
              width: 200.0,
              height: 800.0,
              child: actual.validated? HorizontalBarLabelCustomChart.withDiscipline(actual.disciplinas) : 
              new Center(
                child: new Text("${actual.message}",style: TextStyle(fontSize: 20,color: Colors.black),), 
      )       ,
            )
          ],
        ), 
      ),
    );

    
  }

}