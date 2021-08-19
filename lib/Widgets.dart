import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import 'package:kaban/CreateOrder/CreateOrderSelectCategoryController.dart';
import 'package:kaban/Managers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Styles.dart' as styles;
import 'package:flutter_rating/flutter_rating.dart';

import 'app_localizations.dart';

class Dialogs {

  Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.transparent,
                  elevation:0,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CupertinoActivityIndicator(radius: 15.0),
                         ]),
                    )
                  ])
          );
        });
  }

  Future<void> errorAlert(BuildContext context) async {
    return alert(context, AppLocalizations.of(context).translate('error'), AppLocalizations.of(context).translate('ups'));
  }

  Future<void> alertAction(BuildContext context, String title, String message, void action()) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ок'),
              onPressed: action,
            ),
          ],
        );

      },
    );
  }



  Future<void> alert(BuildContext context, String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ок'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );

      },
    );
  }

  Future<void> errorsAlert(BuildContext context) async {
    return alert(context, "Упс", AppLocalizations.of(context).translate('ups2'));}

}

class Widgets {

  Widget topBar(BuildContext context) => Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MaterialButton(
            child: Image(
              image: AssetImage('assets/arrow_back.png'),
              width: 10,
              height: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Image(
            image: AssetImage('assets/logo.png'),
            //width: 131,
            height: 32,
          ),
          MaterialButton(
            child: Container(),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      )
  );

  Widget horizontalLine() => Container(
      alignment: Alignment.bottomLeft,
      height: 1,
      padding: EdgeInsets.only(right: 0, left: 0, bottom: 0),
      color: styles.Colors.orangeTrans
  );

  Widget orderTopWidget(Map orderInfo, bool bigText) {
    var statuses;
    '${orderInfo['order_status']}' == 'empty'
    ?statuses = "Не подписано"
    :statuses = '${orderInfo['order_status']}';
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
          : status == 'Принято' ? styles.Colors.acceptedgreen
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
    var inputRequest = orderInfo['input_request'] as List;
    var confirmedRequest = orderInfo['confirmed'] as bool;

    return Stack(
      
      children: <Widget>[
        new SingleChildScrollView(
      child:  Align(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 130),
                child:Row(children: <Widget>[
                Expanded(child:
                Text(
                '${orderInfo['title']}',style: styles.TextStyles.darkText24))])),
              SizedBox(height: 2,),
             Align(child: _statusInfoWidget('$statuses'),
            alignment: Alignment.centerLeft,),
            SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  text: '${orderInfo["start_date"]} - ', // default text style
                  style: bigText ? styles.TextStyles.darkRegularText18 : styles.TextStyles.orangeText14,
                  children: <TextSpan>[
                    TextSpan(text: '${orderInfo['start_time']}', style: bigText ? styles.TextStyles.orangeText18 : styles.TextStyles.orangeText14),
                  ],
                ),
              ),
            ],
          ),
          alignment: Alignment.topLeft,
        ),),
        Align(
          child: confirmedRequest ? executorInfo(orderInfo['executor']) : Container(
            decoration: new BoxDecoration(
                color: Color.fromRGBO(255, 76, 0, 0.3),
                borderRadius: new BorderRadius.all(
                    const Radius.circular(15.5))),
            width: 31,
            height: 31,
            child: Container(
              child: Text(
                '${inputRequest.length}',
                style: styles.TextStyles.orangWText18,
                textAlign: TextAlign.center,
              ),
              alignment: Alignment.center,
            ),
          ),
          alignment: Alignment.topRight,
        )
        
      ],
    );
  }

  Widget executorInfo(Map userInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 31.0,
          height: 31.0,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              fit: BoxFit.cover,
                image: '${userInfo['image_url']}' == "https://api.lemmi.app/null"
                ? NetworkImage( "https://api.lemmi.app/uploads/user/default-non-user-no-photo.jpg")
                : NetworkImage('${userInfo['image_url']}'),
                  ),
            borderRadius: new BorderRadius.all(new Radius.circular(15.5)),
            border: new Border.all(
              color: Colors.transparent,
              width: 0.0,
            ),
          ),
        ),
        Text(
          "${userInfo['name']}\n${userInfo['surname']}",
          textAlign: TextAlign.right,
          style: styles.TextStyles.darkText18,
        ),
      ],
    );
  }
 

  Widget userShortRatingRow(Map userInfo) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
     
      Row(
        children: <Widget>[
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image:'${userInfo['image_url']}' == "https://api.lemmi.app/null"
                  ?NetworkImage( "https://api.lemmi.app/uploads/user/default-non-user-no-photo.jpg")
                  :NetworkImage('${userInfo['image_url']}'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(30)),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
            height: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${userInfo['name']} ${userInfo['surname']}',
                  style: styles.TextStyles.darkText18,
                ),
                Container(
                  width: 100,
                  alignment: Alignment.centerLeft,
                  child: Widgets().ratingWidget(userInfo['rating'], Alignment.centerLeft),
                )
              ],
            ),
          ),
        ],
      ),
      GestureDetector(
        child: Image(
        image: AssetImage('assets/phone_black_icon.png'),
        width: 33,
        height: 33,
      ),
      onTap: ()async{
    var phone = '${userInfo['phone']}';
     var url = "tel:$phone";
    await launch(url);
  }),
    ],
  );

  Widget userFullRatingRow(double rating, String userName, RatingChangeCallback onRatingChanged, String userAvatar) => Row(
    children: <Widget>[
      Container(
        width: 40.0,
        height: 40.0,
        decoration: new BoxDecoration(
          image: new DecorationImage(
              image: userAvatar == 'https://api.lemmi.app/null'
                              ? new NetworkImage( "https://api.lemmi.app/uploads/user/default-non-user-no-photo.jpg")
                              : new NetworkImage(userAvatar),//AssetImage('assets/image_1.png'),
              fit: BoxFit.cover
          ),
          borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
          border: new Border.all(
            color: Colors.transparent,
            width: 0.0,
          ),
        ),
      ),

      Container(
        padding: EdgeInsets.only(left: 10, top: 1, bottom: 1),
        height: 40,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              userName,
              style: styles.TextStyles.darkText18,
            ),
            new Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(top: 0),
              width: 112,
              height: 16.6,
              child: new StarRating(
                size: 20,
                rating: 4,
                color: Color.fromRGBO(255, 230, 125, 1.0),
                borderColor: Color.fromRGBO(255, 230, 125, 1.0),
                starCount: 5,
                onRatingChanged: onRatingChanged,
              ),
            ),
          ],
        ),
      ),

    ],
  );

  Widget ratingWidget(double rating, Alignment alignment) =>  Container(
    alignment: alignment,
    height: 25,
    width: 150,
    child: Row(
     // crossAxisAlignment: CrossAxisAlignment.end,
      //mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: alignment == Alignment.centerRight ? 7 : 0,
          child: Container(
            child: Image(image:
            AssetImage('assets/star_icon.png'),
              width: 20,
              height: 20,
            ),
            alignment: alignment,
          ),
        ),
        SizedBox(width: 6,),
        new Expanded(
          flex: alignment == Alignment.centerRight ? 0 : 7,
          child: Container(
            child: Text('${rating}',
              style: styles.TextStyles.darkText18,),
            alignment: alignment,
          ),
        ),
      ],
    ),
  );

}

