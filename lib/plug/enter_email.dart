import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/plug/email_send_succ.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Styles.dart' as styles;
import '../app_localizations.dart';

class EmailView extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return EmailViewState();
  }

}

class EmailViewState extends State<EmailView>{
  var errorText="";
  var _focusNode=new FocusNode();

  var textEditingController =new TextEditingController();

  var errorResp=false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: styles.Colors.background,
        body: Stack(children: <Widget>[

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.bottom,
              color: textEditingController.text.contains("@")&&textEditingController.text.split("@")[1].contains(".")
                  ?styles.Colors.orange
                  :Color(0xffFBC5AE),
            ),
          ), SafeArea(
        child: Scaffold(
            backgroundColor: styles.Colors.whiteColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              leadingWidth: 70,
              toolbarHeight: 42,
              leading: FlatButton(
                padding: EdgeInsets.all(1),
                child: Icon(Icons.arrow_back_ios),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              elevation: 0,
            ),

            body: Column(
              children: [
                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60,),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 37),
                          child: Text(AppLocalizations.of(context).translate('enterEmail'),
                            textAlign: TextAlign.left,
                            style: styles.TextStyles.darkRegularText14.copyWith(fontWeight: FontWeight.w500,color: Color(0xff2E2E2E)),maxLines: 4,),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 37,vertical: 22),
                          child: Text("E-mail",
                            textAlign: TextAlign.left,
                            style: styles.TextStyles.darkRegularText14.copyWith(fontWeight: FontWeight.w500,color: Color(0xff2E2E2E).withOpacity(0.8)),maxLines: 4,),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 37),
                          height: 56,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(width: 0.5,color:errorResp? Color(0xffCC3300):Color(0xffADADAD)))
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  focusNode: _focusNode,
                                  style: TextStyle(fontWeight: FontWeight.w400,fontSize: 17),
                                  decoration: InputDecoration(
                                      hintText: "email@example.com",
                                      hintStyle: TextStyle(fontSize: 17,fontWeight: FontWeight.w400,color: Colors.grey),
                                      enabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      errorText: errorText,
                                      border: InputBorder.none,
                                  ),
                                  controller: textEditingController,
                                  onChanged: (value){
                                    if(value.contains("@")){
                                      if(value.split("@")[1].contains("."))
                                      {
                                        setState(() {
                                          errorText="";
                                        });

                                      }
                                      else{
                                        setState(() {
                                          errorText=AppLocalizations.of(context).translate('enterEmail');
                                        });
                                      }
                                    }else{
                                      setState(() {
                                        errorText=AppLocalizations.of(context).translate('enterEmail');
                                      });

                                    }
                                  },
                                ),
                              ),
                              // textEditingController.text!=""?GestureDetector(
                              //   child: Icon(
                              //     Icons.clear,color: styles.Colors.gray,
                              //   ),
                              //   onTap: (){
                              //     setState(() {
                              //       textEditingController.text="";
                              //       errorText="";
                              //     });
                              //   },
                              // ):Container()

                            ],
                          ),
                        ),
                        errorResp?Container(
                          margin: EdgeInsets.symmetric(horizontal: 37,vertical: 8),
                          child: Text(
                               "Данная почта уже существует. Введите другую почту",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,fontSize: 12,color: Color(0xffCC3300)
                            ),
                          ),
                        ):Container()
                      ],
                    )
                ),
                MaterialButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                    color: textEditingController.text.contains("@")&&textEditingController.text.split("@")[1].contains(".")
                        ?styles.Colors.orange
                        :Color(0xffFBC5AE),
                    child: new Container(
                      height: 50,
                      width: double.infinity,
                      //375,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(bottom: 0),
                      // color: Colors.red,
                      child: Text(
                        AppLocalizations.of(context).translate('next'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:  styles.Colors.whiteColor,
                            fontFamily: 'Gilroy',
                            fontSize: 18),
                      ),
                    ),
                    onPressed: ()async{
                      if(textEditingController.text.contains("@")){
                        if(textEditingController.text.split("@")[1].contains("."))
                        {
                          setState(() {
                            errorText="";
                          });
                          var resp=await  ServerManager(context).saveUser(textEditingController.text);
                          SharedPreferences prefs=await SharedPreferences.getInstance();
                          prefs.setString("email", textEditingController.text);
                          print(resp);
                            if(jsonDecode(resp)['code']==200){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EmailSendSucc()));
                            }else{
                              setState(() {
                                errorResp=true;

                              });
                            }
                        }
                        else{
                          setState(() {
                            errorText=AppLocalizations.of(context).translate('enterEmail');
                          });
                        }
                      }else{
                        setState(() {
                          errorText=AppLocalizations.of(context).translate('enterEmail');
                        });

                      }
                    })

                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 20),
                //   child:FlatButton(
                //     padding: EdgeInsets.all(0),
                //     child: Container(
                //       height: 56,
                //       decoration: BoxDecoration(
                //           color: styles.Colors.primary.withOpacity(0.4),
                //           borderRadius: BorderRadius.circular(51)
                //       ),
                //       child: Center(
                //         child: Text(AppLocalizations.of(context).translate('accept'),
                //             textAlign: TextAlign.center,
                //             style: styles.TextStyles.sFProText),
                //       ),
                //     ),
                //     onPressed: ()async{
                //       if(textEditingController.text.contains("@")){
                //         if(textEditingController.text.split("@")[1].contains("."))
                //         {
                //           setState(() {
                //             errorText="";
                //           });
                //           var resp=await  ServerManager(context).saveUser(textEditingController.text);
                //           SharedPreferences prefs=await SharedPreferences.getInstance();
                //           prefs.setString("email", textEditingController.text);
                //           print(resp);
                //           if("Invalid_Email"!=jsonDecode(resp)['errorCode'].toString())
                //           if(jsonDecode(resp)['code']==200){
                //             showCupertinoDialog(context: context, builder: (context){
                //               return CupertinoAlertDialog(
                //                 actions: [FlatButton(
                //                   padding: EdgeInsets.all(1),
                //                   child: Text("Закрыть",
                //                     style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),
                //                   ),
                //                   onPressed: (){
                //                     Navigator.of(context).pop();
                //                   },
                //                 )],
                //                 title: Column(
                //                   children: [
                //                     Text("Спасибо",
                //                       style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),
                //                     ),
                //                     Text("Ваш тестовый аккаунт зарегистрирован",
                //                       style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400),
                //                     ),
                //
                //                   ],
                //                 ),
                //               );
                //             });
                //           }
                //         }
                //         else{
                //           setState(() {
                //             errorText=AppLocalizations.of(context).translate('enterEmail');
                //           });
                //         }
                //       }else{
                //         setState(() {
                //           errorText=AppLocalizations.of(context).translate('enterEmail');
                //         });
                //
                //       }
                //     },
                //   )
                //   ,
                // ),

              ],
            ),
          ))]));

  }
}