import 'dart:ui';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/Styles.dart' as styles;
import '../app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ExecutorUser extends StatefulWidget {
 
  ExecutorUser( this.performer_id, {Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  
   final String title;
   final String performer_id;
  @override
  _ExecutorUserState createState() => _ExecutorUserState();
}

class _ExecutorUserState extends State<ExecutorUser> {
  

  void initState() {
    super.initState();
    getPerformer();
    
  }


  int sharedValue = 0;
  String name = "";
  String checkImage;
  List<ServiceInfo> servicesList = [];
  List<Comment> commentList = [];
  List<dynamic> performerComment = [];
  List<Map<String, String>> categoryList = [];
  double ratingValue;
  String userImage;
  
  getPerformer()async {
    String id = widget.performer_id;
    await ServerManager(context).performerRequest(id, (result){  
      print(result);
     Map<String, dynamic> user = result['user'];
     setState((){
      user['last_name'].toString() == "null"
      ? name = "${user["first_name"]}"
      :name = "${user["first_name"]} ${user["last_name"]}";    
       var rating = double.parse("${user["rating"]}");
       assert(rating is double);
       ratingValue = rating;
       userImage = "https://api.lemmi.app/${user["photo"]}";
     });
      var _length= result["services"].length;      
            
      for(int i = 0; i < _length; i++){
                    
          var _lengthC= result["services"].elementAt(i)["subspecialization"].length;  
          categoryList=[];

          for(int j = 0; j<_lengthC; j++){
              categoryList.add({"title":"${result["services"].elementAt(i)["subspecialization"].elementAt(j)["name"]}"});
          }  
          servicesList.add(ServiceInfo("${result["services"].elementAt(i)["specialization"]}", categoryList));
           
       }
       var reviewsLength = result['reviews'].length;

       for( int j = 0; j < reviewsLength; j++){
        var comment = result['reviews'].elementAt(j); 
        var data = '${comment['createdAt']}';
        // String startDate = data.substring(0,10);
         String rightDate = '${data.substring(8,10)}.${data.substring(5,7)}.${data.substring(0,4)}.'; 
         String startTime = data.substring(11,16);
         if(comment["user"]["last_name"] == null){
           comment["user"]["last_name"] ="";
         }
         commentList.add(Comment('${comment["user"]["first_name"]}',"${comment["user"]["last_name"]}","https://api.lemmi.app/${comment["user"]["photo"]}","${comment['review']}","$startTime $rightDate"));
         
       }
    }, (error){});
  }
 
  String token;
  SharedPreferences sharedPreferences;

  getJWTToken() async {

    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    token = sharedPreferences.getString("token").toString();
  }

     
    
  


  @override
  Widget build(BuildContext context) {

    final Map<int, Widget> logoWidgets =  <int, Widget>{
      0: Text(AppLocalizations.of(context).translate('comments')),
      1: Text(AppLocalizations.of(context).translate('services')),
    };

    Widget _buildCommentItem(BuildContext context, int index) {     
      Comment comment = commentList[index];      
      
      return Column(
        children: <Widget>[           
         Card(
          elevation: 1,
          color: styles.Colors.background,
          child: new Container(
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width - 30,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ClipOval(
                      child: 
                      Image(
                        image: comment.userImage == 'https://api.lemmi.app/null'
                        ? NetworkImage("https://api.lemmi.app/uploads/user/default-non-user-no-photo.jpg")
                        : NetworkImage('${comment.userImage}'),
                       fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text(comment.userFullName(),
                        style: styles.TextStyles.darkText18),
                  ],
                ),

                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${comment.commentBody}',
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
                   // comment.formattedDate,
                    '${comment.date}',
                    style: styles.TextStyles.darkRegularText10,
                  ),
                )
              ],
            ),
          ),
        ),        
        SizedBox(height: 10,)
      ]
      );
    }

    Widget _buildServiceItem(BuildContext context, int index) {

      var service = servicesList[index];

      var categoryList = service.categoryList;

      return Column(children: <Widget>[
        Card(
          elevation: 1,
          color: styles.Colors.background,
          child: new Container(
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width - 30,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              //physics: NeverScrollableScrollPhysics(),
              children: <Widget>[

                Row(
                  children: <Widget>[
                    Text(
                      service.title,
                      style: styles.TextStyles.darkText24,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (contextNew, indexNew) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${categoryList[indexNew]['title']}',
                            style: styles.TextStyles.darkRegularText18,
                          ),
                        ),
                      ],
                    );
                  },
                    itemCount: categoryList.length,
                    padding: EdgeInsets.all(0),
                  ),
                  height: categoryList.length * 21.0,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10,)
      ]);
    }

    var builCommentList = ListView.builder(
      itemBuilder: (context, index) {
        return _buildCommentItem(context, index);
      },
      itemCount: commentList.length,
      padding: EdgeInsets.only(bottom: 10, top: 15),

    );

    var buildServicesList = ListView.builder(
      itemBuilder: (context, index) {
        return _buildServiceItem(context, index);
      },
      itemCount: servicesList.length,
      padding: EdgeInsets.only(bottom: 10, top: 15),
    );
    
    return Scaffold(
        appBar: ExecutorInfoAppBar(
          user: "$name",
          image:"$checkImage",
          userImage: "$userImage",
           rating: ratingValue),
        backgroundColor: styles.Colors.whiteColor,
        body: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 60,
              height: 28,
              //color: styles.Colors.orangeTrans,
              child: CupertinoSegmentedControl<int>(
                padding: EdgeInsets.all(0),
                selectedColor: styles.Colors.orange,
                borderColor: styles.Colors.orange,
                pressedColor: Colors.transparent,
                
                children: logoWidgets,
                onValueChanged: (int val) {
                  setState(() {
                   // print(val);
                    sharedValue = val;
                  });
                },
                groupValue: sharedValue,
              ),
            ),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child:
                        sharedValue == 0 
                        ? builCommentList 
                        : buildServicesList)
            )
          ],
        ),
      );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
  }
}
