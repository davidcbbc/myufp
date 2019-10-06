import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Seemore extends StatefulWidget {
  String nome_evento;
  String descricao_evento;
  int numero_likes;
  int numero_interesse;
  String photoUrl;

  Seemore(this.nome_evento,this.descricao_evento,this.numero_interesse,this.numero_likes,this.photoUrl);


  @override
  State<StatefulWidget> createState() => SeemoreState(this.nome_evento,this.descricao_evento,this.numero_interesse,this.numero_likes,this.photoUrl);


}


class SeemoreState extends State<Seemore> {
  String nome_evento;
  String descricao_evento;
  int numero_likes;
  int numero_interesse;
  String photoUrl;

  SeemoreState(this.nome_evento,this.descricao_evento,this.numero_interesse,this.numero_likes,this.photoUrl);

  @override
  Widget build(BuildContext context) {
   
    return new Scaffold(
      
    );
  }



}