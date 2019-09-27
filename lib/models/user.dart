class User {
  String username = '';
  String password = '';
  String token = '';
  String licenciatura = '';

  User({this.username, this.password});
  User.authenticatedUser({this.username, this.token});

  factory User.fromJson(Map<String, dynamic> json, String number) => new User.authenticatedUser (
    username: number,
    token: json['message']
  );

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = username;
    map["password"] = password;
    return map;
  }

  Map toMapToken() {
    var map = Map<String,String>();
    map = {
      "token" : "$token"
    };
    return map;
  }
}