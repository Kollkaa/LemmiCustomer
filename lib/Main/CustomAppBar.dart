import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:kaban/Authentication/AuthorizationController.dart';
import 'package:kaban/Authentication/CheckMobileController.dart';
import 'package:kaban/Authentication/Story.dart';
import 'package:kaban/Main/SearchController.dart';
import 'package:kaban/MyOrders/MyOrderListController.dart';
import 'package:kaban/Profile/ProfileController.dart';
import 'package:kaban/Profile/UserInfoController.dart';
import 'package:kaban/Profile/MyFeedbackController.dart';
import 'package:kaban/Profile/ContactsPage.dart';
import '../app_localizations.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:kaban/Widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;

  final double height;

  final double topConstraint;  
  
  const MainAppBar(
      {Key key,
      @required this.height,
      @required this.titleAppBar,
      @optionalTypeArgs this.topConstraint})
      : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    void profileAction() async {

        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.785,
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
                        child: ProfileController());
                  },
                ),
              ),
            ),
          ),
          isScrollControlled: true
      );
     

    }

    return Container(
        decoration: new BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: styles.Colors.tintColor,
                blurRadius: 10.0, // has the effect of softening the shadow
                spreadRadius: 5.0, // has the effect of extending the shadow
                offset: Offset(
                  0.0, // horizontal, move right 10
                  2.0, // vertical, move down 10
                ),
              )
            ],
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              bottomRight: const Radius.circular(16.0),
              bottomLeft: const Radius.circular(16.0), 
            )),
        //color: Colors.white,

        padding: new EdgeInsets.only(top: 43, bottom: 9, left: 30, right: 30),
        child: new Container(          
          child: new Stack(
            children: <Widget>[
              new Align(
                alignment: Alignment.centerLeft,
                child:  MaterialButton(                  
                    padding: EdgeInsets.all(0),
                    minWidth: 46,
                    child: Image(
                      image: AssetImage('assets/profile_icon.png'),
                      width: 45,
                      height: 45,
                    ),
                    onPressed: () {
                      profileAction();
                    },
                  ),
              ),
              new Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(titleAppBar,
                        textAlign: TextAlign.left,
                        style: TextStyle(
      fontFamily: 'Gilroy',
      fontStyle: FontStyle.normal,
      fontSize: 18,
      letterSpacing: -0.078,
      color: styles.Colors.darkText
  )),
                  )),
              new Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                      padding: EdgeInsets.all(0),
                        minWidth: 46,
                        child: Image(
                          image: AssetImage('assets/search_icon.png'),
                          width: 45,
                          height: 45,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            //fullscreenDialog: true,
                              builder: (context) =>  new SearchController()));
                        }
                    ),
              ),              
            ],
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(height - topConstraint);
}

class FakeMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;

  final double height;

  final double topConstraint;  
  
  const FakeMainAppBar(
      {Key key,
      @required this.height,
      @required this.titleAppBar,
      @optionalTypeArgs this.topConstraint})
      : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    void authorizationAction() async {    
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new AuthorizationController(ScreenType.registrationType)),
    );
    }

    return Container(
        decoration: new BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: styles.Colors.tintColor,
                blurRadius: 10.0, // has the effect of softening the shadow
                spreadRadius: 5.0, // has the effect of extending the shadow
                offset: Offset(
                  0.0, // horizontal, move right 10
                  2.0, // vertical, move down 10
                ),
              )
            ],
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              bottomRight: const Radius.circular(30.0),
            )),
        padding: new EdgeInsets.only(top: 45, bottom: 10, left: 30, right: 30),
        child: new Container(
          child: new Stack(
            children: <Widget>[
              new Align(
                alignment: Alignment.centerLeft,
                child: new Container(
                  height: 39,
                  width: 39,
                  child: MaterialButton(
                    padding: EdgeInsets.all(0),
                    minWidth: 39,
                    child: Image(
                      image: AssetImage('assets/profile_icon.png'),
                      width: 39,
                      height: 39,
                    ),
                    onPressed: () {
                      authorizationAction();
                    },
                  ),
                )
              ),
              new Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 39,
                    width: 39,
                    child: MaterialButton(
                      padding: EdgeInsets.all(0),
                        minWidth: 39,
                        child: Image(
                          image: AssetImage('assets/search_icon.png'),
                          width: 39,
                          height: 39,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => new SearchController()));
                        }
                    ),
                  )
              ),
              new Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(titleAppBar,
                        textAlign: TextAlign.left,
                        style: styles.TextStyles.darkText18),
                  ))
            ],
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(height - topConstraint);
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;

  final double height;

  final TextField textField;

  final double topConstraint;

  const SearchAppBar(
      {Key key,
      @required this.height,
      @required this.titleAppBar,
      @required this.textField,
      @optionalTypeArgs this.topConstraint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0, // has the effect of softening the shadow
                spreadRadius: 5.0, // has the effect of extending the shadow
                offset: Offset(
                  0.0, // horizontal, move right 10
                  2.0, // vertical, move down 10
                ),
              )
            ],
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              bottomLeft: const Radius.circular(30.0),
            )),

        padding: new EdgeInsets.only(top: 55, bottom: 28, left: 20, right: 20),
        child: new Container(
          child: new Stack(
            // alignment: Alignment.topCenter,
            children: <Widget>[
              new Align(
                alignment: Alignment.centerLeft,
                child: new MaterialButton(
                  minWidth: 10,
                  child: Image(
                    image: AssetImage('assets/arrow_back.png'),
                    width: 10,
                    height: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              new Align(alignment: Alignment.centerLeft, child:Padding(
                child: textField,
              padding: EdgeInsets.only(left:40)))
            ],
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(height - topConstraint);
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;

  final double height;
  final double topConstraint;
  final String userImage;  
  final String userName;

   ProfileAppBar({
    Key key,
    @required this.height,
    @required this.titleAppBar,
    @required this.userImage,
    @required this.userName,
    @optionalTypeArgs this.topConstraint,
  }) : super(key: key);

    /*Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      
      return permission;
    }
  }*/
     
 

  @override
  Widget build(BuildContext context) {
     Future<void> share() async {
    await FlutterShare.share(
      title: 'Invite',
      text: 'Your invite link to Lemmi',
      linkUrl: 'https://lemmi.app/',
      chooserTitle: AppLocalizations.of(context).translate('choose')
    );
  }
    return Container(
      decoration: new BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0, // has the effect of softening the shadow
            spreadRadius: 5.0, // has the effect of extending the shadow
            offset: Offset(
              0.0, // horizontal, move right 10
              2.0, // vertical, move down 10
            ),
          )
        ],
        color: Colors.white,
      ),
      //color: Colors.white,

      padding: new EdgeInsets.only(top: 8, bottom: 10, left: 30, right: 30),

      // child: new Container(

      child: new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          InkWell(
                onTap: () async => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 24,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Color(0xFFC4C4C4),
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                CircleAvatar( 
                  backgroundColor: Color.fromRGBO(221,98,67, 1),                       
                  radius: 30,
                  child: ClipRRect(
                        borderRadius:BorderRadius.circular(60),
                        child: userImage == 'https://api.lemmi.app/null'
                              ? Image.network( "https://api.lemmi.app/uploads/user/default-non-user-no-photo.jpg",
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100)
                              : Image.network("$userImage",
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100),                                                    
                                    )),
                                    
              SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 12,),
                    Text("$titleAppBar",
                        style: styles.TextStyles.darkText18),
                    new GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                            //fullscreenDialog: true,
                            builder: (context) => new UserInfoController()));
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('edit'),
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontFamily: 'Gilroy',
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: styles.Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
             /* new GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Image.asset(
                    "assets/close_icon.png",
                    width: 20,
                    height: 20,
                  ),
                ),
              )*/
            ],
          ),

          SizedBox(
            height: 20,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/my_order_icon.png",
                      height: 20,
                    ),
                    SizedBox(height:8.60),
                    Text(AppLocalizations.of(context).translate('titleMyTasks'), style: styles.TextStyles.darkText14),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => new MyOrderListController()));
                },
              ),
              GestureDetector(
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/invite_user_icon.png",
                      height: 24,
                    ),
                    SizedBox(height:4.60),
                    Text(AppLocalizations.of(context).translate('invite'), style: styles.TextStyles.darkText14),
                  ],
                ),
                onTap: () async{
                   share();
        //final PermissionStatus permissionStatus = await _getPermission();
        //if (permissionStatus == PermissionStatus.granted) {
       //   Navigator.push(
       //   context, MaterialPageRoute(builder: (context) => ContactsPage()));
       // } else {
          //If permissions have been denied show standard cupertino alert dialog
         /* showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text(AppLocalizations.of(context).translate('error')),
                    content: Text(AppLocalizations.of(context).translate('sub3')),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));}
                },
              ),*/
             /*
              GestureDetector(
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/feedback_icon.png",
                      height: 30,
                    ),
                    Text(AppLocalizations.of(context).translate('comments'), style: styles.TextStyles.darkText14),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      //fullscreenDialog: true,
                      builder: (context) => new MyFeedbackController()));
                },*/
                })
            ],
          )

          //Icon(Icon, color: Colors.blue, size: 40,)
        ],
      ),

      // )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height - topConstraint);
}

class CreateAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;

  final double height;
  final double topConstraint;

  final bool showAddButton;
  final VoidCallback addButtonAction;

  const CreateAppBar(
      {Key key,
      @required this.height,
      @required this.titleAppBar,
      @required this.showAddButton,
      @required this.topConstraint,
      @optionalTypeArgs this.addButtonAction})
      : super(key: key);

  Widget _addButton() {
    if (showAddButton == true) {
      return Container(
          child: MaterialButton(
              onPressed: () {
                addButtonAction();
              },
              child: Image(
                image: AssetImage('assets/plus.png'),
                width: 39,
                height: 39,
              ),
              minWidth: 39));
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0, // has the effect of softening the shadow
              spreadRadius: 5.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                2.0, // vertical, move down 10
              ),
            )
          ],
          color: Colors.white,
          borderRadius: new BorderRadius.only(
              bottomRight: const Radius.circular(16.0),
              bottomLeft: const Radius.circular(16.0), 
            ),
        ),
        padding: new EdgeInsets.only(top: 55, bottom: 10, left: 20, right: 30),
        child: new Container(
          child: new Stack(
            // alignment: Alignment.topCenter,
            children: <Widget>[
              new Align(
                alignment: Alignment.centerLeft,
                child: Container(
                 // padding: EdgeInsets.only(top: 10),
                  child: CupertinoButton(
                    padding: EdgeInsets.all(0),
                    //color: Colors.red,
                    child: Image(
                      image: AssetImage('assets/arrow_back.png'),
                      width: 10,
                      height: 20,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  height: 40,
                  width: 30,
                )
              ),
              new Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.only(left: 20),
                    child: Align(
                      child: Text(
                          titleAppBar,
                        textAlign:TextAlign.center,                        
                        style: styles.TextStyles.darkGText18,
                      //alignment: Alignment.center,
                    )),
                    height: 56,
                  )),
              new Align(
                alignment: Alignment.centerRight,
                child: _addButton(),
              )
            ],
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(height - topConstraint);
}

class OrderInfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;
  final VoidCallback detailButtonAction;
  final Map orderInfo;
  final status;

  const OrderInfoAppBar(
      {Key key,
      @required this.titleAppBar,
        @required this.orderInfo,
        @required this.status,
      @optionalTypeArgs this.detailButtonAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
     var height;

    return  Container(
         height: 180,
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                  topRight: const Radius.circular(30.0),
                  topLeft: const Radius.circular(30.0))),
          padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
          //width: MediaQuery.of(context).size.width,
          // color: Colors.white,
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () async => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 24,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Color(0xFFC4C4C4),
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),

              Widgets().orderTopWidget(orderInfo, true),
              SizedBox(height:5),
              Container(
                color:Colors.transparent,
                height:25,
                padding: EdgeInsets.only(top:0),
                alignment:Alignment.centerLeft,
                  child:GestureDetector(
                    child: Text(AppLocalizations.of(context).translate('details'),
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: styles.Colors.darkText,
                            decoration: TextDecoration.underline)),
                    onTap: () {
                      detailButtonAction();
                    },
                  ),
              ),
            ],
          )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(178);
}


class ExecutorInfoAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String titleAppBar;
  final String userImage;
  final String user;
  final String image;
  final VoidCallback addButtonAction;
  final double rating;
  final bool send;

  const ExecutorInfoAppBar({
    Key key,
    @required this.titleAppBar,
    @required this.userImage,
    @required this.user,
    @required this.image,
     @optionalTypeArgs this.addButtonAction,
     @required this.rating,
     @optionalTypeArgs this.send,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 127,
      child: Container(
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                  topRight: const Radius.circular(30.0),
                  topLeft: const Radius.circular(30.0))),
          padding: EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 0),
          //width: MediaQuery.of(context).size.width,
          // color: Colors.white,
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () async {
                  var sendi;
                  if(image=='assets/check_green_icon.png'){
                  sendi = true;
                  }else{
                    sendi = false;  
                  }
                  Navigator.of(context).pop(sendi);                  
                } ,
             //   Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 24,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Color(0xFFC4C4C4),
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[ userImage =='https://api.lemmi.app/null'
                      ?CircleAvatar(
                        maxRadius:30 ,
                        backgroundImage: AssetImage('assets/placeholder.png') ,
                        child:Text( "${user[0]}",
               style: styles.TextStyles.whiteText18)
                      )
                      :Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("$userImage"),
                              //AssetImage('assets/user_image_1.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                        height: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child:Text('$user',
                              style: styles.TextStyles.darkText18,
                            )),
                            Container(
                              width: 100,
                              alignment: Alignment.centerLeft,
                              child: Widgets()
                                  .ratingWidget(rating, Alignment.centerLeft),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  new GestureDetector(
                    onTap: (){
                       addButtonAction();
                    },
                  child: Image(
                    image: AssetImage('$image'),
                   // ('assets/arrow_next_icon.png'),
                    width: 28.35,
                    height: 28.35,
                  ),
                  ),
                ],
              ),
              SizedBox(height:10),
              Container(
                  alignment: Alignment.bottomLeft,
                  height: 1,
                  padding: EdgeInsets.only(right: 0, left: 0),
                  color: Color(0XFFC4C4C4)),
            ],
          )),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(124);
}

class TitleSubtitleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String titleAppBar;
  final String subtitleAppBar;

  const TitleSubtitleAppBar({
    Key key,
    @required this.titleAppBar,
    @required this.subtitleAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0, // has the effect of softening the shadow
              spreadRadius: 5.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                2.0, // vertical, move down 10
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
                  child: new Text(
                    titleAppBar,
                    style: styles.TextStyles.darkText18,
                    textAlign: TextAlign.center,
                  )),
              new Align(
                  alignment: Alignment.bottomCenter,
                  child: new Container(
                    //padding: EdgeInsets.only(left: 35, right: 35),
                    child: Text(
                      subtitleAppBar,
                      style: styles.TextStyles.darkText14,
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
