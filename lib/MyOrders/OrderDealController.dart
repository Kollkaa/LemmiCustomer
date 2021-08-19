import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kaban/Widgets.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Managers.dart';
import '../ServerManager.dart';
import '../app_localizations.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:kaban/MyOrders/OrderSuccessPayController.dart';

class OrderDealController extends StatefulWidget {
  OrderDealController(this.taskId, this.id, {Key key, this.orderDeal}) : super(key: key);
  final String taskId;
  final String id;
  final OrderDeal orderDeal;

  @override
  _OrderDealControllerState createState() => _OrderDealControllerState(orderDeal);
}

class _OrderDealControllerState extends State<OrderDealController> {
_OrderDealControllerState(this._orderDeal);
 OrderDeal _orderDeal;
 var rating;
 String title;
 String data;
 String location;
 String time;
 List <dynamic> subItems;
 var plus;
 DateTime todayDate;
getData() async{
    var strDate = "${_orderDeal.startDate.substring(6,10)}-${_orderDeal.startDate.substring(3,5)}-${_orderDeal.startDate.substring(0,2)} ${_orderDeal.startTime.substring(0,5)}";
    todayDate = DateTime.parse(strDate);
    print(todayDate);
    String smth = "${DateTime.now().timeZoneOffset}";
    plus = smth.substring(0,1);
  } 
  void initState() {
    super.initState(); 
    rating = double.parse("${_orderDeal.rating}");    
    assert(rating is double); 
    title = _orderDeal.title;
    location = "${_orderDeal.address} ${_orderDeal.detailAddress}";  
    data = "${_orderDeal.startDate}";
    time =  "${_orderDeal.startTime}";  
    subItems = _orderDeal.subCategories;
    print(_orderDeal.price);
    print(_orderDeal.changePrice);
    print(_orderDeal.comment);
    getData();

  }
 
