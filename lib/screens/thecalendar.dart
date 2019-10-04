import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:myufp/models/disciplina.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:myufp/models/evento.dart';
import 'package:myufp/screens/schedule.dart';
import 'package:myufp/services/api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';





class TheCalendar extends StatefulWidget {
  String _token;
  String number;
  bool validated = true;
  List<Disciplina> diplinas;
  Schedule horario;
  

  TheCalendar(this._token,{Key key, this.number}) : super(key: key);


  Map toMap() {
    var map = Map<String,String>();
    map = {
      "token" : "${_token}"
   };
    return map;
  }
  TheCalendar.notValidated(this.validated);
  TheCalendar.validated(this.diplinas);

  factory TheCalendar.fromJson(Map<String, dynamic> json){
    List<Disciplina> dips = new List<Disciplina>();
    List mensagem = json['message'];
    for(int i = 0 ; i < mensagem.length ; i++) {
      Map aux = mensagem[i];
      aux.forEach((chave,valor) {
        String dataExame = chave.toString();
        List examesMesmoDia = valor;
        for(int p = 0 ; p < examesMesmoDia.length ; p++) {
          Map exame = examesMesmoDia[p];
          String nomeExame = exame["subject"].toString();
          String horasExame = exame["time"].toString();
          List salasExame = exame['room'];
          List<String> salasExameParaList = new List<String>();
          for(int k = 0 ; k < salasExame.length; k++) salasExameParaList.add(salasExame[k].toString());
          List profsExame = exame['assignee'];
          List<String> profsExameParaList = new List<String>();
          for(int l = 0 ; l < profsExame.length; l++) profsExameParaList.add(profsExame[l].toString());
          dips.add(new Disciplina.exame(nomeExame,dataExame,horasExame,salasExameParaList,profsExameParaList));
        }
      });
    }
    return TheCalendar.validated(dips);
  }

  @override
  _TheCalendarState createState() => _TheCalendarState(this,this.number);
}

