import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kaban/ServerManager.dart';

import '../app_localizations.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:kaban/Widgets.dart';

class MyFeedbackController extends StatefulWidget {
  MyFeedbackController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyFeedbackControllerState createState() => _MyFeedbackControllerState();
}

class _MyFeedbackControllerState extends State<MyFeedbackController> {
  var commentList =[];
  bool showEmptyPage;

  void initState() {
    getComments();
    super.initState();    
  }

  getComments() async{
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    await ServerManager(context).getComment((result) async {
      var length = result.length;
      if(length == 0){
        showEmptyPage = true;
      }else{
        showEmptyPage= false;
      for(int i =0; i<length; i++){
        var user = result[i]['user'];
        var time = DateFormat.Hm().format(DateTime.parse(result[i]['createdAt']));
        var day, timeForSign;
        await initializeDateFormatting("ru", null).then((_) {
        var format = DateFormat.yMMMMd('ru');
        var l = DateTime.parse('${result[i]['createdAt']}');
        day = format.format(l);
        timeForSign = '$time, $day';        
        }); 
        var rate = double.parse('${result[i]['users_rating']['rating']}');
        assert(rate is double);       
        commentList.add( {'user_name':user['first_name'], 'user_surname':user['last_name'], 'user_avatar': user['photo'], 'time':timeForSign, 'comment':'${result[i]['review']}',
        'rating':rate },);
      }
      }
      setState((){});
     }, (errorCode) { });

    });
  }

  Future<void> _getData() async {
    setState(() {
     commentList =[];
     getComments();
    });
  }

  var selectedAddress = {};

  @override
  Widget build(BuildContext context) {

  /*  final commentList = [
      {'user_name':'Иван', 'user_surname':'Нестеров', 'comment':'Другие пользователи оставляют свой комментарий, делятся впечетлениями о проделанной работе специалиста'},
      {'user_name':'Вадим', 'user_surname':'Павлов', 'comment':'Другие по'},
      {'user_name':'Аркадий', 'user_surname':'Калинин', 'comment':'Другие пользователи оставляют свой комментарий, делятся впечетлениями о проделанной работе специалиста'},
      {'user_name':'Dima', 'user_surname':'Bogonos', 'comment':'Другие пользователи оставляют свой комментарий, делятся впечетлениями о проделанной работе специалиста'},
    ];*/
    
    final builCommentList =  commentList.isNotEmpty
    ? RefreshIndicator(
          color:styles.Colors.orange,
          child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.transparent,
          //indent: 30,
          //endIndent: 30,
          height: 10,
        ),
        padding: EdgeInsets.fromLTRB(25, 15, 25, 20),//.all(20),
        itemCount: commentList.length,
        itemBuilder: (context, index) {

          var commentInfo = commentList[index];

          return Card(
            elevation: 0,
            color: Colors.transparent,
            child: new Container(
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
                    Radius.circular(10.0),
                  )
              ),
              // color: Colors.white,
              alignment: Alignment.centerLeft,
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 30,
              //height: 170,
              padding: EdgeInsets.all(20),
              child: Column(
                //physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Widgets().userFullRatingRow(commentInfo["rating"],
                      "${commentInfo["user_name"]} ${commentInfo["user_surname"]}",
                          (rating) =>
                          setState(
                                () {

                            },
                          ),
                  'https://api.lemmi.app/${commentInfo["user_avatar"]}'
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text("${commentInfo["comment"]}",            
            style: styles.TextStyles.darkRegularText14,
          ),
        ),
      ],
    ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${commentInfo["time"]}",
                      style: styles.TextStyles.darkRegularText10,
                    ),
                  )
                ],
              ),
            ),
          );
        }

    ),
    onRefresh: _getData,)
    :Center(child: CupertinoActivityIndicator(radius: 15.0));

    

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
          titleAppBar: AppLocalizations.of(context).translate('titleMyComments'),
          showAddButton: false
        ),

        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: showEmptyPage == true
          ? Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: <Widget>[
            Container(
            child: Text(AppLocalizations.of(context).translate("archive"), style: styles.TextStyles.darkText21),),
            SizedBox(height: 5,),
            Text(AppLocalizations.of(context).translate("pusto2"), style: styles.TextStyles.darkRegularText14,),
            ])) 
          : builCommentList,
        )

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
