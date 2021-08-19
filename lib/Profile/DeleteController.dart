import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kaban/ServerManager.dart';
import '../Widgets.dart';
import '../app_localizations.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DeleteController extends StatefulWidget {
  DeleteController(this.result,{Key key, this.title}) : super(key: key);
  final bool result;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _DeleteControllerState createState() => _DeleteControllerState();
}

class _DeleteControllerState extends State<DeleteController> {
  final storage = new FlutterSecureStorage();
  
   _goToMainController() async {
    String token = await storage.read(key: 'token');
    //print(token);   
      print(widget.result);     
      return  showDialog(
    context: context,
    builder: (BuildContext context) {
      return widget.result == true 
      ?CupertinoAlertDialog(
          title:  Text(''),
          content: Text ("Ваш аккаунт буде видалено протягом 30 днів"),
        actions: [
        CupertinoDialogAction(child: 
        Text("OK",style:TextStyle(
          fontFamily: 'Roboto-Medium',
        fontSize: 14,
        color: Color.fromRGBO(221,98,67,1))),
       onPressed:() async {          
           var accessToken = "";
    storage.write(key: 'refresh_token', value: accessToken);
    storage.deleteAll(); 
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("token", accessToken);    
   Navigator.of(context).pushReplacementNamed('login');
        })]):
        CupertinoAlertDialog(
        title:  Text(''),
          content: Text ("Ми не можемо видалити ваш аккаунт. Ви маєте незавершенні завдання"),
        actions: [
        CupertinoDialogAction(child: Text("OK",style:TextStyle(
          fontFamily: 'Roboto-Medium',
        fontSize: 14,
        color: Color.fromRGBO(221,98,67,1))),
       onPressed:(){          
         Navigator.pop(context);
        })]);
    
    });
}
     
    

  _goToProfileController() async {
    Navigator.pop(context);
  }
   
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: styles.Colors.background,

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: Container(

       child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
           children: <Widget>[
             new SizedBox(height: 120,),
             new Expanded(
                 child: Container(
                   margin: EdgeInsets.all(0),
                   child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: <Widget>[
                         Container(
                           height: 199.47,
                           child:Image(
                           image: AssetImage('assets/logo.png'),
                           width: 225.4,                           
                         )),
                         new SizedBox(
                           height: 10,
                         ),
                         Text(AppLocalizations.of(context).translate('ensureDelete'),
                           textAlign: TextAlign.center,
                           style:styles.TextStyles.darkText24,
                         ),
                       ]
                   ),
                 )

               //)
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
                            child: Text(AppLocalizations.of(context).translate('yesDelete'), style: styles.TextStyles.orangeText18,),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 60,
                          child: MaterialButton(
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(16.0),
                            ),
                            height: 50,
                            color: styles.Colors.orange,
                            onPressed: () => _goToProfileController(),
                            child: Text(AppLocalizations.of(context).translate('noDelete'), style: styles.TextStyles.whiteText18,),
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
    ));
  }
}
