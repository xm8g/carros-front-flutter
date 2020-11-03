import 'package:flutter/material.dart';

alert(BuildContext context, String msg, {Function callback}) {
  showDialog(context: context, barrierDismissible: false, builder: (context) {
    return WillPopScope(
      onWillPop: () async => false, //impede que o usuário saia da tela antes de fechar o Dialog
      child: AlertDialog(
        title: Text("Carros"),
        content: Text(msg),
        actions: <Widget>[
          FlatButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              if (callback != null) {
                callback();
              }
            },
          )
        ],
      ),
    );
  });
}