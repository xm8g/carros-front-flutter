import 'package:carros/firebase/firebase_service.dart';
import 'package:carros/pages/carros/site_page.dart';
import 'package:carros/pages/login/login_page.dart';
import 'package:carros/pages/login/usuario.dart';
import 'package:carros/util/nav.dart';
import 'package:flutter/material.dart';

class DrawerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            FutureBuilder(
                future: Usuario.get(),
                builder: (context, snapshot) {
                  Usuario u = snapshot.data;
                  return u != null ? _avatar(u) : Container();
                }),
            ListTile(
              leading: Icon(Icons.star),
              title: Text("Favoritos"),
              subtitle: Text("mais informações..."),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                print("Item 1");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text("Configurações"),
              trailing: Icon(Icons.settings),
              onTap: () {
                print("Settings");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text("Visite o site..."),
              trailing: Icon(Icons.dvr),
              onTap: () {
                _onClickSite(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("Ajuda"),
              subtitle: Text("mais informações..."),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                print("Item 1");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Usuario.clear();
                FirebaseService().logout();
                Navigator.pop(context);
                push(context, LoginPage(), replace: true);
              },
            )
          ],
        ),
      ),
    );
  }

  UserAccountsDrawerHeader _avatar(Usuario usuario) {
    return UserAccountsDrawerHeader(
      accountName: Text(usuario.login),
      accountEmail: Text(usuario.email),
      currentAccountPicture: usuario.urlFoto != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(usuario.urlFoto),
            )
          : FlutterLogo(),
    );
  }

  void _onClickSite(BuildContext context) {
    Navigator.pop(context);
    push(context, SitePage());
  }
}
