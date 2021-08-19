import 'dart:io';
import 'dart:ui';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../app_localizations.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/MyOrders/OrderInfoController.dart';
import 'package:kaban/MyOrders/OrderInputRequestController.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Widgets.dart';
import 'package:kaban/Styles.dart' as styles;


Future<dynamic> _onBackgroundMessage(Map<String, dynamic> message) async {
  debugPrint('On background message $message');
  return Future<void>.value();
}

class MainController extends StatefulWidget {
  MainController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainControllerState createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];
  String road;
  var fcmToken;
  void initState() {
    super.initState();
    getMainPage();
    getMessage();

  }
  getTokens() async {
    String token = await storage.read(key: "token");
    print(token);
    fcmToken = token.toString();
    print("fcm:$fcmToken");
    tokenRequest(fcmToken);
  }
  tokenRequest(fcmToken) async{

    await ServerManager(context).tokenRequest(fcmToken,(result) {
      print(result);
    }).catchError((error) {
      print("Error: $error");});
  }


  handlePath(message, id){
    OrderInfo orderInfo;
    if (road == "my_orders"/* || road == "general_page"*/){
      Navigator.of(context).push(
          CupertinoPageRoute(
              builder: (context) =>  OrderInfoController(id, orderInfo: orderInfo))
        // MyOrderListController())

      ); setState((){
        //initState();
      });
    }else {
      Navigator.of(context).push(
          CupertinoPageRoute(
              builder: (context) =>  MainController()));
      setState((){
        initState();
      });
    }
  }
  getMessage(){
    getToken();
    if (Platform.isIOS){
      _firebaseMessaging.configure(
        onBackgroundMessage: _onBackgroundMessage,
        onMessage: (Map <String, dynamic> message) async {
          print("onMessage:$message");
          final notification = message['aps'];
          final data = message;
          road = message['action'];
          print("Action:${message['action']}");
          showDialog(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                    title: Text(message['aps']['alert']['title']),
                    content: Text(message['aps']['alert']['body']),
                    actions: [
                      CupertinoDialogAction(child: Text("OK", style: TextStyle(
                          fontFamily: 'Roboto-Medium',
                          fontSize: 14,
                          color: Color.fromRGBO(221, 98, 67, 1))),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            //initState();
                          });
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (context) => new MainController()));
                        },
                      ),
                    ]);
              });
          setState(() {
            messages.add(Message(
                title: notification['alert']['title'], body: notification['alert']['body']));
            showDialog();
          });
        },
        onLaunch: (Map <String, dynamic> message) async {
          final data = message;
          road = message['action'];
          var id = "${message['id_task']}";
          print("onLaunch:$message");
        },
        onResume: (Map <String, dynamic> message) async {
          final data = message;
          road = message['action'];
          var id = "${message['id_task']}";
          print("onResume:$message");
          handlePath(message, id);
        },
      );

      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound:true, badge:true, alert:true));
    }else{
      _firebaseMessaging.configure(
        onBackgroundMessage: _onBackgroundMessage,
        onMessage:(Map <String,dynamic> message) async {
          print("onMessage:$message");
          final notification = message['notification'];
          final data = message['data'];
          road = message['data']['action'];
          print("Action:${message['data']['action']}");
          showDialog(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                    title:  Text ('${message['notification']['title']}' == "null" ? 'Lemmi' :message['notification']['title']),
                    content: Text (message['notification']['body']),
                    actions: [
                      CupertinoDialogAction(child: Text("OK",style:TextStyle(
                          fontFamily: 'Roboto-Medium',
                          fontSize: 14,
                          color: Color.fromRGBO(221,98,67,1))),
                        onPressed:(){
                          Navigator.pop(context);
                          setState((){
                            initState();
                          });
                        },
                      ),
                    ]);
              });
          setState(() {
            messages.add(Message(title: notification['title'], body: notification['body']));
            showDialog();
          });
        },
        onLaunch: (Map <String,dynamic> message) async {
          final data = message['data'];
          road = message['data']['action'];
          var id = "${message['data']['id_task']}";
          print("onLaunch:$message");
          //handlePath(message, id);
          // message.(road);
          // setState(() => message = message["notification"]["title"]);
        },
        onResume: (Map <String,dynamic> message) async {
          final data = message['data'];
          road = message['data']['action'];
          var id = "${message['data']['id_task']}";
          print("onResume:$message");
          handlePath(message, id);
          // setState(() => message = message["notification"]["title"]);
        },);
    }
  }

  int orderIndex;
  String id;
  List<dynamic> send = List();
  List<Map<String, String>> firstList = [];
  List<Map<String,Object>> myOrdersList =[];
  List<Map<String,Object>> inputRequest = [];
  final storage = new FlutterSecureStorage();

  Future <String> getToken() async {
    String token = await storage.read(key: "token");
    String refreshtoken = await storage.read(key:"refresh_token").then((refreshToken){
      return refreshToken;
    });
    return token;
  }

  void getMainPage() async{
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      getTokens();
      await ServerManager(context).myTasksRequest((result){
        var _slength = result["specialist"].length;
        List <String> images = [];
        Map<String, Object> executor = {};
        firstList =[];
        send = []; int j = 0; int z = 0;
        for(int i = 0; i < _slength; i++){
          Map<String, dynamic> element = result["specialist"].elementAt(i);
          firstList.add({'name': "${element['name']}", 'image': 'https://api.lemmi.app/${element['spcialist']['photo']}', 'id':'${element['spcialistId']}'});
          j++;
          if (j <= 1){
            if(i == _slength -1) {
              send.insert(z,firstList);
              z++;}
          }else{
            send.insert(z,firstList);
            firstList = [];
            z++;
            j = 0;
          }
          print(send.length);
        }
        setState(() { });

        myOrdersList = [];
        var _length= result["result"].length;
        if (_length == 0){ }else{
          for(int n = 0; n < _length; n++){
            List<dynamic> subCategories = result["result"][n]['serviceNames'];
            var data  = "${result["result"][n]["data"]}";
            String rightDate = '${data.substring(8,10)}.${data.substring(5,7)}.${data.substring(0,4)}';
            String smth = "${DateTime.now().timeZoneOffset}";
            var plus = smth.substring(0,1);
            var newTime  = DateFormat("HH:mm").parse(data.substring(11,16)).add(Duration(hours:int.parse(plus)));
            String startTime =  '${DateFormat("HH:mm").format(newTime)}';
            var lengthPhoto= result["result"][n]["activity_task_photos"].length;
            images =[];
            for(int z = 0; z < lengthPhoto; z++){
              images.add("https://api.lemmi.app/${result["result"][n]["activity_task_photos"].elementAt(z)['photo']}");
            }
            var _lengthC = result["result"][n]["costumers"].length;
            if (result["result"][n]["confirmUser"] != null && result["result"][n]["confirmUser"] != 'null'){
              var res = result["result"][n]['confirmUser']['order_status'];
              inputRequest =[];
              var exec = result["result"][n]["confirmUser"]['user'];
              var coordinates = result["result"][n]["confirmUser"];
              var surname;
              "${exec["last_name"]}" != null?
              surname = "${exec["last_name"]}": surname = "";
              executor ={"name":"${exec["first_name"]}","surname":surname, "image_url":"https://api.lemmi.app/${exec["photo"]}", "phone":"${exec["phone"]}",
                'consumerLat':'${coordinates['lat']}', 'consumerLong':'${coordinates['long']}'};
              var show  = result["result"][n]["addresses"].elementAt(0);
              var status = '';
              result["result"][n]['confirmUser'] != null && res != null
                  ?status = res
                  :status = 'empty';

              myOrdersList.add({"subCategories":subCategories,
                "id":"${result["result"].elementAt(n)["id"]}","title":"${result["result"].elementAt(n)["title"]}", "start_date":"$rightDate", "start_time":"$startTime",
                "confirmed":true, 'images':images,
                'executor':executor ,'adres':{"lat":"${show['latlng']}", "lng":"${show['long']}"}, 'input_request':inputRequest,
                'description':'${result["result"].elementAt(n)["description"]}',
                'taskPrice':'${result["result"].elementAt(n)["price"]}',
                'order_status':status,
                'town':'${show['town']}',
                'address':'${show['adress']}',
                'adDescription':'${show['description']}'});
            }
            else {
              executor = {};
              if (_lengthC == 0){
                executor = {};
                inputRequest = [];}
              else{
                executor = {};
                inputRequest = [];
                for(int j = 0; j<_lengthC; j++){
                  var short = result["result"][n]["costumers"].elementAt(j);
                  var res = result["result"][n]["costumers"].elementAt(j)['order_status'];
                  var raiting = double.parse("${short["user"]["rating"]}");
                  var surname;
                  '${short["user"]["last_name"]}' != null && '${short["user"]["last_name"]}' != 'null'?
                  surname = '${short["user"]["last_name"]}': surname = "";
                  assert(raiting is double);
                  inputRequest.add({"executor":{'theId':'${short['id']}',
                    'name':'${short["user"]['first_name']}',
                    'surname':surname,
                    'phone':"${short["user"]["phone"]}",
                    'image_url':'https://api.lemmi.app/${short['user']["photo"]}',
                    'rating':raiting,},
                    'status':res,
                    'comment':'${short["comment"]}',
                    'price':'${short["price_offered"]}',
                    'activityTaskId':'${short["activityTaskId"]}',
                    'userId':'${short["userId"]}',});
                }
              }

              var show  = result["result"][n]["addresses"].elementAt(0);
              var status = '';

              status = 'empty';
              myOrdersList.add({"subCategories":subCategories,
                "id":"${result["result"][n]["id"]}",
                "title":"${result["result"][n]["title"]}",
                "start_date":"$rightDate",
                "start_time":"$startTime",
                "confirmed":false,
                'images':images,
                'executor':executor,
                'adres':{"lat":"${show['latlng']}",
                  "lng":"${show['long']}"},
                'input_request':inputRequest,
                'description':'${result["result"][n]["description"]}',
                'taskPrice':'${result["result"][n]["price"]}',
                'order_status':status,
                'town':'${show['town']}',
                'address':'${show['adress']}',
                'adDescription':'${show['description']}'});

            }

          }
        }

        setState(() {

        });

      }, (error){  });
    });
  }

  selectCategory() async {
    print("11");
    await ServerManager(context).getSpecialistsIdRequest(id, (result) {
      //print('result = $result');
    }, (error){ });
  }

  @override
  Widget build(BuildContext context) {

    void onOrderClick(BuildContext context, Map orderInfo) {
      var height = orderInfo['order_status'] == "empty" && orderInfo['input_request'].length == 0 || orderInfo['order_status'] == "Завершено"? 0.46 :0.9;
      print(orderInfo['input_request'].length);
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          //enableDrag: false,
          builder: (context) => FractionallySizedBox(
            heightFactor: height,
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
                  child: Material(
                      clipBehavior: Clip.none,
                      elevation: 4, child: OrderInputRequestController(orderInfo, orderIndex,))
              ),
            ),
          ),
          isScrollControlled: true).then((onValue){
        _getData();
      });
    }

    final bottomOrderList = ListView.separated(
      itemCount: myOrdersList.length,
      padding: EdgeInsets.only(left: 4,top: 2, right: 3),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var orderInfo = myOrdersList[index];
        return GestureDetector(
          child: Container(
            height: 125,
            decoration: new BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: styles.Colors.tintColor,
                    blurRadius: 5.0, // has the effect of softening the shadow
                    spreadRadius: 1.0, // has the effect of extending the shadow
                    offset: Offset(
                      0.0, // horizontal, move right 10
                      1.0, // vertical, move down 10
                    ),
                  )
                ],
                borderRadius: new BorderRadius.only(
                    topRight: const Radius.circular(30.0),
                    topLeft: const Radius.circular(30.0))),
            padding: EdgeInsets.only(left: 21, right: 21, top: 14, bottom: 10),
            width: MediaQuery.of(context).size.width-7,
            //color: Colors.red,
            child:
            Widgets().orderTopWidget(orderInfo, false),

          ),
          onTap: () {
            onOrderClick(context, orderInfo);
            orderIndex = index;
          },
        );
      },
      separatorBuilder: (context, index) => Divider(
        indent: 1,
        endIndent: 1.5,
      ),
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    print(send.length);
    return Scaffold(
        backgroundColor: Color.fromRGBO(247, 249, 252, 1),
        appBar: MainAppBar(
            height: 118,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate('titleChooseSpecialist')),
        bottomNavigationBar:
        myOrdersList.length != 0
            ? Container(
            width: double.infinity,
            height: 135,
            child:  bottomOrderList)
            :null,
        body: send.isNotEmpty
            ? RefreshIndicator(
            color:styles.Colors.orange,
            child: new ListView.builder(
                itemCount: send.length,
                padding: EdgeInsets.only(top: 20, bottom: 20),
                itemBuilder: (context, int index) {
                  return new GestureDetector(
                    child: HorizontalList(
                      mainList:  send.elementAt(index),
                    ),
                    onTap: ()async {
                      id = "$index";
                      await selectCategory();},
                  );
                }),
            onRefresh: _getData)
            : Center(child: CupertinoActivityIndicator(radius: 15.0))

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _getData() async {
    setState(() {
      getMainPage();
    });
  }
}



