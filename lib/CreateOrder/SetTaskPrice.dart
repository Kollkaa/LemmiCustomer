import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

import 'package:mask_shifter/mask_shifter.dart';
import '../app_localizations.dart';

import 'package:kaban/Managers.dart';
import 'package:kaban/Main/CustomAppBar.dart';
import 'package:kaban/CreateOrder/CreateOrderAddressController.dart';
import 'package:kaban/Styles.dart' as styles;

class SetTaskPrice extends StatefulWidget {
  Task task;
  SetTaskPrice({Key key, this.title, this.task}) : super(key: key);
  final String title;
  @override
  _SetTaskPriceState createState() => _SetTaskPriceState();
}

class _SetTaskPriceState extends State<SetTaskPrice> {
  TextEditingController _controller = TextEditingController();

  var selectedPriceType = 'indicate_price'; 
  String price1;

  _selectAddressButtonAction() async {      
    widget.task.price = _controller.text;
    widget.task.indexToRemember = "$price1 uah.";   
     if(widget.task.price.isNotEmpty){
      widget.task.price0 = "${widget.task.price} uah.";         
    }else{
    widget.task.price0 = AppLocalizations.of(context).translate('priceNotSetted');
    widget.task.price = "0"; 
    }    
      Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => new CreateOrderAddressController(task:widget.task)),
    );
  }

  TextStyle style = TextStyle(fontFamily: 'Gilroy', fontSize: 34.0);

  void initState() {
      super.initState();
    }

  @override
  Widget build(BuildContext context) {

    final timeField = new AutoSizeTextField(
  controller: _controller,
   keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
      style: TextStyle(
        fontFamily: 'Impact',
          wordSpacing: -6.0,
          fontStyle: FontStyle.normal,
          fontSize: 108),
 
  maxLines: 1,
   decoration: new InputDecoration(
        hintText: '0000',
        border: InputBorder.none,
      ),
      inputFormatters: [
        MaskedTextInputFormatterShifter(
          maskONE: "XXXXXX",
          maskTWO: "XXXXXX",
        ),
        WhitelistingTextInputFormatter.digitsOnly
      ],
      onSubmitted: (String value) {
                            _controller.text = value;
                                                                                  
                          }
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
        onPressed: _selectAddressButtonAction);

    final buttonView = new Container(
      padding: new EdgeInsets.only(top: 0, left: 10, right: 30),
      alignment: Alignment.topRight,
      child: Column(children: <Widget>[
        new Container(
            width: 39,
            height: 39,
            child: new FloatingActionButton(
              heroTag: "plus",
              onPressed: () {
                if(_controller.text.isEmpty){
                 _controller.text ="0"; 
                }                
                int currentValue = int.parse(_controller.text);                                       
                setState(
                  () {
                    _controller.text =
                        (currentValue+ 10).toString();
                  },
                );                
              },
              foregroundColor: Color.fromRGBO(221, 98, 67, 1),
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              child: Icon(Icons.add),
            )),
        new SizedBox(height: 50),
        new Container(
          width: 39,
          height: 39,
          child: new FloatingActionButton(
              heroTag: "minus",
              onPressed: () {
                if(_controller.text.isEmpty){
                 _controller.text ="0"; 
                }
                int currentValue = int.parse(_controller.text);
                if(currentValue >= 10){                
                setState(() {
                  _controller.text =
                      (currentValue-10).toString(); // decrementing value               
                });
                }else{
                 _controller.text ="0"; 
                }
              },
              foregroundColor: Color.fromRGBO(221, 98, 67, 1),
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              child: Icon(Icons.remove)),
        )
      ]),
    );

    Widget buildButton(String title, String key) {
      var selected = selectedPriceType == key;

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
              selectedPriceType = key;
            });
          });
    }

    Widget priceTypeWidget() {
      return new Container(
          padding: EdgeInsets.only(left: 18),
          child: Row(
            children: <Widget>[
              buildButton(AppLocalizations.of(context).translate('setPrice'), 'indicate_price'),
              SizedBox(
                width: 5,
              ),
              buildButton(AppLocalizations.of(context).translate('zeroPrice'), 'free_price'),
            ],
          ));
    }

    Widget getPriceWidget() {
      if (selectedPriceType == 'free_price') {
        widget.task.price = "";
        return Container(
          height: 137,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context).translate('withoutPrice'),
              style: styles.TextStyles.darkRegularText17,
            ),
          ),
        );
      } else {
        return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 17.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new SizedBox(
                  width: 263,
                  child: timeField,
                ),
                buttonView,
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,              
              child:Text("UAH",
             style: TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.normal,
          fontSize: 36,
          letterSpacing: -1.02227)))
            ]));
      }
    }

    return Scaffold(
        backgroundColor: styles.Colors.background,
        appBar: CreateAppBar(
            height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate('titleHowMuch'),
            showAddButton: false),
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
                padding: new EdgeInsets.only(top: 0, bottom: 100),
                child: new Form(
                  child: new ListView(
                    children: <Widget>[
                      SizedBox(height: 20),
                      priceTypeWidget(),
                      SizedBox(height: 43),
                      getPriceWidget(),
                      SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).translate('ownPrice'),
                        textAlign: TextAlign.center,
                        style: styles.TextStyles.darkRegularText12),
                    SizedBox(
                      height: 10,
                    ),
                    bottomButton
                  ],
                ),
              )
            ]),
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          )),
        ])
        );
  }
// This trailing comma makes auto-formatting nicer for build methods.
}
