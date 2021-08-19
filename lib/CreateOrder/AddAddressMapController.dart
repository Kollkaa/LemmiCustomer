import 'dart:async';
import 'package:location/location.dart' as loc;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaban/CreateOrder/CreateOrderSelectCategoryController.dart';
import 'package:kaban/Styles.dart' as styles;


class MapSample extends StatefulWidget {
  MapSample( this.longitude, this.latitude, {Key key,}) : super(key: key);
  
  final double longitude;
  final double latitude;
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {

  Completer<GoogleMapController> _controller = Completer();
  Position position;
  Widget _child;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
 var location = loc.Location();
Future _checkGps() async {
if(!await location.serviceEnabled()){
   location.requestService();
  }
  else print('not');
}
  getProgressDialog() {
    return new Container(
        decoration: const BoxDecoration(        
        ),
        child: new Center(child: const CupertinoActivityIndicator(radius: 15.0)));
  }
  
   @override
  void initState() 
    { 
      print(widget.longitude);
      _child = getProgressDialog();
      setCustomMapPin();
       _getLocation();    
      
    super.initState();
    }

  Widget mapWidget(){
    return GoogleMap(
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      markers:_createMarker(),
      initialCameraPosition: CameraPosition(
        target:LatLng(latitude, longitude),
        zoom:18.0 ),
        onMapCreated: _onMapCreated ,
    );
  }
  void getCurrentLocation() async
  
  { await _checkGps();
    Position res = await Geolocator().getCurrentPosition(); 
    setState((){
      position = res;
      _child = mapWidget();     
    });
  }
  
  BitmapDescriptor pinLocationIcon;

  void setCustomMapPin() async {
      pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/pin_location.png');
   }
double latitude;
double longitude;
 _getLocation() async
  
      {
        await _checkGps();
         if (widget.longitude != null ){
          latitude = widget.latitude;
          longitude= widget.longitude;
          setState((){
            _child = mapWidget(); 
          }); 
          final coordinates = new Coordinates(latitude, longitude);       
          var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
         }else{
         Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
       // debugPrint('location: ${position.latitude}');
        final coordinates = new Coordinates(position.latitude, position.longitude);
        var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
        var first = addresses.first;
        print("${first.featureName} : ${first.addressLine}");
        print("${position.latitude} : ${position.longitude}");
       
        latitude = position.latitude;
        longitude = position.longitude;
          setState((){
            _child = mapWidget(); 
          });      
         }
      }

Set <Marker> _createMarker(){
  return <Marker>[
    Marker
    (markerId: MarkerId ("home"),
    draggable: true,
    position:LatLng (latitude, longitude),
    onDragEnd: ((position) {
            print(position.latitude);
            print(position.longitude);}),
    icon: pinLocationIcon, ),
  ].toSet();
}


void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      extendBodyBehindAppBar: true,
        backgroundColor: styles.Colors.background,
        appBar: TitleAppBar(
          titleAppBar: "",
        ),
        body:  _child,
    );
  }

}