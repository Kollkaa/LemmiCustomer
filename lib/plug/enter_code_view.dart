import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/custom_widget/pin_put.dart';
import 'package:mask_shifter/mask_shifter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Styles.dart' as styles;
import '../Widgets.dart';
import '../app_localizations.dart';
import 'toast_utils.dart';
class EnterCodeView extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return EnterCodeViewState();
  }
}
class EnterCodeViewState extends State<EnterCodeView>{
  String currentText;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  var errorCode =false;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      color: styles.Colors.grayTransPlugOp60,
      borderRadius: BorderRadius.circular(7.0),
    );
  }
  var _codeController = TextEditingController();
  bool _isOtpValid = false;

  @override
  Widget build(BuildContext context) {
    final topNavigationBar = Widgets().topBar(context);

    final codeField = new TextFormField(
        keyboardType: TextInputType.text,
        style: styles.TextStyles.darkGRegularText32,
        textAlign: TextAlign.left,
        controller: _codeController,
        decoration: new InputDecoration(
            hintText: '0-0-0-0',
            hintStyle: styles.TextStyles.hintdarkGRegularText32.copyWith(color: styles.Colors.darkTextTrans),
            border: InputBorder.none),
        inputFormatters: [
          MaskedTextInputFormatterShifter(
              maskONE: "X-X-X-X", maskTWO: "X X X X")
        ],

        onSaved: (String value) {
          _codeController.text = value;
          // this._data.email = value;
        },
        onChanged: (String value) {
          if(value.length>=7){
            setState(() {
              _isOtpValid = true;
            });
            FocusScope.of(context).requestFocus(new FocusNode());
          }else{
            setState(() {
              _isOtpValid = false;
            });
          }
        });

    return Scaffold(
      backgroundColor: styles.Colors.background,
      body: Stack(children: <Widget>[

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).padding.bottom,
            color: _isOtpValid
                ?styles.Colors.orange
                :Color(0xffFBC5AE),
          ),
        ),
        SafeArea(
            child: GestureDetector(
              child: Stack(children: <Widget>[
                Container(
                  padding: new EdgeInsets.only(top: 30, bottom: 0),
                  child: new Form(
                      child: Column(
                        children: [
                          Expanded(child: ListView(
                              children: <Widget>[
                                topNavigationBar,

                                new SizedBox(height: 100),
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                      top: 10.0, bottom: 22.0,left: 25,right: 25),
                                  child: new Text(AppLocalizations.of(context).translate('enterCode'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 16)),
                                ),
                                SizedBox(height: 20,),
                                Align(
                                  child: Container(
                                      width: 135,
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: codeField,
                                      )),
                                ),
                                new Container(
                                    padding: new EdgeInsets.only(top: 16),
                                    child: new Center(

                                      child: InkWell(
                                        onTap: ()async{
                                          Navigator.of(context).pushNamed("enter_email");
                                        },
                                        child: new Text("У меня нет кода",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontFamily: 'Gilroy',
                                                color: Colors.black,
                                                decoration: TextDecoration.underline,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 12
                                            )
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(bottom: 5
                                    )
                                ),


                              ])),
                          MaterialButton(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                              color: _isOtpValid
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
                                String er="";
                                _codeController.text.split("-").forEach((element) {er+=element;});
                                var resp=await  ServerManager(context).confirmCode(er);
                                print(resp.body);
                                SharedPreferences prefs =await SharedPreferences.getInstance();
                                await prefs.setString("email", jsonDecode(resp.body)['email']);

                                if(jsonDecode(resp.body)['code']!=200)
                                {
                                  ToastUtils.showCustomToast(context, "Такого кода не существует, попробуйте снова");
                                }
                                else{
                                  SharedPreferences prefs=await SharedPreferences.getInstance();
                                  await prefs.setString("email", jsonDecode(resp.body)['email']);
                                  print(prefs.getString("email"));

                                  Navigator.of(context).pushNamed("login");

                                }
                                print("error");

                              })
                        ],
                      )),
                ),

              ]),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
            )),
      ]),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 140,
        toolbarHeight: 42,
        leading: FlatButton(
          padding: EdgeInsets.all(1),
          child: Container(
            height: 42,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(width: 1,color: styles.Colors.primary)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back_ios,color: styles.Colors.primary,size: 20,),
                Text("Назад",style: styles.TextStyles.sFProTextPrimary15,)
              ],
            ),
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      backgroundColor: styles.Colors.whiteColor,
      body: Column(
        children: [
          Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 37),
                      child: Text(AppLocalizations.of(context).translate('enterCode'),
                        textAlign: TextAlign.center,
                        style: styles.TextStyles.darkRegularText14,maxLines: 4,),
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(left:24.0,top: 30,right: 37),
                      child: PinPut(
                        keyboardType: TextInputType.text,
                        fieldsCount: 4,
                        focusNode: _pinPutFocusNode,
                        controller: _pinPutController,
                        onChanged: (v){
                          print(v);
                        },
                        submittedFieldDecoration: _pinPutDecoration.copyWith(
                            borderRadius: BorderRadius.circular(7.0),
                            color: styles.Colors.primary.withOpacity(0.12)
                        ),
                        selectedFieldDecoration: _pinPutDecoration.copyWith(
                            borderRadius: BorderRadius.circular(7.0),
                            color: styles.Colors.primary.withOpacity(0.12),
                            border: Border.all(width:1,color: styles.Colors.primary)

                        ),
                        followingFieldDecoration: _pinPutDecoration.copyWith(
                            borderRadius: BorderRadius.circular(7.0),
                            color: styles.Colors.primary.withOpacity(0.12)
                        ),
                        onSubmit: (val)async{
                          var resp=await  ServerManager(context).confirmCode(val.trim());
                          print(resp.body);
                          SharedPreferences prefs =await SharedPreferences.getInstance();
                           await prefs.setString("email", jsonDecode(resp.body)['email']);

                          if(jsonDecode(resp.body)['code']!=200)
                            {
                              showCupertinoDialog(context: context, builder: (context){
                                return CupertinoAlertDialog(
                                  actions: [FlatButton(
                                    padding: EdgeInsets.all(1),
                                    child: Text("Закрыть",
                                      style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),
                                    ),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  )],
                                  title: Column(
                                    children: [
                                      Text("Спасибо",
                                        style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),
                                      ),
                                      Text("${jsonDecode(resp.body)['msg']}",
                                        style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400),
                                      ),

                                    ],
                                  ),
                                );
                              });
                            }
                          else{
                            SharedPreferences prefs=await SharedPreferences.getInstance();
                            await prefs.setString("email", jsonDecode(resp.body)['email']);
                            print(prefs.getString("email"));

                            Navigator.of(context).pushNamed("login");

                          }
                          print("error");                        },
                      ),
                    ),
                    errorCode?Text("Такого кода не существует, попробуйте снова",style: TextStyle(
                        fontSize: 16,color: Colors.red
                    ),):Container()
                  ],
                ),
              )
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 35,vertical: 60),
            child:FlatButton(
              padding: EdgeInsets.all(0),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                    border: Border.all(width: 1,color: styles.Colors.primary),
                    borderRadius: BorderRadius.circular(51)
                ),
                child: Center(
                  child: Text(AppLocalizations.of(context).translate('dontHaveCode'),
                      textAlign: TextAlign.center,
                      style: styles.TextStyles.sFProTextPrimary),
                ),
              ),
              onPressed: (){
                Navigator.of(context).pushNamed("enter_email");
              },
            ),
          )

        ],
      ),
    );

  }

  void _repeatSms() {

  }

}