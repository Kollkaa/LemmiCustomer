import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Styles.dart' as styles;
import 'package:url_launcher/url_launcher.dart';

class SupportController extends StatefulWidget {
  SupportController({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  final String title;

  @override
  _SupportControllerState createState() => _SupportControllerState();
}
class Categories {
  int id;
  String name;
  Categories(this.id, this.name);
  static List<Categories> getCategories(){
    return<Categories>[
      Categories(1, 'Автоэксперты'),
      Categories(2, 'Благоустройство территории'),
      Categories(3, 'Бурение скважин'),
      Categories(4, 'Бытовая техника'),
      Categories(5, 'Вентиляция и кондиционеры'),
      Categories(6, 'Водители'),
      Categories(7, 'Возведение стен и перегородок'),
      Categories(8, 'Вывоз мусора'),
      Categories(9, 'Высотные работы'),
      Categories(10, 'Грузоперевозки'),
      Categories(11, 'Двери'),
      Categories(12, 'Демонтаж сооружений'), 

    ];
  }
}
class _SupportControllerState extends State<SupportController> {
  List<Categories> _categories = Categories.getCategories();
  List<DropdownMenuItem<Categories>> _dropdownMenuItems;
  Categories _selectedCategory;
  String url;
  bool selected= false;
  
  final _taskTitleController = TextEditingController();

  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_categories);
    _selectedCategory = _dropdownMenuItems[0].value;
    super.initState();

  }
  List<DropdownMenuItem<Categories>> buildDropdownMenuItems(List categories){
    List<DropdownMenuItem<Categories>> items = List();
    for(Categories category in categories){
     items.add(DropdownMenuItem(value: category,child:Text(category.name),)); 
    }
    return items;
  }
  onChangeDropdownItem(Categories selectedCategory){
    setState(() {
      _selectedCategory = selectedCategory;
    });
  }
  _mailChat() async {
    url ='mailto:kaban@email.com?subject=test%20subject&body=test%20body';
      await launch(url);
  }

  _telegramChat() async {
    url ='https://t.me/Kabanprog';
      await launch(url);
  }

  _phoneChat() async {
    //url ="tel:+380970000000";
    url ="whatsapp://send?phone=+380970000000";
    await launch(url);
  }

  Future<void> _selectedTask(BuildContext context) async {
    var task = await showCupertinoModalPopup(
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
                child: Text('Отмена',style: TextStyle( color:Color.fromRGBO(255, 178, 158, 1.0)),),
                onPressed: () {
                  _taskTitleController.text = '';
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
                   _taskTitleController.text = _categories[0].name.toString(); 
                  }
                  selected= false;
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
            itemExtent: 50,
            backgroundColor: Colors.white,
            children: List<Widget>.generate(_categories.length, (index){
              return Center(
                child: Text(_categories[index].name),
              );
            }),
            looping: true, onSelectedItemChanged: (value) {
              _taskTitleController.text = _categories[value].name.toString();
              selected = true;
            },
            /* the rest of the picker */
          ),
        )
      ],
    );
  },
);
  }

  @override
  Widget build(BuildContext context) {
  
  Widget _builComment() {
  return new ListView(
  padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
    children: <Widget>[
      new Column(
        children: <Widget>[
           Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectedTask(context),
                        child: AbsorbPointer(
                        child: TextFormField(
                        controller: _taskTitleController,
                        maxLines: null,
                          style: styles.TextStyles.darkText24,
                          decoration: new InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Название заказа',
                            hintStyle: TextStyle(fontFamily: 'Gilroy',
                                fontStyle: FontStyle.normal,
                                color: Color(0X99FFB29E),
                                letterSpacing: -0.146769,
                                fontSize: 18,
                            ),
                          ),
                        ),
                        ),
                      ),
                    ),                   
                  ],                    
                ),
            Container(            
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: Color(0XFFFFB29E),
          ),
        ],
      ),
          new Stack(
            children: <Widget>[
              new Container(
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: styles.TextStyles.darkRegularText18,
                  decoration: new InputDecoration(
                    hintText: 'Ваш комментарий',
                    hintStyle: TextStyle(
                      fontFamily: 'Gilroy',
                        fontStyle: FontStyle.normal,
                        color: Color(0X99FFB29E),
                        letterSpacing:-0.146769,
                        fontSize: 18
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          Container(            
              alignment: Alignment.bottomLeft,
              height: 1,
              padding: EdgeInsets.only(right: 30, left: 30, bottom: 0),
              color: Color(0XFFFFB29E),
          ),
            Container(
              padding: EdgeInsets.only(right: 30, left: 30, top: 30) ,
               child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Container(
            width: 38,
            height: 38,
        child: FloatingActionButton(         
          elevation: 0,
          foregroundColor: Color.fromRGBO(225,178,158,1),
          backgroundColor: Color.fromRGBO(225,255,255,1),
          child: Image(image:
              AssetImage('assets/phone_icon.png'),
               width: 39,
              height: 39,),
              onPressed: (){
                _phoneChat();
              },
              ),),
              new Container(width: 38,
            height: 38,
          child: FloatingActionButton(
            elevation: 0,
            foregroundColor: Color.fromRGBO(221,98,67,1),
            backgroundColor: Color.fromRGBO(225,255,255,1),
          child: Image(image:
              AssetImage('assets/comment_orange_icon.png'),
               width: 39,
              height: 39,),
            onPressed: (){
              _telegramChat();
            }),),
           new Container(width: 38,
            height: 38, child: FloatingActionButton(
            elevation: 0,
             foregroundColor: Color.fromRGBO(225,178,158,1),
             backgroundColor: Color.fromRGBO(225,255,255,1),
          child: Image(image:
              AssetImage('assets/mail_icon.png'),
               width: 39,
              height: 39,),
            onPressed: (){
              _mailChat();
            }),), 
        ],
      ))
            ],
      );
    }
     final bottomButton = new MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,//375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          // color: Colors.red,
          child: Text('Отправить',
              textAlign: TextAlign.center,
              style: styles.TextStyles.whiteText18),

        ),
        onPressed: (){}
      //  _selectAddressButtonAction
    );

     // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: styles.Colors.background,
        appBar: CreateAppBar(height: 118,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: "Техническая поддержка",
            showAddButton: false),
             bottomSheet: Container(
          width: double.infinity,
          height: 50,
          child: bottomButton,
        ),

        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              }
              ,
              child: _builComment(),
                          //  child: Container(
           //   padding: new EdgeInsets.only(top: 20, bottom: 0),
            //  child: new Form(
            //    child: new ListView(
            //      physics: NeverScrollableScrollPhysics(),
            //      children: <Widget>[
            //        _builComment(),
                 //   _contactButton()
          //       ]
                 ));
  //  )
  //      )
 //   );
  
  }
}
