import 'dart:async';

import 'package:carros/pages/favoritos/carro-dao.dart';
import 'package:carros/util/network.dart';

import 'carro.dart';
import 'carros_api.dart';

class CarrosBloc { //Business Logic Component

  final _streamController = StreamController<List<Carro>>();

  Stream<List<Carro>> get stream => _streamController.stream;

  Future<List<Carro>> loadCarros(String tipo) async {
    try {

      bool networkOn = await isNetworkOn();

      if (!networkOn) {
        List<Carro> carros = await CarroDAO().findAllByTipo(tipo);
        _streamController.add(carros);

        return carros;
      }

      List<Carro> carros = await CarrosApi.getCarros(tipo);

      if (carros.isNotEmpty) {
        final dao = CarroDAO();
        carros.forEach((Carro c) => dao.save(c));
      }

      _streamController.add(carros);

      return carros;
    } catch(e) {
      print(e);
      _streamController.addError(e);
    }
  }

  Future<List<Carro>> fetchMore(int page) async {
    if (page == 0) {
      return loadCarros(TipoCarro.classicos);
    } else if (page == 1) {
      return loadCarros(TipoCarro.esportivos);
    } else if (page == 2) {
      return loadCarros(TipoCarro.luxo);
    }
    return [];
  }


  void dispose() {

   // _streamController.close();
  }
}
