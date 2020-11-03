import 'dart:convert' as convert;

import 'package:carros/util/prefs.dart';

class Usuario {

  String login;
  String nome;
  String email;
  String token;
  String urlFoto;
  List<String> roles;

  Usuario(
      {this.login,
        this.nome,
        this.email,
        this.urlFoto,
        this.token,
        this.roles});

  Usuario.fromJson(Map<String, dynamic> map):
    login = map["login"],
    nome = map["nome"],
    email = map["email"],
    urlFoto = map["urlFoto"],
    token = map["token"],
    roles = map["roles"] != null ? map["roles"].map<String>( (role) => role.toString() ).toList() : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["login"] = this.login;
    data["nome"] = this.nome;
    data["email"] = this.email;
    data["urlFoto"] = this.urlFoto;
    data["token"] = this.token;
    data["roles"] = this.roles;

    return data;
  }

  void save() {
    Map map = toJson();
    String json = convert.json.encode(map);
    Prefs.setString("user.prefs", json);
  }

  static Future<Usuario> get() async {

    String user = await Prefs.getString("user.prefs");
    if (user.isEmpty) {
      return null;
    }

    Map userMap = convert.json.decode(user);

    return Usuario.fromJson(userMap);
  }

  static void clear() {
    Prefs.setString("user.prefs", "");
  }

  @override
  String toString() {
    return 'Usuario{login: $login, nome: $nome, email: $email}';
  }


}