class _TheCalendarState extends State<TheCalendar> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  String number;
  bool refreshed = false;
  bool connected = true;
  TheCalendar actual;
  Schedule horarioAtual;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;

  _TheCalendarState(this.actual,this.number) {
    horarioAtual = new Schedule(actual._token);
  }


  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void refreshEventos(TheCalendar cale, Schedule horario) {
    final _selectedDay = DateTime.now();
    Map<DateTime,List> eventitos = new Map<DateTime,List>();
    print("a ir buscar eventos da bd");
    var eventosDaBD = returnAllEventsOfUser(this.number);
    
    eventosDaBD.then((lista) {
      
    if(lista != null) {
      
      for( int i = 0 ; i < lista.length ; i++) {
        Event ev = lista[i];
        String ano1 = ev.dia.substring(0,4);
        String mes2 = ev.dia.substring(5,7);
        String dia2 = ev.dia.substring(8,10);
        DateTime tempo = new DateTime(int.parse(ano1),int.parse(mes2),int.parse(dia2));
        if(eventitos[tempo] == null){
        eventitos[tempo] = new List<Event>();
        eventitos[tempo].add(ev);
      } 
      else eventitos[tempo].add(ev);
      }
    }
    if(actual.validated) {
      print("entrei no actual");
      cale.diplinas.forEach((diplina) {
      String ano;
      String mes;
      String dia;
      ano = diplina.dataDoExame.substring(0, 4);
      mes = diplina.dataDoExame.substring(6, 7);
      dia = diplina.dataDoExame.substring(9, 10);
      Event ev = new Event("EXAM", diplina.nome,disciplina: diplina);
      DateTime tempo = new DateTime(int.parse(ano),int.parse(mes),int.parse(dia));
      if(eventitos[tempo] == null){
        eventitos[tempo] = new List<Event>();
        eventitos[tempo].add(ev);
      } 
      else eventitos[tempo].add(ev);
      }
    );  
    }if(horario.validated) {
      for( int i = 0 ; i < horario.eventos.length ; i++) {
        DateTime tempo2 = horario.eventos[i].getDateTime();
        if(eventitos[tempo2] == null){
        eventitos[tempo2] = new List<Event>();
        eventitos[tempo2].add(horario.eventos[i]);
        } 
        else eventitos[tempo2].add(horario.eventos[i]);
      }

    }
    _events = eventitos;
    _selectedEvents = _events[_selectedDay] ?? [];
    setState(() {
      
    });
    });

    _events = eventitos;
    _selectedEvents = _events[_selectedDay] ?? [];

  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
  }

  Future<TheCalendar> refreshValues(Map<String,String> apiMap) async {
    //da refresh aos valores de calendario fazendo pedidos
    try {
     TheCalendar valor = await valores_calendario(apiMap);
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


  Future<Event> addEvent(String user_number,String event_day,String event_description, String event_name , String event_hours) async {
    //print("$event_day");
            String mesAux;
            String diaAux;
            Event novo_evento = new Event(event_description,event_name,dia: event_day, descricao: event_description , horas: event_hours);
            var instantace = fb.FirebaseDatabase.instance.reference();
            var user = instantace.child("users").child(user_number).child("calendar_events");
            //fb.FirebaseDatabase.instance.reference().child("users").child(user_number).child("calendar_events").
            print(novo_evento.getDateTime().toString());
            print(novo_evento.getDateTime().month.toString());
            if(novo_evento.getDateTime().month.toString().length == 1) {
              mesAux = "0${novo_evento.getDateTime().month.toString()}";
            }else mesAux = novo_evento.getDateTime().month.toString();

            print("mes $mesAux");

            if(novo_evento.getDateTime().day.toString().length == 1) {
              diaAux = "0${novo_evento.getDateTime().day.toString()}";
            } else diaAux = novo_evento.getDateTime().day.toString();

            print("dia $diaAux");

            var ano = user.child(novo_evento.getDateTime().year.toString());
            var mes = ano.child(mesAux);
            var dia = mes.child(diaAux);
            var horas = dia.child(event_hours);
            var setzito = horas
            .set({
                'event_description': event_description,
                'event_name': event_name

            }
                 ).then((_) {

                  print('Evento adicionado na BD');
                  return novo_evento;
            });

            return null;

  }


  Future deleteEvent(String user_number,Event event) async {
    print("A ELIMINAR EVENTO");
    //print("$user_number : ${event.toString()}");
    String mezito;
    String diazito;
    if(event.dia.substring(5,6) == "0") mezito = event.dia.substring(6,7);
    else mezito = event.dia.substring(5,7);
    if(event.dia.substring(8,9) == "0") diazito = event.dia.substring(8,9);
    else diazito = event.dia.substring(8,10);
     
     if(mezito.length == 1) mezito = "0$mezito";
     if(diazito.length == 1) diazito = "0$diazito";
      print(mezito);
     print(diazito);
    print(event.getDateTime().year.toString());
            fb.FirebaseDatabase.instance.reference().child("users").child(user_number).child("calendar_events").
            child(event.getDateTime().year.toString()).
            child(mezito).
            child(diazito).
            child(event.horas)
            .set(null).then((_) {
                  print('Dados apagados da BD');
            });

  }

  Future<List<Event>> returnAllEventsOfUser(String user_number) async{
    print("A ENTRAR");
  List<Event> eventos = new List<Event>();
  print("A DAR RETURN");
  return fb.FirebaseDatabase.instance.reference().child("users").child(user_number).child("calendar_events").once().then((valor) {
    fb.DataSnapshot ds = valor;

    Map hey = ds.value;
    if(hey != null)
    print("1");
    hey.forEach((ano,resto) {
      print("entrei no for each");

      String anito = ano.toString();
      print("ANO $anito");
      print(resto);
      Map info = resto;
      print("a entrar no segundo for each");
      info.forEach((mes, restito) {
        print("2");
        String mesito = mes.toString();
        if( mesito.toString().length == 1) mesito = "0$mesito";
        Map info2 = restito;
        info2.forEach((dia , restito2) {
          String diazito = dia.toString();
            if(diazito.toString().length == 1) diazito = "0$diazito";
          Map info3 = restito2;
          info3.forEach((hora, restito3) {
            String horita = hora.toString();
            //print("HORA $horita");
            Map desc = restito3;
            Event aux = new Event(
              "COSTUM",
              desc['event_name'].toString(),
              dia: "$anito-$mesito-$diazito",
              descricao: desc['event_description'].toString(),
              horas: horita);
              eventos.add(aux);
          });
        });
      });
    });
  return eventos;
  });
}






  @override
  Widget build(BuildContext context) {
  if(refreshed == false) {
    var net = isConnected();
    net.then((isOn) {
    if(isOn) {
      var bode = refreshValues(actual.toMap());
      bode.then((inst) {
        actual = inst;
        var horariozito = horarioAtual.refreshValues();
        horariozito.then((horario) {
        horarioAtual = horario;
        setState(() {
          refreshEventos(inst, horarioAtual);
          refreshed = true;
          connected = true;
        });
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
      appBar: new AppBar(title: new Text("Calendar"), backgroundColor: Colors.white),
      body: new Center(
        child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/no_wifi.png',scale: 2.8,color: Colors.grey[400],),
          Text("Please check your connection\n \t\t\t\t\t\t\t\t\t\t\tand refresh",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
          IconButton(
            icon: Icon(Icons.refresh,color: Colors.grey[900],),
            padding: EdgeInsets.only(right: 70),
            iconSize: 40,
            onPressed: () {
              setState(() {
                connected = true;
                refreshed = false;
              });
            },
          )
        
        ],
      ),
      )
    );
  } else if( refreshed == false ) {
     return new Scaffold(
       appBar: new AppBar(title: new Text("Calendar"), backgroundColor: Colors.white),
       body: new Center(
         child: new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)), 
       ),
     );
     } else 
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Calendar"),
         actions: <Widget>[
           IconButton(
             color: Colors.black,
             icon: Icon(Icons.add), 
             onPressed: () {
               //adicionar evento
               _criarEvento(context);
               setState(() {
                
               });
             },
           )
         ],
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }


  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.green[400],
        todayColor: Colors.green[200],
        markersColor: Colors.grey[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }


  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  color: event.type == "EXAM"? Colors.yellow[100] : Colors.grey[200],
                  border: Border.all(width: 0.2),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: new Icon(Icons.event),
                  title: Text((event.nome.toString()),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey[900]),),
                  subtitle: Text("${event.horas}"),
                  trailing: new Icon(Icons.touch_app,color: Colors.grey[400],),
                  onTap: () {
                    if(event.type == 'EXAM'){
                    Disciplina eev = event.disciplina;
                    _infoExame(
                    context,
                    event.nome,
                    eev.horaDoExame,
                    eev.salasDoExame,
                    eev.profsDoExame);
                    } else if(event.type == 'NORMAL'){
                      _infoEvento(
                        context,
                        event
                      );
                    } else {
                      _infoEventoCostum(context, event);
                    }

                  },
                ),
              ))
          .toList(),
    );
  }

    _infoExame(context, String nome , String hora,List<String> salas, List<String> profs) {
    String n_sala = salas.length > 1 ? "Rooms ": "Room ";
    String salitas = '';
    salas.forEach((sala) {
      if(salitas.isNotEmpty) salitas += ', ';
      salitas += sala;
    });
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      image: Image.asset('assets/exame.png',scale: 3,),
      title: "Information",
      content: Column(
        children: <Widget>[
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Time", style: TextStyle(fontWeight: FontWeight.bold),),
            Text("$hora")
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(n_sala, style: TextStyle(fontWeight: FontWeight.bold),),
            Text("${salitas}")
          ],
        ),
        Text("$nome", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14,color: Colors.grey),),

        ],
      ),
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

    _infoEvento(context, Event evento) {
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      image: Image.asset('assets/calendar.png',scale: 7,),
      title: "${evento.nome}",
      content: Column(
        children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Time ", style: TextStyle(fontWeight: FontWeight.bold),),
            evento.horas == null? Text("00:00"): Text("${evento.horas}")
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Room", style: TextStyle(fontWeight: FontWeight.bold),),
            SingleChildScrollView(
              child: evento.descricao == null? Text("Without description"):Text("${evento.descricao}"),
            )
            
            
          ],
        ),
        ],
      ),
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
    
    _infoEventoCostum(context, Event evento) {
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      image: Image.asset('assets/calendar.png',scale: 7,),
      title: "${evento.nome}",
      content: Column(
        children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Time ", style: TextStyle(fontWeight: FontWeight.bold),),
            evento.horas == null? Text("00:00"): Text("${evento.horas}")
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Description", style: TextStyle(fontWeight: FontWeight.bold),),
            SingleChildScrollView(
              child: evento.descricao == null? Text("Without description"):Text("${evento.descricao}"),
            )
            
            
          ],
        ),
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             IconButton(
               icon: Icon(Icons.delete_forever,color:Colors.grey[400]),
               onPressed: () {
                 //apaga evento
                 deleteEvent(this.number, evento);
                 setState(() {
                  _events[evento.getDateTime()].remove(evento);
                 });
                 Navigator.pop(context);
               },
             )
           ],
         )
        


        ],
      ),
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
    _criarEvento(context) {
    String nome;
    String descricao;
    String horas;
    String date;
    DateTime dt;
    var controller = new MaskedTextController(mask: '00:00');
    
    
    final _formKey = GlobalKey<FormState>();
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      image: Image.asset('assets/calendar.png',scale: 5,),
      title: "Create an event",
      content: Column(
        children: <Widget>[
          Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[  
          TextFormField(
            onSaved: (nomezito) {
              nome = nomezito;
            },
            maxLength: 20,
            cursorColor: Colors.black,
            autofocus: false,
            initialValue: '',
                  validator: (val) {
            if(val.isEmpty) return "Please enter the name";
              },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(12.0))
              ),
               enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              icon: Icon(Icons.title,color: Colors.grey,),
              hintText: "Name",
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            
          ),
          TextFormField(
            onSaved: (desc) {
              descricao = desc;
            },
            keyboardType: TextInputType.multiline,
            maxLines: null,
            maxLength: 150,
            cursorColor: Colors.black,
            autofocus: false,
            initialValue: '',
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(12.0))
              ),
               enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              icon: Icon(Icons.description,color: Colors.grey,),
              hintText: "Description",
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            
          ),
          TextFormField(
            controller: controller,
            onSaved: (value) {
               if(value.isNotEmpty){
                String horitas = value.toString().substring(0,2);
                horitas += ':';
                horitas += value.toString().substring(3,5);
                horas = horitas;
               } else horas = "09:00";

            },
            cursorColor: Colors.black,
            keyboardType: TextInputType.number,
            autofocus: false,
            validator: (val) {
             
              if(val.isNotEmpty) {
                if(val.length < 5) return "Please enter all the numbers";
                int horas = int.parse(val.substring(0,2));
                int minutos = int.parse(val.substring(3,5));
                if(horas > 24 || minutos > 60) 
                  return "Please enter a valid format!";
                  date = _calendarController.selectedDay.toString().substring(0,10);
                  String y = date.substring(0,4);
                  String m = date.substring(5,7);
                  String d = date.substring(8,10);
                  dt = new DateTime(int.parse(y),int.parse(m),int.parse(d));
                  print(date);
                  List<Event> listaDoDia = _events[dt];
                  //print("TAMANHO ${listaDoDia.length}");
                  if(listaDoDia != null)
                    for(int i = 0 ; i <listaDoDia.length ; i++) {
                      print(listaDoDia[i].horas);
                      if(listaDoDia[i].horas == val) return "Time already picked";
                    }
              }
            },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(12.0))
              ),
               enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              icon: Icon(Icons.watch,color: Colors.grey,),
              hintText: "Time (hh:mm)",
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),  
          ),
          ]),
      ),
    
        ],
      ),
      buttons: [
        DialogButton( 
          height: 35,
          child: Text("Create",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () async {
            // aqui cria o evento
            date = _calendarController.selectedDay.toString().substring(0,10);
            String y = date.substring(0,4);
            String m = date.substring(5,7);
            String d = date.substring(8,10);
            dt = new DateTime(int.parse(y),int.parse(m),int.parse(d));
           // dt = new DateTime(year)
            if(_formKey.currentState.validate()){
              _formKey.currentState.save();
              Event ev = new Event("COSTUM", nome,descricao: descricao,dia: date,horas: horas);
              addEvent(this.number, date, descricao, nome, horas); //adiciona na fb
              if(_events[dt] == null) {
                //ainda nao ha eventos neste dia
                _events[dt] = new List<Event>();
                _events[dt].add(ev);
              } else _events[dt].add(ev);
              setState(() {
                
              });
              return Navigator.pop(context);
            }
          } ,
          width:120,
          color: Colors.green,
        ),
          DialogButton( 
          height: 35,
          child: Text("Cancel",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () {
            return Navigator.pop(context);
          } ,
          width:120,
          color: Colors.grey,
        ),
      ]
    ).show();
  }

//

}
