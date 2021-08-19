import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:flutter/cupertino.dart';

import '../app_localizations.dart';
import 'package:kaban/Widgets.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:permission_handler/permission_handler.dart';

import 'WebViewController.dart';

class RulesController extends StatefulWidget {
  RulesController({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RulesControllerState createState() => _RulesControllerState();
}

class _RulesControllerState extends State<RulesController> {
  bool _location = false;
  bool _photo = false;
  bool _contacts = false;
  bool _calendar = false;

  

  PermissionStatus _status, _statusC, _statusP, _statusK;
  //create list
  void switchesPosition()async {
    final PermissionStatus _status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse);
      if (_status == PermissionStatus.granted){
      setState((){ _location = true; });
      } else{
      setState((){_location = false;}); 
      }
    final PermissionStatus _statusC = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
      if(_statusC == PermissionStatus.granted){
      setState((){ _contacts = true; });     
      }else {
      setState((){ _contacts = false;});
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



  void initState() {
    super.initState(); 
    switchesPosition();   
   /* PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse)
    .then(_updateStatus);*/

  }
  void _updateStatuses(Map<PermissionGroup, PermissionStatus> statuses){
   final status = statuses[PermissionGroup.locationWhenInUse];
    if (status != _status){
      setState((){_status = status;}); 
    }
    final statusC = statuses[PermissionGroup.contacts];
    if (statusC != _statusC){
      setState((){_statusC = statusC;}); 
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
  void _updateCStatus(PermissionStatus statusC){
     if (statusC != _statusC){
      setState((){
        _statusC = statusC;
      });
    }
  }
  void _askPermission(){
    PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse])
    .then(_onStatusRequested);
  }
  void _askPermissionC(){
   PermissionHandler().requestPermissions([PermissionGroup.contacts])
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
     PermissionHandler().openAppSettings();}     
     else{_updateStatus(status);}       
    // else {_updateStatuses(statuses);}
    final statusC = statuses[PermissionGroup.contacts];
    if (statusC == PermissionStatus.granted) {
     PermissionHandler().openAppSettings();}
     else{ _updateCStatus(statusC);}     
     //else {_updateStatuses(statuses);}
    final statusP = statuses[PermissionGroup.storage];
    if (statusP == PermissionStatus.granted) {
     PermissionHandler().openAppSettings();}
     else{_updateStatusP(statusC); } 
    //else {_updateStatuses(statuses);}
    final statusK = statuses[PermissionGroup.calendar];
    if (statusK == PermissionStatus.granted) {
     PermissionHandler().openAppSettings();}
     else{_updateStatusK(statusC);}
   //else {_updateStatuses(statuses);}
  }

  @override
  Widget build(BuildContext context) {
     final rulesList = [
    //{"title": AppLocalizations.of(context).translate('deletPersDetails'), "action": "delete", "type": "list"},
    {"title": AppLocalizations.of(context).translate('geoposition'), "action": "location", "type": "switch"},
    {"title": "Фото", "action": "photo", "type": "switch"},
    {"title": AppLocalizations.of(context).translate('phonebook'), "action": "contacts", "type": "switch"},
    {"title": AppLocalizations.of(context).translate('calendar'), "action": "calendar", "type": "switch"}
  ];

    Widget _buildSwitchesList() {
    return ListView(
        // physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(30, 20, 30, 0),

//      crossAxisAlignment: CrossAxisAlignment.start,
//      mainAxisSize: MainAxisSize.max,
//      mainAxisAlignment: MainAxisAlignment.start,

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
            value: _contacts,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() {
                _contacts = value;
              });
            },
            title:
                Text(AppLocalizations.of(context).translate('phonebook'), style: styles.TextStyles.darkText21),
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
      padding: EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 50),
      //physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var detailItem = rulesList[index];

        var type = "${detailItem["type"]}";
if (type == "switch") {

          var actionKey = "${detailItem["action"]}";

          return new ListTile(
              contentPadding: EdgeInsets.only(top: 5, left: 30, right: 30),
              trailing: Container(
                padding: EdgeInsets.all(0),
                child: CupertinoSwitch(
                  value: actionKey == "location" ? _location : actionKey == "photo" ? _photo : actionKey == "contacts" ? _contacts : actionKey == "calendar" ? _calendar : false,
                  onChanged: (bool value) {
                    setState(() {
                      

                      if (actionKey == "location") {
                        _location = value;
                        _askPermission();                        
                                              
                      }else if (actionKey == "photo") {
                        _photo = value;
                        _askPermissionP();
                      }else if (actionKey == "contacts") {
                        _contacts = value;
                        _askPermissionC();
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
                  }else if (actionKey == "photo") {
                    _photo = !_photo;
                  }else if (actionKey == "contacts") {
                    _contacts = !_contacts;
                  }else if (actionKey == "calendar") {
                    _calendar = !_calendar;
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

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
        backgroundColor: styles.Colors.background,
        appBar: CreateAppBar(
            height: 118,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: "Правила", showAddButton: false),
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: _buildList()           
            ));
  }
}

// This trailing comma makes auto-formatting nicer for build methods.
