//import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class MAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;
  final double height;

  const MAppBar({
    Key key,
    @required this.height,
    @required this.titleAppBar,
    
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
            color: Colors.white ,
            //borderRadius: new BorderRadius.only(
            //  bottomRight: const Radius.circular(30.0),
           // )

        ),
        //color: Colors.white,

        padding: new EdgeInsets.only(top: 45, bottom: 10, left: 22, right: 22),

        child: new Container(

          child: new Stack(
            // alignment: Alignment.topCenter,
            children: <Widget>[

              new Align(
               alignment: Alignment.centerLeft,
                child: new MaterialButton(
                  minWidth: 42,
                  child: Image(image: AssetImage('assets/arrow_back.png'),
                    width: 15,
                    height: 15,
                    
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            
              new Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(titleAppBar,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontFamily: 'Roboto-Medium',
                          fontStyle: FontStyle.normal,
                          fontSize: 24
                      )

                  ),

                )
              )

            ],
          ),


        ));

  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}