import 'dart:convert';

import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/login/usuario.dart';
import 'package:http/http.dart' as http;

class LoginApi {
  static Future<ApiResponse<Usuario>> login(String login, String senha) async {
    try {
      var url = "https://carros-springboot.herokuapp.com/api/v1/login";

      Map<String, String> headers = {"Content-Type": "application/json"};

      Map params = {"username": login, "password": senha};

      String s = json.encode(params);

      var response = await http.post(url, body: s, headers: headers);

      Map mapResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        Usuario usuario = Usuario.fromJson(mapResponse);

        usuario.save();

        return ApiResponse.ok(result: usuario);
      }

      return ApiResponse.error(msg: mapResponse["error"]);
    } catch (error, exception) {
      print("Erro no login $error > $exception");

      return ApiResponse.error(msg: "Não foi possível fazer o login.");
    }
  }
}
