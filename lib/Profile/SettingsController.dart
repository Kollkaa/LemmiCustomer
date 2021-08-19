import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaban/Profile/ExitController.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ServerManager.dart';
import '../Widgets.dart';
import '../app_localizations.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:kaban/Styles.dart' as styles;

import 'DeleteController.dart';

class SettingsController extends StatefulWidget {
  SettingsController({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsControllerState createState() => _SettingsControllerState();
}

class _SettingsControllerState extends State<SettingsController> {
  bool _suggestions;
  bool _executorlocation;
  bool _comment;
  Map<String, String> values;
  bool _location = false;
  bool _photo = false;
  bool _calendar = false;
  final storage = new FlutterSecureStorage();  

  void initState() {
    storeData();
    super.initState();    
    switchesPosition();
  }

  boolGet(String value, bool value2){
    if(value =='false'){
      value2 = false;
    }else{
      value2 = true; }
    return value2;
  }

  storeData() async {
    values = await storage.readAll();
   _suggestions = await boolGet(values["suggestions"], _suggestions);
   _executorlocation= await boolGet(values["executorlocation"], _executorlocation);
   _comment= await boolGet(values["comment"], _comment); 
    setState((){
    });    
  }

  _exitAction() async {
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => new ExitController()));
  } 
  _deleteAction() async {
    await ServerManager(context).deleteRequest((result) {
      print(result);
      //delete = result;
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => new DeleteController(result)));
        }, (errorCode) { });
      
  } 

  Widget _switchesList() {

    return Column(children: <Widget>[

      new ListTile(
        contentPadding: EdgeInsets.only(top: 10, left: 30, right: 40),
        trailing: Image(
                    image: AssetImage('assets/arrow_next.png'),
                    width: 15,
                    height: 15,
                  ),
        title: Text(AppLocalizations.of(context).translate('deletPersDetails'), //'hello',
                          style: styles.TextStyles.darkText18),
        onTap: () {_deleteAction();}),

      new ListTile(
        contentPadding: EdgeInsets.only(top: 10, left: 30, right: 40),
        trailing: Image(
                    image: AssetImage('assets/arrow_next.png'),
                    width: 15,
                    height: 15,
                  ),
        title: Text(AppLocalizations.of(context).translate('exit'), //'hello',
                          style: styles.TextStyles.darkText18),
        onTap: () {_exitAction();})
    ]);
  }
