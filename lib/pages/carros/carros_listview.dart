import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carros/pages/carros/carro_page.dart';
import 'package:carros/pages/carros/carros_bloc.dart';
import 'package:carros/util/TextError.dart';
import 'package:carros/util/nav.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'carro.dart';
import 'carros_api.dart';

class CarrosListView extends StatelessWidget {

  List<Carro> carros;

  final bool search;

  final ScrollController scrollController;

  final bool showProgress;

  CarrosListView(this.carros, {this.search = false, this.scrollController, this.showProgress = false});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(10),
      child: ListView.builder(
          controller: scrollController,
          itemCount: showProgress ? carros.length + 1 : carros.length,
          itemBuilder: (context, index) {
            if(showProgress && carros.length == index) {
              return Container(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator()
                ),
              );
            }

            Carro c = carros[index];

            return Card(
              color: Colors.grey[100],
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(child: CachedNetworkImage(imageUrl: c.urlFoto, width: 200)),
                    Text(c.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 22)),
                    Text("Detalhes", style: TextStyle(fontSize: 16)),
                    ButtonTheme(
                      child: ButtonBar(
                        children: <Widget>[
                          FlatButton(
                              child: const Text('DETALHES'),
                              onPressed: () => _onClickCarro(context, c)),
                          FlatButton(
                            child: const Text('SHARE'),
                            onPressed: () =>  _onClickShare(context, c)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }

  _onClickCarro(context, Carro c) {
    if (search) {
      Navigator.pop(context, c);
    } else {
      push(context, CarroPage(c));
    }
  }

  _onClickShare(BuildContext context, Carro c) {
    print("Share ${c.nome}");
    Share.share(c.urlFoto);
  }

}
