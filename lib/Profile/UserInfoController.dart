import 'dart:io';
import "dart:convert" as JSON;
import 'package:flutter_date_picker/flutter_date_picker.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart' show get;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';


import 'package:kaban/Managers.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Widgets.dart';
import '../app_localizations.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as sec;
import 'package:kaban/main.dart';


import 'package:flutter/painting.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class UserInfoController extends StatefulWidget {
  Test test;
  UserInfoController({Key key, this.title, this.test}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  final String title;

  @override
  _UserInfoControllerState createState() => _UserInfoControllerState();
}

class _UserInfoControllerState extends State<UserInfoController> {
//class UserInfoController extends StatelessWidget {
  bool _isLoggedIn;
  bool selected = false;
  String photo;
  String userName;  
  String userSurname = "";
  String token;
  String formatted;
  var _birthdayController = TextEditingController();  
  final _userFNameController = TextEditingController();
  final _userSNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _userCityController = TextEditingController();
  var userCity ="";
  var _birthdayString = "";
  var _birthday = "";
  var _emailString = "";
  var _phoneController = TextEditingController();
  var _cities = List<String>();
  File _image;
  Map userProfile;
  Dio dio = new Dio();
  var selectedDateType = 'ru';
  
  SharedPreferences sharedPreferences;  
  
  List<String> _getCities() {
    var list = List<String>();
    list.add("Киев");
    list.add("Харьков");
    list.add("Одесса");
    list.add("Днепр");
    list.add("Львов");
    list.add("Каменец-Подольский");
    return list;
  }

  //static Map get userInfo => null;
  
  void initState() {  
  super.initState(); 
   getProfileInfo();
   _cities = _getCities();
   getLanguage();
  }

  void getLanguage() async{
    final storage = new sec.FlutterSecureStorage();
    String language =  await storage.read(key: 'language');
    if (language == "uk"){ selectedDateType = "uk";
    }else
      selectedDateType = "ru";
  }

  void setlanguage(int index) async{
    final storage = new sec.FlutterSecureStorage();
    String language;
    if (index == 0) {
      storage.write(key: "language", value: "ru");
    } else {
      storage.write(key: "language", value: "uk");}
    language = await storage.read(key: "language");
    print(language);
  }

  getProfileInfo() async{
    await ServerManager(context).getUserInfoRequest((Map user) async {    
      _userFNameController.text = user["first_name"];
      _userSNameController.text = user["last_name"];
      _userEmailController.text = user["email"];
      _userCityController.text = user["address"]; 
      _phoneController.text = user["phone"];
      photo = 'https://api.lemmi.app/${user["photo"]}';
      if ("${user['birthday']}" != "null"){
      var strDate = user['birthday'];
      DateTime todayDate = DateTime.parse(strDate);
     // var date = DateFormat("dd MMMM yyyy").format(todayDate);      
      await initializeDateFormatting("ru", null).then((_) {
      var formatter = DateFormat.yMMMMd('ru');
      formatted = formatter.format(todayDate);
    });   
      _birthdayController.text = '$formatted'; }
      else{
      _birthdayController.text ="";  
      }
      
     setState(() {
       
     });  
    }, (error) {

    }); 
  }
 
  _userInfoUpdate() async {
    
    String userName= _userFNameController.text;
    String userSurname = _userSNameController.text;
    String birthday = _birthday;
    String userCity = _userCityController.text;
    var _emailString =_userEmailController.text;

    await ServerManager(context).userInfoUpdateRequest(userName,userSurname,birthday,userCity,_emailString,(code){
    Navigator.pop(context, () {

      setState(() { initState(); });
        
    });}, (error){
      
    });
  }

  getJWTToken() async {
    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    token = sharedPreferences.getString("token").toString();
  }

  void uploadImage(File _image ) async { 

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  Dialogs().showLoadingDialog(context, _keyLoader);
if (_image != null) {
  String fileName =_image.path.split('/').last;

  FormData formData = FormData.fromMap({
  "photo":
      await MultipartFile.fromFile(_image.path, filename:fileName),    
  });
    
    await getJWTToken();

    await dio.post("https://api.lemmi.app/api/user/update", data: formData,
    options: Options(headers: {
           "Authorization": "Bearer $token",
           "Content-Type": "multipart/form-data"
         })).then((response) {
          //print("Response status: ${response.statusCode}");
          //print("Response status: ${response.statusCode}");

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

      if (response.statusCode == 200) { 
        var code = "${response.data["result"]}";

       }else{
        print("response = ${response}");

      }

    });
    //Navigator.pop(context);
  Navigator.pop(context);
    setState((){});}
    else {}//Navigator.pop(context);
  }

