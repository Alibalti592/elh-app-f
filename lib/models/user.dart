import 'dart:convert' show json, base64, ascii;

class User {
  int? id;
  String? name;
  String? username;
  User({this.id, this.name, this.username});

  User.initial() {
    id = 0;
    name = '';
    username = '';
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
  }

  User.fromJwt(String jwt) {
    String token = json.decode(jwt)['token'];
    var userInfoFromJwt = json.decode(
        ascii.decode(
            base64.decode(base64.normalize(token.split(".")[1]))
        )
    );

    id = userInfoFromJwt['id'];
    name = userInfoFromJwt['name'];
    username = userInfoFromJwt['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    return data;
  }
}