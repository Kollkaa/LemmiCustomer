import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:intl/intl.dart';

import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/MyOrders/ExecutorUser.dart';
import 'package:kaban/MyOrders/OrderGalleryController.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:kaban/MyOrders/OrderCommentController.dart';
import 'package:kaban/Main/MainController.dart';
import '../app_localizations.dart';

class OrderInfoController extends StatefulWidget {
  OrderInfoController(this.taskId, {Key key, this.orderInfo}) : super(key: key);

  final OrderInfo orderInfo;
  final String taskId;

  @override
  _OrderInfoControllerState createState() => _OrderInfoControllerState(orderInfo);
}

class _OrderInfoControllerState extends State<OrderInfoController> {
  _OrderInfoControllerState(this._orderInfo);
  
  OrderInfo _orderInfo;
  List<OrderInfo> orderList = [];
  OrderInfo orderInfo =OrderInfo([],"", "", "", "Специалист", "", 0.0, "", "",
  '' ,
  "", "","","", [{"id":"","name":"","surname":"","photo":""}], []);
  String performerId;
  String taskId;
  double rating;
  String ratingId;
  List <String> image;
  bool rate = false;
  String userId;
  var plus;
  String startTime;
  String activityTaskId;
  String theRating;
  double firstRating;
  double thisPageRating;
  List <String> images = [];
  var feedback;
  var data;
  List<Map<String, Object>> executor = [];
 var subItems = [];

  void initState() { 
    super.initState();
     getOrderInfo(); 
      
  }

  
  
