import 'dart:async';

import 'package:carros/pages/carros/carro_page.dart';
import 'package:carros/pages/carros/carros_bloc.dart';
import 'package:carros/pages/carros/carros_listview.dart';
import 'package:carros/util/TextError.dart';
import 'package:carros/util/event_bus.dart';
import 'package:carros/util/nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'carro.dart';
import 'carros_api.dart';

class CarrosPage extends StatefulWidget {
  String tipoCarro;

  int page = 0;

  CarrosPage(this.tipoCarro, {this.page});

  @override
  _CarrosPageState createState() => _CarrosPageState();
}

class _CarrosPageState extends State<CarrosPage>
    with AutomaticKeepAliveClientMixin<CarrosPage> {
  List<Carro> carros;

  StreamSubscription<Event> subscription;

  String get tipo => widget.tipoCarro;

  final _bloc = CarrosBloc();

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bloc.loadCarros(tipo);

    //Fim do Scroll, carrega mais
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && widget.page > -1) {
        widget.page++;
        print(widget.page);
        _bloc.fetchMore(widget.page);
      }
    });

    //Escutando uma stream
    final eventBus = EventBus.get(context);
    subscription = eventBus.stream.listen((Event e) {
      print("Event $e");
      CarroEvent carroEvent = e;
      if (carroEvent.tipo == tipo) {
        _bloc.loadCarros(tipo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //indispensável para manter o keepalive

    List<Carro> carros = [];

    return StreamBuilder(
        stream: _bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            var e = snapshot.error;
            return TextError("Não foi possível buscar os carros $e");
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Carro> carrosPorTipo = snapshot.data;
          carros.addAll(carrosPorTipo);

          bool showProgress = widget.page > -1 && widget.page < 2;
          print('showprogrews ${showProgress}');
          return RefreshIndicator(
           onRefresh: _onRefresh,
           child: CarrosListView(carros, scrollController: _scrollController, showProgress: showProgress)
          );
        });
  }





  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    subscription.cancel();
  }

  Future<void> _onRefresh() {
    return _bloc.loadCarros(tipo);
  }
}
