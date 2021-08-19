import 'dart:ui';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:kaban/Authentication/CheckMobileController.dart';
import 'package:kaban/Authentication/RegisterUserController.dart';

import 'package:kaban/Widgets.dart';
import '../Styles.dart' as styles;
import '../app_localizations.dart';
import 'package:kaban/ServerManager.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mask_shifter/mask_shifter.dart';
import 'package:http/http.dart' as http;



class CheckOTPController extends StatefulWidget {
  CheckOTPController(this._phone, this.screenType, {Key key}) : super(key: key);

  final String _phone;
  final ScreenType screenType;
  @override
  _CheckOTPControllerState createState() => _CheckOTPControllerState(_phone, screenType);
}

class _CheckOTPControllerState extends State<CheckOTPController> {
  _CheckOTPControllerState(this._phone, this.screenType);
  @override
  void initState() {
    super.initState(); 
      _getToken();  
      //restartClick();
  }
  String _phone;
  ScreenType screenType;
  bool _isOtpValid = false;
  var fcmToken;
  var _codeController = TextEditingController();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    
 _getToken(){
    _firebaseMessaging.getToken().then((deviceToken){
      fcmToken = deviceToken;
     print("Device Token : $deviceToken");
    });
  }

  _sendOTPCodeAction() async {

    if (_isOtpValid) {

      final iReg = RegExp(r'(\d+)');
      var phoneNumber = iReg.allMatches(_phone).map((m) => m.group(0)).join('');

      var codeOTP = iReg.allMatches(_codeController.text).map((m) => m.group(0)).join('');      
      print(phoneNumber);
      if (screenType == ScreenType.registrationType) {
        await ServerManager(context).checkOTPRequest(phoneNumber, codeOTP, fcmToken ,(code){
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => new RegisterUserController(_phone)));
                  
        }, (error) {});
      }else{
        print({
          "phone": "$phoneNumber",
          "otp": codeOTP,
          "fcmToken": fcmToken
        });
        final response = await http.post(
            'https://api.lemmi.app/api/user/check-otpLogin',
            body: {
              "phone": "$phoneNumber",
              "otp": codeOTP,
              "fcmToken": "fcmToken"
            });
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          print("body = " + response.body);

          BaseResponse baseResponse = BaseResponse.fromJson(
              json.decode(response.body));

          var body = jsonDecode(response.body);
          var code = "${body["code"]}";

          if(code == "203") {

          Dialogs().alert(context, AppLocalizations.of(context).translate('validError'), AppLocalizations.of(context).translate('wrongOTP'));

         } else if (baseResponse.code != 201) {
         
          }else{
            var result = body["result"];

            final storage = new FlutterSecureStorage();

            var accessToken = "${result["accesToken"]}";
            var refreshToken = "${result["refresshToken"]}";

            storage.write(key: 'token', value: accessToken);

            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

            sharedPreferences.setString("token", accessToken);

            Navigator.of(context).pushReplacementNamed('home');

          }
        }
        else {
          // If the server did not return a 200 OK response,
          // then throw an exception.

          throw Exception('Failed to load');
        }



//        await ServerManager(context).loginCheckOTPRequest(phoneNumber, codeOTP, (token, refreshToken) {
//
//          final storage = new FlutterSecureStorage();
//
//          storage.write(key: 'token', value: refreshToken);
//
//          //prefs.setString("token", token);
//          //prefs.setString("refresh_token", refreshToken);
//          Navigator.of(context).pushReplacementNamed('home');
//          buildCategory();
//
//
//
//        }, (error) {
//
//        });
      }

    }
  }

  _repeatSms() async {    
      final iReg = RegExp(r'(\d+)');
      var phoneNumber = iReg.allMatches(_phone).map((m) => m.group(0)).join('');

      if (screenType == ScreenType.registrationType) {
        await ServerManager(context).checkMobileRequest("$phoneNumber", (code){         

          setState((){
            initState();
          });        

        }, (error) {

        });
      }else{

        await ServerManager(context).loginMobileRequest("$phoneNumber", (code){

            setState((){
            initState();
          });
          
        }, (error) {

        });
          
      } 
  }
restartClick() async {
    final response =
    await http.get('https://api.lemmi.app/api/refresh/otp?phone=' + widget._phone);
    BaseResponse baseResponse = BaseResponse.fromJson(
        json.decode(response.body));
    print(baseResponse.toString());
    if (baseResponse.code != 200) {
      try{
        var showToast = Fluttertoast.showToast(
            msg: baseResponse.errorCode.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } catch (error) {

      }

    }
    else {}
  }
  //TextStyle style = TextStyle(fontFamily: 'Roboto', fontSize: 36.0);

  @override
  Widget build(BuildContext context) {
    final codeField = new TextFormField(
        keyboardType: TextInputType.number,
        style: styles.TextStyles.darkGRegularText32,
        textAlign: TextAlign.left,
        controller: _codeController,
        decoration: new InputDecoration(
            hintText: '0-0-0-0',
            hintStyle: styles.TextStyles.darkGTextTrans32,
            border: InputBorder.none),
        inputFormatters: [
          MaskedTextInputFormatterShifter(
              maskONE: "X-X-X-X", maskTWO: "X X X X")
        ],
        onSaved: (String value) {
          _codeController.text = value;
          // this._data.email = value;
        },
        onChanged: (String value) {
          setState(() {
            _isOtpValid = value.length == 7;
          });
        });

    final bottomButton = new MaterialButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          //375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          // color: Colors.red,
          child: Text(
            AppLocalizations.of(context).translate('next'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _isOtpValid
                    ? styles.Colors.whiteColor
                    : styles.Colors.whiteTrans,
                fontFamily: 'Gilroy',
                fontSize: 18),
          ),
        ),
        onPressed: _sendOTPCodeAction);

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
                      alignment: Alignment.center,
                      child: new Stack(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                              padding: const EdgeInsets.only(
                                  top: 10.0, bottom: 0.0),
                              child: new Text(AppLocalizations.of(context).translate('sms'),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14)),
                          ),
                          SizedBox(height: 20,),
                          Align(
                            alignment: Alignment.center,
                              //alignment: Alignment(0.0, 0.0),                             
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                      width: 135,
                                      margin: EdgeInsets.only(top: 50, left:10),                                                                           
                                      //alignment: Alignment.center,
                                      child: codeField)
                                ],
                              )),




                        ],
                      ),
                    ),

                  ])),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                new Container(
//                        padding: new EdgeInsets.only(top: 40),
                        child: new Center(

                          child: InkWell(
                            onTap: (){
                              _repeatSms();
                            },
                            child: new Text(AppLocalizations.of(context).translate('noSms'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Gilroy',
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 12
                              )
                              ),
                          ),
                        ),
                        margin: EdgeInsets.only(bottom: 5
                            )
                    ),
                  bottomButton
                ],
              ),
            )
          ]),
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
        )),
      ]),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
