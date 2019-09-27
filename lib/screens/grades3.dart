import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myufp/models/disciplina.dart';

import 'grades.dart';
import 'grades2.dart';

class Grades3 extends StatefulWidget {
//ESTA CLASS MOSTRA AS DISCIPLINAS QUE PODE ESCOLHER PARA VER OS SUB-MODULOS
  Grades actual;
  List<Disciplina> notas_final;
  List<Disciplina> notas_detailed;
  String ano;
  Grades3(this.actual,this.ano);

  @override
  State<StatefulWidget> createState() => _Grades3State(this.actual,this.ano);
}




class _Grades3State extends State<Grades3> {
  Grades actual;
  String ano;

  _Grades3State(this.actual,this.ano);


Widget mostrar_disciplinas() {
  Map<String , List<String>> mapa =  actual.cadeiras_anos;
  List<Widget> list = new List<Widget>();
  List<String> nome_cadeira = [];
  mapa.forEach((anito, _) {
      if(anito == ano) nome_cadeira = mapa[anito];
  });
  for ( int i = 0 ; i < nome_cadeira.length ; i++) {
    list.add(
      Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Grades2(actual,notas_detalhadas: nome_cadeira,nota_escolhida: nome_cadeira[i],)));
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: new Icon(Icons.subject, color : Colors.grey[400]),
            ),
            title: Text(nome_cadeira[i], style: TextStyle(color: Colors.black , fontWeight: FontWeight.normal),),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios , color: Colors.grey[400]), 
              onPressed: () {
                 Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Grades2(actual,notas_detalhadas: nome_cadeira,nota_escolhida: nome_cadeira[i],)));
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



  @override
  Widget build(BuildContext context) {
        return new Scaffold(
      appBar:new AppBar(title: new Text("Grades"), backgroundColor: Colors.white),
      body: new Center(
        child: new ListView(
          children: <Widget>[
            mostrar_disciplinas()
          ],
        ),
      )
    );
    }
  }






