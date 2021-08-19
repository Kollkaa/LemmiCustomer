import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaban/Authentication/AuthorizationController.dart';

import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Authentication/CheckMobileController.dart';
import 'package:kaban/CreateOrder/CreateOrderDescriptionController.dart';

import '../app_localizations.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;

class SearchController extends StatefulWidget {
  
  SearchController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  _SearchControllerState createState() => _SearchControllerState();
}

class _SearchControllerState extends State<SearchController> {

  Task task = Task();
  String id = "";
  String name = "";
  bool autorisated = false;
  TextEditingController editingController = TextEditingController();
  var items = List<Map<String, String>>();
  List<Map<String, String>> duplicateItems = []; 

  void initState() {
  showList();        
  super.initState();}
  

   showList() async {
    _authentication();
    task.published = false;
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      await ServerManager(context).searchSpecialistsRequest((result){           
      var _length= result["result"].length;
      for(int i = 0; i< _length; i++){
        var element = result['result'].elementAt(i);
        var globalName = "${element["specialist"]["name"]}";
        var globalId = "${element["specialist"]["spcialistId"]}";
        var services = element["services"];
        var _lenth = services.length;
        for(int j = 0; j< _lenth; j++){
        duplicateItems.add({"title":"${services.elementAt(j)['name']}", "firstId":globalId,"specialist":globalName,"id":"${services.elementAt(j)['id']}"}); 
        } 
      } 
        //items.addAll(duplicateItems); 
        setState((){});
    }, (error){});
    });
  }
    _authorizationController() async { 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new AuthorizationController(ScreenType.registrationType)),
    );
  }
    
  void _authentication() async {
     //  String token = sharedPreferences.getString("token").toString();
    //bool autorisated = false;
    final storage = new FlutterSecureStorage();
    String token = null;
    var tok = await storage.read(key: 'token').whenComplete(() {
      autorisated = true;
    }).then((val) {
      if (val == null || val.isEmpty) {
        autorisated = false;
      }else{
        autorisated = true;
        token = val;
      }
    });

    if (tok != null && token == null) {
      token = tok;
    }print("token = $token");     

    if (autorisated == true) {
      if (token == null || token.isEmpty) {
      }else{//if registered and log in
        //print("token = " + token);
      }
    }else{} 
  }

  void filterSearchResults(String query) {
    List<Map<String, String>> dummySearchList = List<Map<String, String>>();
    dummySearchList.addAll(duplicateItems);
    if(query.isNotEmpty) {
      List<Map<String, String>> dummyListData = List<Map<String, String>>();
      dummySearchList.forEach((item) {
        if(item["specialist"].contains(query.toLowerCase())) {
          dummyListData.add(item);
        }else {
          if(item["title"].toLowerCase().contains(query.toLowerCase())) {
            dummyListData.add(item);
          }
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }
  
  void selectOrder(Map<String, String> orderInfo) {
    Navigator.of(context).push(
        CupertinoPageRoute(
           builder: (context) => CreateOrderDescriptionController(task:task)
        )
    );
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
        appBar: SearchAppBar(
          textField: TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: editingController,
            style: TextStyle(fontFamily: 'Roboto-Regular',
                fontStyle: FontStyle.normal,
                fontSize: 18,
                color: Color.fromRGBO(51, 51, 51, 1.0)
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('subName'),
                prefixIcon: Icon(Icons.search,
                color: Colors.grey),
               focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
  ),
                border: UnderlineInputBorder(
                )
            ),
          ),
            height: 128,
            topConstraint: MediaQuery.of(context).padding.top,
        ),
        body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },

        child: items.length == 0
    ? Align(child:Text(AppLocalizations.of(context).translate('searching'), style: styles.TextStyles.darkGText18,  textAlign: TextAlign.center,),
    alignment: Alignment.center,)
   :    
    ListView.separated(
            itemBuilder: (context, index) {
          return ListTile(
            trailing: Image(image:
            AssetImage('assets/arrow_next_orange.png'),
              width: 15,
              height: 15,
            ),
            contentPadding: EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 0),
            title: Text('${items[index]["title"]}',
                style: styles.TextStyles.darkText24),
            subtitle: Text('${items[index]["specialist"]}',
                style: styles.TextStyles.darkRegularText14),
            onTap: () {
              if(autorisated == true){
              selectOrder(items[index]);  
              }else{
              _authorizationController();
              } 
              task.globalCategory = "${items[index]['firstId']}";             
              task.services_id = "${items[index]["id"]}";
              task.category = "${items[index]["title"]}";
            }
          );
        },
            separatorBuilder: (context, index) => Divider(
              color: Color(0XFFADADAD),
              indent: 30,
              endIndent: 30,
              height: 1,
            ),
            itemCount: items.length),
      )
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
