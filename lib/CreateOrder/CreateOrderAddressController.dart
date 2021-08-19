import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import '../app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/CreateOrder/CreateOrderConfirmController.dart';
import 'package:kaban/CreateOrder/AddAddressController.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:kaban/Managers.dart';


class CreateOrderAddressController extends StatefulWidget {
  final Task task;
  CreateOrderAddressController( {Key key, this.title, this.task}) : super(key: key);
  final String title;

  @override
  _CreateOrderAddressControllerState createState() =>
      _CreateOrderAddressControllerState();
}

class _CreateOrderAddressControllerState extends State<CreateOrderAddressController> {
  String idRemoteWork;
  String adres;
  String adres1;
  var lat;
  var long; 
  List<Address> _addressList=[];
  final storage = new FlutterSecureStorage();
  var selectedAddressType = 'indicate_address';  
  var selectedAddress = {};
  int _selectedIndex = 0; 

  void initState() {
    adressAllRequest();
    super.initState();
  }

  void _confirmInfoAction() {
    if(widget.task.address_id == null || widget.task.address_id.isEmpty){
      adres = "${_addressList[0].fullStreetAddress()}";
      adres1 = "${_addressList[0].fullApartmentAddress()}";
      widget.task.address_id= "${_addressList[0].id}";
      lat = double.parse("${_addressList[0].latitude}");
      long = double.parse("${_addressList[0].longitude}");
         assert (lat is double);
         assert(long is double);
      widget.task.latitude = lat;
      widget.task.longitude = long;               
    } else {

    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new CreateOrderConfirmController(adres, adres1,task:widget.task), fullscreenDialog: true));
  }

  void _addAddressAction() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => new AddAddressController(task:widget.task))).then((result) {
                  _addressList.clear();
                  adressAllRequest();
                  });
  }
   
  void  adressAllRequest() async { 

  await  ServerManager(context).addressAllRequest((result) {     
   widget.task.address_id =""; 

    for(int i = 0; i <= result.length; i++){
      if(i<result.length){
        if ("${result.elementAt(i)['type']}" == 'Выполнить удаленно'){
         idRemoteWork = "${result.elementAt(i)['id']}";
        }else{
         _addressList.add(Address(false,"${result.elementAt(i)['type']}",'${result.elementAt(i)['town']}','${result.elementAt(i)['adress']}',"",'${result.elementAt(i)['description']}',"${result.elementAt(i)['id']}",
            result.elementAt(i)['latlng'],result.elementAt(i)['long']));
        }  
      }        
    } 
      setState(() {        
      });

    }, (error){
    });
  }

  _addRemoteAddress() async {
    String id =  '3';
    String town ='', adress='', description='Для выполнения задания не обязательно присутствие исполнителя';
    double lat, long;
    await ServerManager(context).createAddressRequest(town, adress, description, id, lat, long, (result){
    Map<String, dynamic> resul = result;
    var i = resul['id'];
    idRemoteWork = "$i";
    widget.task.address_id = "$i";
    widget.task.latitude = 0;
    widget.task.longitude = 0;   
    }, (error){
    });
  }

  _onSelected(int index) {
    setState(() => _selectedIndex = index);  
     if("${_addressList[index].latitude}" == "null"){
    widget.task.latitude = 0;
    widget.task.longitude = 0;
    adres = "Выполнить удаленно";
    adres1 = "Для выполнения задания не обязательно присутствие  исполнителя"; 
    }  else {
    lat = double.parse("${_addressList[index].latitude}");
    long = double.parse("${_addressList[index].longitude}");
      assert (lat is double);
      assert(long is double);
    widget.task.latitude = lat;
    widget.task.longitude = long;
    adres = "${_addressList[index].fullStreetAddress()}";
    adres1 = "${_addressList[index].fullApartmentAddress()}";
    }   
    widget.task.address_id= "${_addressList[index].id}";    
  }

  @override
  Widget build(BuildContext context) {

    Widget buildButton(String title, String key) {
      var selected = selectedAddressType == key;

      return MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          color: selected ? styles.Colors.orange : Colors.transparent,
          elevation: 0,
          child: new Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(0),
            child: Text(title,
                textAlign: TextAlign.center,
                style: selected
                    ? styles.TextStyles.whiteBoldText17
                    : styles.TextStyles.grayRegularText17),
          ),
          onPressed: () {
            setState(() {
              selectedAddressType = key;
            });
          });
    }

    Widget addressTypeWidget() {
      return new Container(
          padding: EdgeInsets.only(left: 18),
          child: Row(
            children: <Widget>[
              buildButton(AppLocalizations.of(context).translate('add'), 'indicate_address'),
              SizedBox(width: 5,),              
              buildButton(AppLocalizations.of(context).translate('remote'), 'free_address'),
            ],
          ));
    }
    
    Widget _buildAddressItem(BuildContext context, int index) {
      var address = _addressList[index];

      var selected = _selectedIndex == index;

      if (address.isEmpty == true) {
        return Container();
      } else if (address.city.isEmpty && address.street.isEmpty){
        return Card(
            margin: EdgeInsets.only(right:0),
            color: selected ? Colors.white : Colors.transparent,
            elevation: 0,
            child: GestureDetector(
              child: Container(

                decoration: selected ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: styles.Colors.tintColor,
                        blurRadius: 10.0, 
                        spreadRadius: 5.0, 
                        offset: Offset(
                          0.0, 
                          2.0,
                        ),
                      )
                    ],
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: (Radius.circular(10.0)),
                      bottomLeft: (Radius.circular(10.0)),
                    )
                ) : BoxDecoration(),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text( AppLocalizations.of(context).translate('remote'), style: styles.TextStyles.darkBoldText17,
                        ),
                        SizedBox( width: 7,),
                        selected
                            ? Image.asset('assets/check_green_icon.png',
                                width: 12,
                                height: 12,
                              )
                            : Container()
                      ],
                    ),
                    SizedBox( height: 5,),
                    Text(AppLocalizations.of(context).translate('ifRemote'),
                      style: styles.TextStyles.darkRegularText14,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 15),
              ),
              onTap: () {
                setState(() {
                  _onSelected(index);                  
                });
              },
            ));
      }
      else {
        return Card(
          margin: EdgeInsets.only(right:0),
            color: Colors.transparent,
            elevation: 0,
            child:
            Container(
              decoration: _selectedIndex == index ? BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: styles.Colors.tintColor,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                      offset: Offset(
                        0.0, 
                        2.0, 
                      ),
                    )
                  ],
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: (Radius.circular(10.0)),
                      bottomLeft: (Radius.circular(10.0)),
                  )
              ) : BoxDecoration(),
              child: GestureDetector(
                child: AddressListItem(
                  address: address,
                  selected: selected,                  
                  onTap: () {
                    setState(() {
                      _onSelected(index);                                    
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _onSelected(index);                                                      
                  });
                },
              ),
            )
        );
      }
    }
    
    final bottomButton = new MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0, left: 0, right: 0),
          child: Text(AppLocalizations.of(context).translate('next'),
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText18),
        ),
        onPressed: _confirmInfoAction);

    final builAddressList = ListView.builder(  
    shrinkWrap: true,
    physics: ClampingScrollPhysics(),
    scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(left:20, top:20, bottom:20, right:0),
        itemCount: _addressList.length,
        itemBuilder: (context, index) => _buildAddressItem(context, index));

    Widget getAddressWidget() {
      if (selectedAddressType == 'free_address') {
        widget.task.address_id = idRemoteWork;
        widget.task.latitude = 0;
        widget.task.longitude = 0;
        adres = "Выполнить удаленно";
        adres1 = "Для выполнения задания не обязательно присутствие  исполнителя";
        if(idRemoteWork == null || idRemoteWork.isEmpty){
          _addRemoteAddress();
        }
        return Container(
          height: 137,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context).translate('ifRemote'),
              textAlign: TextAlign.center,
              style: styles.TextStyles.darkRegularText17,
            ),
          ),
        );
      } else {
        return  
          builAddressList;
      }
    }

    return new Scaffold(
      backgroundColor: styles.Colors.background,
      floatingActionButton: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          left: 30,
          right: 30,
        ),
        width: double.infinity,
        height: 50,
        child: bottomButton,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: CreateAppBar(
        height: 118.1,
        topConstraint: MediaQuery.of(context).padding.top,
        titleAppBar: AppLocalizations.of(context).translate('place'),
        showAddButton: true,
        addButtonAction: _addAddressAction,
      ),
      body:
              Container(
                padding:EdgeInsets.only(right:0),
                width: double.infinity,
                child: ListView(
                    children: <Widget>[
                      SizedBox(height: 20),
                      addressTypeWidget(),
                      getAddressWidget(),
                      SizedBox(height: 120),
                    ],
                  ),
              ),
    );
  }
}

class AddressListItem extends StatelessWidget {
  const AddressListItem({this.address, this.selected, this.onTap});

  final bool selected;

  final Address address;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Text(
                  address.type,
                  style: styles.TextStyles.darkBoldText17,
                ),
                SizedBox(
                  width: 7,
                ),
                selected
                    ? Image.asset(
                        'assets/check_green_icon.png',
                        width: 12,
                        height: 12,
                      )
                    : Container()
              ],
            ),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          ),
          Container(
            child: Text(
              address.fullStreetAddress(),
              style: styles.TextStyles.darkRegularText22,
            ),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          ),
          Container(
            child: Text(
              address.fullApartmentAddress(),
              style: styles.TextStyles.grayRegularText17,
            ),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          ),
        ],
      ),
    );
  }
}
