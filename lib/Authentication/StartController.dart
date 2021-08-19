import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:kaban/Authentication/CheckMobileController.dart';
import 'package:kaban/Main/FakeMainController.dart';
import 'package:kaban/MyOrders/MyOrderListController.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:kaban/Managers.dart';
import '../app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class StartController extends StatefulWidget {
  StartController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _StartControllerState createState() => _StartControllerState();
}

class _StartControllerState extends State<StartController> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];
  static GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String road;
  _getToken(){
    _firebaseMessaging.getToken().then((deviceToken){
      print("Device Token : $deviceToken");
    });
  }

  _registrationButtonAction() async {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new CheckMobileController(ScreenType.registrationType)),
    );
  }
  void _authentication() async{
    //  String token = sharedPreferences.getString("token").toString();
    bool autorisate = false;

    final storage = new FlutterSecureStorage();

    String token = null;

    var tok = await storage.read(key: 'token').whenComplete(() {

      autorisate = true;

    }).then((val) {

      if (val == null) {
        autorisate = false;
      }else{
        autorisate = true;
        token = val;
      }

    });

    if (tok != null && token == null) {
      token = tok;
    }

    //print("token = $token");

    if (autorisate == true) {

      if (token == null || token.isEmpty) {

      }else{//if registered and log in 

        //print("token = " + token);

        setToken(token);

      }

    }else{

    }
  }

  void _authenticationButtonAction() async {
    //  String token = sharedPreferences.getString("token").toString();
    bool autorisate = false;

    final storage = new FlutterSecureStorage();

    String token = null;

    var tok = await storage.read(key: 'token').whenComplete(() {

      autorisate = true;

    }).then((val) {

      if (val == null) {
        autorisate = false;
      }else{
        autorisate = true;
        token = val;
      }

    });

    if (tok != null && token == null) {
      token = tok;
    }

    //print("token = $token");

    if (autorisate == true) {

      if (token == null || token.isEmpty) {

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => new CheckMobileController(ScreenType.loginType)),

        );
      }else{//if registered and log in 

        //print("token = " + token);

        setToken(token);

      }

    }else{
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => new CheckMobileController(ScreenType.loginType)),
      );
    }
    // Navigator.of(context).pushReplacementNamed('home');


//    if (token == "" || token == null) {
//
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => new CheckMobileController(ScreenType.loginType)),
//      );
//
//    }else{
//
//      Navigator.of(context).pushReplacementNamed('home');
//
//    }

    //Navigator.of(context).pushReplacementNamed('home');

  }

  _fakeroute() async {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => new FakeMainController()));
  }

  void setToken(String token) async {

    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("token", token);

    Navigator.of(context).pushReplacementNamed('home');

  }

  handlePath(message){
    if (road == "my_orders"){
      print("переход на заказы");
      Navigator.of(context).push(
          CupertinoPageRoute(
              builder: (context) => MyOrderListController()
          )
      );
    }else {
      print("переход на главную");
    }
  }

  final storage = new FlutterSecureStorage();

  Future <String> getToken() async {
    String token = await storage.read(key: "token");
    String refreshtoken = await storage.read(key:"refresh_token").then((refreshToken){
      return refreshToken;
    });
    return token;
  }

  getMessage() {
    _firebaseMessaging.configure(
      onMessage:(Map <String,dynamic> message) async {
        print("onMessage:$message");
        final notification = message['notification'];
        showDialog(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                  title:  Text (message['notification']['title']),
                  content: Text (message['notification']['body']),
                  actions: [
                    CupertinoDialogAction(child: Text("OK",style:TextStyle(
                        fontFamily: 'Roboto-Medium',
                        fontSize: 14,
                        color: Color.fromRGBO(221,98,67,1))),
                      onPressed:(){
                        Navigator.pop(context);
                      },
                    ),
                  ]);
            });
        // final notification = message['notification'];
        setState(() {
          messages.add(Message(title: notification['title'], body: notification['body']));
          showDialog();
        });
      },
      onLaunch: (Map <String,dynamic> message) async {
        final data = message['data'];
        road = message['data']['action'];
        print("ZonLaunch:$message");
        handlePath(message);
      },
      onResume: (Map <String,dynamic> message) async {
        final data = message['data'];
        road = message['data']['action'];
        print("ZonResume:$message");
        handlePath(message);
      },
    );
  }

  @override
  void initState() {
    _authentication();
    super.initState();
    //  getMessage();

  }
  gat() async{
    print(Localizations.localeOf(context)); }
  @override
  Widget build(BuildContext context) {
    gat();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      backgroundColor: styles.Colors.background,

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
                child: new Align(
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(AppLocalizations.of(context).translate('welcome'),
                            textAlign: TextAlign.center,
                            style: styles.TextStyles.darkRegularText24),
                        SizedBox(height:20),
                      ]),
                )),
            Image(
              image: AssetImage('assets/logo.png'),
              width: 238,
              height: 155.65,
            ),
            Expanded(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    height: 150,
                    child: Column(
                      children: <Widget>[
                        Container(
                          //padding: EdgeInsets.only(left: 30, right: 30),
                          width: MediaQuery.of(context).size.width - 74,
                          child: MaterialButton(
                            padding: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(16.0),
                                side: BorderSide(
                                    color: styles.Colors.orange
                                )
                            ),
                            height: 50,
                            //minWidth: 315,
                            onPressed: () => _fakeroute(),
                            //_authenticationButtonAction(),
                            child: Text(AppLocalizations.of(context).translate('sign'), style: styles.TextStyles.orangeText18,),
                          ),
                        ),

                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
