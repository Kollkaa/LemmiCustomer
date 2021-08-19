import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Styles.dart' as styles;

class MessengersController extends StatefulWidget { 
  MessengersController(this.phone,  {Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".  
  final String phone;
  @override
  _MessengersControllerState createState() =>
      _MessengersControllerState();
}

class _MessengersControllerState
    extends State<MessengersController> {
  Widget child;
  String day;
  
  void initState() {
    super.initState();
  } 
   
  @override
  Widget build(BuildContext context) {
    final messengersActions = [   
    {"title": "+38(068)298 4428", "icon":"assets/phone_icon.png", "action": '+38(068)298 4428'},
    {"title": "WhatsApp", "icon":"assets/whatsapp.png", "action": 'whatsapp'},
    {"title": "Viber","icon":"assets/viber.png", "action": 'viber'},
    {"title": "Facebook messenger","icon":"assets/facebook.png", "action": 'facebook'},
    {"title": "Telegram","icon":"assets/telegram.png", "action": 'telegram'},
    ];

     _phoneAction() async {
      var url ="phone=+380682984428";
      await launch('tel:+380682984428');  
    }
    _whatsappAction() async {
      var url ="whatsapp://send?phone=+380682984428";
      await launch(url);  
    }
    _viberAction() async {
      var url ="viber://chat?number=380682984428";
      await launch(url); 
    }
    _facebookAction() async {
       var url ="http://m.me/";
      await launch(url);
      
    }
    _telegramAction() async {
      var url ='https://t.me/Lemmiprog';
      await launch(url);
    }

    final messengers = ListView.builder(
          itemCount: messengersActions.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: Color.fromRGBO(221, 98, 67, 1),
                        backgroundImage: AssetImage("${messengersActions[index]["icon"]}"),
                         ),
              title:Text("${messengersActions[index]["title"]}",),
              onTap: (){
                var actionKey = '${messengersActions[index]["action"]}';
                    
                    if (actionKey == '+38(068)298 4428') {
                      _phoneAction();
                    } else if (actionKey == 'whatsapp') {
                      _whatsappAction();
                    } else if (actionKey == 'viber') {
                      _viberAction();
                    } else if (actionKey == 'facebook') {
                      _facebookAction();
                    } else if (actionKey == 'telegram') {
                      _telegramAction();
                    } 
              },

            );
          }
      );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
        backgroundColor: styles.Colors.whiteColor,
        appBar: MessageAppBar(),       
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: messengers           
        )
    );
  }
  
}
class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () async => Navigator.pop(context),
          child: Container(
            color: styles.Colors.whiteColor,
            width: double.infinity,
            height: 54,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Color(0xFFCFCBC4),
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(54);
}