  getOrderInfo() async {    
    taskId = widget.taskId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
    ServerManager(context).myOrderByIdRequest(taskId, (result){
    executor = [];
     List<dynamic> subCategories = result["result"].elementAt(0)['serviceNames'];
      executor = [];      
      var executer = result["result"].elementAt(1)["user"];
        executor.add({"id":"${executer["id"]}",
          "name":"${executer["first_name"]}",
          "surname":"${executer["last_name"]}",
          "photo":"https://api.lemmi.app/${executer["photo"]}"
          });         
      var lengthPhoto= result["result"].elementAt(0)["activity_task_photos"].length; 
      images =[];      
        for(int j = 0; j < lengthPhoto; j++){
          images.add("https://api.lemmi.app/${result["result"].elementAt(0)["activity_task_photos"].elementAt(j)['photo']}");
        }
      var element = result["result"].elementAt(0);        
      data  = "${element["data"]}";
        String rightDate = '${data.substring(8,10)}.${data.substring(5,7)}.${data.substring(0,4)}';       
        String smth = "${DateTime.now().timeZoneOffset}";
        plus = smth.substring(0,1);
        var newTime  = DateFormat("HH:mm").parse(data.substring(11,16)).add(Duration(hours:int.parse(plus)));
         startTime =  '${DateFormat("HH:mm").format(newTime)}';
        print(startTime);
        if(element["addresses"] == []){
          element["addresses"].elementAt(0)["town"] = "";
          element["addresses"].elementAt(0)["adress"] = "";
          element["addresses"].elementAt(0)["description"] = "";
        }
      var raiting; 
      var idRating;       
        if(element['users_ratings'].isEmpty || element['users_ratings'].elementAt(0)['rating'] == null){
        raiting = 0.0;
        idRating = null;
        }
        List<dynamic> urRat = element['users_ratings'];
        urRat.forEach((element) {
          if ("${element['rating']}" == "null"){
            raiting = 0.0;
            idRating = "${element['id']}";
          } else {
        raiting  = double.parse("${element['rating']}");
        assert (raiting is double);
        idRating = "${element['id']}";}});
        var status;
        if(result["result"].elementAt(1)['status'] == 'empty'){
          status = "Не подписано";
          print(status);}
        else if(result["result"].elementAt(1)['status'] == 'done'){
          status = AppLocalizations.of(context).translate('accepted');
        }else if(element['status'] == 'problem'){
           element['order_status'] == 'Завершено'
          ? status ='Завершено'
          : status ='Проблема';
        }else{
          status = "${result["result"].elementAt(1)['order_status']}";
        }
        print("${result["result"].elementAt(1)['order_status']}");
        print(result["result"].elementAt(1)['status']);
        var price;
        "${element['price']}" == '0'
        ?price = AppLocalizations.of(context).translate("zeroPrice")
        :price = "${element['price']} uah.";
        var town;
        "${element["addresses"].elementAt(0)["town"]}"!=''
        ?town = "${element["addresses"].elementAt(0)["town"]},"
        :town = '';
        var adres;
        "${element["addresses"].elementAt(0)["adress"]}"!=''
        ?adres = "${element["addresses"].elementAt(0)["adress"]},"
        :adres = '';


      orderList.add(OrderInfo(subCategories, "${element['id']}", "${element['title']}", "${element['description']}", "Специалист",
       /*"${element['price']}"*/price, raiting,"${element['order_status']}", idRating, "$rightDate" ,"$startTime", status,
      
    "$town $adres","${element["addresses"].elementAt(0)["description"]}", executor, images));
       
    //  } 
      setState(() {
      orderInfo = orderList[0];
      image = orderInfo.images;
      performerId = "${orderInfo.user.elementAt(0)['id']}";
      firstRating = orderInfo.rating;
      subItems = orderInfo.subCategories;
      }); 
 getData();
 
    }, (error){

    });
    });
    String activityTaskId = widget.taskId;
    await ServerManager(context).checkFeedbackRequest(activityTaskId, (result){
    Map<String, dynamic> resul = result;
      feedback = "${resul['rating']}";
      }, (error){});
     
  }
  
  getData() async{
   
    print("d$data");
    var strDate = "${data.substring(0,4)}-${data.substring(5,7)}-${data.substring(8,10)} $startTime";
    var todayDate = DateTime.parse(strDate);
    print(strDate);

  }
  
  void _addCommentAction() async {  
    //if(rate == true){
      //}else if (rate == true && firstRating == 0.0){
      //var ratingId = orderInfo.idRating;      
      //Navigator.push(context,
      //  CupertinoPageRoute(builder: (context) => new OrderCommentController(performerId, taskId, ratingId)));
      var rate = "$thisPageRating";
      "$thisPageRating" == "null"?rate = feedback: rate= "$thisPageRating";
      print(rate);
      theRating = rate.substring(0,1); 
      userId = performerId;
      activityTaskId = taskId;
      await ServerManager(context).ratingPerformerRequest(theRating, userId, activityTaskId, (result){
      ratingId = '$result';
      Navigator.push(context,
        CupertinoPageRoute(builder: (context) => new OrderCommentController(performerId, taskId, ratingId))
      );
        }, (error){}); 
        
    /*}else{
      var ratingId = orderInfo.idRating;      
      Navigator.push(context,
        CupertinoPageRoute(builder: (context) => new OrderCommentController(performerId, taskId, ratingId))
    );
    } */
    
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
                        elevation: 4,
                         child: OrderGalleryController(image, orderInfo: orderInfo)
                        );
                  },
                ),
              ),
            ),
          ),
          isScrollControlled: true);
    }

    _problem() async{
      await ServerManager(context).problemStatus(taskId, (result) {
        orderInfo.status = 'Проблема';
        setState((){});
       }, (errorCode) { });      
    }

    _fullyDone() async{
      await ServerManager(context).accepsDoneStatus(taskId, (result) {
        orderInfo.status = AppLocalizations.of(context).translate('accepted');
        setState((){});
          rate = true;
        
        print(rate);
       }, (errorCode) { });      

    }
    _no(){}
     final PageRouteBuilder _homeRoute = new PageRouteBuilder( 
    pageBuilder: (BuildContext context, _, __) {
      return MainController();
    },
  );
  @override
  Widget build(BuildContext context) {
    void _deletePublicationAction() async{
    showDialog(
    context:context,
    builder: (_)=> CupertinoAlertDialog(
       title: Text(AppLocalizations.of(context).translate("areYouSure")),
      content:Text(AppLocalizations.of(context).translate("deleteTask")),
      actions: [
        CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("yes"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14,)),
       onPressed:() async{
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
 final bottomsButton = new MaterialButton(
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
          taskId = "${widget.taskId}";
         _deletePublicationAction();
        }
    );
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

    final doneButton = 
    '${orderInfo.status}' == "Завершено"?
    new MaterialButton(
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
           setState(() {
             
           });
        }
    ):new MaterialButton(
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
                  color: Colors.grey))),        
        onPressed: (){
           _no(); }
    );

    final bottomButton = new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,//375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: feedback == 'false'?
          Text(AppLocalizations.of(context).translate("rating"),
              textAlign: TextAlign.center,
              style: orderInfo.rating == 0.0 ? styles.TextStyles.whiteTransText18
              : styles.TextStyles.whiteText18)
              :Text(AppLocalizations.of(context).translate("сhangeRating"),
              textAlign: TextAlign.center,
              style:  styles.TextStyles.whiteText18)
        ),
        onPressed:  orderInfo.rating == 0.0
        ? (){}
        : _addCommentAction
    );

    Widget _statusInfoWidget(String status) {

      return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 30,
          width: 136,
          color: status == 'В ожидании' ? styles.Colors.waiting 
          : status == 'В пути' ? styles.Colors.onMyWay
          : status == 'В процессе' ? styles.Colors.inProcess 
          : status == 'Проблема' ? styles.Colors.problem
          : status == AppLocalizations.of(context).translate('accepted') ? styles.Colors.acceptedgreen
          : status == "Не подписано" ?styles.Colors.waiting 
          : status == 'Завершено' ?  styles.Colors.agreen
          :styles.Colors.whiteColor,

          child: Center(
            child: Text(status,
            // status == 'В ожидании' ? AppLocalizations.of(context).translate('wait') : AppLocalizations.of(context).translate('closed'),
              style: styles.TextStyles.whiteRegularText18,
            ),
          ),
        ),
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

        appBar: CreateAppBar(height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: orderInfo.title,
            showAddButton: false),

        floatingActionButton: orderInfo.status == "Принято" || orderInfo.status == "Прийнято"
        ? Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 30, right: 30),
          width: double.infinity,
          height: 50,
          child: bottomButton,
        )
        : Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 30, right: 30,),
          width: double.infinity,
          height: 50,
          child: orderInfo.status != "Не подписано"
              ? null
              : bottomsButton),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(top: 20, left: 30, right: 30),
            children: <Widget>[
               SizedBox(height: 10),
              Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child:Container(margin:EdgeInsets.only(top:5),
                      child: Text('СТАТУС:', style: styles.TextStyles.gilroyDarkText14,))),
                  Align(
                    alignment: Alignment.centerRight,
                    child:_statusInfoWidget('${orderInfo.status}'))]),
              SizedBox(height: 10),
              Container(
              height: 1,
              color: Color(0x88ADADAD)),
              SizedBox(height: 10),
              Text(AppLocalizations.of(context).translate("tabService"), style: styles.TextStyles.gilroyDarkText14,),

              ListTile(
                trailing: Container(
                  width: 46.0,
                  height: 46.0,
                  child: Center(
                      child: Image(image: AssetImage('assets/orange_camera_icon.png'),
                      height:19.5, width:22.3
                      )
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/pink_oval.png'),
                      fit: BoxFit.cover,
                    ),
                    //borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 0, right: 0),
                title: Text('${orderInfo.title}',
                    style: styles.TextStyles.darkBoldText24),
                subtitle:  "${orderInfo.description}" == 'null' || orderInfo.description == null
                ?  Text(AppLocalizations.of(context).translate("withoutDescr"),
                    style: styles.TextStyles.darkRegularText17)
                : Text(orderInfo.description,
                    style: styles.TextStyles.darkRegularText17),
                onTap: () {
                  if (image != null && image.length > 0){
                        galleryWidget(context);}
                  else{}
                },
              ),
              Container(
              height: 1,
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
               title: Text('${subItems[index]}',
               style: TextStyle(fontFamily: 'Gilroy',
                        fontStyle: FontStyle.normal,
                        color: styles.Colors.darkTextPlaceholder,
                        fontSize: 18
                    ))
              );
            }, separatorBuilder: (context, index) => Divider(
              color: Color(0XFFADADAD),
              height:  1,
            ),itemCount: subItems.length),
              Container(
              height: subItems.length == 0 || subItems == null ? 0: 1,
              color: Color(0x88ADADAD)),
              SizedBox(height:20),
              Text(AppLocalizations.of(context).translate("tabTime"), style: styles.TextStyles.gilroyDarkText14,),

              ListTile(
                trailing: Image(image:
                AssetImage('assets/calendar_icon.png'),
                  width: 46,
                  height: 46,
                ),
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 00),
                title: Text('${orderInfo.startTime}',
                    style: styles.TextStyles.darkBoldText24),
                subtitle: Text(orderInfo.startDate,//'Сегодня, 12 марта 2019',
                    style: styles.TextStyles.darkRegularText17),
                onTap: () => {
                              //setState((){}),
                              },
              ), 
              Container(
              height: 1,
              color: Color(0x88ADADAD)),
              SizedBox(height:20),
              Text(AppLocalizations.of(context).translate("tabAddress"), style: styles.TextStyles.gilroyDarkText14,),

               orderInfo.detailAddress == "Для выполнения задания не обязательно присутствие исполнителя"
              ? ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10,bottom:15),
                title: Text(orderInfo.detailAddress,//'кв. 10, 6-й этаж, 7-й подезд ',
                    style: styles.TextStyles.darkRegularText17),
                onTap: () => {
                },
              )              
              : ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10,bottom:15),
                title: Text( orderInfo.address,
                    style: styles.TextStyles.darkText18),               
                subtitle: Text(orderInfo.detailAddress,
                    style: styles.TextStyles.darkRegularText17),
                onTap: () => {
                },),                            
              Container(
              height: 1,
              color: Color(0x88ADADAD)),
              ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10),
                title: Text('${orderInfo.price}',
                    style: styles.TextStyles.darkBoldText24),
                subtitle: Text(AppLocalizations.of(context).translate("taskPayment"),
                    style: styles.TextStyles.darkRegularText17),
                onTap: () => {
                },),

              orderInfo.status != "Не подписано"
              ?Column(
                children: <Widget>[
                  Container(
              height: 1,
              color: Color(0x88ADADAD)),

              SizedBox(height: 20),

              Align(alignment: Alignment.centerLeft,
                child:Text(AppLocalizations.of(context).translate("tabPerformer"), style: styles.TextStyles.gilroyDarkText14,)),

               ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 15),
                leading: '${orderInfo.user.elementAt(0)["photo"]}' == "https://api.lemmi.app/null"
                 ? CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/placeholder.png'),
                  child: Text('${orderInfo.user.elementAt(0)["name"].toString()[0]}',
                  style:styles.TextStyles.whiteText24),
                 )              
                 
                 : CircleAvatar(
                    radius: 30,
                    backgroundColor: styles.Colors.orange,
                    child: ClipRRect(                
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    child: Image.network("${orderInfo.user.elementAt(0)["photo"]}",
                    fit: BoxFit.cover,
                    width: 54,
                    height: 54, 
                    loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                    child: CupertinoActivityIndicator(radius: 7.0),               
                    );
                    },))),              

                    title: Text('${orderInfo.user.elementAt(0)["name"]} ${orderInfo.user.elementAt(0)["surname"]}',
                    style: styles.TextStyles.darkText18),
                    onTap: () => {
                                   
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
                      child: ExecutorUser(performerId),
                                ));
                              },
                            ),
                          ),
                        ),
                      ),
                  isScrollControlled: true)
                    },),              
              Container(
              height: 1,
              color: Color(0x88ADADAD)),
               orderInfo.status == 'Принято' || orderInfo.status == 'Прийнято'
               ? ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10),
                title: Text(
                    AppLocalizations.of(context).translate("tabLiveComment"), style: styles.TextStyles.gilroyDarkText14),
                subtitle: Align(
                    alignment: Alignment.topLeft,
                    child: new Container(
                      padding: EdgeInsets.only(top: 10),
                      width: 205,
                      height: 41,
                      child: new StarRating(
                        size: 41.0,
                        rating: orderInfo.rating,
                        color: styles.Colors.orange,
                        borderColor: Color(0xFFC4C4C4),
                        starCount: 5,
                        onRatingChanged: (rating) => setState(
                              () {  
                                /*if(firstRating != 0.0){
                                  print(firstRating);
                                  print(rate);
                                  print(orderInfo.status);
                                //rate = false;
                              } else{
                               // rate = true;*/
                             // this.rating = rating;
                            //_orderInfo.rating = rating;
                            orderInfo.rating = rating;
                            thisPageRating = rating;
                            //rate = true; 
                           // } 
                            _addCommentAction();},
                        ),
                      ),
                    )
                ),
                onTap: () => {

                },)
              : orderInfo.status == 'Проблема'
               ? Container(child:doneButton,
                  padding: EdgeInsets.only(top:20, left: 0, right: 0))
               : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [ 
                    SizedBox(height: 20,),
                    Container(child:doneButton,
                    padding: EdgeInsets.only(left: 0, right: 0,),),
                    SizedBox(height: 15),
                    Container(child:problemButton,
                    padding: EdgeInsets.only(left: 0, right: 0,),)
                ]),              
              
              orderInfo.status == 'Принято' || orderInfo.status == 'Прийнято' 
              ?SizedBox(height: 120,)
              :SizedBox(height: 25)
               ]):Container(margin: EdgeInsets.only(top:55),)

            ],

          ),
        )

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
