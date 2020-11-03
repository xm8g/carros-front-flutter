import 'dart:async';

import 'package:carros/pages/carros/carro.dart';
import 'package:carros/util/sql/base-dao.dart';
import 'package:carros/util/sql/db-helper.dart';
import 'package:sqflite/sqflite.dart';

// Data Access Object
class CarroDAO extends BaseDAO<Carro> {

  @override
  String get tableName => "carro";

  @override
  Carro fromMap(Map<String, dynamic> map) {

    return Carro.fromJson(map);
  }

  Future<List<Carro>> findAllByTipo(String tipo) async {

    return query('select * from carro where tipo =? ',[tipo]);
  }


}
