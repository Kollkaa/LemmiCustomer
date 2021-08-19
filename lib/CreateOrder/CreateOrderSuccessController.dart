import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating/flutter_rating.dart';

import 'package:kaban/Main/MainController.dart';

import 'package:kaban/Managers.dart';
import '../app_localizations.dart';
import 'package:kaban/MyOrders/ExecutorUserController.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateOrderSuccessController extends StatefulWidget {
  final Task task;
  CreateOrderSuccessController({Key key, this.title, this.task}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _CreateOrderSuccessControllerState createState() =>
      _CreateOrderSuccessControllerState();
}

class _CreateOrderSuccessControllerState extends State<CreateOrderSuccessController> {
  String performer_id;
  bool send= false;
  double rating;
  List<Map<String, Object>> userList = [];
  List<String> userId = []; 
  void initState() {
    performers();
    super.initState();
  }

  getCheck(){
    return new Image(
              image: AssetImage('assets/check_green_icon.png'),
              width: 24,
              height: 24,
            );
  } 

  void performers() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var services_id = widget.task.services_id;
    await ServerManager(context).topPerformerRequest(services_id, (result){
      if(result.length !=0){
      for(int i = 0; i < result.length; i++){
        Map<String, dynamic> element = result.elementAt(i);
        var raiting = double.parse("${element['rating']}");
        assert(raiting is double);
        rating = raiting;
        var init = element['first_name'][0].toString();
         userList.add({'initials':'$init','name':"${element['first_name']}", 'raiting':rating , 'surname':"${element['last_name']}",'image':"https://api.lemmi.app/${element['photo']}", 'id':'${element['id']}', 'send': send});
      }
      }
       setState(() {});
    }, (error){});
    });
  }

  Dio dio = new Dio();
  String token;
  SharedPreferences sharedPreferences;

  getJWTToken() async {

    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    token = sharedPreferences.getString("token").toString();
  }


  final PageRouteBuilder _homeRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return MainController();
    },
  );

  _closeButtonAction() async {
   FormData formData = FormData.fromMap({  
  "user_id":userId,
  "activity_task_id":"${widget.task.activity_task_id}",  
  });    
    print(formData);
    await getJWTToken();
    await dio.post("https://api.lemmi.app/api/activity-task/send-task", data: formData,
      options: Options(headers: {
           "Authorization": "Bearer $token",
           "Content-Type": "multipart/form-data"
        })).then((response) {
           print("data = ${response.data}");
           print("Response status: ${response.statusCode}");
            if (response.statusCode == 200) {    
               Navigator.pushAndRemoveUntil(
        context, _homeRoute, (Route<dynamic> r) => false).then((result){
        }); 
            }else{
          print("response = ${response}");
            }
        });
   
   }

  @override
  Widget build(BuildContext context) {
    final bottomButton = new MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          child: userId.length == 0?
          Text(AppLocalizations.of(context).translate('close'),
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText18)
              :Text(AppLocalizations.of(context).translate('send'),
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText18)
        ),
        onPressed: _closeButtonAction);


    Widget _builUsersList() {
      return new ListView.builder(
        padding:EdgeInsets.only(left:16, right:16, bottom:84),
        itemBuilder: (context, index) {
          return Card(
            shadowColor: Color.fromRGBO(0,0,0,0.25),
            elevation: 4,
            color: styles.Colors.whiteColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child:ListTile(
              contentPadding:EdgeInsets.only(left:11, right:19),
              trailing:GestureDetector(             
              child:  Container(
                child: new InkWell( 
              onTap: (){ 
                send = userList[index]['send'];   
                performer_id = '${userList[index]['id']}';  
                if (send == true){
                widget.task.published = false;
                userList[index]['send'] = false;
                
                userId.remove(performer_id);
                
                print(userId);
              }else{    
                widget.task.published = true;      
                userList[index]['send'] = true;
                userId.add(performer_id);
                print(userId);
              }          
              setState(() {});               
              },
              child: Image(
              image: 
                    userList[index]['send'] == true
                  ? AssetImage('assets/check_green_icon.png')
                  : AssetImage('assets/check_orange_ic.png'),
              width: 28.3,
              height: 28.3,
            ),))),
            leading: userList[index]['image'] == "https://api.lemmi.app/null"
            ? CircleAvatar(
              radius: 27,
              backgroundImage: AssetImage('assets/placeholder.png'),
              child:Text( "${userList[index]["initials"]}",
               style: styles.TextStyles.whiteText18)
            )
            : CircleAvatar(
              radius: 27,
              backgroundColor: styles.Colors.orange,
              child: ClipRRect(                
                borderRadius: BorderRadius.all(Radius.circular(60)),
                child: Image.network('${userList[index]['image']}',
                fit: BoxFit.cover,
                width: 54,
                height:54, 
              loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                 if (loadingProgress == null) return child;
                return Center(
                child: CupertinoActivityIndicator(radius: 7.0),               
            );
            },
               
               
              )
            ),),
            title: Text( userList[index]['surname'] == 'null'
                ?"${userList[index]['name']}"
                :'${userList[index]['name']} ${userList[index]['surname']}',
                
                style: styles.TextStyles.darkText18),
            subtitle: Align(
                alignment: Alignment.topLeft,
                child: new Container(
                  width: 125,
                  child: new StarRating(
                    size: 25.0,
                    rating: userList[index]["raiting"],
                    color: Color(0xFFFF4C00),
                    borderColor: Color(0xFFC4C4C4),
                    starCount: 5,                    
                  ),
                )),            
             
          onTap: () {
             send = userList[index]['send'];
             performer_id = '${userList[index]['id']}';
            // widget.task.published = true;
              setState(() {});
              print("$performer_id");
              print("${widget.task.activity_task_id}");
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
                        send =userList[index]['send'];                
                         widget.task.published = userList[index]['send'];       
                     },
                      child: ExecutorUserController(send, performer_id,userId, task:widget.task,
                      
                      valueChanged: (value) => { userList[index]['send']= value}),
                                ));
                              },
                            ),
                          ),
                        ),
                      ),
                  isScrollControlled: true,
                ).then((onValue){  
                  print( widget.task.published);
                  print(userList[index]['send']);
                userList[index]['send'] =  widget.task.published;
                    print(userId);        
                  if( userList[index]['send'] == true){
                    
                   userId.contains(performer_id) == true
                    ?setState(() {})
                    : userId.add(performer_id);
                  
                    print(userId);
                  }else{
                 
                    userId.contains(performer_id) != true
                    ?setState((){})
                    : userId.remove(performer_id);                     
                    print(userId);
                  }       
                
                 print(userId);
                                    
                widget.task.published = userList[index]['send']; 
                setState((){});
                });
            },));
        },
        itemCount: userList.length,);
        
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return Scaffold(
        backgroundColor: styles.Colors.background,
        floatingActionButton: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
          ),
          width: double.infinity,
          height: 50,
          child: bottomButton,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: TheSubtitleAppBar(
          subtitleAppBar: AppLocalizations.of(context).translate('sendBest'),          
        ),
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: _builUsersList(),
        )

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TheSubtitleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String subtitleAppBar;

  const TheSubtitleAppBar({
    Key key,
    @required this.subtitleAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              spreadRadius: 5.0,
              offset: Offset(
                0.0,
                2.0,
              ),              
            )
          ],
          color: Colors.white,
            borderRadius: new BorderRadius.only(
              bottomLeft: const Radius.circular(16.0),
              bottomRight: const Radius.circular(16.0),
            )
        ),

        padding: new EdgeInsets.only(top: 55, bottom: 28, left: 30, right: 30),
        child: new Center(
          child: new Stack(
            children: <Widget>[ 
              new Align(
                  alignment: Alignment.center,
                  child: new Container(
                    child: Text(
                      subtitleAppBar,
                      style: styles.TextStyles.darkRegularText17,
                      textAlign: TextAlign.center,
                    ),
                  )),
            ],
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(150);
}
