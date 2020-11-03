import 'package:carros/util/sql/base-dao.dart';

import 'favorito.dart';

class FavoritoDAO extends BaseDAO<Favorito> {

  @override
  Favorito fromMap(Map<String, dynamic> map) {
     return Favorito.fromMap(map);
  }

  @override
  String get tableName => "favorito";

}