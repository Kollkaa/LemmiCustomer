import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:kaban/CreateOrder/CreateOrderSuccessController.dart';
import 'package:kaban/CreateOrder/GalleryController.dart';
import 'package:kaban/CreateOrder/AddAddressMapController.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Main/MainController.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:kaban/Widgets.dart';
import 'package:http/http.dart' as http;
import '../app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateOrderConfirmController extends StatefulWidget {
  final Task task;
  CreateOrderConfirmController(this.adres, this.adres1, {Key key, this.title, this.task}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".  
  final String title;
  final String adres;
  final String adres1;
  
  @override
  _CreateOrderConfirmControllerState createState() => _CreateOrderConfirmControllerState();
}

class _CreateOrderConfirmControllerState extends State<CreateOrderConfirmController> { 
  bool published;
  double longitude;
  double latitude;
  DateTime todayDate;
  String status;
  String plus;
  String adres;
  String adres1;
  FormData formData = new FormData();
  Dio dio = new Dio();
  String token;
  SharedPreferences sharedPreferences;
  String sub3;
  var  subItems = [];
  String addressId;

  final gray14 = TextStyle(fontFamily: "Gilroy",fontSize: 14,                        
                        fontStyle: FontStyle.normal,letterSpacing: -0.113412,                        
                        color: Color(0xFF464446),);
  final dark14 = TextStyle( fontFamily: "Gilroy", fontWeight: FontWeight.w500,
                        fontSize: 14, fontStyle: FontStyle.normal,
                        letterSpacing: -0.113412,color: styles.Colors.darkText,);                        
                        

  void initState() {
    addressId = widget.task.address_id;
    getData();    
    super.initState();
    showPrice();
    longitude =widget.task.longitude;
    latitude = widget.task.latitude;
  }

   getData() async{
     published = widget.task.published;
    var strDate = '${widget.task.data}';
      todayDate = DateTime.parse(strDate); 
      String smth = "${DateTime.now().timeZoneOffset}";
      plus = smth.substring(0,1);         
      var date = todayDate.add(Duration(hours: 1));
      subItems = widget.task.subCategory;
      sub3 = widget.task.subCategoryId.toString();
  } 

   showPrice(){
    if(widget.task.price.isNotEmpty){ 
    formData.fields.add(MapEntry("price", widget.task.price));      
    }else{ }
  }  

