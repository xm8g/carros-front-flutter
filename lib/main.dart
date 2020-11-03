import 'package:carros/pages/favoritos/favoritos_bloc.dart';
import 'package:carros/pages/login/login_page.dart';
import 'package:carros/splash_page.dart';
import 'package:carros/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FavoritosBloc>(
          builder: (context) => FavoritosBloc(),
          dispose: (context, bloc) => bloc.dispose()
        ),
        Provider<EventBus>(
            builder: (context) => EventBus(),
            dispose: (context, bus) => bus.dispose()
        )
      ],
      child: MaterialApp(
        title: 'Carros',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white
        ),
        home: SplashPage()
      ),
    );
  }
}

