import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaban/Widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'Authentication/StartController.dart';

class ServerManager {
  BuildContext context;

  ServerManager(this.context);

  String serverURL = "https://api.lemmi.app";

 // User user = User();

  final storage = new FlutterSecureStorage(); 

  String token;
  String refreshtoken;
  String phone;

  SharedPreferences sharedPreferences;

  getJWTToken() async {

    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();}

    token = sharedPreferences.getString("token").toString();

  }

  setJWTToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString("token", token);
  }


  Future <String> getToken() async {
    
    token = await storage.read(key: "token");    
    refreshtoken = await storage.read(key:"refresh_token").then((refreshToken){ 
    
    return refreshToken;
    });
    phone= await storage.read(key:"phone").then((phone){
      return phone;
    });
     return token; 
    }

    Future <String> getrefreshToken() async {
           
    refreshtoken = await storage.read(key:"refresh_token");

    return refreshtoken;
         
    }

  checkMobileRequest(String phone, void onSuccess(String code),
      void onError(String errorCode)) {
    print("phone=$phone");

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);
    var lang = "${ui.window.locale.languageCode}";
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    }
    http.get("$serverURL/api/user/check-mobile?phone=$phone",
     headers: <String, String>{      
          'Accept-Language':'$lang',                  
        }).then((response) {
      print("Response status: ${response.statusCode}api/user/check-mobile?phone=$phone");
      print("Response body: ${response.body}");

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {
          var result = body["result"];
        if(result["otp"] == false){
          onSuccess("${result["otp"]}");
        }
        else{
          Dialogs().alertAction(context, "Ваш OTP код", "${result["otp"]}", (){

            Navigator.of(context).pop();

            onSuccess("${result["otp"]}");

         });
        }
        

        } else if (code == "409") {
          onError("${response.statusCode}");

          Dialogs().alert(context, "Ошибка валидации",
              "Данный номер уже был зарегистрирован в системе");
        } else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }).whenComplete(() {
      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });
  }
  saveUser(email)async{

    var responce= await http.post("$serverURL/api/user/save-tester",
        body: {
          "email" : "$email",
        }
    );
    print(responce.statusCode);
      return responce.body;
  }
  confirmCode(code)async{

    print({
      "code":"$code"
    });
    var responce=await http.post("$serverURL/api/user/get-tester-email",
        body: {
          "code":"$code"
        }
    );
    if(responce!=null)
      return responce;
  }
  loginMobileRequest(String phone, void onSuccess(String code),
      void onError(String errorCode)) {
    print("phone=$phone");

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);
    print("$serverURL/api/user/login?phone=$phone ");

    http.get("$serverURL/api/user/login?phone=$phone").then((response) {
      print("$serverURL/api/user/login?phone=$phone Response status: ${response.statusCode}api/user/login?phone=$phone");
      print("Response body: ${response.body}");

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {
          var result = body["result"];
if(result["otp"] == false){
          onSuccess("${result["otp"]}");
        }
        else{
          Dialogs().alertAction(context, "Ваш OTP код", "${result["otp"]}", (){

            Navigator.of(context).pop();

            onSuccess("${result["otp"]}");

         });
        }

        } else if (code == "418") {
          onError("${response.statusCode}");
          Dialogs().alert(context, "Ошибка валидации",
              "Данный номер не зарегистрирован в системе");

        } else if (code == "401"){
           onError("${response.statusCode}");
          Dialogs().alert(context, "Ошибка валидации",
              "Недопустимый номер. Проверьте номер и повторите попытку");

        }else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }).whenComplete(() {
      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });
  }

  registerUserRequest(String firstname, String gender, String phone,String email,
      void onSuccess(String token, refreshToken), void onError(String errorCode)) {
    print("first_name = $firstname");
    print("gender = $gender");
    print("phone=$phone");
    print({
      "first_name": firstname,
      "gender": gender,
      "phone": phone,
      'email':email,
      "type": "customer",
    });
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);

    http.post("$serverURL/api/user/create", headers: <String, String>{
    }, body: {
      "first_name": firstname,
      "gender": gender,
      "phone": phone,
      'email':email,
      "type": "customer",
    }).then((response) {
      print("Response status: ${response.statusCode}/api/user/create");
      print("Response body: ${response.body}");    

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();


      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "201") {

          var result = body["result"];          

          final storage = new FlutterSecureStorage();
          
          setJWTToken("${result["accessToken"]}");
          
          writeToken({String key, String value}){
          storage.write(key: "token", value: "${result["accessToken"]}");
          storage.write(key: "refresh_token", value: "${result["refresshToken"]}");
          }

          onSuccess("${result["accessToken"]}", "${result["refresshToken"]}");
          writeToken();

        }else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }).whenComplete(() {
      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });
  }
