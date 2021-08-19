import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../app_localizations.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;

class OrderCommentController extends StatefulWidget {
  OrderCommentController(this.performerId, this.taskId, this.ratingId, {Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String performerId;
  final String taskId;
  final String title;
  final String ratingId;
  @override
  _OrderCommentControllerState createState() => _OrderCommentControllerState();
}

class _OrderCommentControllerState extends State<OrderCommentController> {

  final _reviewController = TextEditingController();
   
  void initState() {
    super.initState();
    _checkFeedback();
  }
  
  void _checkFeedback() async{
    String activityTaskId = widget.taskId;
    await ServerManager(context).checkFeedbackRequest(activityTaskId, (result){
    Map<String, dynamic> resul = result;
     var feedback = "${resul['feedback']}";
     if('$feedback' != 'false'){
    _reviewController.text = "$feedback";
    /*showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
          title:  Text('Помилка'),
          content: Text ("Ви вже надіслали коментар"),
        actions: [
        CupertinoDialogAction(child: 
        Text("OK",style:TextStyle(
          fontFamily: 'Roboto-Medium',
        fontSize: 14,
        color: Color.fromRGBO(221,98,67,1))),
       onPressed:() async {               
   Navigator.pop(context);
   Navigator.pop(context);
        })]);});*/
       
     }
      
    }, (error){});
  }

  void _sendCommentButtonAction() async {
    String performerId = widget.performerId;
    String taskId = widget.taskId;
    String review = _reviewController.text;
    String ratinId = widget.ratingId;
    print(performerId);
    print(taskId);
    print(review);
    print(ratinId);
    
   await ServerManager(context).feedbackRequest(performerId, taskId, review, ratinId, (code){
    setState(() {
      
    
    Navigator.pop(context);  
    });
    }, (error){});

  }

  @override
  Widget build(BuildContext context) {

    final bottomButton = new MaterialButton(
      elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,//375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: Text(AppLocalizations.of(context).translate("send"),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Gilroy',
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Colors.white
              )),

        ),
        onPressed: _sendCommentButtonAction
    );

    Widget _builDescription() {
      return new ListView(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
        children: <Widget>[

          new Stack(
            children: <Widget>[

              new Container(


                child: TextField(
                  controller: _reviewController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 100,
                  style: styles.TextStyles.darkRegularText18,
                  decoration: new InputDecoration( 
                    focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange[900], width: 2),
                 ),
                   enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
  ),
                    border: UnderlineInputBorder(
                ),
                    hintText: AppLocalizations.of(context).translate("yourComment"),
                    hintStyle: TextStyle(fontFamily: 'Gilroy',
                        fontStyle: FontStyle.normal,
                        color: styles.Colors.orangeTrans,
                        fontSize: 18),
                   //border: InputBorder.none,
                  ),
                onEditingComplete: (){
                  _reviewController.text;
                  print(_reviewController.text);
                },
                ),
                //padding: EdgeInsets.only(right: 30),

              ),
            ],
          ),

         // Container(
           //   alignment: Alignment.bottomLeft,
         ///     height: 1,
              // width: 100,//MediaQuery.of(context).size.width - 60,
          //    padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              //width: double.infinity,
          //    color: styles.Colors.orangeTrans
  //        ),
//
        ],
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
            titleAppBar: AppLocalizations.of(context).translate("titleLive"),
            //AppLocalizations.of(context).translate("titleLiveComment"),
            showAddButton: false),

        body:
        Stack(children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.bottom,
              color: styles.Colors.orange,
            ),
          ),
          SafeArea(
              child: GestureDetector(
                child: Stack(children: <Widget>[
                  _builDescription(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        bottomButton
                      ],
                    ),
                  )
                ]),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
              )
          ),
        ])
    );
  }
}
