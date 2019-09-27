import 'package:myufp/models/disciplina.dart';

class Event {
  //Existem dois tipos: EXAM e NORMAL
  String dia;
  Disciplina disciplina;
  String type = ''; //EXAM ou NORMAL ou SCHEDULE
  String nome = '';
  String descricao = '';
  String horas ='';

  Event(this.type,this.nome,{this.dia,this.descricao,this.horas,this.disciplina});

  @override
  String toString() {
    String todo = '';
    todo += "Type: $type \n"; 
    todo += "Nome: $nome \n";
    if(descricao.isNotEmpty) todo += "Desc: $descricao \n";
    todo += "Dia: $dia \n";
    if(horas.isNotEmpty) todo += "Hora: $horas"; 
    return todo;
  }

  DateTime getDateTime() {
    String ano2 = dia.toString().substring(0,4);
    String mes2 = (dia.toString().substring(5,7));
    String dia2 = (dia.toString().substring(8,10));
    return new DateTime(int.parse(ano2),int.parse(mes2),int.parse(dia2));
  }
}