tokenRequest(String fcmToken,void onSuccess(result))async{
    String token = await storage.read(key: 'token');
    http.post("$serverURL/api/updateOrCreate/pushToken",
          headers: <String, String>{
           'Authorization': 'Bearer $token',
          },
          body: {
            "fcmToken": "$fcmToken",                       
          }
          ).then((response) {
        print("Response status: ${response.statusCode}api/updateOrCreate/pushToken");
        print("Response body: ${response.body}");
        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);
          if ("${body["code"]}" == "200") {
            onSuccess("");
            print (body['code']);
          } else {
             Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);
        }
      }).catchError((error) {
        print("Error: $error");Dialogs().errorAlert(context);
      }).whenComplete(() {
      });
    
  }
  checkOTPRequest(String phone, String codeOTP, String fcmToken, void onSuccess(String code),
      void onError(String errorCode)) {
    print("phone=$codeOTP");

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);

    http.post("$serverURL/api/user/registration/check-otp?otp",
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },             
        body: {
          "phone": phone,
          "otp": codeOTP,
          "fcmToken": fcmToken.toString()
        }).then((response) {
      print("Response status: ${response.statusCode}api/user/registration/check-otp?otp");
      print("Response body: ${response.body}");
      
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {
          onSuccess("");
        } else if ("${body["code"]}" == "203") {
          onError("${response.statusCode}");

          Dialogs().alert(context, "Ошибка валидации", "Код ОТП неверен");
        } else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }).whenComplete(() {
      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });
  }

