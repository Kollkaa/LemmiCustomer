import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:kaban/Authentication/Story.dart';

import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Profile/MessengersController.dart';
import 'package:kaban/Profile/RulesController.dart';
import 'package:kaban/Profile/SettingsController.dart';
import 'package:kaban/Profile/WebViewController.dart';

import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import 'package:kaban/Managers.dart';

class ProfileController extends StatefulWidget {
  ProfileController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ProfileControllerState createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> {  

  Test test = Test();
  String image;

  void initState() {
    getProfileInfo();
    super.initState();
  }

  getProfileInfo() async{

    await ServerManager(context).getUserInfoRequest((Map user){
      test.firstName = user["first_name"];
      _nameController.text = user["first_name"];
     setState(() {
        image = 'https://api.lemmi.app/${user["photo"]}';
     }); 
     _surnameController.text = user["last_name"];
     _phoneController.text = user["phone"];
      test.phone = user["phone"]; 
    }, (error) {

    });
  }

  var _nameController = TextEditingController();
  var _surnameController = TextEditingController();
  var _phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    
    final profileActions = [   
    /*{"title": "FAQ", "action": 'faq'},
    {"title": AppLocalizations.of(context).translate('aboutUs'), "action": 'about'},
    {"title": "Правила", "action": 'rules'},*/
    {"title": AppLocalizations.of(context).translate('settings'), "action": 'settings'},
  ];
              
    _supportAction(BuildContext context) async {
      var phone = "+380682984428";                 
        showModalBottomSheet(
                backgroundColor:Colors.transparent,
                  context: context,
                  builder: (context) => Container(          
                    alignment: Alignment.bottomCenter,
                    height:350,
                    color: Colors.transparent,
                    child:FractionallySizedBox(
                    heightFactor: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(10),
                            topRight: const Radius.circular(10),
                          ),
                        ),
                        child: DraggableScrollableSheet(
                          initialChildSize: 1,
                          minChildSize: 0.8,
                          builder: (BuildContext context,
                              ScrollController scrollController) {
                            return Material(
                                elevation: 4,
                                child: new InkWell(
                                onTap: () {
                               },
                                child: MessengersController(phone),
                                ));
                          },
                        )),
                      ),
                    ),
                  ),
                  isScrollControlled: true).then((onValue){
                    setState((){
                             
                  });});
            
                //var url ="sms:380970000000";
                //var url ="whatsapp://send?phone=+380970000000";
                //await launch(url);     
                //        Navigator.of(context).push(CupertinoPageRoute(
                //    builder: (context) => new SupportController()));
          
              }
              
            setJWTLanguage() async {
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          
              sharedPreferences.setString("language", "uk");
              setState(() {
                
              });
            }
            
              _faqAction() async {
              //  setJWTLanguage();
                var type = "faq";
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => new WebViewController(type)));          
              }
          
              _aboutAction() async {
                var type = "about";
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => new WebViewController(type)));
              }
          
              _rulesAction() async {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => new RulesController()));
              }
          
              _settingsAction() async {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => new SettingsController()));
              }
          
              // This method is rerun every time setState is called, for instance as done
              // by the _incrementCounter method above.
              //
              // The Flutter framework has been optimized to make rerunning build methods
              // fast, so that you can just rebuild anything that needs updating rather
              // than having to individually change instances of widgets.
              return Scaffold(
                backgroundColor: styles.Colors.background,
          
                appBar: ProfileAppBar(
                    height: 170,
                    topConstraint: MediaQuery.of(context).padding.top,
                    titleAppBar: _nameController.text,
                    userName: "",
                    userImage: "$image",),
          
                body: ListView.separated(
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          trailing: Container(
                            child: Image(
                              image: AssetImage('assets/arrow_next.png'),
                              width: 15,
                              height: 15,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color:  Color.fromRGBO(0, 0, 0, 0),
                                  blurRadius: 6.0, // has the effect of softening the shadow
                                  spreadRadius: 1.0, // has the effect of extending the shadow
                                  offset: Offset(
                                    0.0, // horizontal, move right 10
                                    2.0, // vertical, move down 10
                                  ),
                                )
                              ],
                              borderRadius: new BorderRadius.all(
                                  Radius.circular(15)
                              ),
                            ),
                          ),
                          contentPadding: EdgeInsets.only(left: 30, right: 30, top:10, bottom:10),
                          title:
                              Text(AppLocalizations.of(context).translate('support'), style: styles.TextStyles.darkText18),
                          onTap: () => {
                            _supportAction(context),
                          },
                        );              
                      } else {
                        return ListTile(
                            trailing: Image(
                              image: AssetImage('assets/arrow_next.png'),
                              width: 15,
                              height: 15,
                            ),
                            contentPadding: EdgeInsets.only(left: 30, top:10, bottom:10, right: 30),
                            title:
                                Text("${profileActions[index - 1]["title"]}", //'hello',
                                    style: styles.TextStyles.darkText18),
                            onTap: () {
                              var actionKey = '${profileActions[index - 1]["action"]}';
                              
                              if (actionKey == 'about') {
                                _aboutAction();
                              } else if (actionKey == 'rules') {
                                _rulesAction();
                              } else if (actionKey == 'settings') {
                                _settingsAction();
                              } else if (actionKey == 'faq') {
                                _faqAction();
                              } 
                            });
                      }
                    },
                    separatorBuilder: (context, index) => Divider(
                          color: Color(0xFFC4C4C4),
                          indent: 30,
                          endIndent: 30,
                          height: 1,
                        ),
                    itemCount: profileActions.length + 1 ,
                    padding: EdgeInsets.only(top: 10),//items.length
                    ),
          
                // This trailing comma makes auto-formatting nicer for build methods.
              );
            }
          }
          

