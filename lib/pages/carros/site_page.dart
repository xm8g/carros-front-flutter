import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SitePage extends StatefulWidget {
  @override
  _SitePageState createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  WebViewController controller;

  var _stackIdx = 1;

  var _showProgress = true;

//  @override
//  Widget build(BuildContext context) {
//    return IndexedStack(
//        index: _stackIdx,
//        children: < Widget > [
//          Column(
//              children: < Widget > [
//                Expanded(
//                    child: WebView(
//                      initialUrl: "http://flutter.dev",
//                      onWebViewCreated: (controller) {
//                        this.controller = controller;
//                      },
//                      onPageFinished: _onPageFinished,
//                    )
//                )
//              ]
//          ),
//          Container(
//              color: Colors.white,
//              child: Center(
//                  child: CircularProgressIndicator()
//              )
//          )
//        ]
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: < Widget > [
          Column(
              children: < Widget > [
                Expanded(
                    child: WebView(
                      initialUrl: "http://flutter.dev",
                      onWebViewCreated: (controller) {
                        this.controller = controller;
                      },
                      onPageFinished: _onPageFinished,
                    )
                )
              ]
          ),
          Opacity(
              opacity: _showProgress ? 1 : 0,
              child: Center(
                  child: CircularProgressIndicator()
              )
          )
        ]
    );
  }

  void _onClickRefresh() {
    this.controller.reload();
  }

  void _onPageFinished(String url) {
    setState(() {
      _stackIdx = 0;
      _showProgress = false;
    });
  }
}
