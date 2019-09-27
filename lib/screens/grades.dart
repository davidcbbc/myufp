import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myufp/mist/progress_dial.dart';
import 'package:myufp/models/disciplina.dart';
import 'package:myufp/services/api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'grades2.dart';
import 'grades3.dart';

class Grades extends StatefulWidget {
  // NAO ESQUECER , NOTAS OU SAO final OU detailed
  String _token;
  String message;     //for errors
  bool validated;
  List<Disciplina> notas_final;
  List<Disciplina> notas_detailed;
  Map<String , List<Disciplina >> cadeiras_notas;
  // cadeiras_notas guarda o nome_da_cadeira : lista_de_sub_modulo ( ex : AED1 : [AED1 PL , AED1 TP] )
  Map<String , List<String>> cadeiras_anos;
  // cadeiras_anos guarda o ano_da_cadeira : nome_da_cadeira ( ex : 2018/19 : [AED1 PL , AED1 TP] )
  List<String> anos;    // quantidade de anos letivos que tem o utilizador

  factory Grades.fromJson(Map<String, dynamic> json, String type) {
    List<Disciplina> notas_final =[];
    List<Disciplina> notas_detailed = [];
    List<String> anitos = [];
    Map<String , List<Disciplina >> cadeiras_dt = new Map<String , List<Disciplina >>();
    Map<String , List<String>> cadeiras_years = new Map<String , List<String> >();

    //final
    Map<String, dynamic> message = json['message'];
    if( type == "final") {
      Map<String,dynamic> licenciatura;
    message.forEach((tipo, _) {
      licenciatura = message[tipo];
    });
    
    licenciatura.forEach((key , _) {
      var notas = licenciatura[key];
      for( int i = 0 ; i < notas.length ; i ++) {
        Map nota_separada = notas[i];
        Disciplina dp = new Disciplina.nota_final(nota_separada['unidade'].toString(),nota_separada['nota'].toString());
        notas_final.add(dp);
        //print("NOTA ADD ${dp.nome} : ${dp.nota_final}");
      }
    });
    return Grades.validated(true,notas_final: notas_final);
  } else {
    //detailed
    var ano = [];
    message.forEach((key,_) {
      //para cada ano
      ano.add(key);
      });
      
      ano.forEach((ano_letivo) {
        // para cada disciplina
        anitos.add(ano_letivo.toString());
        Map<String,dynamic> disciplina = message[ano_letivo];
        List<String> aux2 = [];
        disciplina.forEach((dis, _) {
            //print(dis);
            var arr = [];
            arr = disciplina[dis]; 
            List<Disciplina> aux = [];
            
            for (int i = 0; i < arr.length ; i++) {
              Map<String , dynamic> sub_elementos = arr[i];
              String nome_disciplina = sub_elementos["unidade"].toString();
              String elemento = sub_elementos["elemento"].toString();
              String notita = sub_elementos["nota"].toString();
              if(notita == "F") notita = "-1";
              if(notita == "D") notita = "-2";
              Disciplina dp = new Disciplina.nota_detailed(nome_disciplina, elemento, notita,ano: ano_letivo);
              notas_detailed.add(dp);
              aux.add(dp);
              if(aux2.indexOf(dp.nome) == -1 ) aux2.add(dp.nome);
            }
            cadeiras_dt[dis] = aux;
            if(aux2.indexOf(dis) == -1 ) aux2.add(dis);
            
        });
        cadeiras_years[ano_letivo] = aux2;
      });
    return Grades.validated(true,
    notas_detailed: notas_detailed, 
    anos: anitos,
    cadeiras_notas: cadeiras_dt,
    cadeiras_anos: cadeiras_years,
    );
  }
}
    
  Grades.notValidated(this.message,this.validated);
  Grades.validated(this.validated,{this.notas_final,this.notas_detailed,this.anos,this.cadeiras_notas,this.cadeiras_anos});
  Grades(this._token);

  @override
  State<StatefulWidget> createState() => _GradesState(this,this);

    Map toMap() {
    var map = Map<String,String>();
    map = {
      "token" : "${_token}"
    };
    return map;
  }
}



class _GradesState extends State<Grades> {
  Grades actual;
  Grades original;
  bool refreshed = false;
  bool connected = true;


  _GradesState(this.actual,this.original);

    Future<Grades> refreshValores(Map<String,String> apiMap,String type) async {
    //da refresh aos valores de assiduidade fazendo pedidos
    try {
     Grades valor = await valores_notas(apiMap,type);
      return valor;
    }on Exception catch(e) {
      print(e.toString());
   }
   return null;
  }


  Widget primeira_opcao(List<String> anoos) {
    List<Widget> list = new List<Widget>();
    for(int i = 0;  i < anoos.length; i ++) {
      String anito = actual.anos[i].toString();
      list.add(Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Grades3(actual,anito)));
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: new Icon(Icons.account_box, color : Colors.grey[400]),
            ),
            title: Text(anito, style: TextStyle(color: Colors.grey[500] , fontWeight: FontWeight.normal),),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios , color: Colors.grey[400]), 
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Grades3(actual,anito)));
              },
            ),
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
      var detailed = refreshValores(actual.toMap(),"detailed");
      detailed.then((inst) {
        if( inst.validated == false) {
          // AINDA NAO TEM NOTAS , CALOIRO
          print("caloiro");
          actual = inst;
          setState(() {
            refreshed = true;
            connected = true;
          });
        } else {
          print("avancei");
          actual = inst;
          var finalito = refreshValores(original.toMap(), "final");
          print(actual.message);
          finalito.then((instFinal) {
          setState(() {
            actual = new Grades.validated(
              true, 
              notas_final: instFinal.notas_final,
              notas_detailed: inst.notas_detailed,
              anos: actual.anos,
              cadeiras_anos: actual.cadeiras_anos,
              cadeiras_notas: actual.cadeiras_notas,);
            refreshed = true;
            connected = true;
          });
          });
        }

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
      appBar: new AppBar(title: new Text("Grades"), backgroundColor: Colors.white,
      actions: <Widget>[          IconButton(icon: Icon(Icons.refresh, color: Colors.grey[600],),
            onPressed: () {
              setState(() {
                refreshed = false;
              });
            },)],),
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
      appBar: new AppBar(title: new Text("Grades"), backgroundColor: Colors.white),
      body: new Center(
        child: new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)), 
      ),
    );
  }else return new Scaffold(
      appBar:new AppBar(title: new Text("Grades"), backgroundColor: Colors.white,
      actions: <Widget>[          IconButton(icon: Icon(Icons.refresh, color: Colors.grey[600],),
            onPressed: () {
              setState(() {
                refreshed = false;
              });
            },)],),
      body: new Center(
        child: new ListView(
          children: <Widget>[
            actual.validated? primeira_opcao(actual.anos) : Center(child: 
              Text(actual.message, style: TextStyle(fontSize: 20),),)
          ],
        ),
      )
    );
  }

    _alertaErroConnect(context) {
    Alert(
      context: context,
      type: AlertType.error,
      title: "Ups!",
      desc: "Please check your connection",
      buttons: [
        DialogButton( 
          child: Text("Ok",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () {
            return Navigator.pop(context);
          } ,
          width:120,
          color: Colors.green,
        ),
      ]
    ).show();
  }
}