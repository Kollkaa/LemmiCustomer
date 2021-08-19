import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


import 'package:kaban/Styles.dart' as styles;
import 'package:flutter/cupertino.dart';
import 'package:kaban/Main/MainController.dart';
import '../app_localizations.dart';


class OrderSuccessPayController extends StatefulWidget {
  OrderSuccessPayController(this.title, this.location, this.data, this.time, {Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;
  final String location;
  final String data;
  final String time;

  @override
  _OrderSuccessPayControllerState createState() =>
      _OrderSuccessPayControllerState();
}

class _OrderSuccessPayControllerState extends State<OrderSuccessPayController> {
  final PageRouteBuilder _homeRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return MainController();
    },
  );

  DateTime todayDate;
  String title;
  String location;
  String plus;

  _goToMainController() async {
    Navigator.pushAndRemoveUntil(context, _homeRoute, (Route<dynamic> r) => false);
  }

  void initState() {  
  super.initState();

  getData();
 

  }
  
  getData() async{
    var strDate = "${widget.data.substring(6,10)}-${widget.data.substring(3,5)}-${widget.data.substring(0,2)} ${widget.time}";
    todayDate = DateTime.parse(strDate);
    print(todayDate);
    String smth = "${DateTime.now().timeZoneOffset}";
    plus = smth.substring(0,1);
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
            mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              height: 90,
            ),
            new Expanded(
                child: new Align(
              alignment: Alignment.topCenter,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Image.asset("assets/done_orange_icon.png",width:90), 
                    new SizedBox(
                      height: 10,
                    ),
                    Padding(padding:EdgeInsets.only(left:15, right:15),
                      child:Text(AppLocalizations.of(context).translate('success'),
                     // 'Ваша услуга была\n успешно оплачена!',
                        textAlign: TextAlign.center,
                        style: styles.TextStyles.darkText24)),
                    new SizedBox(
                      height: 20,
                    ),
                  /*  Text(
                        'У Вас будет возможность следить за перемещением Вашего специалиста',
                        textAlign: TextAlign.center,
                        style: styles.TextStyles.darkGText18),*/
                  /*  new SizedBox(
                      height: 30,
                    ),*/                   
                  ]),
            )),
            Expanded(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    height: 190,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height:60),
                        Container(
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(16.0),
                                side: BorderSide(
                                    color: Color.fromRGBO(221, 98, 67, 1))),
                            textColor: Color.fromRGBO(221, 98, 67, 1),
                            onPressed: () => {
                              setState((){}),
                          },                            
                            child: new Container(
                              height: 50,
                              width: double.infinity,
                              //375,
                              alignment: Alignment.center,
                              padding:
                              EdgeInsets.only(bottom: 0, left: 0, right: 0),
                              // color: Colors.red,
                              child: Text(AppLocalizations.of(context).translate('addCalendar'),
                                  textAlign: TextAlign.center,
                                  style: styles.TextStyles.orangeText18),
                            ),
                          ),
                          padding: EdgeInsets.only(left: 30, right: 30),
                        ),
                      /*  SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(16.0),
                                side: BorderSide(
                                    color: Color.fromRGBO(221, 98, 67, 1))),
                            textColor: Color.fromRGBO(221, 98, 67, 1),
                           // onPressed:(){},
                           // _goToMainController,                            
                            child: new Container(
                              height: 50,
                              width: double.infinity,
                              //375,
                              alignment: Alignment.center,
                              padding:
                              EdgeInsets.only(bottom: 0, left: 0, right: 0),
                              // color: Colors.red,
                              child: Text(AppLocalizations.of(context).translate('share'),
                                  textAlign: TextAlign.center,
                                  style: styles.TextStyles.orangeText18),
                            ),
                          ),
                          padding: EdgeInsets.only(left: 30, right: 30),
                        ),*/
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                              color: styles.Colors.orange,
                              child: new Container(
                                height: 50,
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding:
                                EdgeInsets.only(bottom: 0, left: 0, right: 0),
                                child: Text('Готово',
                                    textAlign: TextAlign.center,
                                    style: styles.TextStyles.whiteText18),
                              ),
                              onPressed: _goToMainController),
                          padding: EdgeInsets.only(left: 30, right: 30),

                        )
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
