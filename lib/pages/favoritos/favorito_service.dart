import 'package:carros/firebase/firebase_service.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/favoritos/carro-dao.dart';
import 'package:carros/pages/favoritos/favorito.dart';
import 'package:carros/pages/favoritos/favorito_dao.dart';
import 'package:carros/pages/favoritos/favoritos_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class FavoritoService {

  getCarrosFirebase() => _carros.snapshots();

  CollectionReference get _carros {
    String uid = firebaseUserId;
    DocumentReference refUser = Firestore.instance.collection("users").document(uid);

    return refUser.collection("carros");
  }


  static Future<bool> favoritar(Carro c, BuildContext context) async {
    Favorito f = Favorito.fromCarro(c);

    final dao = FavoritoDAO();

    final bool exists = await dao.exists(c.id);
    
    if(exists) {
      dao.delete(c.id);
      Provider.of<FavoritosBloc>(context, listen: false).loadCarros();
      return false;
    } else {
      dao.save(f);
      Provider.of<FavoritosBloc>(context, listen: false).loadCarros();
      return true;
    }

  }

  Future<bool> favoritarFirebase(Carro c) async {

    String uid = firebaseUserId;
    DocumentReference refUser = Firestore.instance.collection("users").document(uid);

    var document = _carros.document("${c.id}");
    var documentSnapshot = await document.get();

    if(!documentSnapshot.exists) {
      print("${c.nome} adicionado aos favoritos");
      document.setData(c.toMap());
      return true;
    } else {
      print("${c.nome} removido dos favoritos");
      document.delete();
      return false;
    }


  }

  static Future<List<Carro>> getCarros() async {

    List<Carro> carrosFavoritos = await CarroDAO().query("select * from carro c, favorito f where c.id = f.id");

    return carrosFavoritos;
  }

  static Future<bool> isFavorito(Carro c) async {

    final dao = FavoritoDAO();

    bool exists = await dao.exists(c.id);

    return exists;
  }

  Future<bool> exists(Carro c) async {

    var document = _carros.document("${c.id}");

    var documentSnapshot = await document.get();

    return await documentSnapshot.exists;
  }

}