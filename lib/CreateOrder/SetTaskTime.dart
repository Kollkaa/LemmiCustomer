import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import '../Widgets.dart';
import '../app_localizations.dart';
import 'package:mask_shifter/mask_shifter.dart';

import 'package:kaban/CreateOrder/SetTaskPrice.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/Managers.dart';
import 'package:kaban/Styles.dart' as styles;

class SetTaskTime extends StatefulWidget {
  final Task task;
  SetTaskTime({Key key, this.title, this.task}) : super(key: key);

  final String title;

  @override
  _SetTaskTimeState createState() => _SetTaskTimeState();
}

class _SetTaskTimeState extends State<SetTaskTime> {
  TextEditingController _timeController = TextEditingController();
   
  var selectDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  DateTime _selectedTime;
  var selectedDateType = 'today';
  bool selected =false;
  bool choosed = false;
  var minutes;
  var hours;

  void initState() {
    var i = DateTime.now().minute;
    if   (i > 0 && i<= 15){minutes = 15; hours = DateTime.now();}
    else if(i > 15 && i <= 30 ){minutes = 30; hours = DateTime.now();}
    else if(i > 30 && i <= 45 ){minutes = 45; hours = DateTime.now();}
    else {minutes = 00; hours = DateTime.now().add(Duration(hours: 1));}

    _selectedTime = DateFormat("HH:mm").parse(
      "${DateFormat("HH").format(hours)}:$minutes");
    super.initState();
  }  

