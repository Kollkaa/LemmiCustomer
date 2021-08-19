import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_pro/carousel_pro.dart';
import '../app_localizations.dart';
import 'package:kaban/Styles.dart' as styles;

class Story extends StatefulWidget {
  Story({Key key}) : super(key: key);
  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> {
  String accessToken;

  
  _goToMainController() async {
    Navigator.of(context).pushReplacementNamed('home');
  }
   var _current = 0;

  @override
  Widget build(BuildContext context) {
  
  final double height = MediaQuery.of(context).size.height;
  var button = GestureDetector(
              child:
            Container(
              child: Text.rich(TextSpan(                  
                        text: AppLocalizations.of(context).translate('spend'),
                        style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            color: styles.Colors.whiteColor))),    
              padding: EdgeInsets.only(left: 33, top:45),),
              onTap: (){
           _goToMainController();
             });
 
  
    return Scaffold(
     body:
      Stack(children:<Widget>[        
        SizedBox(
  height: height,
  width:MediaQuery.of(context).size.width,
  child:
      Carousel(
        autoplay: false,
        boxFit: BoxFit.fill,
    images: [ExactAssetImage('assets/First.png'),
    ExactAssetImage('assets/Second.png'),
    ExactAssetImage('assets/Third.png'),
    ExactAssetImage('assets/Four.png'),
    ExactAssetImage('assets/Five.png'),
    ExactAssetImage('assets/Map.png'),
    ExactAssetImage('assets/Main.jpg')
      ]      
                  )
                   ),
                   button,])
                   );
                  }
               
          
  }


