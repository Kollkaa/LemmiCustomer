import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kaban/Profile/WebViewController.dart';
import 'package:http/http.dart' as http;
import 'package:mask_shifter/mask_shifter.dart';
import '../app_localizations.dart';
import 'package:kaban/Widgets.dart';
import 'package:kaban/Authentication/CheckOTPController.dart';
import 'package:kaban/ServerManager.dart';
import '../Styles.dart' as styles;


enum ScreenType {
  loginType,
  registrationType
}

class CheckMobileController extends StatefulWidget {
  CheckMobileController(this.screenType, {Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final ScreenType screenType;
 // final String title;

  @override
  _CheckMobileControllerState createState() => _CheckMobileControllerState(screenType);
}

class _CheckMobileControllerState extends State<CheckMobileController> {
  _CheckMobileControllerState(this.screenType);

  void initState() {
    super.initState();
    _phoneController.text = "";
    
  }

  ScreenType screenType;
  
  bool _agree = false;
  bool _isNumberValid = false;
  String phoneN;
  var _phoneController = TextEditingController();

  _loginUserAction(phoneNumber) async {
   print("38${_phoneController.text}");
     await ServerManager(context).loginMobileRequest("38$phoneNumber", (code){
          var screenType = ScreenType.loginType;
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                  new CheckOTPController("38${_phoneController.text}", screenType)));
          
        }, (error) {

      });
   }

  _registrationButtonAction() async {
    if (_agree && _isNumberValid) {

      String strNum = _phoneController.text;
      final iReg = RegExp(r'(\d+)');
      var phoneNumber = iReg.allMatches(strNum).map((m) => m.group(0)).join('');
      phoneN = '38$phoneNumber';

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    Dialogs().showLoadingDialog(context, _keyLoader);

      var lang = "${ui.window.locale.languageCode}";
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    }
    var serverURL ="https://api.lemmi.app";
    http.get("$serverURL/api/user/check-mobile?phone=38$phoneNumber",
     headers: <String, String>{      
          'Accept-Language':'$lang',                  
        }).then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {
          var result = body["result"];
           if(result["otp"] == false){}
        else{
          Dialogs().alertAction(context, "Ваш OTP код", "${result["otp"]}", (){

            Navigator.of(context).pop();

          //  onSuccess("${result["otp"]}");

         });
        }
         // Dialogs().alertAction(context, "Ваш OTP код", "${result["otp"]}", (){

          //Navigator.of(context).pop();

            var screenType = ScreenType.registrationType;
            Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                  new CheckOTPController("38${_phoneController.text}", screenType)));

        //  });

        }/*else if (code == "400") {
          Dialogs().alert(context, "Ошибка","Пользователь заблокирован");
        }*/
        else if (code == "409") {
          _loginUserAction(phoneNumber);
        } else {
          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);
      }
    }).catchError((error) {
      print("Error: $error");
      Dialogs().errorAlert(context);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }).whenComplete(() {
      Dialogs().errorAlert(context);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });
    }
  }

  _offertAction() async {}

  @override
  Widget build(BuildContext context) {
var phoneField = TextFormField(
        controller: _phoneController,
        onChanged: (String value) {
         setState(() {
          _isNumberValid = value.length == 14;
        });
        },
        onSaved: (String value) {
        _phoneController.text = value;
      },
        keyboardType: TextInputType.phone,
        style: styles.TextStyles.darkGRegularText32,
        decoration: new InputDecoration(
            prefixIcon: Container(
              padding: EdgeInsets.only(right: 14),
              child: SizedBox(
                child: Center(
                  widthFactor: 0.0,
                  child: Text('+38', style: styles.TextStyles.darkGRegularText32),
                ),
              ),
            ),
            hintText: '(000)000 00 00',
            hintStyle: styles.TextStyles.darkGTextTrans32,
            border: InputBorder.none),
        inputFormatters: [
          MaskedTextInputFormatterShifter(
              maskONE: "(XXX)XXX XX XX", maskTWO: " XXX XXX XX XX")
        ]);
    
    final bottomButton = new MaterialButton(
      elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: Text(
            AppLocalizations.of(context).translate('next'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isNumberValid & _agree
                  ? styles.Colors.whiteColor
                  : styles.Colors.whiteTrans,
              fontFamily: 'Gilroy',
              fontSize: 18,
            ),
          ),
        ),
        onPressed: _registrationButtonAction
    );

    final agreementsView = Container(
      child: GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                        color: styles.Colors.darkText,
                        width: 1
                    )
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(3)),                    
                    child: Container(
                      width: 26,
                      height: 26,
                      child: Theme (                        
                        data: ThemeData(unselectedWidgetColor: Colors.white,),
                        child:
                          Checkbox(
                        value: _agree,
                        onChanged: (checked) {
                          setState(() {
                            _agree = checked;
                          });
                        },
                        checkColor: styles.Colors.orange,
                        activeColor: styles.Colors.whiteColor,
                      ),
                      ),
                      color: styles.Colors.whiteColor,
                    ),
                ),
              ),
              padding: EdgeInsets.only(top: 5),
            ),
            GestureDetector(
              child:
            Container(
              child: Text.rich(TextSpan(
                  text: AppLocalizations.of(context).translate('iAccept'),
                  style: styles.TextStyles.darkRegularText12,
                  children: <InlineSpan>[
                    TextSpan(
                        text: AppLocalizations.of(context).translate('agreement'),
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: styles.Colors.orange)),
                    
                  ]
              )
              ),
              padding: EdgeInsets.only(left: 33, top:5),
            ),onTap: () {
               var type = "confRules";
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => new WebViewController(type)));
            },)

          ],

        ),
        onTap: () {
          _agree = !_agree;
        },
      ),
      padding: EdgeInsets.only(left: 30, right: 30),
    );

    final topNavigationBar = Widgets().topBar(context);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: styles.Colors.background,      
        body: Stack(children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.bottom,
              color: styles.Colors.orange,
            ),
          ),
          SafeArea(
              child: GestureDetector(
                child: Stack(children: <Widget>[
                  Container(
                    padding: new EdgeInsets.only(top: 30, bottom: 0),
                    child: new Form(
                        child: new ListView(
                            physics: NeverScrollableScrollPhysics(),
                            children: <Widget>[
                              topNavigationBar,
                              new SizedBox(height: 100),
                              new Container(
                                child: new Stack(
                                  children: <Widget>[
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 30.0, bottom: 6.0),
                                      child: new Text(AppLocalizations.of(context).translate('enterPhone'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontFamily: 'Gilroy-Medium',
                                              fontStyle: FontStyle.normal,
                                              fontSize: 24)),
                                    ),
                                    new Container(
                                      alignment: Alignment.center,
                                      padding:
                                      const EdgeInsets.only(top: 40.0, left: 24.0),
                                      child: phoneField,
                                    ),
                                  ],
                                ),
                              ),
                              agreementsView,
                            ])),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            child: Text(AppLocalizations.of(context).translate('severalSec')),
                            margin: EdgeInsets.only(bottom: 5
                            )),
                        bottomButton
                      ],
                    ),
                  )
                ]),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
              )
          ),
        ])     
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