  _registrationButtonAction() async {
    setState(() {
      
    });
    var selectTime =_timeController.text ;
    widget.task.data = "$selectDate $selectTime";    
    widget.task.hours = "$selectTime";
    widget.task.day = "$_selectedDate";
    var checkDate = DateTime.parse(widget.task.data);
    if(checkDate.isAfter(DateTime.now())){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => new SetTaskPrice(task:widget.task)),
    );
    }else{
      Dialogs().alert(context, AppLocalizations.of(context).translate('error'), AppLocalizations.of(context).translate('validDate'));
    }
  
  }

  TextStyle style = TextStyle(fontFamily: 'Roboto', fontSize: 36.0);

  var _selectedDate = DateFormat("dd.MM.yyyy").format(DateTime.now());
  

  

  DateTime _currentdate = new DateTime.now();

  Future<Null> _selectdate(BuildContext context) async {
    final DateTime _seldate = await showDatePicker(
        context: context,
        locale: const Locale('ru'),
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2050),        
        builder: (context, child) {
          return Container(
              height: 437 + MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.only(
                //  top: MediaQuery.of(context).size.height - (417 + MediaQuery.of(context).padding.bottom),
                bottom: 0,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                //child: ListView(
                //physics: NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      height: 197,
                      child: CupertinoDatePicker(
                        backgroundColor: Colors.white,
                        initialDateTime: DateTime.now().add(Duration(days: 2)),
                        mode: CupertinoDatePickerMode.date,
                        minimumDate: DateTime.now().add(Duration(hours: 1)),
                        maximumDate: DateTime.now().add(Duration(days: 500)),
                        onDateTimeChanged: (DateTime value) {
                          _selectedDate =
                              new DateFormat("dd.MM.yyyy").format(value);
                          selectDate = 
                              new DateFormat("yyyy-MM-dd").format(value); 
                          choosed = true; 
                        },
                      ),
                      padding: EdgeInsets.only(top: 0),
                    ),
                    Container(
                      color: Colors.white,
                      height: 130,
                      padding: EdgeInsets.only(
                          left: 30, right: 30, bottom: 40, top: 40),
                      child: MaterialButton(
                          padding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          color: Color(0xFFFF4C00),
                          child: new Container(
                            height: 50,
                            width: double.infinity,
                            //375,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(bottom: 0),
                            // color: Colors.red,
                            child: Text(AppLocalizations.of(context).translate('select'),
                                textAlign: TextAlign.center,
                                style: styles.TextStyles.whiteText18),
                          ),
                          onPressed: () {
                            setState(() {
                            if(choosed == false){
                              _selectedDate =
                              new DateFormat("dd.MM.yyyy").format(DateTime.now().add(Duration(days:2)));
                              selectDate = 
                              new DateFormat("yyyy-MM-dd").format(DateTime.now().add(Duration(days:2)));
                            }else{}
                              Navigator.of(context).pop();
                              choosed = false;
                            });
                          }),
                      alignment: Alignment.bottomCenter,
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom)
                  ],
                ),
              ));
        });
    if (_seldate != null) {
      setState(() {
        _selectedDate = new DateFormat.yMd().format(_seldate);        
        //print(_selectedDate);
        //_currentdate = _seldate;
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final DateTime _seltime = await showDatePicker(
        context: context,
        initialDate: DateFormat("HH:mm").parse(
            "${DateFormat("HH").format(hours)}:$minutes"),
        firstDate: DateFormat("HH:mm").parse(
            "${DateFormat("HH").format(hours)}:$minutes"),
        lastDate: DateTime(2050),
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Container(
                height: 197,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  minimumDate: _selectedDate ==
                    new DateFormat("dd.MM.yyyy").format(_currentdate)
                  ? DateFormat("HH:mm").parse(
                      "${DateFormat("HH").format(hours)}:$minutes")
                  :null,
                  initialDateTime: DateFormat("HH:mm").parse(
                      "${DateFormat("HH").format(hours)}:$minutes"),                  
                 // minimumDate:DateTime.now().add(Duration(hours: 1)),                  
                 // maximumDate:DateTime.now().add(Duration(days: 500)),                  
                  minuteInterval: 15,
                  backgroundColor: Colors.white,
                  onDateTimeChanged: (DateTime value) {
                    _selectedTime = value;
                    selected = true;
                  },
                ),
                padding: EdgeInsets.only(top: 0),
              ),
              Container(
                color: Colors.white,
                height: 110,//130
                padding: EdgeInsets.only(
                    left: 30, right: 30, bottom: 40, top: 20),//bottom:40,top:40),
                child: MaterialButton(
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10))),
                    color: Color(0xFFFF4C00),
                    child: new Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(bottom: 0),                      
                      child: Text(AppLocalizations.of(context).translate('select'),
                          textAlign: TextAlign.center,
                          style: styles.TextStyles.whiteText18),
                    ),
                    onPressed: () {
                      setState(() {
                        // if nothing is selected, remember initial pikers' time                        
                        if(selected == false){
                        _selectedTime = DateFormat("HH:mm").parse(
                          "${DateFormat("HH").format(new DateTime.now())}:00");
                        _timeController.text = DateFormat("HH:mm").format(_selectedTime);//rewrite the text                        
                        }else{}
                      Navigator.of(context).pop();
                      selected = false;//for next changes
                      });
                    }),
                alignment: Alignment.bottomCenter,
              ),
              SizedBox(
                  height: MediaQuery.of(context).padding.bottom)
            ],
          );
        });
    if (_seltime != null) {
      setState(() {
        //print(_seltime);

        _selectedTime = _seltime;
      });
    }
  }

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay picked;

  Future<Null> selectTime(BuildContext context) async {
    picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    setState(() {
      _time = picked;
      //print(_time);
    });
  }


  @override
  Widget build(BuildContext context) {
    //bool pressed = false;
    //var _value = "$_currentdate"; //variable to save

    _timeController.text = DateFormat("HH:mm").format(_selectedTime);

    final timeField = new TextFormField(
      readOnly: true,
      controller: _timeController,
      keyboardType:
          TextInputType.numberWithOptions(decimal: false, signed: false),
      style: TextStyle(
          fontFamily: 'Impact',
          wordSpacing: -6.0,
          fontStyle: FontStyle.normal,
          fontSize: 108),
      decoration: new InputDecoration(
        hintText: '20:00',
        border: InputBorder.none,
      ),
      inputFormatters: [
        MaskedTextInputFormatterShifter(
          maskONE: "XX:XX",
          maskTWO: "XX:XX",
        ),
      ],
      onTap: () {
        _selectTime(context);
      },
    );

    final bottomButton = new MaterialButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        color: styles.Colors.orange,
        child: new Container(
          height: 50,
          width: double.infinity,
          //375,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 0),
          // color: Colors.red,
          child: Text(AppLocalizations.of(context).translate('continue'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Colors.white)),
        ),
        onPressed: _registrationButtonAction);

    final buttonView = new Container(
      padding: new EdgeInsets.only(top: 10, left: 10),
      alignment: Alignment.topRight,
      child: Column(children: <Widget>[
        new Container(
            width: 39,
            height: 39,
            child: new FloatingActionButton(
              heroTag: "plus",
              onPressed: () {
                setState(
                  () {
                    _selectedTime = _selectedTime.add(Duration(minutes: 15));

                    _timeController.text =
                        DateFormat("HH:mm").format(_selectedTime);
                  },
                );
              },
              foregroundColor: Color.fromRGBO(221, 98, 67, 1),
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              child: Icon(Icons.add),
              tooltip: "Increment",
            )),
        new SizedBox(height: 50),
        new Container(
          width: 39,
          height: 39,
          child: new FloatingActionButton(
              heroTag: "minus",
              onPressed: () {
                setState(
                  () {
                    _selectedTime = _selectedTime.add(Duration(minutes: -15));
                    _timeController.text =
                        DateFormat("HH:mm").format(_selectedTime);
                  },
                );
              },
              tooltip: "Decrement",
              foregroundColor: Color.fromRGBO(221, 98, 67, 1),
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              child: Icon(Icons.remove)),
        )
      ]),
    );

    Widget buildButton(String title, String key) {
      var selected = selectedDateType == key;

      if (key == 'other' && selected == true) {
        title = _selectedDate;
      }

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
            setState(() {
              selectedDateType = key;

              if (key == 'today') {
                _selectedDate =
                    new DateFormat("dd.MM.yyyy").format(_currentdate);
                selectDate =  new DateFormat("yyyy-MM-dd").format(_currentdate);
              } else if (key == 'tomorrow') {
                _selectedDate = new DateFormat("dd.MM.yyyy")
                    .format(_currentdate.add(Duration(days: 1)));
                selectDate = new DateFormat("yyyy-MM-dd")
                    .format(_currentdate.add(Duration(days: 1)));    
              } else if (key == 'other') {
                _selectdate(context);
              }
              //print(_selectedDate);
            });
          });
    }

    Widget buttonDateWidget() {
      return new Container(
          padding: EdgeInsets.only(left: 15),
          child: Row(
            children: <Widget>[
              buildButton(AppLocalizations.of(context).translate('today'), 'today'),
              SizedBox(
                width: 5,
              ),
              buildButton(AppLocalizations.of(context).translate('tomorrow'), 'tomorrow'),
              SizedBox(
                width: 5,
              ),
              buildButton(AppLocalizations.of(context).translate('chooseDate'), 'other'),
            ],
          ));
    }

    //     );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        backgroundColor: styles.Colors.background,
        appBar: CreateAppBar(
            height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate('titleWhen'),
            showAddButton: false),
