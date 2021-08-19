import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:kaban/Authentication/CheckMobileController.dart';
import 'package:mask_shifter/mask_shifter.dart';

import '../app_localizations.dart';
import 'package:kaban/Widgets.dart';
import 'package:kaban/Authentication/CheckOTPController.dart';
import 'package:kaban/ServerManager.dart';
import '../Styles.dart' as styles;


class AuthorizationController extends StatefulWidget {
  AuthorizationController(this.screenType, {Key key}) : super(key: key);
  final ScreenType screenType;

  @override
  _AuthorizationControllerState createState() => _AuthorizationControllerState(screenType);
}

class _AuthorizationControllerState extends State<AuthorizationController> {
  _AuthorizationControllerState(this.screenType);

  void initState() {
    super.initState();
    _phoneController.text = "+38";
  }

  ScreenType screenType;
  
  bool _agree = false;
  bool _isNumberValid = false;
  String phoneN;
  var _phoneController = TextEditingController();

  _loginUserAction(phoneNumber) async {
print("38$phoneNumber");
     await ServerManager(context).loginMobileRequest("$phoneNumber", (code){
          var screenType = ScreenType.loginType;
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                  new CheckOTPController("${_phoneController.text}", screenType)));

        }, (error) {

      });
   }

  _registrationButtonAction() async {
    if (_agree && _isNumberValid) {

      String strNum = _phoneController.text;
      final iReg = RegExp(r'(\d+)');
      var phoneNumber = iReg.allMatches(strNum).map((m) => m.group(0)).join('');
      phoneN = phoneNumber;

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    Dialogs().showLoadingDialog(context, _keyLoader);

      var lang = "${ui.window.locale.languageCode}";
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    }
    
    var serverURL ="https://api.lemmi.app";
    http.get("$serverURL/api/user/check-mobile?phone=$phoneNumber",
     headers: <String, String>{      
          'Accept-Language':'$lang',                  
        }).then((response) {
      print("$serverURL/api/user/check-mobile?phone=$phoneNumber Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {
          var result = body["result"];
           if(result["otp"] == false) {
             var screenType = ScreenType.registrationType;
            Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                  new CheckOTPController("${_phoneController.text}", screenType)));
           }
           else{
          Dialogs().alertAction(context, "Ваш OTP код", "${result["otp"]}", (){

            Navigator.of(context).pop();

            var screenType = ScreenType.registrationType;
            Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                  new CheckOTPController("${_phoneController.text}", screenType)));

          });
           }
        } else if (code == "409") {
          _loginUserAction(phoneNumber);
        } else {
          Fluttertoast.showToast(
              msg: "Ошибка соединения",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      } else {
        Fluttertoast.showToast(
            msg: "Ошибка соединения",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
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


  @override
  Widget build(BuildContext context) {

    final phoneField = new TextFormField(
      autofocus: true,
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: styles.TextStyles.darkGRegularText32,
      decoration: new InputDecoration(
        hintText: '+38 (000) 000 00 00',
        hintStyle: styles.TextStyles.darkGTextTrans32,
        border: InputBorder.none,
      ),
      inputFormatters: [
        MaskedTextInputFormatterShifter(
          maskONE: "+XX(XXX)XXX XX XX",
          maskTWO: "+XX XXX XXX XX XX",
        ),
      ],
      onSaved: (String value) {
        _phoneController.text = value;
      },
      onChanged: (String value) {
        setState(() {
          _isNumberValid = value.length == 17;
        });
      },
    );

    final bottomButton = new MaterialButton(
     // elevation: 0,
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
                    TextSpan(text: AppLocalizations.of(context).translate('and')),
                    TextSpan(
                        text: AppLocalizations.of(context).translate('confidential'),
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: styles.Colors.orange))
                  ]
              )
              ),
              padding: EdgeInsets.only(left: 33, top:5),
            )

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
                              new SizedBox(height: 40),
                              Padding(
                                padding: EdgeInsets.only(left:30),
                                child:new Text(AppLocalizations.of(context).translate('sub4'),
                                          textAlign: TextAlign.left,
                                          style: styles.TextStyles.darkText18)),
                              new SizedBox(height: 21),
                              new Container(
                                child: new Stack(
                                  children: <Widget>[
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 30.0, bottom: 6.0),
                                      child: new Text(AppLocalizations.of(context).translate('enterPhone'),
                                          textAlign: TextAlign.left,
                                          style: styles.TextStyles.gilroyDarkText14),
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
                              Container(
                            margin: EdgeInsets.only(bottom:45, left:30, right:30),
                            height: 1,
                            color: Color(0x88ADADAD)),
                              agreementsView,                              
                            ])),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child:bottomButton
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
