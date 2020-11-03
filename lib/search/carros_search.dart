import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carros_api.dart';
import 'package:carros/pages/carros/carros_listview.dart';
import 'package:flutter/material.dart';

class CarrosSearch extends SearchDelegate<Carro> {

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.clear)
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length > 2) {
      return FutureBuilder(
          future: CarrosApi.search(query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Carro> carros = snapshot.data;
              return CarrosListView(carros, search: true);
            } else {
              return Center(
                  child: CircularProgressIndicator()
              );
            }
          }
      );
    }
    return Container();
  }


}
