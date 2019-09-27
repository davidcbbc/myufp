import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myufp/models/evento.dart';
import 'package:myufp/services/api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Schedule  {
  bool validated = true;
  String token;
  List<Event> eventos = new List<Event>();


  Schedule.notValidated(this.validated);
  Schedule.fromJson(Map<String, dynamic> json) {
    Map message = json['message'];
    message.forEach((data , cadeiras) {
      List cadeirasAux = cadeiras;
      for( int i = 0 ; i < cadeirasAux.length ; i ++) {
        String nome = cadeirasAux[i]['unidade'].toString();
        nome += ' ';
        nome += cadeirasAux[i]['tipo'].toString();
        String desc = "${cadeirasAux[i]['sala']}";
        String horas = "${cadeirasAux[i]['inicio']} - ${cadeirasAux[i]['termo']}";
        Event ev = new Event("NORMAL", nome,descricao: desc,dia: data,horas: horas);
        eventos.add(ev);
      }
    });

  }







  Schedule(this.token);
  Map toMap() {
    var map = Map<String,String>();
      map = {
        "token" : "$token"
      };
      return map;
  }

    Future<Schedule> refreshValues() async {
    //da refresh aos valores de assiduidade fazendo pedidos
    try {
     Schedule valor = await valoresHorario(this.toMap());
      return valor;
    }on Exception catch(e) {
      print(e.toString());
   }
   return null;
  } 
}