String firstName1;
String lastName1;

  getUserInfoRequest(void onSuccess(Map user),
      void onError(String errorCode)) async {

    await getJWTToken().whenComplete(() {
  //  await getToken().whenComplete(() { 
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();

      Dialogs().showLoadingDialog(context, _keyLoader);

      //final prefs = await SharedPreferences.getInstance();

      http.get("$serverURL/api/user/profile",
          headers: <String, String>{
            // 'Content-Type':  'application/x-www-form-urlencoded',
            'Authorization' : 'Bearer $token',

          }).then((response) {

        //print("token = ${prefs.getString("token")}");

        print("Response status: ${response.statusCode}/api/user/profile");
        print("Response body: ${response.body}");


        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);

          var code = "${body["code"]}";

          if (code == "200") {
            var result = body["result"];

            onSuccess(result);

            storage.write(key: "id", value: "${result["id"]}");
            storage.write(key:"phone", value: "${result["phone"]}");

          } else if (code == "409") {
            onError("${response.statusCode}");

            Dialogs().alert(context, "Ошибка валидации",
                "");
          } else {
            onError("${response.statusCode}");

            Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);

          onError("${response.statusCode}");
        }
      }).catchError((error) {
        print("Error: $error");
        onError("${error.hashCode}");

        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).whenComplete(() {
        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });


    });

  }

  userInfoUpdateRequest(
      String userName,
      String userSurname,
      String birthday,
      String userCity,
      String _emailString,      
      void onSuccess(String code),
      void onError(String errorCode)) async {
    print("first_name = $userName");
    print("last_name =$userSurname");
    print("birthday =$birthday");
    print("address =$userCity");
    print("email=$_emailString");
    
   // await getToken().then((token){

    await getJWTToken().whenComplete(() {
   
    //await getToken().then((token){
    print("token= $token");

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);

    http.post("$serverURL/api/user/update",
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',

        },
        body: {
          "first_name": userName,
          "last_name": userSurname,
          "birthday": birthday,
          "address": userCity,
          "email": _emailString,
          "facebook_id": "",
          "facebook_token":"",
          "type": "customer",
        }).then((response) {
      print("Response status: ${response.statusCode}/api/user/update");
      print("Response body: ${response.body}");

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        
        if ("${body["code"]}" == "200") {
          var result = body["result"];
          onSuccess("");
          
        } else if ("${body["code"]}" == "400"){
           onError("${response.statusCode}");

           Dialogs().alert(context, "Ошибка ввода",
              "Этот email уже зарегистрирован");
        }else if ("${body["code"]}" == "401"){
          onError("${response.statusCode}");

          Dialogs().alert(context, "Ошибка ввода",
              "Неверный E-mail");
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }).whenComplete(() {
      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });
   });
  }

   getSpecialistsRequest(void onSuccess(List specialists),
      void onError(String errorCode)) async {
  // final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  // Dialogs().showLoadingDialog(context, _keyLoader);

  // await getToken().then((token){
    await getJWTToken().whenComplete(() async {    
     var lang =  await storage.read(key: "language");
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    }   
    http.get("$serverURL/api/activity-task/specialists-all",
        headers: <String, String>{      
          'Accept-Language':'$lang',                  
        }).then((response) {
             
      print("Response status: ${response.statusCode}api/activity-task/specialists-all");

      BaseListResponse baseResponse = BaseListResponse.fromJson(
          json.decode(response.body));
       
      if (baseResponse.code != 200) {
        print(baseResponse.code);
        Dialogs().errorAlert(context);
        onError("${response.statusCode}");


      }else{
        List<dynamic> result = baseResponse.result;
// Navigator.of(context).pop();
        onSuccess(result);

      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

    }).whenComplete(() {

    });
    });
  }

  getSpecialistsIdRequest(String id, void onSuccess(List result),
    void onError(String errorCode)) async {
    
    //await getJWTToken().whenComplete(() {
   // await getToken().then((token){

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);
    var lang =  await storage.read(key: "language");
    //var lang = "${ui.window.locale.languageCode}";
   if(lang == "uk"){
     lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    } 
    else {
       lang = "ru";
    }      
    http.get("$serverURL/api/activity-task/services-all?id=$id",
        headers: <String, String>{       
        'Accept-Language':lang,
        }).then((response) {
      print("$id");    
      print("Response status: ${response.statusCode}/api/activity-task/services-all?id=$id");
      print("Response body: ${response.body}");
            
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {

        print('body = $response.body');

        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {
          
          var result = body["result"];

          print(result);

          onSuccess(result);
                  
        } else if (code == "409") {
          onError("${response.statusCode}");

          Dialogs().alert(context, "Ошибка валидации",
              "");
        } else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }).whenComplete(() {
      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });

   //});

  }
