import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;
import '../app_localizations.dart';

class OrderInputCommentController extends StatefulWidget {
  OrderInputCommentController({Key key, this.title, this.comment}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  final String title;
  final RequestComment comment;
  @override
  _OrderInputCommentControllerState createState() => _OrderInputCommentControllerState(comment);
}

class _OrderInputCommentControllerState extends State<OrderInputCommentController> {
  _OrderInputCommentControllerState(this._comment);
  RequestComment _comment;
  final _commentController = TextEditingController();
  void initState() {
    super.initState();  
  }

  void _sendCommentButtonAction() async {
    String activityTaskId ='${_comment.activityTaskId}';
    String userId ='${_comment.userId}';
    String theId = '${_comment.theId}';
    String replyComment = _commentController.text;
   await ServerManager(context).replyCommentRequest(activityTaskId, userId, theId, replyComment, (code){
    Navigator.pop(context);
    }, (error){});
    

  }

  @override
  Widget build(BuildContext context) {

    final bottomButton = new MaterialButton(
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
                  fontSize: 18,
                  color: Colors.white
              )),

        ),
        onPressed: _sendCommentButtonAction
    );

    Widget _builDescription() {
      return new ListView(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
        children: <Widget>[

          Row(
            children: <Widget>[
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: "${_comment.userImage}" == 'https://api.lemmi.app/null'
                      ? AssetImage('assets/placeholder.png')
                      : NetworkImage ('${_comment.userImage}'),                    
                      fit: BoxFit.cover,
                    ),
                    borderRadius:
                    BorderRadius.circular(30)),
              ),
              Container(
                padding: EdgeInsets.only(
                    left: 10),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${_comment.userName} ${_comment.userSurname}',
                     // 'User Name Surname',
                      style: styles.TextStyles.darkText18,
                    )
                  ],
                ),
              ),
            ],
          ),


          new Container(
            padding: EdgeInsets.only(top: 10, bottom: 30),
            child: Text( '${_comment.performerComment}' == "null"
            ?""
            :'${_comment.performerComment}',
              style: styles.TextStyles.darkGText18,
            ),
          ),

          new Stack(
            children: <Widget>[

              new Container(

                child: TextField(
                  controller: _commentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: styles.TextStyles.darkGText18,
                  decoration: new InputDecoration(
                    hintText: AppLocalizations.of(context).translate('yourComment'),
                    hintStyle: TextStyle(fontFamily: 'Gilroy',
                        fontStyle: FontStyle.normal,
                        color: styles.Colors.grayTrans,
                        fontSize: 18
                    ),
                    border: InputBorder.none,
                  ),
                onEditingComplete: (){
                  _commentController.text;
                },
                ),
                padding: EdgeInsets.only(right: 30),

              ),




            ],
          ),

          Container(
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: styles.Colors.grayTrans
          ),

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
        bottomSheet: Container(
          width: double.infinity,
          height: 50,
          child: bottomButton,
        ),
        appBar: CreateAppBar(height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate("titleLiveComment"),
            showAddButton: false),

        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: _builDescription(),
        )

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
