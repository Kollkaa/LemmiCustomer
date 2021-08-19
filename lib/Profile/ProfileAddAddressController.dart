import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../app_localizations.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/CreateOrder/AddAddressMapController.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;

import 'package:dio/dio.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';


class ProfileAddAddressController extends StatefulWidget { 
  ProfileAddAddressController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ProfileAddAddressControllerState createState() => _ProfileAddAddressControllerState();
}

class _ProfileAddAddressControllerState extends State<ProfileAddAddressController> {

  var _addressType = "";

  var _cities = List<String>();
  String _selectedCity;
  //var _dropdownItems = List<DropdownMenuItem<String>>();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController =TextEditingController();
  double latitude; 
  double longitude;
  bool selected = false;

  void initState() {
     //typesAddress();
    super.initState();

    _cities = _getDummyCities();
    _selectedCity = "";
   // _dropdownItems = _buildDropdownItems(_cities);

  }

  List<String> _getDummyCities() {
    var list = List<String>();
    list.add("Киев");
    list.add("Харьков");
    list.add("Одесса");
    list.add("Днепр");
    list.add("Львов");
    list.add("Каменец-Подольский");
    return list;
  }

 /* List<DropdownMenuItem<String>> _buildDropdownItems(List<String> cities) {
    var list = List<DropdownMenuItem<String>>();
    for (var value in cities) {
      list.add(DropdownMenuItem(
          value: value,
          child: Text(value, style: styles.TextStyles.darkText24)));
    }
    return list;
  }

  void _onChangeCity(value) {
    setState(() {
      _selectedCity = value;
    });
  }*/

  coordinatesFromQuery() async{
  if(_addressController.text.isEmpty){
    final query = null;
  }else{
    final query = "Украина, $_selectedCity, ${_addressController.text}";
    print("$query");
    var addresses = await Geocoder.local.findAddressesFromQuery(_addressController.text);
    var first = addresses.first;
    //final coordinates = new Coordinates(first.latitude, first.longitude);
    print("${first.featureName} : ${first.coordinates}");
  latitude = first.coordinates.latitude;
  longitude = first.coordinates.longitude;
  print("$latitude");
  print("$longitude");
  }
 
  }

  /*void typesAddress() async{
    await ServerManager(context).addressTypeAllRequest((code){}, (error){});
  }*/

  static List<String> places =[];

  getLocationResults(String input) async{
  
  const PLACE_API_KEY = "AIzaSyC9pMhEcBVyniaEHgWhJ71BLcY4Qt1ZcqY";
  String baseURL ='https://maps.googleapis.com/maps/api/place/autocomplete/json';
  String type = 'address';
  String request = '$baseURL?input=$_selectedCity,$input&key=$PLACE_API_KEY&type=$type&components=country:ua';
  Response response = await Dio().get(request);
  
  final predictions = response.data['predictions'];
  places =[];
  for (var i = 0; i< predictions.length; i++ ){

    String name = predictions[i]['description'];
    places.add("$name");
    
  }  
      setState(() {
     }); 
       
   return places;
  }

  List<String> _getSuggestions(String query){
   
    List<String> matches = List();
    matches.addAll(places);
    matches = places;
    return matches;
  }
  
