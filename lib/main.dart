
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/plug/enter_code_view.dart';

import 'Authentication/AuthorizationController.dart';
import 'Authentication/CheckMobileController.dart';
import 'MyOrders/OrderInfoController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:overlay_support/overlay_support.dart';
import 'Main/MainController.dart';
import 'package:kaban/Authentication/StartController.dart';

import 'app_localizations.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart' as sec;

import 'plug/enter_email.dart';
import 'plug/plug_view.dart';
String jwt;
SharedPreferences sharedPreferences;

getJWTToken() async {
    if(sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    jwt = sharedPreferences.getString("token").toString();
    final storage = new sec.FlutterSecureStorage();
      var language = await storage.read(key: "language");
    print(language);
  }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getJWTToken();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(new MyApp());
    });
}

class MyApp extends StatefulWidget {
  MyApp({Key, key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
//class MyApp extends StatelessWidget {
  @override
  void initState() {
    super.initState();
    //LocalNotificationService.instance.start();  
 
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
    child:  MaterialApp(      
      supportedLocales: [
      const  Locale('ru',''),
      const  Locale('uk', 'UA'),
      const  Locale('en', ''),
      ], 
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      title: 'Lemmi',
      theme: ThemeData(
          fontFamily: 'Gilroy',
        primarySwatch: MaterialColor(0xffDD6243, {
          50: Color(0xffDD6243),
          100: Color(0xffDD6243),
          200: Color(0xffDD6243),
          300: Color(0xffDD6243),
          400: Color(0xffDD6243),
          500: Color(0xffDD6243),
          600: Color(0xffDD6243),
          700: Color(0xffDD6243),
          800: Color(0xffDD6243),
          900: Color(0xffDD6243)
        }),
        cardColor: Colors.transparent,
        ),
     home: new MainController(),
      initialRoute: jwt == null || jwt == 'null' || jwt.isEmpty ||jwt=="" ? 'plugs' : 'home',
      routes: {
        'plugs':(context)=>PlugView(),
        'submit_code':(context)=>EnterCodeView(),
        'enter_email':(context)=>EmailView(),

        'home':(context) => MainController(),
        'login': (context) => AuthorizationController(ScreenType.registrationType),
      },
    ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
         
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}