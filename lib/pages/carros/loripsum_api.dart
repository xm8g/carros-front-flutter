
import 'dart:async';

import 'package:http/http.dart' as http;

class LoripsumBloc { //Business Logic Component

  final _streamController = StreamController<String>();

  static String lorim; //cache pra não ter q chamar o serviço toda hora

  Stream<String> get stream => _streamController.stream;

  void fetch() async {
    try {
      String s  = lorim ?? await LoripsumApi.getLoripsum();

      lorim = s;

      _streamController.add(s);
    } catch(e) {
      _streamController.addError(e);
    }
  }


  void dispose() {

    _streamController.close();
  }
}

class LoripsumApi {

  static Future<String> getLoripsum() async {

    var url = "https://loripsum.net/api";

    var response = await http.get(url);

    String text = response.body;

    text = text.replaceAll("<p>", "");
    text = text.replaceAll("</p>", "");

    return text;
  }
}