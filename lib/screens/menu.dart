import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myufp/services/api.dart';

/// Class que permite ver a janela de menu das cantinas
class Menu extends StatefulWidget {
  String cantina;
  String diaDaSemana;
  String comida;
  bool validated = true;
  List<Menu> listaComidas;

  Menu.init();
  Menu(this.cantina,this.diaDaSemana,this.comida);
  Menu.validated(this.listaComidas);
  Menu.notValidated(this.validated);
  factory Menu.fromJson(Map<String, dynamic> json) {
    // Serialiaze json data into @Menu class
    List<Menu> listaComidasAux = new List<Menu>();
    Map message = json['message'];
    message.forEach((bar , menuDoBar) {
      String cantinaAux = bar.toString();
      List menuzito = menuDoBar;
      //List diaSemana = menuDoBar['$bar'];
      for( int k = 0 ; k < menuzito.length ; k ++) {
        Map menuDoDia = menuzito[k];
        menuDoDia.forEach((diaSemana , arrayComidas) {
          String diaDaSemanaAux = diaSemana.toString();
          List diferentesComidas = arrayComidas;
          for( int comida = 0 ; comida < diferentesComidas.length ; comida++) {
            String comidaAux = diferentesComidas[comida].toString();
            Menu adicionarEste = Menu(cantinaAux,diaDaSemanaAux,comidaAux);
            listaComidasAux.add(adicionarEste);
          }
        });
      }   
    });
    return Menu.validated(listaComidasAux);
  }
  @override
  State<StatefulWidget> createState() => _MenuState(this.listaComidas, this.validated);
}


class _MenuState extends State<Menu> {
  List<Menu> listaMenus;
  bool refreshed = false;
  bool connected = true;
  bool validated;


  _MenuState(this.listaMenus,this.validated);

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

      Future<Menu> refreshValores() async{
        try {
        Menu valor = await valoresMenu();
          return valor;
        }on Exception catch(e) {
          print(e.toString());
         }
           return null;
      }
    

  Widget menus() {
    // Pick all the information in the List @listaComidas (Menu) and serialize it to Cards
    List<Widget> listaComidas = new List<Widget>();
    for (int i = 0 ; i < listaMenus.length ; i++) {
      listaComidas.add(
        Card(
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
                child: new Text("${listaMenus[i].diaDaSemana}", 
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18
                                    ),
                                  ),
              ),
              title: Text("${listaMenus[i].comida}", style: TextStyle(color: Colors.black , fontWeight: FontWeight.normal, fontSize: 15),),
              subtitle: Text("${listaMenus[i].cantina}" , style: TextStyle(fontSize: 12 , color: Colors.grey[500]),),
              trailing: new Icon(Icons.fastfood),
            ),
          ),
        )
      );
    }
    return new Column(
      children: listaComidas
    );
  }

  @override
  Widget build(BuildContext context) {
     if(refreshed == false) {
    var net = isConnected();
    net.then((isOn) {
    if(isOn) {
      var bode = refreshValores();
      bode.then((inst) {
        validated = inst.validated;
        this.listaMenus = inst.listaComidas;
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
      appBar: new AppBar(title: new Text("Menu"), backgroundColor: Colors.white),
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
  } else if(refreshed == false){
  return new Scaffold(
      appBar: new AppBar(title: new Text("Menu"), backgroundColor: Colors.white),
      body: new Center(
        child: new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)), 
      ),
    );
    } else return new Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
        backgroundColor: Colors.white,
      ),
      body: validated ?  ListView(
        children: <Widget>[
          menus()
        ],
      ) : Center(child: Text("There are no food menus at the moment", 
        style:TextStyle(fontSize: 20)))  
    );
  }

}