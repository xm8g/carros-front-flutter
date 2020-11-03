import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carros/firebase/firebase_service.dart';
import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/carros/carro.dart';
import 'package:carros/pages/carros/carros_api.dart';
import 'package:carros/util/alert.dart';
import 'package:carros/util/event_bus.dart';
import 'package:carros/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CarroFormPage extends StatefulWidget {
  final Carro carro;

  CarroFormPage({this.carro}); //atributo opcional, usado na hora de editar

  @override
  State<StatefulWidget> createState() => _CarroFormPageState();
}

class _CarroFormPageState extends State<CarroFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final tNome = TextEditingController();
  final tDesc = TextEditingController();
  final tTipo = TextEditingController();

  int _radioIndex = 0;

  var _showProgress = false;

  File _image;

  Carro get carro => widget.carro;

  // Add validate email function.
  String _validateNome(String value) {
    if (value.isEmpty) {
      return 'Informe o nome do carro.';
    }

    return null;
  }

  @override
  void initState() {
    //inicia e confgura a tela
    super.initState();

    // Copia os dados do carro para o form
    if (carro != null) {
      tNome.text = carro.nome;
      tDesc.text = carro.descricao;
      _radioIndex = getTipoInt(carro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          carro != null ? carro.nome : "Novo Carro",
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: _form(),
      ),
    );
  }

  _form() {
    return Form(
      key: this._formKey,
      child: ListView(
        children: <Widget>[
          _headerFoto(),
          Text(
            "Clique na imagem para tirar uma foto",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Divider(),
          Text(
            "Tipo",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
          ),
          _radioTipo(),
          Divider(),
          TextFormField(
            controller: tNome,
            keyboardType: TextInputType.text,
            validator: _validateNome,
            style: TextStyle(color: Colors.blue, fontSize: 20),
            decoration: new InputDecoration(
              hintText: '',
              labelText: 'Nome',
            ),
          ),
          TextFormField(
            controller: tDesc,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
            decoration: new InputDecoration(
              hintText: '',
              labelText: 'Descrição',
            ),
          ),
          AppButton("Salvar",
              onPressed: _onClickSalvar, showProgress: _showProgress)
        ],
      ),
    );
  }

  _headerFoto() {
    return InkWell(
        onTap: _onClickFoto,
        child: _image != null
            ? Image.file(_image, height: 150)
            : carro != null
                ? CachedNetworkImage(
                    imageUrl: carro.urlFoto,
                  )
                : Image.asset(
                    "assets/images/camera.png",
                    height: 150,
                  ));
  }

  _radioTipo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio(
          value: 0,
          groupValue: _radioIndex,
          onChanged: _onClickTipo,
        ),
        Text(
          "Clássicos",
          style: TextStyle(color: Colors.blue, fontSize: 15),
        ),
        Radio(
          value: 1,
          groupValue: _radioIndex,
          onChanged: _onClickTipo,
        ),
        Text(
          "Esportivos",
          style: TextStyle(color: Colors.blue, fontSize: 15),
        ),
        Radio(
          value: 2,
          groupValue: _radioIndex,
          onChanged: _onClickTipo,
        ),
        Text(
          "Luxo",
          style: TextStyle(color: Colors.blue, fontSize: 15),
        ),
      ],
    );
  }

  void _onClickTipo(int value) {
    setState(() {
      _radioIndex = value;
    });
  }

  getTipoInt(Carro carro) {
    switch (carro.tipo) {
      case "classicos":
        return 0;
      case "esportivos":
        return 1;
      default:
        return 2;
    }
  }

  String _getTipo() {
    switch (_radioIndex) {
      case 0:
        return "classicos";
      case 1:
        return "esportivos";
      default:
        return "luxo";
    }
  }

  void _onClickFoto() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    FirebaseService.uploadFirebaseStorage(image);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  _onClickSalvar() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    // Cria o carro
    var c = carro ?? Carro();
    c.nome = tNome.text;
    c.descricao = tDesc.text;
    c.tipo = _getTipo();

    print("Carro: $c");

    setState(() {
      _showProgress = true;
    });

    ApiResponse<bool> response = await CarrosApi.save(c, _image);

    if (response.ok) {
      alert(context, "Carro salvo com sucesso", callback: () {
        EventBus.get(context).sendEvent(CarroEvent("carro_salvo", c.tipo));
        Navigator.pop(context); //volta pra Home após salvar
      });
    } else {
      alert(context, response.msg);
    }

    setState(() {
      _showProgress = false;
    });
  }
}
