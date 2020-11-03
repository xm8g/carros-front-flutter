import 'package:cached_network_image/cached_network_image.dart';
import 'package:carros/pages/carros/carro-form-page.dart';
import 'package:carros/pages/carros/carros_api.dart';
import 'package:carros/pages/carros/loripsum_api.dart';
import 'package:carros/pages/carros/mapa_page.dart';
import 'package:carros/pages/carros/video_page.dart';
import 'package:carros/pages/favoritos/favorito_service.dart';
import 'package:carros/util/alert.dart';
import 'package:carros/util/event_bus.dart';
import 'package:carros/util/nav.dart';
import 'package:carros/util/text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_response.dart';
import 'carro.dart';

class CarroPage extends StatefulWidget {
  Carro carro;

  CarroPage(this.carro);

  @override
  _CarroPageState createState() => _CarroPageState();
}

class _CarroPageState extends State<CarroPage> {
  final _loripsumBloc = LoripsumBloc();

  Color color = Colors.grey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

//    FavoritoService.isFavorito(widget.carro).then((favorito) {
//      setState(() {
//        color = favorito ? Colors.red : Colors.grey;
//      });
//    });

    FavoritoService().exists(widget.carro).then((b) {
      if (b) {
        setState(() {
          color = b ? Colors.red : Colors.grey;
        });
      }
    });

    _loripsumBloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.carro.nome), actions: <Widget>[
          IconButton(
              icon: Icon(Icons.place),
              onPressed: () {
                _onClickMapa(context);
              }),
          IconButton(
              icon: Icon(Icons.videocam),
              onPressed: () {
                _onClickVideo(context);
              }),
          PopupMenuButton<String>(
              onSelected: (String value) => _onClickPopupMenu(value),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(value: "Editar", child: Text("Editar")),
                  PopupMenuItem(value: "Deletar", child: Text("Deletar")),
                  PopupMenuItem(value: "Share", child: Text("Share"))
                ];
              })
        ]),
        body: _body());
  }

  _body() {
    return Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            CachedNetworkImage(imageUrl: widget.carro.urlFoto),
            _bloco1(),
            Divider(),
            _bloco2()
          ],
        ));
  }

  Row _bloco1() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              text(widget.carro.nome, fontSize: 20, bold: true),
              text(widget.carro.tipo, fontSize: 16, bold: false)
            ],
          ),
          Row(children: <Widget>[
            IconButton(
                icon: Icon(Icons.favorite),
                color: color,
                onPressed: _onClickFavoritoFirebase),
            IconButton(icon: Icon(Icons.share), onPressed: _onClickShare),
          ])
        ]);
  }

  void _onClickMapa(BuildContext context) {
    if (widget.carro.latitude != null && widget.carro.longitude != null) {
      //launch(widget.carro.urlVideo);
      push(context, MapaPage(widget.carro));
    } else {
      alert(context, "Carro sem referência de latidude/longitude!");
    }
  }

  void _onClickVideo(BuildContext context) {
    if (widget.carro.urlVideo != null && widget.carro.urlVideo.isNotEmpty) {
      //launch(widget.carro.urlVideo);
      push(context, VideoPage(widget.carro));
    } else {
      alert(context, "Carro sem vídeo!");
    }
  }

  _onClickPopupMenu(String value) {
    switch (value) {
      case "Editar":
        push(context, CarroFormPage(carro: widget.carro));
        break;
      case "Deletar":
        deletar();
        break;
      case "Share":
        print("Share");
        break;
    }
  }

  void _onClickFavorito() async {
    bool favoritou = await FavoritoService.favoritar(widget.carro, context);

    setState(() {
      color = favoritou ? Colors.red : Colors.grey;
    });
  }
  void _onClickFavoritoFirebase() async {
    bool favoritou = await FavoritoService().favoritarFirebase(widget.carro);

    setState(() {
      color = favoritou ? Colors.red : Colors.grey;
    });
  }


  void _onClickShare() {}

  _bloco2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        text(widget.carro.descricao, fontSize: 14),
        SizedBox(height: 20),
        StreamBuilder<String>(
            stream: _loripsumBloc.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return text(snapshot.data, fontSize: 14);
            })
      ],
    );
  }

  void deletar() async {
    ApiResponse<bool> response = await CarrosApi.delete(widget.carro);

    if (response.ok) {
      alert(context, "Carro apagado com sucesso", callback: () {
        EventBus.get(context)
            .sendEvent(CarroEvent("carro_deletado", widget.carro.tipo));
        Navigator.pop(context); //volta pra Home após salvar
      });
    } else {
      alert(context, response.msg);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _loripsumBloc.dispose();
  }
}