   Future<void> _selectedTown(BuildContext context) async {
    var city = await showCupertinoModalPopup(
  context: context,
  builder: (context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            border: Border(
              bottom: BorderSide(
                color: Color(0xff999999),
                width: 0.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                child: Text(AppLocalizations.of(context).translate('cup_cancel'),style: TextStyle( color:Color.fromRGBO(255, 178, 158, 1.0)),),
                onPressed: () {
                  _cityController.text = '';
                  Navigator.pop(context);                  
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 5.0,
                ),
              ),
              CupertinoButton(
                child: Text('Готово',style: TextStyle( color:Color(0xFFDD6243))),
                onPressed: () {
                   if(selected == false){
                    _cityController.text = _cities[0].toString(); 
                   }else{}
                   _selectedCity = _cityController.text;
                  Navigator.pop(context);
                  selected = false; 
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 5.0,
                ),
              )
            ],
          ),
        ),
        Container(
          height: 150.0,
          color: Color(0xfff7f7f7),
          child: new CupertinoPicker(
            itemExtent: 35,
            backgroundColor: Colors.white,
            children: List<Widget>.generate(_cities.length, (index){
              return Center(
                child: Text(_cities[index]),
              );
            }),
            looping: true,
            onSelectedItemChanged: (value) {
              _cityController.text = _cities[value].toString();
              selected = true;
            },
            /* the rest of the picker */
          ),
        )
      ],
    );
  },
);
  }
  
  void _newAddressAction() async {
    String town = _selectedCity;
    String adress = _addressController.text ;
    String description = _descriptionController.text;
    String id = '4';
    double lat = latitude;
    double long = longitude;
    await coordinatesFromQuery();
    await ServerManager(context).createAddressRequest(town, adress, description, id, lat, long, (result){
    
        Navigator.pop(context, () {
 setState(() {});});
   

    }, (error){

    });
    
  }
  @override

  Widget build(BuildContext context) {
    final bottomButton = new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,//375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: Text(AppLocalizations.of(context).translate('add'),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Gilroy',
                  fontStyle: FontStyle.normal,
                  fontSize: 18,
                  color: Colors.white
              )),

        ),
        onPressed: _newAddressAction
    );

  
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: styles.Colors.background,
        floatingActionButton: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 30, right: 30,),//bottom: 30),
          width: double.infinity,
          height: 50,//100
          child: bottomButton,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        appBar: CreateAppBar(height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate('titleAddAddress'),
            showAddButton: false),

        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 14, bottom: 0),
            child: ListView(

              children: <Widget>[

                Align(
                  child: Text(AppLocalizations.of(context).translate('town'), style: styles.TextStyles.darkText18,),
                  alignment: Alignment.centerLeft,
                ),

                 Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectedTown(context),
                        child: AbsorbPointer(
                        child: TextFormField(
                        controller: _cityController, // Use email input type for emails.
                          style: styles.TextStyles.darkText24,
                          decoration: new InputDecoration(
                            hintText: AppLocalizations.of(context).translate('yourTown'),
                            hintStyle: TextStyle(fontFamily: 'Gilroy',
                    fontStyle: FontStyle.normal,
                    color: Color(0xFFADADAD),
                    fontSize: 24
                ),
                          ),
                        //  }
                        ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30,),
                Align(
                  child: Text(AppLocalizations.of(context).translate('address'), style: styles.TextStyles.darkText18,),
                  alignment: Alignment.centerLeft,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TypeAheadFormField(
                       
                       textFieldConfiguration: TextFieldConfiguration(
                         controller: _addressController,
                          keyboardType: TextInputType.text, // Use email input type for emails.
                          style: styles.TextStyles.darkText24,
                          decoration: new InputDecoration(
                            hintText: AppLocalizations.of(context).translate('yourAddress'),
                            hintStyle: TextStyle(fontFamily: 'Gilroy',
                    fontStyle: FontStyle.normal,
                    color: Color(0xFFADADAD),
                    fontSize: 24
                ),
                          ),
                       ),
                       transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                        },
                       onSuggestionSelected: (suggestion) {
                         this._addressController.text = suggestion;
                        },                       
                        itemBuilder: (context, input) {
                          return ListTile(
                          title: Text(input),                           
                          );
                          },
                         suggestionsCallback: (pattern) async {                          
                         await getLocationResults(pattern);  
                         return _getSuggestions(pattern);                          
                           },
                        onSaved: (value) => 
                        this._selectedCity = value,
                        )                   
                    ),

                    GestureDetector(
                      child: Image(image: AssetImage('assets/pin_location.png'),
                        fit: BoxFit.fitHeight,
                        width: 36,
                        height: 36,),
                      onTap: () async {
                       await coordinatesFromQuery();
                        showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => FractionallySizedBox(
                              heightFactor: 0.9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                                clipBehavior: Clip.hardEdge,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: styles.Colors.background,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(30),
                                      topRight: const Radius.circular(30),
                                    ),
                                  ),
                                  child: DraggableScrollableSheet(
                                    initialChildSize: 1,
                                    minChildSize: 0.8,
                                    builder: (BuildContext context,
                                        ScrollController scrollController) {
                                      return Material(
                                          elevation: 4,
                                          child:
                                          MapSample(longitude, latitude));
                                    },
                                  ),
                                ),
                              ),
                            ),
                            isScrollControlled: true);

                      },
                    )

                  ],
                ),
                SizedBox(height: 30,),
                Align(
                  child: Text(AppLocalizations.of(context).translate('addressDescription'), style: styles.TextStyles.darkText18,),
                  alignment: Alignment.centerLeft,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                          controller: _descriptionController,
                          keyboardType: TextInputType.text, // Use email input type for emails.
                          style: styles.TextStyles.darkRegularText18,
                          decoration: new InputDecoration(
                            hintText: AppLocalizations.of(context).translate('entrance'),
                            hintStyle: TextStyle(fontFamily: 'Gilroy',
                    fontStyle: FontStyle.normal,
                    color: Color(0xFFADADAD),
                    fontSize: 24
                ),
                            //border: InputBorder.none,
                          ),
                          onSaved: (String value) {
                            _descriptionController.text = value;
                            // this._data.email = value;
                          }

                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30,)

              ],
            ),
          )
        )

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
