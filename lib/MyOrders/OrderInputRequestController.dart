
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Main/MainController.dart';
import 'package:kaban/MyOrders/OrderInfoController.dart';
import 'package:kaban/MyOrders/OrderInputCommentController.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_localizations.dart';
import 'package:kaban/MyOrders/OrderDealController.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Widgets.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/Styles.dart' as styles;

import 'ExecutorUser.dart';

class OrderInputRequestController extends StatefulWidget {
  OrderInputRequestController(this.orderInfo, this.orderIndex, {Key key,}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Map orderInfo;
  final int orderIndex;

  @override
  _OrderInputRequestControllerState createState() =>
      _OrderInputRequestControllerState(orderInfo);
}

class _OrderInputRequestControllerState extends State<OrderInputRequestController> {

  Completer<GoogleMapController> _controller = Completer();
  _OrderInputRequestControllerState(this.orderInfo);
GoogleMapController mapController;  
 Set<Marker> markers = {};
 
  CameraPosition _initialLocation ;
  Map orderInfo;
  String phone;
  var requestList;
  void initState() {
    super.initState(); 
    phone = "${orderInfo['executor']['phone']}";
    setCustomMapPin();
    requestList = orderInfo['input_request'] as List;
  }

  final PageRouteBuilder _homeRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return MainController();
    },
  );
  
  void _contactWithExecutorAction() async {
    whatToDoDialog(phone);
  }

  whatToDoDialog(phone) {
    setState(()  {
       var action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text( AppLocalizations.of(context).translate('toCall'),),
            onPressed: () async {
              var url = "tel:$phone";
              await launch(url);                        
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context).translate('toSms')),
            onPressed: () async {
          if(Platform.isAndroid){
        //FOR Android
       String url ='sms:$phone?body=';
        await launch(url);
        } 
        else if(Platform.isIOS){
        //FOR IOS
        String  url ='sms:$phone&body=';
        await launch(url);
    }          
              },
          )
        ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context).translate('cup_cancel')),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          )
      );

      showCupertinoModalPopup(context: context, builder: (BuildContext context) => action);

    });
  }
  
  void _deletePublicationAction() async{
    showDialog(
    context:context,
    builder: (_)=> CupertinoAlertDialog(
       title: Text(AppLocalizations.of(context).translate("areYouSure")),
      content:Text(AppLocalizations.of(context).translate("deleteTask")),
      actions: [
        CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("yes"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14)),
       onPressed:()async{
          await ServerManager(context).deleteTaskRequest(taskId, (code){
      Navigator.pushAndRemoveUntil(
        context, _homeRoute, (Route<dynamic> r) => false).then((result){          
          initState();
        });
    }, (error){});
          
        },),
        CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("no"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14)),
      isDefaultAction: true,
        onPressed: (){
          Navigator.pop(context);
        },)
      ],

    ),
  );    
    showDialog();   
  }
  
  bool z = false;
  String id;
  String taskId;
  String idTask;
   List<Map<String,Object>> myNewOrdersList = [];
   List<Map<String,Object>> inputNewRequest = [];
   Map<String, Object> executor = {};
    Map<String, Object> adres = {};
   List <String> images = [];
   List<Map<String,Object>> user = [];

  /*accept() async {
    await ServerManager(context).acceptRequest(id, taskId, (code){   
    
    }, (error){});
  }*/
  
  cancel(index) async {
  showDialog(
    context:context,
    builder: (_)=> CupertinoAlertDialog(
       title: Text(AppLocalizations.of(context).translate("areYouSure")),
      content:Text(AppLocalizations.of(context).translate("deletePending")),
      actions: [
        CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("yes"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14)),
       onPressed:()async{
         Navigator.pop(context);
        await ServerManager(context).cancelRequest(id, taskId, (code){ 

        //   Navigator.pushAndRemoveUntil(
        //context, _homeRoute, (Route<dynamic> r) => false).then((result){          
        //  initState();         
        //});         
          requestList.removeAt(index);
          setState((){}); 
       }, (error){});          
        },),
        CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("no"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14)),
      isDefaultAction: true,
        onPressed: (){
          Navigator.pop(context);
        },)
      ],

    ),
  );    
    showDialog();
   
  }

  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor executorLocationIcon;

  void setCustomMapPin() async {
      pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/pin_location.png');
      executorLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/snail.png');
   }

  comment(String taskId){
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
          //title:  Text(AppLocalizations.of(context).translate("titleLive")),
          content: Text (AppLocalizations.of(context).translate("titleLivePerson")),
        actions: [
         CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("yes"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14,)),  
       onPressed:(){         
          Navigator.pop(context);
          Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => new OrderInfoController(taskId)));
        },),
        CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("no"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14)),
      isDefaultAction: true,
        onPressed: (){
          Navigator.pop(context);
          Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => new MainController()));
        },)
        ]);});

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    Widget requestCell(Map requestInfo, int index) {
      var executor = requestInfo['executor'];
      return Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: styles.Colors.tintColor,
                blurRadius: 5.0,
                // has the effect of softening the shadow
                spreadRadius: 0.0,
                // has the effect of extending the shadow
                offset: Offset(
                  0.0, // horizontal, move right 10
                  1.0, // vertical, move down 10
                ),
              )
            ],
            color: Colors.white,
            borderRadius: new BorderRadius.all(
              Radius.circular(16.0),
            )
        ),
        alignment: Alignment.centerLeft,
        width: MediaQuery.of(context).size.width - 30,
        height: 270,
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
           GestureDetector(child: Widgets().userShortRatingRow(executor),
           onTap:(){                       
              var performer_id = '${requestInfo['userId']}';
              
              print("$performer_id");
             showModalBottomSheet(
               context: context,
                    backgroundColor: Colors.transparent,
                  builder: (context) =>
                      FractionallySizedBox(
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
                      child: new InkWell(
                      onTap: () {                        
                     },
                      child: ExecutorUser( performer_id),
                                ));
                              },
                            ),
                          ),
                        ),
                      ),
                  isScrollControlled: true);
           }),
            SizedBox(
              height: 10,
            ),
            Container(
                alignment: Alignment.bottomLeft,
                height: 1,
                padding: EdgeInsets.only(right: 0, left: 0),
                color: Color(0XFFC4C4C4)),
            SizedBox(
              height: 7,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text("${requestInfo['comment']}" == "null"
                    ?''
                    :"${requestInfo['comment']}",
                    style: styles.TextStyles.darkRegularText14,
                  ),
                ),
                GestureDetector(
                  child: Image(
                    image: AssetImage(
                        'assets/comment_orange_icon.png'),
                    fit: BoxFit.fitHeight,
                    width: 33,
                    height: 33,
                  ),
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) =>
                            OrderInputCommentController(
                              comment: RequestComment(
                                '${requestInfo['executor']['name']}',
                                '${requestInfo['executor']['surname']}',
                                '${requestInfo['executor']['image_url']}',
                                '${requestInfo['comment']}',
                                '${requestInfo['activityTaskId']}',
                                '${requestInfo['executor']['theId']}',
                                '${requestInfo['userId']}',
                              )
                            )));
                  },
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                Text(
                  'Оплата:',
                  style: styles.TextStyles.grayTransRegularText24,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '${requestInfo['price']} uah.',
                  style: styles.TextStyles.darkText24,
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
          
            SizedBox(
              height: 14,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: Color(0xFFC4C4C4),
          ),
          SizedBox(
              height: 14,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(16))),
                    color: styles.Colors.orange,
                    child: new Container(
                      alignment: Alignment.center,
                      child: Text(AppLocalizations.of(context).translate("accept"),
                          textAlign: TextAlign.center,
                          style: styles.TextStyles.whiteText18),
                    ),
                    onPressed: () {
                      taskId = '${requestInfo['activityTaskId']}';
                          id = '${requestInfo['userId']}';
                      //    accept();        
                      var adres;
            '${orderInfo['address']}' == ""|| '${orderInfo['adress']}' == ""
            ?adres = '${orderInfo['town']}':adres ='${orderInfo['address']} ,${orderInfo['town']}';             
                      Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (context) =>
                                  OrderDealController(
                                    taskId, id, 
                                     orderDeal: OrderDeal(
                            orderInfo['subCategories'],
                            '${orderInfo['title']}',
                            '${orderInfo['description']}', 
                             '${orderInfo['taskPrice']}',        
                            '${requestInfo['price']}',                            
                            '${orderInfo['start_date']}',
                            '${orderInfo['start_time']}',                            
                            adres,
                            '${orderInfo['adDescription']}',
                            '${requestInfo['executor']['rating']}',
                            '${requestInfo['executor']['name']} ${requestInfo['executor']['surname']}',
                            '${requestInfo['executor']['image_url']}',
                            '${requestInfo['comment']}',
                            )
                          )));
                    },
                  ),
                  padding: EdgeInsets.all(0),
                  width: (MediaQuery.of(context).size.width / 2) -
                      40,
                  height: 40,
                ),
                SizedBox(width: 5,),
                Container(
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        new BorderRadius.circular(16.0),
                        side: BorderSide(
                            color: styles.Colors.orange)),
                    height: 50,
                    minWidth: 315,
                    textColor: Color.fromRGBO(221, 98, 67, 1),
                    child: Text(AppLocalizations.of(context).translate("cancelPending"),
                        textAlign: TextAlign.center,
                        style: styles.TextStyles.orangeText18),
                        onPressed: (){ z = true;                          
                          taskId = '${requestInfo['activityTaskId']}';
                          id = '${requestInfo['userId']}';
                          cancel(index);                        
                          }
                  ),
                  width: (MediaQuery.of(context).size.width / 2) -
                      40,
                  height: 40,
                ),
                
              ],
            )
          ],
        ),
      );

    }

    Widget buildInputRequestList() {
      
      
      return Stack(
        children: <Widget>[
          Container(
            child: Text(AppLocalizations.of(context).translate("requests"),
              style: styles.TextStyles.darkText18,
            ),
            padding: EdgeInsets.only(left: 30, top: 2, right: 30),
          ),
          Container(
            child: ListView.separated(
              itemBuilder: (contexNew, index) {                        
                 return requestCell(requestList[index], index);                 
              },
              separatorBuilder: (contextNew, index) => Divider(
                color: Colors.transparent,
                height: 10,
              ),
              itemCount: requestList.length,//.compareTo(0),
              padding: EdgeInsets.only(left: 15, right: 15, top:2, bottom: 75),
            ),
            padding: EdgeInsets.only(left: 0, right: 0, top: 55, bottom: 0),
          )
        ],
      );
    }    

    void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
}

 _calculateDistance() async {
   bool validate;
      var latitude = double.parse("${orderInfo["adres"]["lat"]}");
      var longitude = double.parse("${orderInfo["adres"]["lng"]}");
      var validation = "${orderInfo["executor"]["consumerLat"]}";
      var conslatitude; var conslong;
      if(validation == null || validation == 'null'|| validation == 0 || validation=='0') {
      validate = false;
      }else{
      conslatitude = double.parse("${orderInfo["executor"]["consumerLat"]}");
      conslong = double.parse("${orderInfo["executor"]["consumerLong"]}");
      validate = true;
      assert (conslatitude is double);
      assert(conslong is double);}      

        Position startCoordinates = Position(
                latitude: latitude,
                longitude: longitude);
        Position destinationCoordinates = Position(
                latitude: conslatitude,
                longitude: conslong);
    validate == true ?             
   _initialLocation = CameraPosition(target: LatLng (conslatitude, conslong), zoom: 14)
   :_initialLocation = CameraPosition(target: LatLng (latitude, longitude), zoom: 14);
        // Start Location Marker
        markers.add(Marker
    (markerId: MarkerId ("home"),
    draggable: true,
    position:LatLng (latitude, longitude),
    icon: pinLocationIcon,
    onDragEnd: ((position) {
            print(position.latitude);
            print(position.longitude);})));
             validate == true ? 
    markers.add(Marker(markerId: MarkerId ('performer'),
    draggable: false,
    icon: executorLocationIcon,
    position:LatLng (conslatitude, conslong))):
    markers.add(Marker(markerId: MarkerId ('performer'),
    draggable: false,
    visible: false,
    position:LatLng (latitude, longitude)));
   
  }

    Widget buildMapWidget() {
      _calculateDistance();
     
     return Stack(children: <Widget>[ 
        GoogleMap(
              markers: markers ,
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,              
              onMapCreated: (GoogleMapController controller) {                
                mapController = controller;
              },
            ),
             SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child:Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10, top:10),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: styles.Colors.orange,// button color
                        child: InkWell(
                          splashColor: styles.Colors.whiteColor, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add, color: Colors.white,),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ClipOval(
                      child: Material(
                        color: styles.Colors.orange, // button color
                        child: InkWell(
                          splashColor: styles.Colors.whiteColor, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove, color: Colors.white),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )),
            ),
       
]);

    }
    
    _problem() async{
      taskId = orderInfo['id'];
      await ServerManager(context).problemStatus(taskId, (result) {
        orderInfo['order_status'] = 'Проблема';
        setState((){});
       }, (errorCode) { });      
    }

   void  _fullyDone() async{
      taskId = orderInfo['id'];
     await ServerManager(context).accepsDoneStatus(taskId, (result) {
        orderInfo['order_status'] = AppLocalizations.of(context).translate('accepted');
      setState((){});      
      }, (errorCode) { });  
      Navigator.pop(context);
      comment(taskId);
      }
    final problemButton = new OutlineButton(
      hoverColor: Colors.white,
      borderSide: BorderSide(
      color: styles.Colors.orange, style: BorderStyle.solid, 
      width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      child: new Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.only(bottom: 0),
        child: Text('Проблема',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Gilroy',
        fontStyle: FontStyle.normal,
        fontSize: 18,
        color: styles.Colors.orange))),        
        onPressed: (){
          _problem();
        }
    );

    final doneButton = new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: Text(AppLocalizations.of(context).translate('accept'),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Gilroy',
                  fontStyle: FontStyle.normal,
                  fontSize: 18,
                  color: Colors.white))),        
        onPressed: (){
           _fullyDone();
           //Navigator.pop(context);
        }
    );
    final roundedButton = new FloatingActionButton(
        backgroundColor: Colors.white,
        child: Center(child: Image.asset('assets/pin_location.png')),
        onPressed: (){
          _contactWithExecutorAction();
          },
    );
   theEnd(){
     var statuses;
    '${orderInfo['order_status']}' == 'empty'
    ?statuses = "Не подписано"
    :statuses = '${orderInfo['order_status']}';
    
  return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [              
                    Container(child:doneButton,
                    padding: EdgeInsets.only(left: 10, right: 10)),
                    SizedBox(height: 15),
                    Container(child:problemButton,
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10)),
                    ]);
                    
}
    final bottomButton = orderInfo['order_status'] == 'Завершено' || orderInfo['order_status'] == AppLocalizations.of(context).translate('accepted')?
    Container()
    :new MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0, left: 0, right: 0),
          child: Text(AppLocalizations.of(context).translate("contact"),
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText18),
        ),
        onPressed: (){
          _contactWithExecutorAction();
          },
    );

    final theBottomButton = new MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0, left: 0, right: 0),
          child: Text(AppLocalizations.of(context).translate("removeFromPublication"),
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText18),
        ),
        onPressed: (){
          taskId = "${orderInfo['id']}";
          _deletePublicationAction();
        }
    );
    bool button;
    return Scaffold(
        backgroundColor: styles.Colors.background,
        appBar: OrderInfoAppBar(
          titleAppBar: AppLocalizations.of(context).translate("titleMyTasks"),
          orderInfo: this.orderInfo,
          status: '${orderInfo['status']}',
          detailButtonAction: () {
            orderInfo['executor'] == null || orderInfo['executor'].isEmpty
                ? button = false
            : button = true;
            idTask = '${orderInfo['id']}';
            var adres;
            '${orderInfo['address']}' == ""|| '${orderInfo['adress']}' == ""
            ?adres = '${orderInfo['town']}':adres ='${orderInfo['address']} ,${orderInfo['town']}';
            print(adres);
            print('${orderInfo['address']} ,${orderInfo['town']}');

            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => new OrderInfoController(idTask)));
          },
        ),
        
        floatingActionButton: orderInfo['confirmed'] 
        ? Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
          ),
          width: double.infinity,
          height: 50,
          child: bottomButton,
        )
        : Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
          ),
          width: double.infinity,
          height: 50,
          child: theBottomButton,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: orderInfo['confirmed'] 
        ?
         orderInfo['order_status'] == 'Завершено' || orderInfo['order_status'] == AppLocalizations.of(context).translate('accepted')
          ? theEnd()
       
          : "${orderInfo["adres"]["lat"]}" == "null" || "${orderInfo["adres"]["lat"]}" == '0'  
           ? Container(
            child: Text(AppLocalizations.of(context).translate("noAddress"),
              textAlign: TextAlign.center,              
              style: styles.TextStyles.darkText18,
            ),
            padding: EdgeInsets.only(left: 15, top: 15),
           )
           : buildMapWidget() 
          
        : orderInfo['input_request'].length == 0
        ?  Container(
            child: Text(
              AppLocalizations.of(context).translate("waitForPerformer"),
              style: styles.TextStyles.darkText18,
            ),
            padding: EdgeInsets.only(left: 30, top: 1, right: 30),
          )
        : buildInputRequestList()

        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
