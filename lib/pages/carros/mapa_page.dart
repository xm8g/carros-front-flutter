import 'package:carros/pages/carros/carro.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatelessWidget {
  final Carro carro;

  MapaPage(this.carro);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(carro.nome),
      ),
      body: _body(carro),
    );
  }

  _body(Carro carro) {
    return Container(
        child: GoogleMap(
      //mapType: MapType.satellite,
      zoomGesturesEnabled: true,
      initialCameraPosition: CameraPosition(target: carro.latlng(), zoom: 17),
      markers: Set.of(_getMarkers()),
    ));
  }

  List<Marker> _getMarkers() {
    return [
      Marker(
          markerId: MarkerId("1"),
          position: carro.latlng(),
          infoWindow: InfoWindow(
              title: carro.nome,
              snippet: "Fábrica localizada aqui",
              onTap: () {
                print("Clicou na janela");
              }),
          onTap: () {
            print("Clicou no marcador");
          })
    ];
  }
}
