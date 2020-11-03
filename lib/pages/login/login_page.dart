import 'dart:async';
import 'dart:io';

import 'package:carros/firebase/firebase_service.dart';
import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/carros/home_page.dart';
import 'package:carros/pages/login/cadastro_page.dart';
import 'package:carros/pages/login/login_api.dart';
import 'package:carros/pages/login/login_bloc.dart';
import 'package:carros/pages/login/usuario.dart';
import 'package:carros/util/alert.dart';
import 'package:carros/util/fingerprint.dart';
import 'package:carros/util/nav.dart';
import 'package:carros/widgets/app_button.dart';
import 'package:carros/widgets/app_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _tLogin = TextEditingController();

  final _tPassword = TextEditingController();

  final _focusPassword = FocusNode();

  final _bloc = LoginBloc();

  FirebaseUser fUser;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var showForm = false;

  void initState() {
    super.initState();

    Future<Usuario> usuario = Usuario.get();
    usuario.then((Usuario u) {
      if (u != null) {
        setState(() {
          _tLogin.text = u.login;
        });
      }
    });

    FirebaseAuth.instance.currentUser().then((fUser) {
      setState(() {
        this.fUser = fUser;
        if (fUser != null) {
          //pushReplacement(context, HomePage());
          showForm = true;
        } else {
          showForm = true;
        }
      });
    });

    _initRemoteConfig();
    _initFcm();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Carros"),
        ),
        body: _body());
  }

  _body() {
    return Form(
      key: _formKey, //controla o estado do formulário
      child: Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            AppText("User Account", "Digite o username", controller: _tLogin,
                validator: (String text) {
                  if (text.isEmpty) {
                    return "Campo obrigatório não preenchido!";
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                nextFocus: _focusPassword),
            SizedBox(height: 15),
            AppText("Password", "Digite a senha",
                senha: true,
                controller: _tPassword, validator: (String text) {
                  if (text.isEmpty) {
                    return "Campo obrigatório não preenchido!";
                  }
                  if (text.length < 3) {
                    return "Senha muito pequena! Mínimo 4 caracteres.";
                  }
                  return null;
                }, keyboardType: TextInputType.number, focusNode: _focusPassword),
            StreamBuilder<bool>(
              stream: _bloc.stream,
              initialData: false,
              builder: (context, snapshot) {
                return AppButton("Login",
                    onPressed: _onClickLogin,
                    showProgress: snapshot.data
                );
              }
            ),
            Container(
              height: 46,
              margin: EdgeInsets.only(top: 20),
              child: GoogleSignInButton(
                onPressed: _onClickLoginGoogle,
              ),
            ),
            Container(
              height: 46,
              margin: EdgeInsets.only(top: 20),
              child: InkWell(
                onTap: _onClickLoginCadastrar,
                child: Text(
                  "Cadastre-se",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.blue,
                    decoration: TextDecoration.underline
                  ),
                )
              ),
            ),
            Opacity(
              opacity: fUser != null ? 1 : 0,
              child: Container(
                height: 46,
                child: InkWell(
                  onTap: () {
                    _onClickFingerPrint(context);
                  },
                  child: Image.asset("assets/images/fingerprint.png", color: Colors.blue)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  _onClickLogin() async {
    bool formOk = _formKey.currentState.validate();

    if (!formOk) {
      return;
    }

    String login = _tLogin.text;
    String senha = _tPassword.text;

    //ApiResponse response = await _bloc.login(login, senha);
    ApiResponse response = await _bloc.loginFirebase(login, senha);

    if (response.ok) {

      Usuario user = response.result;

      print(">>> $user");
      push(context, HomePage());
    } else {
        alert(context, response.msg);
    }

  }

  void _initFcm() {
    _firebaseMessaging.getToken().then((token) {
      print("Firebase Token [$token]");
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('\n\n\n*** on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("iOS Push Settings: [$settings]");
      });
    }
  }

  _initRemoteConfig() {
    RemoteConfig.instance.then((remoteConfig) {
      remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));

      try {
        remoteConfig.fetch(expiration: const Duration(minutes: 1));
        remoteConfig.activateFetched();
      } catch (error) {
        print("Remote Config: $error");
      }

      final mensagem = remoteConfig.getString("welcome");

      print('Mensagem: $mensagem');
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bloc.dispose();
  }

  void _onClickLoginGoogle() async {
    final service = FirebaseService();
    ApiResponse response = await service.loginGoogle();
    if (response.ok) {
      push(context, HomePage(), replace: true);
    } else {
      alert(context, response.msg);
    }
  }

  void _onClickLoginCadastrar() {
    push(context, CadastroPage(), replace: true);
  }

  void _onClickFingerPrint(BuildContext context) async {
    final ok = await FingerPrint.verify();
    if (ok) {
      push(context, HomePage(), replace: true);
    }
  }
}
