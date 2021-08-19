
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app_localizations.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Widgets.dart';
import 'package:kaban/Styles.dart' as styles;


class FakeMainController extends StatefulWidget {
  FakeMainController({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FakeMainControllerState createState() => _FakeMainControllerState();
}

class _FakeMainControllerState extends State<FakeMainController> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];
  final storage = new FlutterSecureStorage();
  String road;
  var fcmToken;
  int orderIndex;
  String id;
  List<dynamic> send = List();

  void initState() {  
  getSpecialistListRequestNew(); 
  
   super.initState();    
  }
  
  _selectCategory() async {    
    await ServerManager(context).getSpecialistsIdRequest(id, (result) {
      }, (error){ });
  }

  void getSpecialistListRequestNew() async {  
   
   ServerManager(context).getSpecialistsRequest((result) {

      List<Map<String, String>> firstList = [];
      int j = 0; int z = 0;
       print(result.length);
        for(int i = 0; i < result.length; i++){
        Map<String, dynamic> element = result.elementAt(i);  
        firstList.add({'name': "${element['name']}", 'image': 'https://api.lemmi.app/${element['spcialist']['photo']}', 'id':'${element['spcialistId']}'});
        j++;        
        if (j <= 1){  
          if(i == result.length -1) {       
          send.insert(z,firstList);
          z++;}
        }else{          
          send.insert(z,firstList);
          firstList = [];
          z++;
          j = 0;
          }
        }
      print(send);
      setState(() {        
      });
      
    }, (error){

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
        backgroundColor: Color.fromRGBO(247, 249, 252, 0),
        appBar: FakeMainAppBar(
            height: 135,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate('titleChooseSpecialist')
        ),
        body: ListView.builder(
            itemCount: send.length,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(top: 20, bottom: 60),
            itemBuilder: (context, int index) {
              return new GestureDetector(
                child: HorizontalList(
                  mainList:  send.elementAt(index),                
                ),
                onTap: ()async {
                  id = "$index";
                 await _selectCategory();},
              );             
            })
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

