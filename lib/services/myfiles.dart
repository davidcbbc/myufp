import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}


Future<File>  _localFile(String fileName) async {
  final path = await _localPath;
  return File('$path/$fileName');
}


Future<File> writeTokenTxt(String token,String username, String password, String fileName, String licenciatura) async {
  //escreve num ficheiro em formato json
  final file = await _localFile(fileName);
  return file.writeAsString(
    "{\n\"username\": \"$username\",\n\"password\": \"$password\",\n\"token\": \"$token\",\n\"licenciatura\": \"$licenciatura\"\n}"
  );
}

Future<String> writeLoggedTxt(bool logged) async{
  // funcao que permite escrever no ficheiro txt se quer estar sempre logado ou nao
  final file = await _localFile("logged.txt");
  file.writeAsString(
    "{\n\"logged\": \"$logged\"\n}"
    );
  String log = await readFile("logged.txt");
  print(log);
  return null;
}

Future<bool> isKeepLogged() async{
  String rawText = await readFile("logged.txt");
  try{
     Map mapa = json.decode(rawText);
     return mapa['logged'].toString() == 'true'? true : false;
  }on Exception {
    return false;
  }
  
}

Future<File> appendFile(String token, String fileName) async {
  final file = await _localFile(fileName);
  return null;
}


Future<String> readFile(String fileName) async {
  try {
    final file = await _localFile(fileName);
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    // If encountering an error, return 0.
    return "FILE_ERROR1";
  }
}


String getUsername(){

  var raw = readFile("token.txt");
  raw.then((rawText) {
    Map mapa = json.decode(rawText);
    return mapa['username'].toString();
  });
}

String getToken(){
    var raw = readFile("token.txt");
  raw.then((rawText) {
    Map mapa = json.decode(rawText);
    return mapa['token'].toString();
  });

}

bool isAlreadyLogged() {
  
  var aux = isKeepLogged();
  aux.then((valor) {
    print("O VALOR A SERIO $valor");
    return valor;
  });
}