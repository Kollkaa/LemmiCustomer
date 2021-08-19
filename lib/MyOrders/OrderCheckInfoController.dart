import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Main/MainController.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/MyOrders/OrderGalleryController.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:flutter/cupertino.dart';
import '../app_localizations.dart';

class OrderCheckInfoController extends StatefulWidget {
  OrderCheckInfoController(this.button, this.idTask,  {Key key, this.orderInfo}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final OrderInfo orderInfo;
  final String idTask;
  final bool button;
  @override
  _OrderCheckInfoControllerState createState() => _OrderCheckInfoControllerState(orderInfo);
}

class _OrderCheckInfoControllerState extends State<OrderCheckInfoController> {
  _OrderCheckInfoControllerState(this._orderInfo);

  OrderInfo _orderInfo;
  String taskId;
  List <String> image;
  List<dynamic> subItems = [];

  void initState() {
    image = _orderInfo.images;
    subItems = _orderInfo.subCategories;
    super.initState();
  }
  
  final PageRouteBuilder _homeRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return MainController();
    },
  );
  
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
                         child: OrderGalleryController(image, orderInfo: _orderInfo,)
                        );
                  },
                ),
              ),
            ),
          ),
          isScrollControlled: true);
    }
    
  @override
  Widget build(BuildContext context) {
 var price = '${_orderInfo.price}';
 price  != '0'?price = '${_orderInfo.price} uah.'
 :price = AppLocalizations.of(context).translate("zeroPrice");

     final bottomButton = new MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          //375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0, left: 0, right: 0),
          // color: Colors.red,
          child: Text(AppLocalizations.of(context).translate("removeFromPublication"),
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText18),
        ),
        onPressed: (){

          taskId = "${widget.idTask}";
         _deletePublicationAction();
        }
    );

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
     Widget _statusInfoWidget(String status) {
      _orderInfo.status == 'empty'?
          status = "Не подписано":
          status = _orderInfo.status;
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
  
    return Scaffold(
        backgroundColor: styles.Colors.background,

        appBar: CreateAppBar(
            height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: _orderInfo.title,
            showAddButton: false),

        floatingActionButton: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 30, right: 30,),
          width: double.infinity,
          height: 50,
          child: widget.button == true
              ? null
              : bottomButton,
          //padding: EdgeInsets.only(left: 30, right: 30, bottom: 50),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ListView(
            padding: EdgeInsets.only(top: 20, left: 30, right: 30),
            children: <Widget>[
               Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child:Container(margin:EdgeInsets.only(top:5),
                      child: Text('СТАТУС:', style: styles.TextStyles.gilroyDarkText14,))),
                  Align(
                    alignment: Alignment.centerRight,
                    child:_statusInfoWidget('${_orderInfo.status}'))]),
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
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 0, right: 0),
                title: Text('${_orderInfo.title}',
                    style: styles.TextStyles.darkBoldText24),
                subtitle: "${_orderInfo.description}" == 'null' || _orderInfo.description == null
                ?  Text(AppLocalizations.of(context).translate("withoutDescr"),
                    style: styles.TextStyles.darkRegularText14)
                : Text(_orderInfo.description,
                    style: styles.TextStyles.darkRegularText14),
                
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
              height: 1,
            ),itemCount: subItems.length),
              Container(
              height: subItems.length == 0 || subItems == null ? 0: 1,
              color: Color(0x88ADADAD)),
              Container(
              height: subItems.length == 0 || subItems == null ? 0: 1,
              color: Color(0x88ADADAD)),
              SizedBox(height:10),
              Text(AppLocalizations.of(context).translate("tabTime"), style: styles.TextStyles.gilroyDarkText14,),
              ListTile(
                trailing: Image(image:
                AssetImage('assets/calendar_icon.png'),
                  width: 46,
                  height: 46,
                ),
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0),
                title: Text('${_orderInfo.startTime}',
                    style: styles.TextStyles.darkBoldText24),
                subtitle: Text('${_orderInfo.startDate}',
                    style: styles.TextStyles.darkRegularText14),
                onTap: () => {
print('${_orderInfo.startTime}')
                },
              ),
              Container(
              height: 1,
              color: Color(0x88ADADAD)),
              SizedBox(height:10),
              Text(AppLocalizations.of(context).translate("tabAddress"), style: styles.TextStyles.gilroyDarkText14,),
             
              _orderInfo.detailAddress == "для выполнения задания не обязательно присутствие исполнителя"
              ? ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0),
                title: Text(_orderInfo.detailAddress,
                    style: styles.TextStyles.darkRegularText14),
                onTap: () => {
                },
              )              
              : ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10),
                title: Text( _orderInfo.address,//'Большая Васильковская 32, Киев',
                    style: styles.TextStyles.darkText18),               
                subtitle: Text(_orderInfo.detailAddress,//'кв. 10, 6-й этаж, 7-й подезд ',
                    style: styles.TextStyles.darkRegularText17),
                onTap: () => {
                },
              )
              ,
              Container(
              height: 1,
              color: Color(0x88ADADAD)),
              ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10,),
                title: Text(price,//'${_orderInfo.price} uah.',
                    style: styles.TextStyles.darkBoldText24),
                subtitle: Text(AppLocalizations.of(context).translate('taskPayment'),
                    style: styles.TextStyles.darkRegularText17),
                onTap: () => {
                },
              ),            
               SizedBox(height: 10,),
               _orderInfo.status == "Не подписано"?
               Column(
                children: <Widget>[
                  Container(
              height: 1,
              color: Color(0x88ADADAD)),

              SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft,
                child:Text(AppLocalizations.of(context).translate("tabPerformer"), style: styles.TextStyles.gilroyDarkText14,)),
                
               ListTile(
                contentPadding: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 15),
                leading: '${_orderInfo.user.elementAt(0)["image_url"]}' == "https://api.lemmi.app/null"
                 ? CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/placeholder.png'),
                  child: Text('${_orderInfo.user.elementAt(0)["name"].toString()[0]}',
                  style:styles.TextStyles.whiteText24),
                 )              
                 
                 : CircleAvatar(
                    radius: 30,
                    backgroundColor: styles.Colors.orange,
                    child: ClipRRect(                
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    child: Image.network("${_orderInfo.user.elementAt(0)["image_url"]}",
                    fit: BoxFit.cover,
                    width: 54,
                    height: 54, 
                    loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                    child: CupertinoActivityIndicator(radius: 7.0),               
                    );
                    },))),              

                    title: Text('${_orderInfo.user.elementAt(0)["name"]} ${_orderInfo.user.elementAt(0)["surname"]}',
                    style: styles.TextStyles.darkText18),
                    )  
            ],

          ):SizedBox(height: 5), 
         ])
        )
    );
  }
}