deleteRequest(void onSuccess(dynamic result),
    void onError(String errorCode)) async {
    await getJWTToken().whenComplete(() {        

    //await getJWTToken().whenComplete(() {
   // await getToken().then((token){

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);
    
    http.get("$serverURL/api/user/block",
        headers: <String, String>{
          'Authorization' : 'Bearer $token'
        }).then((response) {
        
      print("Response status: ${response.statusCode}/api/user/block");
      print("Response body: ${response.body}");
            
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {

        print('body = ${response.body}');
        var body = jsonDecode(response.body);
        var code = "${body["code"]}";
        if (code == "200") {          
          var result = body["block"];

          print(result);

          onSuccess(result);
                  
        } else if (code == "409") {
          onError("${response.statusCode}");

          Dialogs().alert(context, "Ошибка валидации",
              "");
        } else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    }).whenComplete(() {
      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });

   });

  }
  getSubServicesRequest(String id, void onSuccess(List result),
    void onError(String errorCode)) async {
    
    await getJWTToken().whenComplete(() async {        

    

    var lang =  await storage.read(key: "language");
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    }   
    http.get("$serverURL/api/activity-task/under-services?service_id=$id",
        headers: <String, String>{       
        'Accept-Language':lang,
        'Authorization' : 'Bearer $token',
        }).then((response) {
      print("$id");    
      print("Response status: ${response.statusCode}/api/activity-task/under-services?service_id=$id");
      print("Response body: ${response.body}");
            

      if (response.statusCode == 200) {

        print('body = $response.body');
        var body = jsonDecode(response.body);
        var code = "${body["code"]}";

        if (code == "200") {
          
          var result = body["result"];
          print(result);
          onSuccess(result);
                  
        } else if (code == "409") {
          onError("${response.statusCode}");

          Dialogs().alert(context, "Ошибка валидации",
              "");
        } else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

    });

   });

  }

  addressAllRequest(void onSuccess(List result),
    void onError(String errorCode)) async {

    await getJWTToken().whenComplete(() {
   // await getToken().then((token){

   // final GlobalKey<State> _keyLoader = new GlobalKey<State>();

//    Dialogs().showLoadingDialog(context, _keyLoader);

    http.get("$serverURL/api/activity-task/address-all",
        headers: <String, String>{

        'Authorization' : 'Bearer $token',

        }).then((response) {
             
      print("Response status: ${response.statusCode}/api/activity-task/address-all");
      print("Response body: ${response.body}");

     // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      BaseListResponse1 baseResponse1 = BaseListResponse1.fromJson(
          json.decode(response.body));
      if (baseResponse1.code != 200) {
        //validation errors, wrong token e.t.c.
      //  print(baseResponse1.code);

        onError("${response.statusCode}");

      }else{
        List<dynamic> result = baseResponse1.result;
        
        onSuccess(result);
        
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

    });
    });
  }

  createAddressRequest(String town, String adress, String description, String id,
   double lat, double long, 
  void onSuccess(result),
  void onError(String errorCode))async {
    print("town = $town");
    print("adress = $adress");
    print("description =$description");
    print("id = $id");
    print("latitude = $lat");
    print("longitude = $long");
   String latitude1 = "$lat";
  String longitude1 = "$long";
    await getJWTToken().whenComplete(() {
  //  await getToken().then((token){

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);

    http.post("$serverURL/api/activity-task/create-address",
    headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization' : 'Bearer $token',
    },
    body: {
      "town":town,
      "adress":adress,
      "description":description,
      "id":id,
      "latitude":latitude1,
      "longitude":longitude1,
     
    }).then((response){
    print("Response status: ${response.statusCode}/api/activity-task/create-address");
    print("Response body: ${response.body}");

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        var result = body['result'];

        if ("${body["code"]}" == "200" ) {
          onSuccess(result);
          
        } else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      }else if(response.statusCode == 502){
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          Dialogs().alert(context, "Ошибка 502", "502 Bad Gateway");
        } else {
        Dialogs().errorAlert(context);
        onError("${response.statusCode}");
      }

    });
    });
  }

  topPerformerRequest(String services_id, void onSuccess(List performers),
    void onError(String errorCode)) async {

    await getJWTToken().whenComplete(() {
   // await getToken().then((token){

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);

    http.get("$serverURL/api/activity-task/top-performers?service_id=$services_id",
        headers: <String, String>{
        'Authorization' : 'Bearer $token',
        }).then((response) {
      print("Response status: ${response.statusCode}/api/activity-task/top-performers?service_id=$services_id");
      print("Response body: ${response.body}");

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {

          var result = body["result"];

          onSuccess(result);

        }  else {
          onError("${response.statusCode}");

          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });

   });

  } 

  performerRequest(String id, void onSuccess(result), void onError (String errorCode))async{

    await getJWTToken().whenComplete((){
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();
      Dialogs().showLoadingDialog(context, _keyLoader); 

      http.get("$serverURL/api/activity-task/performer?id=$id",
      headers: <String, String>{

        'Authorization' : 'Bearer $token',
   })        
        .then((response) {

      print("Response status: ${response.statusCode}/api/activity-task/performer?id=$id");
      print("Response body: ${response.body}");

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {
          var result = body;
         // var result = body["user"];
          
          
          onSuccess(result);
          
        }  else if(code == "400"){
          onError("${response.statusCode}");
           Dialogs().alert(context, "400", "failed to get performer");
        }else{
          onError("${response.statusCode}");
          
          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);

        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });   

   });

  } 

   myTasksRequest(void onSuccess(result),
    void onError(String errorCode)) async {
  
    await getJWTToken().whenComplete(() async {
     token = await storage.read(key: 'token');
     print(token);
    var lang =  await storage.read(key: "language");
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    } else lang = "ru";
    http.get("$serverURL/api/activity-task/customer/my-tasks",
        headers: <String, String>{
        'Accept-Language':'$lang',
        'Authorization' : 'Bearer $token',

        })        
        .then((response) {
    print('Bearer $token');
    print("Response status: ${response.statusCode}/api/activity-task/customer/my-tasks");
     print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {

          var result = body;
          onSuccess(result);

        }  else if(code == "400" || code == "403"){
          storage.write(key: 'token', value: "");
          sharedPreferences.setString("token", "");}
        else{
          onError("${response.statusCode}");
        }
      } else {
        onError("${response.statusCode}");
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");
    });  

   });
  } 
  

   searchSpecialistsRequest(void onSuccess(result),
    void onError(String errorCode)) async {

   // await getJWTToken().whenComplete(() {
   // await getToken().then((token){

    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);
    var lang =  await storage.read(key: "language");
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    } 
    else {
       lang = "ru";
    }     
    http.get("$serverURL/api/user/customer/all-specialists",
        headers: <String, String>{
       'Accept-Language':'$lang', 
        }).then((response) {
             
      print("Response status: ${response.statusCode}/api/user/customer/all-specialists");
      print("Response body: ${response.body}");

      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      BaseListResponse1 baseResponse1 = BaseListResponse1.fromJson(
          json.decode(response.body));
      if (baseResponse1.code != 200) {
        //validation errors, wrong token e.t.c.
        onError("${response.statusCode}");

      }else{
      var result = json.decode(response.body);      
        onSuccess(result);        
      }
    }).catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

      Dialogs().errorAlert(context);

    })
    .whenComplete( () {
    });
   // });
  }

  cancelRequest(String id, String taskId, void onSuccess(result),
  void onError(String code))async{
   await getJWTToken().whenComplete(() async {
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();

      Dialogs().showLoadingDialog(context, _keyLoader);
     var lang =  await storage.read(key: "language");
      if(lang == "uk"){
      lang = "ua";
      }else if(lang == "en"){
       lang = "ru";
      } 
      http.post("$serverURL/api/activity-task/customer/cancel-task",
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
            'Accept-Language':'$lang',
          },
          body: {
            "task_id": "$taskId",
            "userId": "$id",            
          }).then((response) {
        print("Response status: ${response.statusCode}/api/activity-task/customer/cancel-task");
        print("Response body: ${response.body}");

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);

          if ("${body["code"]}" == "200") {
            print(body);
            onSuccess("");
          } else {
            onError("${response.statusCode}");

            Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);

          onError("${response.statusCode}");
        }
      }).catchError((error) {
        print("Error: $error");
        onError("${error.hashCode}");

        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).whenComplete(() {
        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });
    });  
  }

  acceptRequest(String id, String taskId, void onSuccess(result),
  void onError(String code))async{
   await getJWTToken().whenComplete(() async {
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();

      Dialogs().showLoadingDialog(context, _keyLoader);
     var lang =  await storage.read(key: "language");
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    } 
      http.post("$serverURL/api/activity-task/customer/accept",
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
            'Accept-Language':'$lang', 
          },
          body: {
            "task_id": "$taskId",
            "performer_id": "$id",            
          }
          ).then((response) {
        print("Response status: ${response.statusCode}/api/activity-task/customer/accept");
        print("Response body: ${response.body}");

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);

          if ("${body["code"]}" == "200") {
            onSuccess("");
            print (body);
          } else {
            onError("${response.statusCode}");

            Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);

          onError("${response.statusCode}");
        }
      }).catchError((error) {
        print("Error: $error");
        onError("${error.hashCode}");

        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).whenComplete(() {
        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });
    });  
  }

  deleteTaskRequest(String taskId, void onSuccess(result),
  void onError(String code))async{
   await getJWTToken().whenComplete(() {
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();

      Dialogs().showLoadingDialog(context, _keyLoader);

      http.delete("$serverURL/api/activity-task/customer/delete-task?task_id=$taskId",
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },).then((response) {
        print("Response status: ${response.statusCode}/api/activity-task/customer/delete-task?task_id=$taskId");
        print("Response body: ${response.body}");

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);

          if ("${body["code"]}" == "200") {
            print(body);
            onSuccess("");
          } else {
            onError("${response.statusCode}");

            Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);

          onError("${response.statusCode}");
        }
      }).catchError((error) {
        print("Error: $error");
        onError("${error.hashCode}");

        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).whenComplete(() {
        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });
    });  
  }

   myOrderRequest(void onSuccess(result),
    void onError(String errorCode)) async {
  
    await getJWTToken().whenComplete(() {   
  
   http.get("$serverURL/api/activity-task/customer/my-orders",
        headers: <String, String>{

        'Authorization' : 'Bearer $token',

        })        
        .then((response) {

      print("Response status: ${response.statusCode}/api/activity-task/customer/my-orders");
      print("Response body: ${response.body}");

       if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {

          var result = body;

          onSuccess(result);

        }  else {
          onError("${response.statusCode}");          
          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);
        onError("${response.statusCode}");
      }
    });
   });
  } 

  myOrderByIdRequest(String idTask, void onSuccess(result),
    void onError(String errorCode)) async {
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();

    Dialogs().showLoadingDialog(context, _keyLoader);
    await getJWTToken().whenComplete(() {  
  
   http.get("$serverURL/api/activity-task/customer/my-order?id_task=$idTask",
        headers: <String, String>{
        'Authorization' : 'Bearer $token',
        })        
        .then((response) {

      print("Response status: ${response.statusCode}/api/activity-task/customer/my-order?id_task=$idTask");
      print("Response body: ${response.body}");

     Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

       if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {

          var result = body;

          onSuccess(result);

        }  else {
          onError("${response.statusCode}");          
          Dialogs().errorAlert(context);
        }
      } else {
        Dialogs().errorAlert(context);
        onError("${response.statusCode}");
      }
    })
    .catchError((error) {
      print("Error: $error");
      onError("${error.hashCode}");

     Dialogs().errorAlert(context);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });
   });

  } 

  replyCommentRequest(String activityTaskId, String userId, String theId, String replyComment, void onSuccess(result),
  void onError(String code))async{
   await getJWTToken().whenComplete(() {
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();

      Dialogs().showLoadingDialog(context, _keyLoader);

      http.put("$serverURL/api/activity-task/customer/reply-comment",
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },
          body: {
            "activityTaskId": "$activityTaskId",
            "userId": "$userId",
            "id":"$theId",
            "reply_comment":"$replyComment",            
          }
          ).then((response) {
        print("Response status: ${response.statusCode}/api/activity-task/customer/reply-comment");
        print("Response body: ${response.body}");

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);

          if ("${body["code"]}" == "200") {
            onSuccess("");
            print (body);
          } else {
            onError("${response.statusCode}");

            Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);

          onError("${response.statusCode}");
        }
      }).catchError((error) {
        print("Error: $error");
        onError("${error.hashCode}");

        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).whenComplete(() {
        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });
    });  
  }

   feedbackRequest(String performerId, String taskId, String review,String ratinId, void onSuccess(result),
  void onError(String code))async{
   await getJWTToken().whenComplete(() async {
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();

      Dialogs().showLoadingDialog(context, _keyLoader);
   var lang =  await storage.read(key: "language");
    if(lang == "uk"){
      lang = "ua";
    }else if(lang == "en"){
       lang = "ru";
    }
      http.post("$serverURL/api/user/customer/send-feedback",
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
            'Accept-Language':'$lang',
          },
          body: {
          'review': "$review",
          "activityTaskId": "$taskId",
          "user_profile_id": "$performerId",
          "usersRatingId":"$ratinId",            
          }
          ).then((response) {
        print("Response status: ${response.statusCode}/api/user/customer/send-feedback");
        print("Response body: ${response.body}");

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);

          if ("${body["code"]}" == "200") {
            onSuccess("");
            print (body);
          }else if ("${body["code"]}" == "400") {
            onSuccess("${body["code"]}");
            print ("${body["code"]}");
          } else {
            onError("${response.statusCode}");
            //Dialogs().alert(context, "Ошибка", '${body['err']}');
            Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);

          onError("${response.statusCode}");
        }
      }).catchError((error) {
        print("Error: $error");
        onError("${error.hashCode}");

        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).whenComplete(() {
        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });
    });  
  }

  ratingPerformerRequest(String rating, String userId, String activityTaskId, void onSuccess(result),
  void onError(String code))async{
   await getJWTToken().whenComplete(() {
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();

      Dialogs().showLoadingDialog(context, _keyLoader);
        
        var body = {
          'rating': "$rating",
          "activityTaskId": "$activityTaskId",
          "userId": "$userId",            
          };
        print(body);
      http.post("$serverURL/api/user/add-rating",
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },
          body: {
          'rating': "$rating",
          "activityTaskId": "$activityTaskId",
          "userId": "$userId",            
          }
          ).then((response) {
            
        print("Response status: ${response.statusCode}/api/user/add-rating");
        print("Response body: ${response.body}");

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);

          if ("${body["code"]}" == "200") {
            onSuccess("${body['ratingId']}");
            
          }else if("${body["code"]}" == "400"){
           onSuccess("${body['usersRatingId']}"); 
           //Dialogs().alert(context, "Упс, ошибка",
             // "вы уже оценили работу исполнителя");
            }else {
            onError("${response.statusCode}");

            Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);

          onError("${response.statusCode}");
        }
      }).catchError((error) {
        print("Error: $error");
        onError("${error.hashCode}");

        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).whenComplete(() {
        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });
    });  
  }

   checkFeedbackRequest(String activityTaskId, void onSuccess(result), void onError(String code))async{
   await getJWTToken().whenComplete(() {
      final GlobalKey<State> _keyLoader = new GlobalKey<State>();
      Dialogs().showLoadingDialog(context, _keyLoader);
      http.post("$serverURL/api/user/customer/check-feedback",
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token',
          },
          body: {
          "activityTaskId": "$activityTaskId",           
          }
          ).then((response) {
        print("Response status: ${response.statusCode}/api/user/customer/check-feedback");
        print("Response body: ${response.body}");

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);
          var result = body;
            if ("${body["code"]}" == "200") {
            onSuccess(result);
          } else {
            onError("${response.statusCode}");

            Dialogs().errorAlert(context);
          }
        } else {
          Dialogs().errorAlert(context);

          onError("${response.statusCode}");
        }
      }).catchError((error) {
        print("Error: $error");
        onError("${error.hashCode}");

        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }).whenComplete(() {
        Dialogs().errorAlert(context);

        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      });
    });  
  }

 problemStatus(String idTask, void onSuccess(result), void onError(String errorCode)) async {
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    Dialogs().showLoadingDialog(context, _keyLoader);

    await getJWTToken().whenComplete(() {  
  
   http.get("$serverURL/api/task/problem?task_id=$idTask",
        headers: <String, String>{
        'Authorization' : 'Bearer $token',
        })        
        .then((response) {
      print("Response status: ${response.statusCode}/api/task/problem?task_id=$idTask");
      print("Response body: ${response.body}");

     Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

       if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {

          var result = body;

          onSuccess(result);

        } else {
          onError("${response.statusCode}");          
          Dialogs().errorAlert(context);          
        }
      } else {        
        onError("${response.statusCode}");
        Dialogs().errorAlert(context);        
      }
    });
   });
  } 

  accepsDoneStatus(String idTask, void onSuccess(result), void onError(String errorCode)) async {
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    Dialogs().showLoadingDialog(context, _keyLoader);

    await getJWTToken().whenComplete(() {  
  
   http.get("$serverURL/api/task/accept?task_id=$idTask",
        headers: <String, String>{
        'Authorization' : 'Bearer $token',
        })        
        .then((response) {
      print("Response status: ${response.statusCode}/api/task/accept?task_id=$idTask");
      print("Response body: ${response.body}");

      

       if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {

          var result = body;

          onSuccess(result);          
        } else {          
          onError("${response.statusCode}");      
          Dialogs().errorAlert(context);
        }
      } else {        
        Dialogs().errorAlert(context);
        onError("${response.statusCode}");        
      }
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    });
   });
  } 

  getComment(void onSuccess(result), void onError(String errorCode)) async {
  
    await getJWTToken().whenComplete(() {
    
   http.get("$serverURL/api/performer/get-reviews",
        headers: <String, String>{
        'Authorization' : 'Bearer $token', 
        })        
        .then((response) {
      print("Response status: ${response.statusCode}/api/performer/get-reviews");
      print("Response body: ${response.body}");

       if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        var code = "${body["code"]}";

        if (code == "200") {

          var result = body['reviews'];

          onSuccess(result);

        } else {          
          onError("${response.statusCode}");      
          Dialogs().errorAlert(context);
        }
      } else {        
        Dialogs().errorAlert(context);
        onError("${response.statusCode}");        
      }
    });
   });
  } 
}
 