  void payButtonAction() async {
    var id = widget.id;
    var taskId= widget.taskId;
     await ServerManager(context).acceptRequest(id, taskId, (code){  

      Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) =>
            OrderSuccessPayController(title, location, data, time)));

    }, (error){});    
  }

  @override
  Widget build(BuildContext context) {

    final executorRow = new Row(
      children: <Widget>[
        Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image:"${_orderDeal.imageUrl}" == "https://api.lemmi.app/null" || '${_orderDeal.imageUrl}' == 'null'
               ? NetworkImage("https://api.lemmi.app/uploads/user/default-non-user-no-photo.jpg",)
              : NetworkImage("${_orderDeal.imageUrl}"),

              ),
               
              borderRadius:
              BorderRadius.circular(30)),
        ),
        Container(
          padding: EdgeInsets.only(
              left: 10, top: 5, bottom: 5),
          height: 60,
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Text(
               // 'User Name Surname',
                _orderDeal.name,
                style: styles.TextStyles.darkText18,
              ),
              new Row(children:<Widget>[
              /*Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 10),
                width: 112,
                height: 20,
                child: new StarRating(
                  size: 20.0,
                  rating: rating,                 
                  color: Color(0xFFFF4C00),
                  borderColor: Color(0xFFC4C4C4),
                  starCount: 1,                  
                ),
              ),
              Text(
               // 'User Name Surname',
                rating,
                style: styles.TextStyles.darkText18,
              ),*/
              Widgets().ratingWidget(rating, Alignment.centerLeft),
              ])
            ],
          ),
        ),

      ],
    );

    final serviceCell = new ListTile(
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
        ),
      ),
      contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10),
      title: Text(
      _orderDeal.title,
          style: styles.TextStyles.darkBoldText24),
      subtitle:  "${_orderDeal.description}" == 'null' || _orderDeal.description == null
                ?  Text(AppLocalizations.of(context).translate("withoutDescr"),
                    style: styles.TextStyles.darkRegularText17)
                : Text(_orderDeal.description,
                    style: styles.TextStyles.darkRegularText17),
      onTap: () => {
      },
    );


    final orderDateCell = new ListTile(
      trailing: Image(image:
      AssetImage('assets/calendar_icon.png'),
        width: 46,
        height: 46,
      ),
      contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10),
      title: Text(_orderDeal.startTime,
          style: styles.TextStyles.darkBoldText24),
      subtitle: Text(_orderDeal.startDate,
          style: styles.TextStyles.darkRegularText17),
      onTap: () => {
      },
    );

    final addressCell =  _orderDeal.detailAddress == "для выполнения задания не обязательно присутствие исполнителя"   
      ? new ListTile(
      contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0),      
      subtitle: Text(_orderDeal.detailAddress,
          style: styles.TextStyles.darkRegularText17),
      onTap: () => {
      },
    )
    : new ListTile(
      contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0),
      title: Text(_orderDeal.address,
          style: styles.TextStyles.darkText18),
      subtitle: Text(_orderDeal.detailAddress,
          style: styles.TextStyles.darkRegularText17),
      onTap: () => {
      },
    );
    final payMoneyButton = new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,//375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 5, right: 5),
          child: //Row(
            //children: <Widget>[
              Center(child:Text( AppLocalizations.of(context).translate('titleDeal'),
               // AppLocalizations.of(context).translate("toPay"),
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText16)),
              
            //  Text('${_orderDeal.price} uah',
            //      textAlign: TextAlign.center,
            //      style: styles.TextStyles.whiteText24),

          //  ],
        //  ),
        ),
        onPressed: payButtonAction
    );

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
            titleAppBar: AppLocalizations.of(context).translate('titleDeal'),
            showAddButton: false),

        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(

            padding: EdgeInsets.only(top: 15, left: 30, right: 30),
            children: <Widget>[

              SizedBox(height: 10,),
              Text(AppLocalizations.of(context).translate("tabPerformer"), style: styles.TextStyles.gilroyDarkText14,),
              SizedBox(height: 20,),
              executorRow,             
              SizedBox(height: 10,),
              /*Row(children:<Widget>[Expanded(
                  child: Text("${_orderDeal.comment}" == "null"
                    ?''
                    :"${_orderDeal.comment}",
                    style: styles.TextStyles.darkRegularText18,
                  ),
                )]),*/
              SizedBox(height: 10,),
              Container(
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: Color(0xFFADADAD)),          
              SizedBox(height: 10,),
              Text(AppLocalizations.of(context).translate("tabService"), style: styles.TextStyles.gilroyDarkText14,),
              serviceCell,
              Container(
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: Color(0xFFADADAD)),
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
              height: 1,
            ),itemCount: subItems.length),
              Container(
              height: subItems.length == 0 || subItems == null ? 0: 1,
              color: Color(0x88ADADAD)), 
              SizedBox(height: 15),
              Text(AppLocalizations.of(context).translate("tabTime"), style: styles.TextStyles.gilroyDarkText14,),
              orderDateCell,
              Container(
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: Color(0xFFADADAD)), 
              SizedBox(height: 20,),  
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
                  '${_orderDeal.changePrice} uah.',
                  style: styles.TextStyles.darkText24,
                )
              ],
            ),
            SizedBox(height: 20,),
            Container(
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: Color(0xFFADADAD)),             
              SizedBox(height: 20,),
              Text(AppLocalizations.of(context).translate("tabAddress"), style: styles.TextStyles.gilroyDarkText14,),
              addressCell,
              Container(
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: Color(0xFFADADAD)),
              SizedBox(height:20), 
              payMoneyButton,
              //SizedBox(height:20),
              //Text(AppLocalizations.of(context).translate("taskPayment"), style:  styles.TextStyles.darkRegularText17,),
              //SizedBox(height: 20,),
              //bonusesRow,
              //SizedBox(height: 40,),
              //Text(AppLocalizations.of(context).translate("wayOfPayment"), style: styles.TextStyles.darkRegularText17),
              SizedBox(height: 140,),
            ],

          ),
        )

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
