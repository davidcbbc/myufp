import 'package:firebase_database/firebase_database.dart';




//usado para fazer pedidos ao firestore realtime database
//https://myufp-94b7d.firebaseio.com/
//myufp
//TODO Implementar binary search

 //var referencia = FirebaseDatabase.instance.reference();

Future<bool> userNovo(String numeroUser) async {
  // Retorna null se nao existe utilizador , false se e antigo e true se e novo.
  var referencia = FirebaseDatabase.instance.reference().child('users');
    DataSnapshot snapshot = await referencia.once();
    bool flag ;
    List users = snapshot.value;
    users.forEach((numero)  {
        Map userInfo = numero;
        userInfo.forEach((numero, info) {
          if(numero == numeroUser)
            if(info['isNew'].toString() == 'true')
              flag =  true;
            else flag = false;
        });
   });  
        return flag;
}