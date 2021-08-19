import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import 'package:kaban/Authentication/WellcomeMainController.dart';
import 'package:kaban/Widgets.dart';
import '../Styles.dart' as styles;
import 'package:kaban/ServerManager.dart';
import '../app_localizations.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterUserController extends StatefulWidget {
  //RegisterUserController({Key key, this.title}) : super(key: key);
  RegisterUserController(this._phone, {Key key, this.firstname}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
 // final String title;
  final String firstname;
  final String _phone;

  @override
  _RegisterUserControllerState createState() => _RegisterUserControllerState(_phone);
}

class _RegisterUserControllerState extends State<RegisterUserController> {
  _RegisterUserControllerState(this._phone);
  @override
  
  final _usernameController = TextEditingController();
// Create a text controller and use it to retrieve the current value
// of the TextField.
  final String _phone;
  var _gender = "";
  String firstname;
  bool _validateName = false;
  bool _genderSet = false;

 

  
  void initState() {
    super.initState();
  }

  _finishRegistrationButtonAction() async {

    String firstname = _usernameController.text;
    var gender = "male";

    if(_validateName){
    SharedPreferences prefs =await SharedPreferences.getInstance();
      final iReg = RegExp(r'(\d+)');
      var phoneNumber = iReg.allMatches(_phone).map((m) => m.group(0)).join('');
      print(prefs.getString("email"));
    await ServerManager(context).registerUserRequest(firstname , gender, phoneNumber,prefs.getString("email"), (token, refreshToke){

      setToken(token, refreshToke);
      
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new WellcomeMainController()),);

      }, (error) {

      });

      
    } else{ 

      Dialogs().errorsAlert(context);
    
    }
 
  }

  void setToken(String token, String refreshToke) async {
    final storage = new FlutterSecureStorage();

    var accessToken = "$token";
    var refreshToken = "$refreshToke";

    storage.write(key: 'token', value: accessToken);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString("token", accessToken);
  }

    
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _usernameController.dispose();
    super.dispose();
  }

  TextStyle style = TextStyle(fontFamily: 'Roboto', fontSize: 36.0);

  @override
  Widget build(BuildContext context) {

    final userNameField = new Theme(
          data: new ThemeData(
          primaryColor: Color(0XFFADADAD),
          ),child:new TextFormField(
            controller: _usernameController,
        keyboardType: TextInputType.text,
        autofocus: true,
        style: TextStyle(fontFamily: 'Gilroy',
            fontStyle: FontStyle.normal,
            fontSize: 24
        ),
        decoration: new InputDecoration(
           enabledBorder: new UnderlineInputBorder(
                 borderSide: new BorderSide(color: Color(0xFFADADAD), style: BorderStyle.solid)),
          hintText: AppLocalizations.of(context).translate('hintName'),
          hintStyle: TextStyle(fontFamily: 'Gilroy',
              fontStyle: FontStyle.normal,
              color: Color(0xFFADADAD),
              fontSize: 24
          ),
        ),
        onSaved: (String value) {
          this.firstname = value;
          firstname = _usernameController.text = value;
        },
        onChanged: (String value) {
        setState(() {
          _usernameController.text.isEmpty ? _validateName=false : _validateName=true;
          
         });
      },
          ),
          
    );

    final bottomButton = new MaterialButton(
      elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,//375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: Text(AppLocalizations.of(context).translate('next'),
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText18),
        ),
        onPressed: 
         _finishRegistrationButtonAction,
          );
    final topNavigationBar = Widgets().topBar(context);
   /* var genderMale = GestureDetector(
      child: Container(
        width: 30,
        height: 74,
        child: Image.asset(_gender == "male"
            ? 'assets/gender_man_selected_icon.png'
            : 'assets/gender_man_unselected_icon.png'),
      ),
      onTap: () {
        setState(() {
          _gender = "male";
          _genderSet = true;

        });
      },
    );
    var genderFemale = GestureDetector(
      child: Container(
        width: 32,
        height: 74,
        child: Image.asset(_gender == "female"
            ? 'assets/gender_woman_selected_icon.png'
            : 'assets/gender_woman_unselected_icon.png'),
      ),
      onTap: () {
        setState(() {
          _gender = "female";
          _genderSet = true;
        });
      },
    );
*/

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: styles.Colors.background,

        body:  Stack(children: <Widget>[
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

                    child: new Form(child: new ListView(
                      //physics: NeverScrollableScrollPhysics(),
                        children: <Widget>[

                          topNavigationBar,

                          new SizedBox(height: 110),

                          /*new Container(
                            //alignment: Alignment.center,
                            child: new Stack(


                              children: <Widget>[

                                new Container(
                                  //alignment: Alignment.center,
                                  padding: const EdgeInsets.only(top: 10.0, left: 30.0, bottom: 15.0),
                                  child: new Text(AppLocalizations.of(context).translate('hintGender'),
                                    textAlign: TextAlign.left,
                                    style: styles.TextStyles.darkText24,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // new SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              genderMale,
                              SizedBox(width: 40),
                              genderFemale
                            ],
                          ),
*/
          //                new SizedBox(height: 60,),
                          new Container(
                            //alignment: Alignment.center,
                            child: new Stack(
                              children: <Widget>[
                                new Container(
                                  //alignment: Alignment.center,
                                  padding: const EdgeInsets.only(top: 0, left: 30.0, bottom: 0.0),
                                  child: new Text(AppLocalizations.of(context).translate('appeal'),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontFamily: 'Gilroy',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 24
                                      )
                                  ),
                                ),
                                new Container(
                                  //alignment: Alignment.center,
                                  //width: MediaQuery.of(context).size.width - 60,
                                  padding: const EdgeInsets.only(top: 31.0, left: 30.0, right: 30.0),
                                  child: userNameField,
                                ),
                              ],
                            ),
                          ),
                          new SizedBox(
                            height: 100,
                          )
                        ]
                    )),

                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
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
    );
  }
}


