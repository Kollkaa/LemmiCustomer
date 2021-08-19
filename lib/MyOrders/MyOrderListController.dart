import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/MyOrders/OrderInfoController.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/ServerManager.dart';
import '../app_localizations.dart';

import 'package:kaban/Widgets.dart';
import 'package:kaban/Styles.dart' as styles;

class MyOrderListController extends StatefulWidget {
  MyOrderListController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  //_MyOrderListControllerState createState() = _MyOrderListControllerState();

  _MyOrderListControllerState createState() {
    return new _MyOrderListControllerState();
  }

}

class _MyOrderListControllerState extends State<MyOrderListController> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  bool showEmpty;
  void initState() {    
    super.initState();
    myOrders();
  }

 
/*  void _openOrderController(OrderInfo orderInfo) {

    Navigator.of(context).push(
        CupertinoPageRoute(
            builder: (context) => OrderInfoController(taskId)
        )
    );

  }*/
  List<OrderInfo> orderList = [];


  @override
  Widget build(BuildContext context) {

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
          : styles.Colors.agreen,
          child: Center(
            child: Text(status,
            // status == 'В ожидании' ? AppLocalizations.of(context).translate('wait') : AppLocalizations.of(context).translate('closed'),
              style: styles.TextStyles.whiteRegularText18,
            ),
          ),
        ),
      );

    }

    Widget _ratingWidget(double rating) {

      if (rating == null || rating == 0.0) {
        return Container();
      }

      if (rating > 0.0 && rating <= 5) {

        return Widgets().ratingWidget(rating, Alignment.centerRight);

      }else{

        return Container();
      }

    }
    Future<void> _getData() async {
    setState(() {
     myOrders();
    });
  }

    Widget _builOrdersList() {

      return orderList.isNotEmpty
      ? RefreshIndicator(
          color:styles.Colors.orange,
          child:ListView.separated(
            itemBuilder: (context, index) {
        return  Container(child:
        GestureDetector(
            child: Container(
               //height: 155,
               color: Colors.transparent,
              padding: EdgeInsets.only(left: 30, right: 30, bottom:15),
              child: Stack(
                children: <Widget>[

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),

                      Container(child:
                      Row(children: [Expanded(child:Text('${orderList[index].title}',
                        style: styles.TextStyles.darkText24,))]),
                        padding: EdgeInsets.only(right: 70),
                        alignment: Alignment.centerLeft,
                      ),

                      Container(
                        child: Text(
                          '${orderList[index].subtitle}',
                          style: styles.TextStyles.darkRegularText14,),
                        //  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: Text('${orderList[index].startDate}',
                          style: styles.TextStyles.darkText18,),
                        //   padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      ),
                      SizedBox(height: 10),
                      Stack(
                        children: <Widget>[_statusInfoWidget('${orderList[index].status}')],
                      )
                    ],
                  ),

                  Column(
                    // align the text to the left instead of centered
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Container(child: Text('${orderList[index].price} грн.',
                        style: styles.TextStyles.darkText24,),
                        // padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        alignment: Alignment.topRight,
                      ),
                      SizedBox(height: 10),


                      _ratingWidget(orderList[index].rating)
                    ],
                  ),


                ],
              ),
            ),
            onTap: () {

             // setState(() {
                var taskId = orderList[index].taskId;
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => new OrderInfoController(taskId, orderInfo: orderList[index]))
                );

              //});

            },
          
        ));
      },
        separatorBuilder: (context, index) =>
            Divider(
              color: Color.fromRGBO(255, 178, 158, 1.0),
              indent: 30,
              endIndent: 30,
              height: 0,
            ),
        itemCount: orderList.length,
        padding: EdgeInsets.only(bottom: 100),
        key: _listKey,
      ),
      onRefresh: _getData)
      :Center(child: CupertinoActivityIndicator(radius: 15.0));
    }

    
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: styles.Colors.background,

        appBar: CreateAppBar(height: 118,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate('titleMyTasks'),
            showAddButton: false),

        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            
          },
          child: showEmpty == true       
          ? Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: <Widget>[
            Container(
            child: Text(AppLocalizations.of(context).translate("archive"), style: styles.TextStyles.darkText21),),
            SizedBox(height: 5,),
             Text(AppLocalizations.of(context).translate("pusto"), style: styles.TextStyles.darkRegularText14,),
            ]
        ),)        
        :_builOrdersList(),
        ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  List <String> images = [];
  List<Map<String, Object>> executor = [];
  
   myOrders() async{
   WidgetsBinding.instance.addPostFrameCallback((_) {
  
   ServerManager(context).myOrderRequest((result){
    orderList = [];
    var _length= result["result"].length;
    executor = [];
    if(_length == 0){
      showEmpty = true;
    }else{
      showEmpty = false;
      for(int i = 0; i < _length; i++){
      //  print(result["result"].elementAt(i));
      executor = [];
        var executer = result["result"].elementAt(i)["user"];
         executor.add({"id":"${executer["id"]}",
         "name":"${executer["first_name"]}",
         "surname":"${executer["last_name"]}",
         "photo":"https://api.lemmi.app/${executer["photo"]}"
         });
      var lengthPhoto= result["result"].elementAt(i)["activity_task_photos"].length; 
      images =[];      
      for(int j = 0; j < lengthPhoto; j++){
        images.add("https://api.lemmi.app/${result["result"].elementAt(i)["activity_task_photos"].elementAt(j)['photo']}");
      }
        
        var element = result["result"].elementAt(i);        
        var data  = "${result["result"].elementAt(i)["data"]}";
        String rightDate = '${data.substring(8,10)}.${data.substring(5,7)}.${data.substring(0,4)}';   
        String startTime = "";//data.substring(11,16);

        if(element["addresses"] ==[]){
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
        if(element['status'] == 'empty'){
          status = "Не подписано";
          print(status);}
          else if(element['status'] == 'done'){
          status = AppLocalizations.of(context).translate('accepted');
        }else if(element['status'] == 'problem'){
           element['order_status'] != 'Проблема'
          ? status =element['order_status']
          : status ='Проблема';
        }else{
          status = "${element['order_status']}";
        }
        
        var town;
        "${element["addresses"].elementAt(0)["town"]}"!=''
        ?town = "${element["addresses"].elementAt(0)["town"]},"
        :town = '';
        orderList.add(OrderInfo([],"${element['id']}", "${element['title']}", "${element['description']}", 
        "Специалист", "${element['price']}", raiting, "${element['order_status']}",idRating, "$rightDate" ,"$startTime", status, 
        //
        "$town ${element["addresses"].elementAt(0)["adress"]}","${element["addresses"].elementAt(0)["description"]}", executor, images));
     
      }
    }    
      setState(() {

      });

    }, (error){

    });
});
    
  }
}