  getJWTToken() async {
    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    token = sharedPreferences.getString("token").toString();
  }

  
  @override
  Widget build(BuildContext context) {
final PageRouteBuilder _bestRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return CreateOrderSuccessController(task:widget.task);
    },
  );

    final PageRouteBuilder _homeRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return MainController();
    },
  );

  _createOrderAction(String status) async  {
    if (widget.task.price.isEmpty){
    widget.task.price = "0";
    }
    await getJWTToken();
    
    //final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    //Dialogs().showLoadingDialog(context, _keyLoader);
    try{
      print("https://api.lemmi.app/api/activity-task/create");
      print({
        "photo":widget.task.photo,
        "description": widget.task.description,
        "price": widget.task.price,
        "data": widget.task.data,
        //"address_id":widget.task.address_id,
        "address_id": addressId,
        "services_id": widget.task.services_id,
        "specialist_id": widget.task.globalCategory,
        "under_services":sub3,
        "status": status
      });
      print(
        jsonEncode({
          // "photo":widget.task.photo,
          "description": widget.task.description,
          "price": widget.task.price,
          "data": widget.task.data,
          //"address_id":widget.task.address_id,
          "address_id": addressId,
          "services_id": widget.task.services_id,
          "specialist_id": widget.task.globalCategory,
          "under_services":sub3,
          "status": status
        })
      );
    var response =  await http.post("https://api.lemmi.app/api/activity-task/create",
     body: jsonEncode({
       // "photo":widget.task.photo,
       "description": widget.task.description,
       "price": widget.task.price,
       "data": widget.task.data,
       //"address_id":widget.task.address_id,
       "address_id": addressId,
       "services_id": widget.task.services_id,
       "specialist_id": widget.task.globalCategory,
       "under_services":sub3,
       "status": status
     }),
      headers:{
           "Authorization": "Bearer $token",
        "Content-Type": "application/json"
         });
    //Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print(response.body);

      if(response.statusCode == 200){
      print(response);
          var responseBody = response.body;
          // if(responseBody['code'] == 200){
          // print(responseBody);
          // widget.task.activity_task_id="${responseBody["result"]["id"]}";
          // widget.task.published = published = false;
          //
          // } else{
          //   print("${response.statusCode}");
          //   print(response.data);
          //   //Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          //   Dialogs().alertAction(context, "Error", "${response.statusCode}", (){
          //
          //   Navigator.of(context).pop();
          //   //Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          //
          // });
          // }
        } else if(response.statusCode == 502){
          //Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          Dialogs().alert(context, "Error 502", "502 Bad Gateway");
        }else{
         // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          Dialogs().alertAction(context, "Error", "${response.statusCode}", (){

            Navigator.of(context).pop();
           // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

          });
        }
    //print(response);
    }
    catch(e){
      //Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print(e);      
      Dialogs().alert(context, "Error", "$e");
    }       
    status == 'active'
    ?Navigator.pushAndRemoveUntil(
        context, _homeRoute, (Route<dynamic> r) => false).then((result){
        })
    :Navigator.pushAndRemoveUntil(
        context, _bestRoute, (Route<dynamic> r) => false).then((result){
        });
     //setState((){});
    }

    

    void _goToMainAction() async{
    Navigator.pushAndRemoveUntil(
        context, _homeRoute, (Route<dynamic> r) => false).then((result){
        }); 
  }

  void _sendBestAction() async {
    Navigator.pushAndRemoveUntil(
        context, _bestRoute, (Route<dynamic> r) => false).then((result){
        });
    } 

    void galleryWidget(BuildContext context) {
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
                        elevation: 4, child: GalleryController(task:widget.task));
                  },
                ),
              ),
            ),
          ),
          isScrollControlled: true);
    }

    void mapWidget(BuildContext context) {
    widget.task.longitude == null || widget.task.longitude == 0
       ?  Dialogs().alert(context, AppLocalizations.of(context).translate('error'),
        AppLocalizations.of(context).translate('addressNotSet'))
     : showModalBottomSheet(
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
                child:DraggableScrollableSheet(
                  initialChildSize: 1,
                  minChildSize: 0.8,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Material(
                        elevation: 4, child: 
                         MapSample(longitude, latitude)
                    );
                  },
                ),
              ),
            ),
          ),
          isScrollControlled: true);         
    }

    final publishButton = new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: Text(AppLocalizations.of(context).translate('toPublish'),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Gilroy',
                  fontStyle: FontStyle.normal,
                  fontSize: 18,
                  color: Colors.white))),        
        onPressed: (){_createOrderAction('active');
       //_goToMainAction();
       }
    );


    final closeButton = new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: Text(AppLocalizations.of(context).translate('close'),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Gilroy',
                  fontStyle: FontStyle.normal,
                  fontSize: 18,
                  color: Colors.white))),        
        onPressed: (){_goToMainAction();}
    );

    final sendBestButton = new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: Text(AppLocalizations.of(context).translate('sub1'),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Gilroy',
                  fontStyle: FontStyle.normal,
                  fontSize: 18,
                  color: Colors.white))),        
        onPressed: (){_createOrderAction('personal');
        _sendBestAction();}
    );

    var selectedAddress = {};

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    
    return WillPopScope(
      onWillPop: () async => false,
      child:Scaffold(
        backgroundColor: styles.Colors.background,
        floatingActionButton: published == false        
        ? Column(
          mainAxisAlignment: MainAxisAlignment.end,
         children: [ 
            Container(child:sendBestButton,
             padding: EdgeInsets.only(left: 30, right: 30,),),
            SizedBox(height: 15),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 30, right: 30,),
          width: double.infinity,
          height: 50,
          child: publishButton,
        )])
        : 
            Container(child:closeButton,
            padding: EdgeInsets.only(left: 30, right: 30,),),
        // ] 
        //),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        appBar: published == false
        ? CreateAppBar(height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
          titleAppBar: AppLocalizations.of(context).translate('titleLetsCheck'),
          showAddButton: false)
        : TitleSubtitleAppBar(
          titleAppBar: "",//AppLocalizations.of(context).translate('published'),
          subtitleAppBar:
          AppLocalizations.of(context).translate('sendBest'),
        ),
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(

            padding: EdgeInsets.only(top: 20,left:30, right:30),
              children: <Widget>[

                ListTile(
                  trailing: 
                  GestureDetector(
                    child: Container(
                      width: 46.0,
                      height: 46.0,
                      child: Center(
                          child: Image(image: AssetImage('assets/orange_camera_icon.png'),
                          height:19.5, width:22
                          )
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/pink_oval.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    onTap: () {
                      if (widget.task.images != null && widget.task.images.length > 0){
                        galleryWidget(context);}
                        else{}
                    },
                  ),
                  contentPadding: EdgeInsets.only(left: 0, right: 0),
                  title: Text(widget.task.category,
                      style: styles.TextStyles.darkText24),
                  subtitle: Text(widget.task.description,    
                  style: gray14),
                  onTap: () => {
                  },
                ),
               Container(
              padding:EdgeInsets.only(left:30,right:30),
              height: subItems.length == 0 || subItems == null ? 0: 1,
              color: Color(0x88ADADAD)),
               ListView.separated(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index){
              return ListTile(
               contentPadding: EdgeInsets.only( right: 7, top: 0, bottom: 0),
               trailing: Image(
              image: AssetImage('assets/check_green_icon.png'),
              width: 28.3,
              height: 28.3,
            ),
               title: Text('${subItems[index]['title']}',
               style: TextStyle(fontFamily: 'Gilroy',
                        fontStyle: FontStyle.normal,
                        color: styles.Colors.darkTextPlaceholder,
                        fontSize: 18
                    ))
              );
            }, separatorBuilder: (context, index) => Divider(
              color: Color(0XFFADADAD),
              height: 1,
            ),itemCount: subItems.length),
            Container(
              padding:EdgeInsets.only(left:30,right:30),
              height: 1,
              color: Color(0x88ADADAD)),
              ListTile(
                  trailing: Image(image:
                  AssetImage('assets/calendar_icon.png'),
                    width: 46,
                    height: 46,),                  
                  contentPadding: EdgeInsets.only(top: 10),
                    title: Text(widget.task.hours, 
                      style: styles.TextStyles.darkBoldText24),  
                  subtitle: Text(widget.task.day,
                      style: gray14),
                  onTap: () => {
                    setState((){}),
                  },
                ),
              Container(
              height: 1,
              color: Color(0x88ADADAD)),
              ListTile(
                  trailing: Image(image:
                  AssetImage('assets/location_icon.png'),
                    width: 46,
                    height: 46,),                  
                  contentPadding: EdgeInsets.only(top: 10),
                  title: Text(widget.adres,
                      style: styles.TextStyles.darkText18),
                  subtitle: Text(widget.adres1,
                      style: gray14),
                  onTap: () => { 
                   mapWidget(context)
                  },
                ),
              Container(
              height: 1,
              color: Color(0x88ADADAD)),
              ListTile(
                  contentPadding: EdgeInsets.only(top: 10, bottom: 0),
                  title: Text("${widget.task.price0}",
                      style: styles.TextStyles.darkBoldText24),
                  subtitle: Text(AppLocalizations.of(context).translate('taskPayment'),
                      style:gray14),
                  onTap: () => {
                  },
                ),
              Container(
              padding:EdgeInsets.only(left:30,right:30),
              height: 1,
              color: Color(0x88ADADAD)),
              SizedBox(height: 150,)
              ],

          ),
        )

      // This trailing comma makes auto-formatting nicer for build methods.
    ));  
  }
}
