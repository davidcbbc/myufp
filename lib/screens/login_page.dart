import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:myufp/models/user.dart';
import 'package:myufp/mist/progress_dial.dart' as pro;
import 'package:myufp/screens/secretary.dart';
import 'package:myufp/services/api.dart';
import 'package:myufp/services/myfiles.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _user = new User();   //user criado caso as credenciais estejam compridas no form
  bool checked = false;
  bool refreshed = false;
  //bool refreshed = false;


  
  @override
  Widget build(BuildContext context) {

      
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 100.0,
        child: Image.asset('assets/logotipo.png'),
      ),
    );

    final student_number = TextFormField(
      keyboardType: TextInputType.number,
      cursorColor: Colors.black,
      autofocus: false,
      initialValue: '',
      validator: (val) {
        if(val.isEmpty) return "Please enter your student number !";
      },
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.all(Radius.circular(32.0))
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        hintText: 'Student Number',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onSaved: (value) {
        print("STUDENT NUMBER $value");
        _user.username = value;
        },
    );


    final password = TextFormField(
      autofocus: false,
      cursorColor: Colors.black,
      initialValue: '',
      obscureText: true,
      validator: (val) {
        if(val.isEmpty) return "Please enter your password !";
      },
      decoration: InputDecoration(        
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.all(Radius.circular(32.0))
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onSaved: (value) {
        print("PASSWORD $value");
        _user.password = value;
        },
    );


   final keepLogin = Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Checkbox(
        activeColor: Colors.green,
        checkColor: Colors.white,
        onChanged: (bool value) {
          setState(() {
            checked = value;
          });
        },
        value: checked,

      ),
      Text(
      "Keep me logged in",
      style: TextStyle(color: Colors.black54),
      textAlign: TextAlign.center,
    )
        ],
      )
    );

    final formAux = Builder(
      //contem o login e a password
      builder: (context) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            student_number,
            SizedBox(height: 15.0,),
            password,
            keepLogin],
        ),
      ),
    );

 

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: ProgressButton(
        animate: true,
        defaultWidget: const Text('Login', style: TextStyle(color: Colors.white)),
        progressWidget: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        borderRadius: 24,
        width: 114,
        onPressed: () async{
          if(_formKey.currentState.validate()) {
            _formKey.currentState.save(); //salva as credenciais
            new Future.delayed(const Duration(seconds: 1), () => "1");   
            try {
              //  Check da conexão ao servidor da UFP.
              final result = await InternetAddress.lookup('siws.ufp.pt');
              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                // Bem sucedido.
                User loggedInUser = await loginUser(body: _user.toMap());
                User validUser = new User.authenticatedUser(username: loggedInUser.username, token: loggedInUser.token);
                writeLoggedTxt(checked);
                validUser.licenciatura = await licenciatura(validUser.toMapToken());
                // Escreve token em ficheiro para dar refresh mais tarde
                writeTokenTxt(validUser.token,_user.username,_user.password,"token.txt",validUser.licenciatura);
                print(validUser.token);
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new HomePage(validUser)));
              }
            }on SocketException {
              _alertaErroConnection(context);
            }on Exception{
              _alertaErroLogin(context);
            }
          }
        },
        color: Colors.green,
      ),
    );

    final textLabel = 
    Text(
      "Made with love by NIUFP",
      style: TextStyle(color: Colors.black54),
      textAlign: TextAlign.center,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            formAux,
            SizedBox(height: 20.0),
            loginButton,
            textLabel,
            Center(
              child: InkWell(
                onTap:() async{
                  _launchInBrowser("https://www.freeprivacypolicy.com/privacy/view/7dc3d9cebc16eff508cbf7efc9e1af0f");
                } ,
                child: Text('By proceeding you agree with our privacy policy' ,style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[400], decoration: TextDecoration.underline),),
              ),
            )
          ],
        ),
      ),
    );
  }

Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  
  _alertaErroLogin(context) {
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      type: AlertType.warning,
      title: "Ups!",
      desc: "Please check your UFP credentials ",
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

    _alertaErroConnection(context) {
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      type: AlertType.error,
      title: "Ups!",
      desc: "Please check your connection ",
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

}