class BottomDatePicker extends StatefulWidget {
  BottomDatePicker({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _BottomDatePickerState createState() =>
      _BottomDatePickerState();
}

class _BottomDatePickerState extends State<BottomDatePicker> {

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[

          ],
        )


      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class HorizontalList extends StatelessWidget {
  Task task = Task();

  HorizontalList({
    List<Map<String, String>> mainList,
  })  : specialistMainList = mainList;

  var miniCell = false;
  var mini = false;
  var specialistMainList = [];
  String id = "";
  String name = "";
  
  void showCategoryList(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
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
                      child: CreateOrderSelectCategoryController(id, name,task:task),
                      ));
                },
              ),
            ),
          ),
        ),
        isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: MediaQuery.of(context).size.height *0.31,//239
      child: new ListView.builder(
        itemBuilder: (context, index) {
          return new GestureDetector(
            onTap: () async{                       
              id = '${specialistMainList.elementAt(index)['id']}';
              task.globalCategory = id;
              name = '${specialistMainList.elementAt(index)['name']}';
              if(id != null){
              showCategoryList(context);
              }
            },
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left:  MediaQuery.of(context).size.width *0.045, right: 0, top: 0, bottom: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[ 
                  Container(
                  height:  MediaQuery.of(context).size.height *0.21,
                  width:  MediaQuery.of(context).size.width *0.43,//163,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child:  ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image(
                          image: NetworkImage('${specialistMainList.elementAt(index)['image']}'),
                          fit: BoxFit.cover,
                          width: 325,
                          height: 250//(MediaQuery.of(context).size.width - 50) * 0.5, //160,
                      ),
                    ),),
                    SizedBox(height:MediaQuery.of(context).size.height *0.018),
                    new Align(
                      alignment: Alignment.bottomLeft,
                      child: new Container(
                        width: (MediaQuery.of(context).size.width - 50) * 0.5,
                        child:
                        Text(
                            "${specialistMainList.elementAt(index)['name']}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Gilroy-Medium',
                                fontStyle: FontStyle.normal,
                                letterSpacing: -0.08,
                                fontSize: 18))
                                //)]),
                      ),
                    ),

                  ],
                ),
            ),
          );
        },
        scrollDirection: Axis.horizontal,
        itemCount: specialistMainList.length,
      ),
    );
  }
}
