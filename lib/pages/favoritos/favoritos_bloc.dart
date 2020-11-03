import 'dart:async';

import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/favoritos/carro-dao.dart';
import 'package:carros/pages/favoritos/favorito_service.dart';
import 'package:carros/util/network.dart';


class FavoritosBloc { //Business Logic Component

  final _streamController = StreamController<List<Carro>>();

  Stream<List<Carro>> get stream => _streamController.stream;

  Future<List<Carro>> loadCarros() async {
    try {

      List<Carro> carros = await FavoritoService.getCarros();

      _streamController.add(carros);

      return carros;
    } catch(e) {
      print(e);
      _streamController.addError(e);
    }
  }


  void dispose() {

    _streamController.close();
  }
}