PermissionStatus _status,  _statusP, _statusK;
  //create list
  void switchesPosition()async {
    final PermissionStatus _status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse);
      if (_status == PermissionStatus.granted){
      setState((){ _location = true; });
      } else{
      setState((){_location = false;}); 
      }
      final PermissionStatus _statusP = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
      if(_statusP == PermissionStatus.granted){
      setState((){ _photo = true; });     
      }else {
      setState((){ _photo = false;});
      }
      final PermissionStatus _statusK = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.calendar);
      if(_statusK == PermissionStatus.granted){
      setState((){ _calendar = true; });     
      }else {
      setState((){ _calendar = false;});
      }    
  }
  void _updateStatuses(Map<PermissionGroup, PermissionStatus> statuses){
   final status = statuses[PermissionGroup.locationWhenInUse];
    if (status != _status){
      setState((){_status = status;}); 
    }
    final statusP = statuses[PermissionGroup.storage];
    if (statusP != _statusP){
      setState((){_statusP = statusP;}); 
    }
    final statusK = statuses[PermissionGroup.calendar];
    if (statusK != _statusK){
      setState((){_statusK = statusK;}); 
    }  
  }
  void _updateStatusP(PermissionStatus statusP){
    if (statusP != _statusP){
      setState((){
        _statusP = statusP;
      });
    }   
  }
  void _updateStatusK(PermissionStatus statusK){
    if (statusK != _statusK){
      setState((){
        _statusK = statusK;
      });
    }   
  }
  void _updateStatus(PermissionStatus status){
    if (status != _status){
      setState((){
        _status = status;
      });
    }   


  }
  void _askPermission(){
    PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse])
    .then(_onStatusRequested);
  }
  void _askPermissionP(){
    PermissionHandler().requestPermissions([PermissionGroup.storage])
    .then(_onStatusRequested);
  }
  void _askPermissionK(){
    PermissionHandler().requestPermissions([PermissionGroup.calendar])
    .then(_onStatusRequested);
  }

  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statuses){
    final status = statuses[PermissionGroup.locationWhenInUse];
   if (status == PermissionStatus.granted) {
     PermissionHandler().openAppSettings();
   }
     else{
       _updateStatus(status);
     }
    final statusP = statuses[PermissionGroup.storage];
    if (statusP == PermissionStatus.granted) {
    PermissionHandler().openAppSettings();
    }
     else{_updateStatusP(statusP); } 
    //else {_updateStatuses(statuses);}
    final statusK = statuses[PermissionGroup.calendar];
    if (statusK == PermissionStatus.granted) {
     PermissionHandler().openAppSettings();
    }
     else{_updateStatusK(statusK);}
   //else {_updateStatuses(statuses);}
  }
  @override
  Widget build(BuildContext context) {
   final rulesList = [
    {"title": AppLocalizations.of(context).translate('geoposition'), "action": "location", "type": "switch"},
    {"title": "Фото", "action": "photo", "type": "switch"},
    {"title": AppLocalizations.of(context).translate('calendar'), "action": "calendar", "type": "switch"}
  ];

    Widget _buildSwitchesList() {
    return ListView(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
        children: <Widget>[
          new ListTile(
              contentPadding: EdgeInsets.only(top: 5, left: 30, right: 30),
              trailing: Container(
                padding: EdgeInsets.all(0),
                child: CupertinoSwitch(
                  value: _location,
                  onChanged: (bool value) {
                    setState(() {
                      _location = value;

                    });
                  },
                ),
                height: 30,
                width: 64,
              ),
              onTap: () {
                setState(() {
                  _location = !_location;                 
                });
              },
              title: Text(AppLocalizations.of(context).translate('geoposition'),
                  style: styles.TextStyles.darkRegularText18)),
          new ListTile(
              contentPadding: EdgeInsets.only(top: 5, left: 30, right: 30),
              trailing: Container(
                padding: EdgeInsets.all(0),
                child: CupertinoSwitch(
                  value: _photo,
                  onChanged: (bool value) {
                    setState(() {
                      _photo = value;
                    });
                  },
                ),
                height: 30,
                width: 64,
              ),
              onTap: () {
                setState(() {
                  _photo = !_photo;
                  
                });
              },
              title: Text("Фото", style: styles.TextStyles.darkRegularText18)),
          Widgets().horizontalLine(),
          new SwitchListTile(
            contentPadding: EdgeInsets.only(left: 30, right: 30),
            value: _photo,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() {
                _photo = value;
              });
            },
            title: Text("Фото", style: styles.TextStyles.darkText21),
          ),
          new SwitchListTile(
            contentPadding: EdgeInsets.only(left: 30, right: 30),
            value: _calendar,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() {
                _calendar = value;
              });
            },
            title: Text(AppLocalizations.of(context).translate('calendar'), style: styles.TextStyles.darkText21),
          )
        ]);
  }

  Widget _buildList() {
    return new ListView.separated(
      padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
      
      itemBuilder: (context, index) {
        var detailItem = rulesList[index];

        var type = "${detailItem["type"]}";
if (type == "switch") {

          var actionKey = "${detailItem["action"]}";

          return new ListTile(
              contentPadding: EdgeInsets.only(top: 0, left: 30, right: 30),
              trailing: Container(
                padding: EdgeInsets.all(0),
                child: CupertinoSwitch(
                  value: actionKey == "location" ?
                   _location : actionKey == "photo" ?
                    _photo : //actionKey == "contacts" ? _contacts :
                     actionKey == "calendar" ? _calendar : false,
                  onChanged: (bool value) {
                    setState(() {
                      

                      if (actionKey == "location") {
                        _location = value;
                        _askPermission();                        
                                              
                      }else if (actionKey == "photo") {
                        _photo = value;
                        _askPermissionP();
                      }else if (actionKey == "calendar") {
                        _calendar = value;
                        _askPermissionK();
                      }

                    });
                  },
                ),
                height: 30,
                width: 64,
              ),
              onTap: () {
                
                setState(() {
                  if (actionKey == "location") {
                    _location = !_location;
                    _askPermission();
                  }else if (actionKey == "photo") {
                    _photo = !_photo;
                    _askPermissionP();
                  }else if (actionKey == "calendar") {
                    _calendar = !_calendar;
                    _askPermissionK();
                  }
                });
              },
              title: Text('${rulesList[index]["title"]}', style: styles.TextStyles.darkText24));
              
        }else{
          return null;
        }

      },

      separatorBuilder: (context, index) {

        var detailItem = rulesList[index];

        var type = "${detailItem["type"]}";

        return Divider(
          color: type == "list" ? Color.fromRGBO(255, 178, 158, 1.0) : Colors
              .transparent,
          indent: 30,
          endIndent: 30,
        );
      },
      itemCount: rulesList.length,
    );
  }

    return Scaffold(
        backgroundColor: styles.Colors.background,
        appBar: CreateAppBar(
            height: 118,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate('settings'), showAddButton: false),
        body: //SingleChildScrollView(
    //child:
       Column(
    children: [
      Container( height: 200,
        child:GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: _buildList()           
            )),
            Container(
        margin:EdgeInsets.only(top: 10, left: 30, right: 30),
              height: 1,
              color: Color(0x88ADADAD)),
             GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: 
                      _switchesList(),
                 //   ]
                   // )
            //    )
           // )
        )]
      //  )
    ));
  }
}
