import 'dart:io';

import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/upload_service.dart';
import 'package:carros/pages/favoritos/carro-dao.dart';
import 'package:carros/pages/login/usuario.dart';
import 'package:carros/util/http_helper.dart' as http;
import 'dart:convert' as convert;

class TipoCarro {
  static final String classicos = "classicos";
  static final String esportivos = "esportivos";
  static final String luxo = "luxo";
}

class CarrosApi {
  static Future<List<Carro>> getCarros(String tipo) async {

    var url =
        "https://carros-springboot.herokuapp.com/api/v1/carros/tipo/$tipo";

    var response = await http.get(url);

    List listResponse = convert.json.decode(response.body);

    List<Carro> carros =
    listResponse.map<Carro>((map) => Carro.fromJson(map)).toList();

    return carros;
  }

  static Future<List<Carro>> todosCarros() async {

    var url =
        "https://carros-springboot.herokuapp.com/api/v1/carros/";

    var response = await http.get(url);

    List listResponse = convert.json.decode(response.body);

    List<Carro> carros =
    listResponse.map<Carro>((map) => Carro.fromJson(map)).toList();

    return carros;
  }

  static Future<ApiResponse<bool>> save(Carro c, [File image]) async {

    if (image != null) {
      ApiResponse<String> response = await UploadService.upload(image);
      if (response.ok) {
        String urlFoto = response.result;
        c.urlFoto = urlFoto;
      } else {
        return ApiResponse.error(msg: "Não foi possível salvar o carro - ${response.msg}");
      }
    }

    var url = "https://carros-springboot.herokuapp.com/api/v1/carros";
    if (c.id != null) {
      url += "/${c.id}";
    }

    String json = c.toJson();

    var response = await (c.id == null
        ? http.post(url, body: json)
        : http.put(url, body: json));

    if (response.statusCode == 201 || response.statusCode == 200) {
      Map mapResponse = convert.json.decode(response.body);

      Carro carro = Carro.fromJson(mapResponse);

      print("Novo Carro ${carro.id}");

      return ApiResponse.ok(result: true);
    }
    if (response.body == null || response.body.isEmpty) {
      return ApiResponse.error(msg: "Não foi possível salvar o carro");
    }

    Map mapResponse = convert.json.decode(response.body);
    return ApiResponse.error(msg: mapResponse["error"]);
  }

  static delete(Carro c) async {
    try {

      var url = "https://carros-springboot.herokuapp.com/api/v2/carros/${c.id}";

      String json = c.toJson();

      var response = await http.delete(url);

      if (response.statusCode == 200) {
        return ApiResponse.ok(result: true);
      }
      return ApiResponse.error(msg: "Não foi possível apagar o carro!");
    } catch (e) {
      print(e);
      return ApiResponse.error(msg: "Não foi possível apagar o carro!");
    }
  }

  static Future<List<Carro>> search(String query) async {
    List<Carro> carros = await todosCarros();

    return carros.where((c) => c.nome.toUpperCase().contains(query.toUpperCase())).toList();
  }
}
