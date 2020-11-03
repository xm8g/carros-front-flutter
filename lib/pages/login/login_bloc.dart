import 'dart:async';

import 'package:carros/firebase/firebase_service.dart';
import 'package:carros/pages/login/login_api.dart';
import 'package:carros/pages/login/usuario.dart';

import '../api_response.dart';

class LoginBloc {

  final _streamController = StreamController<bool>();

  get stream => _streamController.stream;

  Future<ApiResponse<Usuario>> login(String login, String senha) async {

    _streamController.add(true);

    ApiResponse response = await LoginApi.login(login, senha);

    _streamController.add(false);

    return response;
  }

  Future<ApiResponse> loginFirebase(String login, String senha) async {

    _streamController.add(true);

    ApiResponse response = await FirebaseService().login(login, senha);

    _streamController.add(false);

    return response;
  }

  void dispose() {
    _streamController.close();
  }

}