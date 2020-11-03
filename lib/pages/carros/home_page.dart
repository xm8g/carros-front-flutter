import 'package:carros/pages/carros/carro-form-page.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carros_api.dart';
import 'package:carros/pages/carros/carros_listview.dart';
import 'package:carros/pages/carros/carros_page.dart';
import 'package:carros/pages/favoritos/favoritos_page.dart';
import 'package:carros/search/carros_search.dart';
import 'package:carros/util/alert.dart';
import 'package:carros/util/nav.dart';
import 'package:carros/util/prefs.dart';
import 'package:carros/widgets/drawer_list.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin<HomePage> {
  //carrega em cache os carros. Evita chamar o serviço toda hora

  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: 5, vsync: this);

    Future<int> future = Prefs.getInt("tabIdx");
    future.then((int index) {
      _tabController.index = index;
    });

    _tabController.addListener(() {
      Prefs.setInt("tabIdx", _tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Carros"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: _onClickSearch
            )
          ],
          bottom: TabBar(controller: _tabController, tabs: <Widget>[
            Tab(text: "Clássicos", icon: Icon(Icons.directions_car)),
            Tab(text: "Luxuosos", icon: Icon(Icons.directions_car)),
            Tab(text: "Esportivos", icon: Icon(Icons.directions_car)),
            Tab(text: "Todos", icon: Icon(Icons.all_inclusive)),
            Tab(text: "Favoritos", icon: Icon(Icons.favorite))
          ]),
        ),
        //body: _bodyComRow(),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            CarrosPage(TipoCarro.classicos, page: -1),
            CarrosPage(TipoCarro.luxo, page: -1),
            CarrosPage(TipoCarro.esportivos, page: -1),
            CarrosPage(TipoCarro.classicos, page: 0),
            FavoritosPage()
          ],
        ),
        drawer: DrawerList(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _onClickAddCarro,
        ),
    ); //menu superior esquerdo
  }

  void _onClickAddCarro() {
    push(context, CarroFormPage());
  }

  void _onClickSearch() async {
    final carro = await showSearch(context: context, delegate: CarrosSearch());
    if (carro != null) {
      alert(context, carro.nome);
    }
  }
}
