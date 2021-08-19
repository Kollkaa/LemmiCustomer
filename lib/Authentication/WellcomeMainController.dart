import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../app_localizations.dart';
import 'package:kaban/Styles.dart' as styles;

import 'Story.dart';

class WellcomeMainController extends StatefulWidget {
  WellcomeMainController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _WellcomeMainControllerState createState() => _WellcomeMainControllerState();
}

class _WellcomeMainControllerState extends State<WellcomeMainController> {
  String accessToken;

  
  _goToMainController() async {
    Navigator.of(context).pushReplacementNamed('home');
  }
  _goToStory() async {
   Navigator.of(context).push(CupertinoPageRoute(
                            //fullscreenDialog: true,
                              builder: (context) =>  Story()));
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
      backgroundColor: styles.Colors.background,

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
                child: new Align(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    //SizedBox(height:98),
                    Image(
                      image: AssetImage('assets/logo_color.png'),
                      width: 250,
                      //height: 100,
                    ),
                    new SizedBox(
                      height: 10,
                    ),
                    Text(AppLocalizations.of(context).translate('excurs'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Gilroy-SemiBold',
                            fontStyle: FontStyle.normal,
                            letterSpacing: -0.1,
                            fontSize: 24)),                   
                  ]),
            )),
            SizedBox(height:32),
             Text(
                        AppLocalizations.of(context).translate('textExcurs'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontStyle: FontStyle.normal,
                            fontSize: 14)),

            Expanded(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    height: 150,
                    child: Column(
                      children: <Widget>[
                        Container(
                          //padding: EdgeInsets.only(left: 30, right: 30),
                          width: MediaQuery.of(context).size.width - 60,
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
                            onPressed: () => _goToMainController(),
                            child: Text(AppLocalizations.of(context).translate('noExcurs'), style: styles.TextStyles.orangeText18,),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          //padding: EdgeInsets.only(left: 30, right: 30),
                          width: MediaQuery.of(context).size.width - 60,
                          child: MaterialButton(
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(16.0),
                            ),
                            height: 50,
                            //minWidth: 315,
                            color: styles.Colors.orange,
                            onPressed: () => _goToStory(),
                            child: Text(AppLocalizations.of(context).translate('yesExcurs'), style: styles.TextStyles.whiteText18,),
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
