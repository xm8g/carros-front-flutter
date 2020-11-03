import 'dart:async';

import 'package:carros/firebase/firebase_service.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/main.dart';
import 'package:carros/pages/carros/carros_listview.dart';
import 'package:carros/pages/favoritos/favorito_service.dart';
import 'package:carros/pages/favoritos/favoritos_bloc.dart';
import 'package:carros/util/TextError.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritosPage extends StatefulWidget {
  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage>
    with AutomaticKeepAliveClientMixin<FavoritosPage> {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

//    FavoritosBloc favoritosBloc =
//        Provider.of<FavoritosBloc>(context, listen: false);
//    favoritosBloc.loadCarros();
  }

//  @override
//  Widget build(BuildContext context) {
//    super.build(context); //indispensável para manter o keepalive
//    FavoritosBloc favoritosBloc = Provider.of<FavoritosBloc>(context, listen: false);
//    return StreamBuilder(
//        stream: favoritosBloc.stream,
//        builder: (context, snapshot) {
//          if (snapshot.hasError) {
//            var e = snapshot.error;
//            return TextError("Não foi possível buscar os carros $e");
//          }
//          if (!snapshot.hasData) {
//            return Center(child: CircularProgressIndicator());
//          }
//
//          List<Carro> carros = snapshot.data;
//
//          return RefreshIndicator(
//              onRefresh: _onRefresh, child: CarrosListView(carros));
//        });
//  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //indispensável para manter o keepalive

    return Container(
        padding: EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
            stream: FavoritoService().getCarrosFirebase(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                var e = snapshot.error;
                return TextError("Não foi possível buscar os carros $e");
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              List<Carro> carros =
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return Carro.fromJson(document.data);
              }).toList();

              return CarrosListView(carros);
            }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() {
    FavoritosBloc favoritosBloc =
        Provider.of<FavoritosBloc>(context, listen: false);
    return favoritosBloc.loadCarros();
  }
}
