import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Seemore extends StatefulWidget {
  String nome_evento;
  String descricao_evento;
  String number;
  int numero_likes;
  int numero_interesse;
  String photoUrl;

  Seemore(this.nome_evento,this.descricao_evento,this.numero_interesse,this.numero_likes,this.photoUrl,this.number);


  @override
  State<StatefulWidget> createState() => SeemoreState(this.nome_evento,this.descricao_evento,this.numero_interesse,this.numero_likes,this.photoUrl,this.number);


}


class SeemoreState extends State<Seemore> {
  String nome_evento;
  String descricao_evento;
  int numero_likes;
  String number;
  int numero_interesse;
  String photoUrl;
  bool going = false;
  bool interested= false;

  SeemoreState(this.nome_evento,this.descricao_evento,this.numero_interesse,this.numero_likes,this.photoUrl,this.number);

  @override
  Widget build(BuildContext context) {
    //TODO IMPLEMENTAR O BOOL DO GOING E DO INTERESTED
   
    return new Scaffold(
      appBar: new AppBar(
        title: Text(nome_evento),
        backgroundColor: Colors.white
      ),
      body: ListView(
        children: <Widget>[
          Image.network(photoUrl),
          SizedBox(height: 20,),
          Text(descricao_evento, style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.done_outline, color: going? Colors.green : Colors.grey,),
                              onPressed: () async{
                                //aumenta os likes
                                var instantace = fb.FirebaseDatabase.instance.reference();
                                var likezitos = instantace.child('eventos').child(nome_evento).child('likes');
                                likezitos.child('total').once().then((likkes) {
                                  int hey = int.parse(likkes.value.toString());
                                  print(hey);
                                  if(going) {
                                    likezitos.update({
                                      'total' : hey+1
                                    });
                                    likezitos.update({
                                      number: '${numero_likes+1}',
                                    });
                                  } else {
                                    likezitos.update({
                                      'total' : hey-1
                                    });
                                    likezitos.update({
                                      number: null,
                                    });
                                }
                                });
                                setState(() {
                                  going = !going;
                                });
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text("I'm going"),
                          ),
                          IconButton(
                            icon: Icon(Icons.tag_faces, color: interested? Colors.yellow[700] : Colors.grey,),
                            onPressed: () {
                              setState(() {
                                interested = !interested;
                              });
                              
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text("Interested"),
                          )
                        ],
                      ),
        ],
      ),
      
    );
  }



}