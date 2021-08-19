import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaban/Authentication/AuthorizationController.dart';
import '../app_localizations.dart';

import 'package:kaban/CreateOrder/CreateOrderDescriptionController.dart';
import 'package:kaban/Authentication/CheckMobileController.dart';

import 'package:kaban/Managers.dart';
import 'package:kaban/ServerManager.dart';
import 'package:kaban/Styles.dart' as styles;

class CreateOrderSelectCategoryController extends StatefulWidget {
  Task task;
  CreateOrderSelectCategoryController(this.id, this.name, {Key key, this.title, this.task}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String id;
  final String name;

  @override
  _CreateOrderSelectCategoryControllerState createState() =>
      _CreateOrderSelectCategoryControllerState();
}

class _CreateOrderSelectCategoryControllerState
  extends State<CreateOrderSelectCategoryController> {
    
  void initState() {
  _authentication();
  buildCategoryById();
    super.initState();
  }

  TextEditingController editingController = TextEditingController();
  List<Category1> _categoryList =[];
  Task task= new Task();
  String categoryName;
  String name;
  String id;
  var items = List<Map<String, String>>();
  List<Map<String, String>> duplicateItems = [];
  bool autorisated = false;


  _authorizationButtonAction() async {  
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new AuthorizationController(ScreenType.registrationType)),
    );
  }

  void _authentication() async{
     //  String token = sharedPreferences.getString("token").toString();
    //bool autorisated = false;
    final storage = new FlutterSecureStorage();
    String token = null;
    var tok = await storage.read(key: 'token').whenComplete(() {
      autorisated = true;
    }).then((val) {
      if (val == null || val.isEmpty) {
        autorisated = false;
      }else{
        autorisated = true;
        token = val;
      }
    });

    if (tok != null && token == null) {
      token = tok;
    }
      //print("token = $token");

    if (autorisated == true) {

      if (token == null || token.isEmpty) {

      }else{//if registered and log in 

        //print("token = " + token);


      }
    }else{
    
    }
  }

  void selectCategory() {  
   Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => CreateOrderDescriptionController( task:task))); 
  }
  
  buildCategoryById() async {
    WidgetsBinding.instance.addPostFrameCallback((_)async{
    String id= widget.id;
    await ServerManager(context).getSpecialistsIdRequest(id, (result) {        

        for(int i = 0; i < result.length; i++){         
          Map<String, dynamic> element = result.elementAt(i);            
          _categoryList.add(Category1("${result.elementAt(i)['name']}","${result.elementAt(i)['serviceId']}" ));
          duplicateItems.add({"title":"${element['name']}","specialist":"Специалист","id":"${element['serviceId']}"});      
        } 
        items.addAll(duplicateItems);  
        setState(() {});      
    }, (error){});
  });
  }

  void filterSearchResults(String query) {    
    List<Map<String, String>> dummySearchList = List<Map<String, String>>();
    dummySearchList.addAll(duplicateItems);
    if(query.isNotEmpty) { 
     List<Map<String, String>> dummyListData = List<Map<String, String>>();
     dummySearchList.forEach((item) {
        if(item["specialist"].contains(query.toLowerCase())) {
          dummyListData.add(item);
        }else {
          if(item["title"].toLowerCase().contains(query.toLowerCase())) {
            dummyListData.add(item);
          }
        }
      });    
      setState(() {
      items.clear();
      items.addAll(dummyListData); 
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {  
    Widget _builCategoryList() { 
    return

      ListView.separated(
        itemBuilder: (context, index) {
          return ListTile(
              trailing: Image(image:
              AssetImage('assets/arrow_next_orange.png'),
          width: 15,
          height: 15,
          ),
          contentPadding: EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 0),
          title: Text('${items[index]["title"]}'),
            onTap: () {
            if(autorisated == true){
              selectCategory();  
              }else{
               _authorizationButtonAction();
              }            
            task.category = "${items[index]['title']}";
            task.services_id = "${items[index]['id']}";
            task.globalCategory = widget.id;
            task.published = false;
            },
          );
        },
        separatorBuilder: (context, index) => Divider(
          color: styles.Colors.orangeTrans,
          height: 1,
          indent: 30,
          endIndent: 30,
        ),
        itemCount: items.length,
        padding: EdgeInsets.only(bottom: 100),
      );
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: styles.Colors.background,
        appBar: TitleAppBar(
          titleAppBar: "${widget.name}",
          textField: TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: editingController,
            style: TextStyle(fontFamily: 'Roboto-Regular',
                fontStyle: FontStyle.normal,
                fontSize: 18,
                color: Color.fromRGBO(51, 51, 51, 1.0)
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('subName'),
                
                prefixIcon: Icon(Icons.search,
                color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),),  
                border: UnderlineInputBorder(
                )
            ),
          ),
        ),
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              
            },
            child: _builCategoryList()
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleAppBar;
  final TextField textField;

  const TitleAppBar({
    Key key,
    @required this.titleAppBar,
    @required this.textField,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () async => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: 44,
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
        Text(
          titleAppBar,
          style: styles.TextStyles.darkText24,
        ),
        Align(alignment: Alignment.bottomCenter,
          child:textField)
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120);
}
