import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  String label;
  String hint;
  bool senha;
  TextEditingController controller;
  FormFieldValidator<String> validator;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  FocusNode focusNode;
  FocusNode nextFocus;


  AppText(this.label, this.hint, { this.senha = false, this.controller, this.validator,
      this.keyboardType, this.textInputAction, this.focusNode, this.nextFocus });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        obscureText: senha,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            labelText: label,
            hintText: hint
        ),
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onFieldSubmitted: (String text) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        });
  }
}