class BaseResponse{
  final int code;
  final Map<String, dynamic> result;
  final String errorCode;

  BaseResponse(this.code, this.result, this.errorCode);

  BaseResponse.fromJson(Map<String, dynamic> json):
        code = json['code'],
        result = json['result'],
        errorCode = json['errorCode'];

  Map<String, dynamic> toJson() =>
      {
        'code': code,
        'result': result,
        'errorCode': errorCode
      };
}


class BaseListResponse{
  final int code;
  final List<dynamic> result;
  final String errorCode;

  BaseListResponse(this.code, this.result, this.errorCode);

  BaseListResponse.fromJson(Map<String, dynamic> json):
        code = json['code'],
        result = json['result'],
        errorCode = json['errorCode'];

  Map<String, dynamic> toJson() =>
      {
        'code': code,
        'result': result,
        'errorCode': errorCode
      };
}


class BaseResponse1{
  final int code;
  final Map<String, dynamic> result;
  final String errorCode;

  BaseResponse1(this.code, this.result, this.errorCode);

  BaseResponse1.fromJson(Map<String, dynamic> json):
        code = json['code'],
        result = json['result'],
        errorCode = json['errorCode'];

  Map<String, dynamic> toJson() =>
      {
        'code': code,
        'result': result,
        'errorCode': errorCode
      };
}


class BaseListResponse1{
  final int code;
  final List<dynamic> result;
  final String errorCode;

  BaseListResponse1(this.code, this.result, this.errorCode);

  BaseListResponse1.fromJson(Map<String, dynamic> json):
        code = json['code'],
        result = json['result'],
        errorCode = json['errorCode'];

  Map<String, dynamic> toJson() =>
      {
        'code': code,
        'result': result,
        'errorCode': errorCode
      };
}
