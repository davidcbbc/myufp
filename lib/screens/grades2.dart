import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myufp/models/disciplina.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'grades.dart';

class Grades2 extends StatefulWidget {
  Grades actual;                        // contem toda a informacao
  List<String> notas_detalhadas;
  String nota_escolhida;
  Grades2(this.actual,{this.notas_detalhadas,this.nota_escolhida});

  @override
  State<StatefulWidget> createState() {

      print(" FOI AS DETAILED ");
      List<Disciplina> detalhadas = [];
      List<Disciplina> finalitas = [];
      if(actual.notas_detailed != null && actual.notas_final != null) {
        actual.notas_detailed.forEach((disciplina) {
          if(disciplina.nome == nota_escolhida) detalhadas.add(disciplina);
      });
        actual.notas_final.forEach((disciplina) {
          if(disciplina.nome == nota_escolhida) finalitas.add(disciplina);
        });
      
      return new _Grades2State(detalhadas,finalitas,false);
      } else {
        // nao ha notas
      }
    } 
}



class _Grades2State extends State<Grades2> {
List<Disciplina> actual;
List<Disciplina> finalitas;
bool isFinal;

_Grades2State(this.actual,this.finalitas,this.isFinal);


  Widget contruirDetalhadas(List<Disciplina> lista) {
  List<Widget> list = new List<Widget>();
    for(int i = 0 ; i < lista.length ; i++) {
      double nota = double.parse(lista[i].nota_final);
      list.add(Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
              child: nota == -1 || nota == -2? Icon(Icons.warning, color: Colors.red[300]) 
              : 
              (nota  >= 9.5 ? Icon(Icons.assignment_turned_in,color: Colors.green[300]) : Icon(Icons.assignment_late,color: Colors.orange[300]))
                ,
            ),
            title: Text(lista[i].nome, style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),),
            subtitle: (lista[i].definicao != null ? Text(lista[i].definicao): null),
            trailing: CircularPercentIndicator(
              animation: true,
                radius: 50,
                lineWidth: 6.0,
                percent: nota == -1 || nota == -2? 0.0 : nota/20,
                center: (nota == -1 || nota == -2?
                new Text(nota == -2 ? "D":"F", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: Colors.red)) 
                :
                new Text(lista[i].nota_final, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
                ),

                progressColor: double.parse(lista[i].nota_final) >= 9.5 ? Colors.green : Colors.orange,
                backgroundColor: Colors.grey[300],
              ),
          ),
        ),
      ));
    }
    return new Column(children: list);
  }


  Widget constuirMedia(List<Disciplina> lista) {
    // Controi a media das notas das frequencias da cadeira
    double media = 0;
    for ( int i = 0 ; i < lista.length ; i++ ) {
      double nota = double.parse(lista[i].nota_final);
      if(nota != -1 && nota != -2) {
        media += nota;
      }
    }  

    double mediaTotal = media / lista.length;

    return Column(
      children: <Widget>[
        Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[100]),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child:mediaTotal >= 9.5 ?
              Icon(Icons.assistant_photo,color: Colors.green[900]) :
              Icon(Icons.assistant_photo, color: Colors.orange[900])
                ,
            ),
            title: Text("Frequency Grade Average", style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),),
           // subtitle: Text("Final grade"),
            trailing: CircularPercentIndicator(
              animation: true,
                radius: 50,
                lineWidth: 6.0,
                percent: mediaTotal / 20,
                center:
                new Text(mediaTotal.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
                ,
                progressColor: mediaTotal >= 9.5 ? Colors.green[900] : Colors.orange[900],
                backgroundColor: Colors.grey[300],
              ),
          ),
        ),
      ),
      ],
    );
    


  }

  Widget contruirFinais(List<Disciplina> lista) {
  List<Widget> list = new List<Widget>();
    for(int i = 0 ; i < lista.length ; i++) {
      double nota = double.parse(lista[i].nota_final);
      list.add(Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[100]),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: nota == -1 || nota == -2? Icon(Icons.warning, color: Colors.red[300]) 
              : 
              (nota  >= 9.5 ? Icon(Icons.assistant,color: Colors.green[900]) : Icon(Icons.assistant,color: Colors.orange[700]))
                ,
            ),
            title: Text("Final Grade", style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),),
           // subtitle: Text("Final grade"),
            trailing: CircularPercentIndicator(
              animation: true,
                radius: 50,
                lineWidth: 6.0,
                percent: nota == -1 || nota == -2? 0.0 : nota/20,
                center: (nota == -1 || nota == -2?
                new Text(nota == -2 ? "D":"F", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: Colors.red)) 
                :
                new Text(lista[i].nota_final, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
                ),

                progressColor: double.parse(lista[i].nota_final) >= 9.5 ? Colors.green[900] : Colors.orange[900],
                backgroundColor: Colors.grey[300],
              ),
          ),
        ),
      ));
    }
    return new Column(children: list);
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar:new AppBar(title: new Text("Grades"), backgroundColor: Colors.white),
      body: new Center(
        child: new ListView(
          children: <Widget>[
            contruirFinais(finalitas),
            constuirMedia(actual),
            contruirDetalhadas(actual),
            

          ],
        ),
      )
    );
  }

}