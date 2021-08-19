import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaban/ServerManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/CreateOrder/SetTaskTime.dart';

import 'package:kaban/Styles.dart' as styles;
import '../Managers.dart';
import '../app_localizations.dart';

class CreateOrderDescriptionController extends StatefulWidget {
 final Task task;
 CreateOrderDescriptionController({Key key, this.task}) : super(key: key);

  @override
  _CreateOrderDescriptionControllerState createState() => _CreateOrderDescriptionControllerState();
}

class _CreateOrderDescriptionControllerState extends State<CreateOrderDescriptionController> {
  Dio dio = new Dio();
  var file;
  var editIndex = 0;
  File _file;
  File _image;
  final  _descriptionController = TextEditingController(); 
  List<Future<File>> selectedImage = []; 
  String imagepath="";
  String base64Image;  
  String token;
  SharedPreferences sharedPreferences;  

  void initState() {    
    super.initState();
    getSubItems();
  }
  var subItems = [];

  getSubItems() {
  

    WidgetsBinding.instance.addPostFrameCallback((_)async{
    var id = widget.task.services_id;
    
    await ServerManager(context).getSubServicesRequest(id, (result) {        
        for( int i = 0; i <result.length; i++){
          Map<String, dynamic> subElement = result.elementAt(i);
          subItems.add({'title':'${subElement['name']}', 'id':'${subElement['underServiceId']}', 'send': false}); 
        }
        setState(() {});      
    }, (error){});
  });  
  }
  
  _rememberSub(value){
    widget.task.subCategoryId.add("$value");    
    setState(() {
      print(widget.task.subCategoryId);
    });
  }

