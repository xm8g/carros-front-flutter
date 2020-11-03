import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  Function onPressed;
  String rotulo;
  bool showProgress;

  AppButton(this.rotulo, {this.onPressed, this.showProgress = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: RaisedButton(
          color: Colors.blue,
          textColor: Colors.white,
          child: showProgress
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : Text(
                  rotulo,
                  style: TextStyle(fontSize: 20),
                ),
          onPressed: onPressed),
    );
  }
}