  getImageGallery() async {

    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery,  imageQuality: 25,  maxWidth: 1000);
    _image = imageFile;
    
    setState(() {
      uploadImage(imageFile);
      Navigator.pop(context);

    });   
    Navigator.pop(context);

  }

  getImageCamera() async {

    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 25,  maxWidth: 1000);
    _image = imageFile;
    
    setState(() {
          uploadImage(imageFile);
          Navigator.pop(context);
    });    
    Navigator.pop(context);
  }

  pickImageFromGallery(ImageSource source) {
    setState(()  {
       var action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context).translate('cup_photo')),
            onPressed: () async { 
              await getImageGallery();                                     
            },
          ),
          CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context).translate('cup_takePicture')),
            onPressed: () async {             
          await getImageCamera();          
              },
          )
        ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context).translate('cup_cancel')),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          )
      );

      showCupertinoModalPopup(context: context, builder: (BuildContext context) => action);

    });
  }

  Widget _buildProfileImage() {
    return Center(
      child: new Stack(
        children: <Widget>[
          new Align(
            alignment: Alignment.topLeft,
            child: MaterialButton(
              child: Image(image: AssetImage('assets/arrow_back.png'),
                width: 10,
                height: 20,
              ),
              onPressed: () {
                _userInfoUpdate();                
              },
            ),
          ),

          new Align(
            alignment: Alignment.center,
            child: Container(
              width: 80.0,
              height: 80.0,
              child: Center(
                child: GestureDetector(
                          onTap: ()  {                          
                          pickImageFromGallery(ImageSource.gallery);
                          },
                           child: _image == null
                            ? new Stack(
                            children: <Widget>[
                              new Center( 
                                child: "$photo" == "https://api.lemmi.app/null"
                                  ? Image.asset("assets/profile_image.png")
                                  : CircleAvatar( 
                                    backgroundColor: Color.fromRGBO(221,98,67, 1),                       
                                    maxRadius: 40,
                                    child: ClipRRect(
                                      borderRadius:BorderRadius.circular(60),
                                      child: Image.network("$photo",
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                          child: CupertinoActivityIndicator(radius: 15.0),);
                                          },
                                      ),
                                    ),                
                                  ),
                    ),  
                  ],
                )              
              : new Container(
                  //height: 160.0,
                  //width: 160.0,
                  decoration: new BoxDecoration(
                    color: const Color(0xFFDD6243),
                    image: new DecorationImage(
                    //  image: new ExactAssetImage(_image.path),
                    image: new FileImage(
                    new File(_image.path),),
                    //AssetImage(_image.path),
                      fit: BoxFit.cover,
                    ),
                    border:
                        Border.all(color: Color.fromRGBO(255,178,158,1), width: 2.0),
                    borderRadius:
                        new BorderRadius.all(const Radius.circular(80.0)),
                  ),
                ),               
              ),
              ),
              
            ),
          ),
          new Align(
            alignment: Alignment.center,
            child: Container(
                width: 80.0,
                height: 80.0,
              child: Center(
                child:Text("${_userFNameController.text.length!=0?_userFNameController.text[0].toUpperCase():""}"
                    "${_userSNameController.text.length!=0?_userSNameController.text[0].toUpperCase():""}",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),),
              ),
            ),
          )
        ],
      )

    );
  }
 Widget _buildFirstName() {

    return Stack(
      children: <Widget>[
        new Container(
          //alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 10.0, left: 30.0, bottom: 0.0),
          child: new Text(AppLocalizations.of(context).translate('appeal'),
              textAlign: TextAlign.left,
              style: styles.TextStyles.darkText14),
        ),
        new Container(
          //alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 25.0, left: 30.0, right: 30.0),
          child: new TextFormField(
            controller: _userFNameController,
              keyboardType: TextInputType.text, // Use email input type for emails.
              style: styles.TextStyles.darkText24,
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(255,178,158,1)),),
                enabledBorder: new UnderlineInputBorder(
                 borderSide: new BorderSide(color: Color.fromRGBO(255,178,158,1), style: BorderStyle.solid)),
                hintText: AppLocalizations.of(context).translate('hintName'),
                hintStyle: TextStyle(fontFamily: 'Gilroy',
                    fontStyle: FontStyle.normal,
                    color: Color(0xFFADADAD),
                    fontSize: 24
                ),
                //border: InputBorder.none,
              ),
              onSaved: (String value) {
                this.userName = value;
                userName= _userFNameController.text = value;
                // this._data.email = value;
              },
              onChanged: (String value){
               // userName= _userFNameController.text= value;
              //  this.userName = value;

              },
            
          ),
        ),
      ],

    );
  }

  Widget _buildSecondName() {
    return Stack(
      children: <Widget>[
        new Container(
          //alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 20.0, left: 30.0, bottom: 0.0),
          child: new Text(AppLocalizations.of(context).translate('surname'),
              textAlign: TextAlign.left,
              style: styles.TextStyles.darkText14),
        ),
        new Container(
          //alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 35.0, left: 30.0, right: 30.0),
          child: new TextFormField(
              controller: _userSNameController,
              keyboardType: TextInputType.text, // Use email input type for emails.
              style: styles.TextStyles.darkText24,
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(255,178,158,1)),),
                enabledBorder: new UnderlineInputBorder(
                 borderSide: new BorderSide(color: Color.fromRGBO(255,178,158,1), style: BorderStyle.solid)),
                hintText: AppLocalizations.of(context).translate('hintSurname'),
                hintStyle: TextStyle(fontFamily: 'Gilroy',
                    fontStyle: FontStyle.normal,
                    color: Color(0xFFADADAD),
                    fontSize: 24
                ),
                //border: InputBorder.none,
              ),
              onSaved: (String value) {
                this.userSurname = value;
                userSurname = _userSNameController.text = value;               
                 // this._data.email = value;
              },
              onChanged: (String value){                
              },

          ),
        ),
      ],
    );
  }

  Widget _buildBirthday() {
    return GestureDetector(
      child: Stack(
        children: <Widget>[
          new Container(
            //alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 20.0, left: 30.0, bottom: 0.0),
            child: new Text(AppLocalizations.of(context).translate('birthday'),
                textAlign: TextAlign.left,
                style: styles.TextStyles.darkText14),
          ),

          new Container(
            //alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 35.0, left: 30.0, right: 30.0),
            child: new TextFormField(
              enabled: false,
              controller: _birthdayController,
              keyboardType: TextInputType.text, // Use email input type for emails.
              style: styles.TextStyles.darkText24,
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(255,178,158,1)),),
                enabledBorder: new UnderlineInputBorder(
                    borderSide: new BorderSide(color: Color.fromRGBO(255,178,158,1), style: BorderStyle.solid)),
                hintText: AppLocalizations.of(context).translate('hintBirthday'),
                hintStyle: TextStyle(fontFamily: 'Gilroy',
                    fontStyle: FontStyle.normal,
                    color: Color(0xFFADADAD),
                    fontSize: 24
                ),
                //border: InputBorder.none,
              ),
              // enabled: false,
              onTap: ()async {
                var day= await showDatePicker(context: context,initialDate: new DateTime.now(),firstDate: new DateTime.now(),lastDate: new DateTime(DateTime.now().year+100));
                _birthdayController.text=day.toLocal().toUtc().toString().split(" ")[0];
              },
            ),
          ),
        ],
      ),
      onTap: ()async{
        var day= await showDatePicker(context: context,initialDate: new DateTime.now(),firstDate: new DateTime.now(),lastDate: new DateTime(DateTime.now().year+100));
        _birthdayController.text=day.toLocal().toUtc().toString().split(" ")[0];
        },
    );
  }
   
   Future<void> _selectedTown(BuildContext context) async {
    var city = await showCupertinoModalPopup(
  context: context,
  builder: (context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            border: Border(
              bottom: BorderSide(
                color: Color(0xff999999),
                width: 0.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                child: Text(AppLocalizations.of(context).translate('cup_cancel'),style: TextStyle( color:Color.fromRGBO(255, 178, 158, 1.0)),),
                onPressed: () {                
                   _userCityController.text = '';                                  
                  Navigator.pop(context);                  
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 5.0,
                ),
              ),
              CupertinoButton(
                child: Text('Готово',style: TextStyle( color:Color(0xFFDD6243))),
                onPressed: () {
                  if(selected == false){
                    _userCityController.text = _cities[0].toString(); 
                   }else{}                                     
                  selected = false;
                   Navigator.pop(context); 
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 5.0,
                ),
              )
            ],
          ),
        ),
        Container(
          height: 150.0,
          color: Color(0xfff7f7f7),
          child: new CupertinoPicker(
            itemExtent: 35,
            backgroundColor: Colors.white,
            children: List<Widget>.generate(_cities.length, (index){
              return Center(
                child: Text(_cities[index]),
              );
            }),
            looping: true, onSelectedItemChanged: (value) {
              selected = true;
              _userCityController.text = _cities[value].toString();
            },
          ),
        )
      ],
    );
  },
);
  }

  Widget _buildEmail() {
    return Stack(
      children: <Widget>[
        new Container(
          //alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 20.0, left: 30.0, bottom: 0.0),
          child: new Text('E-mail',
              textAlign: TextAlign.left,
              style: styles.TextStyles.darkText14),
        ),
        new Container(
          //alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 35.0, left: 30.0, right: 30.0),
          child: new TextFormField(
              controller: _userEmailController ,
              keyboardType: TextInputType.text, // Use email input type for emails.
              style: styles.TextStyles.darkText24,
              decoration: new InputDecoration(
                focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(255,178,158,1)),),
                enabledBorder: new UnderlineInputBorder(
                 borderSide: new BorderSide(color: Color.fromRGBO(255,178,158,1), style: BorderStyle.solid)),
                hintText: 'Ваш e-mail',
                hintStyle: TextStyle(fontFamily: 'Gilroy',
                    fontStyle: FontStyle.normal,
                    color: Color(0xFFADADAD),
                    fontSize: 24
                ),
                //border: InputBorder.none,
              ),
              onSaved: (String value) {
                //this._data.email = value;
                _emailString= _userEmailController.text = value;
              }

          ),
        ),
      ],
    );
  }

  Widget buildButton(String title, String key) {
      var selected = selectedDateType == key;

      return MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          color: selected ? styles.Colors.orange : Colors.transparent,
          elevation: 0,
          child: new Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(0),
            child: Text(title,
                textAlign: TextAlign.center,
                style: selected
                    ? styles.TextStyles.whiteBoldText17
                    : styles.TextStyles.grayRegularText17),
          ),
          onPressed: () {            
            showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
          title:  Text(AppLocalizations.of(context).translate('Lang')),
          content: Text (AppLocalizations.of(context).translate('changeLang')),
        actions: [
       CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("yes"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14,)),
       onPressed:() async{
         setState(() {
           selectedDateType = key;
           if (key == 'ru') {
             var index = 0;
             setlanguage(index);
             setState(() {});
           } else if (key == 'uk') {
             var index = 1;
             setlanguage(index);
             setState(() {});
           }
         });
         exit(0);
        },),
        CupertinoDialogAction(child: Text(AppLocalizations.of(context).translate("no"),style:TextStyle(
          fontFamily: 'Gilroy',
      fontSize: 14)),
      isDefaultAction: true,
        onPressed: (){
          Navigator.pop(context);
        },)
        ]);});
          });
          }
    

  Widget _buildPhone() {
    return Stack(
      children: <Widget>[
        new Container(
          //alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 20.0, left: 30.0, bottom: 0.0),
          child: new Text('Телефон',
              textAlign: TextAlign.left,
              style: styles.TextStyles.darkText14),
        ),
        new Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 56.0, left: 30.0, right: 30.0),
          child: new Text("+${_phoneController.text}",
          style: styles.TextStyles.darkText24)
        ),
      ],
    );
  }
pop(){setState(() {
  
});}
  @override
  Widget build(BuildContext context) {

    return new WillPopScope(
      onWillPop: pop(),
      child: new Scaffold(
      backgroundColor: styles.Colors.background,
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },

        child: Stack(
          children: <Widget>[
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 55,),
                    _buildProfileImage(),
                    SizedBox(height: 30,),
                  //  _buildFacebookButton(),
                  //  SizedBox(height: 20,),
                    _buildFirstName(),
                    _buildSecondName(),
                    _buildBirthday(),
                    _buildEmail(),
                    _buildPhone(),
                    SizedBox(height: 18.0),
                    new Container(
                      alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 35.0, bottom: 8.0),
          child: new Text(AppLocalizations.of(context).translate('language'),
              textAlign: TextAlign.left,
              style: styles.TextStyles.darkText14),
        ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildButton("Русский", 'ru'),
              buildButton("Українська", 'uk'),
            ]),
            SizedBox(height: 18.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      )

    ));
  }
}