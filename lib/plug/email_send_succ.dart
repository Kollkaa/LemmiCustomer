import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Styles.dart' as styles;

import '../app_localizations.dart';

class EmailSendSucc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         Column(
           children: [
             Container(
               margin: EdgeInsets.only(top: 100,left: 24,right: 24),
               child: Center(
                 child:  SvgPicture.asset("assets/email_send_succ.svg"),
               ),
             ),
             Container(
               margin: EdgeInsets.only(top: 72,left: 24,right: 24),
               child: Text("Спасибо за интерес к Lemmi",
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 24,fontWeight: FontWeight.w600),
               ),
             ),
             Container(
               margin: EdgeInsets.only(top: 16,left: 24,right: 24),
               child: Text("Ожидайте код приглашения"
                   " Мы стараемся сделать Lemmi доступным для всех как можно скорее.",
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),

               ),
             )
           ],
         ),
          Container(
            margin: EdgeInsets.only(left: 20,right: 20,bottom: 64),
            child: FlatButton(
              padding: EdgeInsets.all(0),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                    color: Color(0xffFF4C00),
                    borderRadius: BorderRadius.circular(51)
                ),
                child: Center(
                  child: Text("Закрыть",
                      textAlign: TextAlign.center,
                      style: styles.TextStyles.sFProTextPrimary.copyWith(color: Colors.white)),
                ),
              ),
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);

              },
            ),
          )


        ],
      ),
    );
  }

}