//      bottomSheet: Container(
//        width: double.infinity,
//        height: 50,
//        child: bottomButton,
//      ),

        //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        body: Stack(children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).padding.bottom,
              color: styles.Colors.orange,
            ),
          ),
          SafeArea(
              child: GestureDetector(
            child: Stack(children: <Widget>[
              Container(
                padding: new EdgeInsets.only(top: 20, bottom: 0),
                child: new Form(
                  child: new ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      //  Text(_dateTime == null ? 'Nothing': _dateTime.toString()),
                      buttonDateWidget(),
                      new Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          left: 17.0,
                        ),
                        child: new Row(children: <Widget>[
                          new SizedBox(
                            width: 267,
                            child: timeField,
                          ),
                          buttonView
                        ]),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[bottomButton],
                ),
              )
            ]),
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          )),
        ])

        /*new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: new Container(
          padding: new EdgeInsets.only(top: 20, bottom: 0),
          child: new Form(
            child: new ListView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                //  Text(_dateTime == null ? 'Nothing': _dateTime.toString()),
                buttonDateWidget(),
                new Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    left: 17.0,
                  ),
                  child: new Row(children: <Widget>[
                    new SizedBox(
                      width: 263,
                      child: timeField,

                    ),
                    buttonView
                  ]),
                )
              ],
            ),
          ),
        ),
      ),*/
        );
// This trailing comma makes auto-formatting nicer for build methods.
  }
}
