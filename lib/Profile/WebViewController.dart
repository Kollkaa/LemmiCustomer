import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kaban/CreateOrder/GalleryController.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:kaban/Styles.dart' as styles;

class WebViewController extends StatefulWidget {
   WebViewController(this.type, {Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String type;

  @override
  _WebViewControllerState createState() => _WebViewControllerState();
}

class _WebViewControllerState extends State< WebViewController> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: CreateAppBar(
        height: 118.1,
        topConstraint: MediaQuery.of(context).padding.top,
        titleAppBar:'',
        showAddButton: false),
      backgroundColor: styles.Colors.background,
      body: WebView(
        initialUrl: widget.type == "about"
        ? "https://lemmi.app/ "
        : widget.type == "faq"
        ? 'https://lemmi.app/#faq'        
        : widget.type == 'rules'
        ? 'https://lemmi.app/rules_1.pdf' 
        :"https://lemmi.app/Privacy_Policy.pdf"
        
        
      )
      );
  }
}