  void _selectTimeAction() {   
    String description = _descriptionController.text;
    widget.task.description = description;
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => new SetTaskTime(task:widget.task
         ))
    );
  }

   getImageGallery() async {
    Navigator.pop(context);
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 25,  maxWidth: 1000);
    setState(() {
      _image = imageFile;
      uploadImage(imageFile);
      widget.task.images.add("${_image.path}");
    });
  }

  getImageCamera() async {
    Navigator.pop(context);
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera,  imageQuality: 25, maxWidth: 1000);
    setState(() {
      _image = imageFile;      
      uploadImage(imageFile);
      widget.task.images.add("${_image.path}");
    });
  }

  getJWTToken() async {

    if (sharedPreferences == null) {

      sharedPreferences = await SharedPreferences.getInstance();
    }

    token = sharedPreferences.getString("token").toString();
  }

  void uploadImage(File _image ) async {

  String fileName = /*"img.jpeg";*/_image.path.split('/').last;

  FormData formData = FormData.fromMap({
  "photo":
      await MultipartFile.fromFile(_image.path, filename:fileName),
  });

    await getJWTToken();

    await dio.post("https://api.lemmi.app/api/activity-task/save-photo", data: formData,
    options: Options(headers: {
           "Authorization": "Bearer $token",
           "Content-Type": "multipart/form-data"
         })).then((response) {
           print("data = ${response}");

      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {       

        selectedImage.add(Future.value(_image));
         setState(() {           
         });

        var code = "${response.data["result"]}";
                
        widget.task.indexToRemember= "";
        for(int z= 1; z<code.length-1; z++ ){
           widget.task.indexToRemember = widget.task.indexToRemember + code[z].toString();         
        }        
        widget.task.photo.add('${widget.task.indexToRemember}');
        }else{
        print("response = ${response}");
      }
    });
    
  }

  pickImageFromGallery(ImageSource source) {
    setState(()  {
       var action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text( AppLocalizations.of(context).translate('cup_photo'),),
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
  
  @override
  Widget build(BuildContext context) {
    final bottomButton = new MaterialButton(
      elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,//375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          // color: Colors.red,
          child: Text(AppLocalizations.of(context).translate('continue'),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Gilroy',
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Colors.white
              )),

        ),
        onPressed: _selectTimeAction
    );

    Widget showImage(Future<File> fileImage, bool editMode) {
      return FutureBuilder<File>(
        future: fileImage,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {

            if (editMode) {              
              var imageWidget = Image.file(
                snapshot.data,
                //width: 224,
                height: 200,
                fit: BoxFit.fitWidth,
              );

              return 
               Container(
                height: 200,
                width: imageWidget.width,
               
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: imageWidget
              );

            }else{

              return Container(
                
              child:Image.file(
                snapshot.data,
                //width: 224,
                height: 200,
                fit: BoxFit.fitWidth,
              ));
            }

          } else if (snapshot.error != null) {
            return const Text(
              'Error Picking Image',
              textAlign: TextAlign.center,
            );
          } else {
            return Container(
              width: 100,        
              child: new Center(child: const CupertinoActivityIndicator(radius: 15.0)));
              //Text(
              //'No Image Selected',
              //textAlign: TextAlign.center,
            //);
          }
        },
      );
    }


    Widget buildPhoto(int index) {
      if (index >= selectedImage.length) {
        return null;
      }
      print('Loading photo[${index}]: ${selectedImage[index]}... done');

      return new Card(
        child: new Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
          ),
            height: 200,
            //width: 224,
            child: showImage(selectedImage[index], index == editIndex),
            
          //  child: GestureDetector (
          //    child: showImage(selectedImage[index], index == null),
          //    onLongPress: (){
          //    setState(() {
          //     showImage(selectedImage[index], index == editIndex); 
          //    });}
          //    )
        ),
      );
    }
    

 
    Widget buildPhotoList() {
      return selectedImage.length == 0
      ? Container()
      : Row (children: <Widget>[
      Expanded(child:Container(
        padding: EdgeInsets.only(top: 30),
        height: 250,
       // color: Colors.red,
        child: new ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: selectedImage.length,
          itemBuilder: (BuildContext context, int index) {
           return Stack(children: <Widget>[
             buildPhoto(index),

             GestureDetector(
              child:  Image.asset('assets/cancel_image.png', height: 25, width: 25),
             onTap: (){
              setState(() {                           
                selectedImage.removeAt(index);
                widget.task.photo.removeAt(index);
                widget.task.images.removeAt(index);
                print("${widget.task.photo}");
                print("${widget.task.images}");
                         });
             },
             
           )]); 
          }
          
          // => buildPhoto(index),
        ),
      ))]);
    }

     Widget _buildSubName(){
      return Container(
       padding:EdgeInsets.fromLTRB(0,15,0,0),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.start,
         children: <Widget>[
           Center(
             child: Text(
               widget.task.category, style:styles.TextStyles.darkGText18,
               textAlign:TextAlign.center),
           ),SizedBox(height: 10,),
           Container(
              height: 1,
              width: (MediaQuery.of(context).size.width - 60),
              color: Color(0x88ADADAD)), 
         ],
       ),
      );
    }
   
    Widget _builDescription() {
      return new ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(30, 10, 0, 20),
        children: <Widget>[

          new Stack(
            children: <Widget>[
              
              new Container(
                child: TextFormField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  autofocus: true,
                  maxLines: null,
                  style: TextStyle(fontFamily: 'Gilroy',
                        fontStyle: FontStyle.normal,
                        color: styles.Colors.black,
                        fontSize: 18
                    ),
                  decoration: new InputDecoration(
                    hintText: AppLocalizations.of(context).translate('hintTellHere'),
                    hintStyle: TextStyle(fontFamily: 'Gilroy',
                        fontStyle: FontStyle.normal,
                        color: styles.Colors.darkTextPlaceholder,
                        fontSize: 18
                    ),
                    border: InputBorder.none,
                  ),
                  onSaved: (String value) {
                            _descriptionController.text = value;                                                       
                          }
                ),
                padding: EdgeInsets.only(right: 75, top: 18),
                alignment: Alignment.topLeft,
              ),

              new Container(
                padding: EdgeInsets.only(right: 26, top: 12),

                child: new Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: ()  {  
                      FocusScope.of(context).requestFocus(new FocusNode());                        
                      pickImageFromGallery(ImageSource.gallery);
                      },
                    child: Container(
                    width: 46.0,
                    height: 46.0,
                    child: Center(                          
                          child: Image(image: AssetImage('assets/add_photo.png')
                          ),
                        )
                    ),
                   // decoration: BoxDecoration(
                    //  image: DecorationImage(
                    //    image: AssetImage('assets/add_photo.png'),
                    //    fit: BoxFit.cover,
                    //  ),
                      //borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                ),
            //  )



            ],
          ), 
              Divider(
              color: Color(0XFFADADAD),
              endIndent: 30,
              height: 1,),
          
          buildPhotoList(),
          ListView.separated(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index){
              return ListTile(
               contentPadding: EdgeInsets.only( right: 30, top: 0, bottom: 0),
               trailing: new InkWell( 
              onTap: (){
                if(subItems[index]['send'] == true){
                   subItems[index]['send'] = false;
                  setState(() {
                  });
                  widget.task.subCategoryId.remove("${subItems[index]['id']}");
                  widget.task.subCategory.forEach((element) {
                    if(element['id'] == "${subItems[index]['id']}"){
                    widget.task.subCategory.remove(element);
                    }
                  });                  
                } else{           
                subItems[index]['send'] = true;
                widget.task.subCategory.add({'id':'${subItems[index]['id']}', 'title':'${subItems[index]['title']}'});                
                _rememberSub(subItems[index]['id']);                
                }               
              },
              child: Image(
              image: 
                    subItems[index]['send'] == true
                  ? AssetImage('assets/check_green_icon.png')
                  : AssetImage('assets/check_orange_ic.png'),
              width: 28.3,
              height: 28.3,
            ),),
               title: Text('${subItems[index]['title']}',
               style: TextStyle(fontFamily: 'Gilroy',
                        fontStyle: FontStyle.normal,
                        color: styles.Colors.darkTextPlaceholder,
                        fontSize: 18
                    ))
              );
            }, separatorBuilder: (context, index) => Divider(
              color: Color(0XFFADADAD),
              endIndent: 30,
              height: 1,
            ),itemCount: subItems.length),
            SizedBox(height: 44,)

        ],
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
        appBar: CreateAppBar(height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: widget.task.category,//"Что нужно сделать",
            showAddButton: false),

        body: /*Stack(children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.bottom,
              color: styles.Colors.orange,
            ),
          ),*/
          SafeArea(
              child: GestureDetector(
                child: Stack(children: <Widget>[
                  //Column(children: <Widget>[
                  //  _buildSubName(),
                    _builDescription(),
                  //],),
                  
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        bottomButton
                      ],
                    ),
                  )
                ]),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
              )
         ),
       // ])



      /*new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: _builDescription(),
        )*/

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  
}

