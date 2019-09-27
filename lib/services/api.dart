import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myufp/models/user.dart';
import 'package:myufp/screens/assiduity.dart';
import 'package:myufp/screens/atm.dart';
import 'package:myufp/screens/grades.dart';
import 'package:myufp/screens/menu.dart';
import 'package:myufp/screens/schedule.dart';
import 'package:myufp/screens/secretary.dart';
import 'package:myufp/screens/thecalendar.dart';
import 'myfiles.dart';

const url = 'https://siws.ufp.pt/api/v1/';


Map credenciais;

Future<User> loginUser({Map body}) async{
    return  http.post(url + 'login', body: body).then((http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on loginUser");
    }
    return User.fromJson(json.decode(response.body),body['username']);
  } );

}


Future<Map<String,String>> refreshToken() async {
  // Devolve em string um token novo válido quando antigo expira.
  return readFile("token.txt")
  .then((rawText) {
    print("Mudar para um token válido ...");
    Map mapa = json.decode(rawText);
    Map<String,String> credenciais = new Map<String,String>();
    credenciais['username'] = mapa['username'].toString();
    credenciais['password'] = mapa['password'].toString();
    credenciais['licenciatura'] = mapa['licenciatura'].toString();
    return loginUser(body: credenciais)
    .then((usuario) {
      print("Novo token criado com sucesso.");
      var tokenValido = new Map<String,String>();
      tokenValido = {
        'token' : usuario.token
      };
      writeTokenTxt(usuario.token, credenciais['username'], credenciais['password'], "token.txt",credenciais['licenciatura']);
      return tokenValido;
    });
  });
}

Future<Atm> valores_atm({Map body}) async {
  // procura os valores de pagamento com um certo token
  return http.get(Uri.http('siws.ufp.pt', '/api/v1/atm', body)).then(
    (http.Response response) {
    final int statusCode = response.statusCode;
    print(statusCode);
    if( statusCode == 404) return new Atm.notValid(message: "There are no payment values.",validated: false,);               //sem valores de pagamento
    if( statusCode == 401) {
      // token esta outdated , vamos refrescar 
      return refreshToken()
      .then((valorToken) {
          try {
            return valores_atm(body: valorToken)
            .then((valorAtm) {
              return valorAtm;
            });
          } on Exception {
            rethrow;
          }
        });
    }
     if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on valores_atm");
    }
    return Atm.fromJson(json.decode(response.body));
  });
}


Future<Assiduity> valores_assiduidade(Map body) async {
   // procura os valores de assiduidade com um certo token
  return http.get(Uri.http('siws.ufp.pt', '/api/v1/assiduity', body)).then(
    (http.Response response) {
    final int statusCode = response.statusCode;
    //print("status code assiduity $statusCode");
    if(statusCode == 404) return new Assiduity.notValidated("No assiduity values.",false);
    if( statusCode == 401) {
      // token esta outdated , vamos refrescar 
      return refreshToken()
      .then((valorToken) {
          try {
            return valores_assiduidade(valorToken)
            .then((valorAssiduity) {
              return valorAssiduity;
            });
          } on Exception {
            rethrow;
          }
        });
    }
    if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on valores_assiduidade");
    }
    return new Assiduity.fromJson(json.decode(response.body));
  });
}


Future<Grades> valores_notas(Map body, String type) async {
    return http.get(Uri.http('siws.ufp.pt', '/api/v1/grades/$type', body)).then(
    (http.Response response) {
    final int statusCode = response.statusCode;
    print("status code notas $statusCode");
    if(statusCode == 404) return new Grades.notValidated("No grade values.",false);
    if( statusCode == 401) {
      // token esta outdated , vamos refrescar 
      return refreshToken()
      .then((valorToken) {
          try {
            return valores_notas(valorToken,type)
            .then((valorNotas) {
              return valorNotas;
            });
          } on Exception {
            rethrow;
          }
        });
    }
    if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on valores_notas");
    }
    return new Grades.fromJson(json.decode(response.body), type);
  });
}


Future<String> licenciatura(Map body) async {
  // Retorna em string a licenciatura
    return http.get(Uri.http('siws.ufp.pt', '/api/v1/grades/final', body)).then(
    (http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on licenciatura");
    }
    Map<String, dynamic> arr = json.decode(response.body);
    Map hey = arr['message'];
    hey.forEach((tipo, _) {
      print(tipo.toString());
      print("1");
      if(tipo.toString() == "Licenciatura") {
        hey = hey[tipo];
        print("${hey[tipo].toString()}");
      }

    });
    
    String licenciatura;
    if(hey == null) {
      return "hey";
    }
    hey.forEach((key, _) {
      licenciatura = key.toString();
      print("2");
    });
    print("Licenciatura: $licenciatura");
    return licenciatura;
  });
}


Future<Secretary> valores_queue() async {
    return http.get(Uri.http('siws.ufp.pt', '/api/v1/queue')).then(
    (http.Response response) {
    final int statusCode = response.statusCode;
    print("status code queue $statusCode");
    if(statusCode == 404) return new Secretary.notValidated(false);
    if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on valores_queue");
    }
    return new Secretary.fromJson(json.decode(response.body));
  });
}


Future<TheCalendar> valores_calendario(Map body) async {
    return http.get(Uri.http('siws.ufp.pt', '/api/v1/exams', body)).then(
    (http.Response response) {
    final int statusCode = response.statusCode;
    print("status code calendario $statusCode");
    if(statusCode == 404) return new TheCalendar.notValidated(false);
    if( statusCode == 401) {
      // token esta outdated , vamos refrescar 
      return refreshToken()
      .then((valorToken) {
          try {
            return valores_calendario(valorToken)
            .then((valorCalendario) {
              return valorCalendario;
            });
          } on Exception {
            rethrow;
          }
        });
    }
    if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on valores_calendario");
    }
    return new TheCalendar.fromJson(json.decode(response.body));
  });
}



Future<Menu> valoresMenu() async {
    return http.get(Uri.http('siws.ufp.pt', '/api/v1/menu/en')).then(
    (http.Response response) {
    final int statusCode = response.statusCode;
    print("status code menu $statusCode");
    if(statusCode == 404) return new Menu.notValidated(false);
    if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on valoresMenu");
    }
    return new Menu.fromJson(json.decode(response.body));
  });
}


Future<Schedule> valoresHorario(Map body) async {
    return http.get(Uri.http('siws.ufp.pt', '/api/v1/schedule', body)).then(
    (http.Response response) {
    final int statusCode = response.statusCode;
    print("status code horario $statusCode");
    if(statusCode == 404) return new Schedule.notValidated(false);
    if( statusCode == 401) {
      // token esta outdated , vamos refrescar 
      return refreshToken()
      .then((valorToken) {
          try {
            return valoresHorario(valorToken)
            .then((valorHorario) {
              return valorHorario;
            });
          } on Exception {
            rethrow;
          }
        });
    }
    if (statusCode < 200 || statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data on valores_calendario");
    }
    return new Schedule.fromJson(json.decode(response.body));
  });

  
}




