import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaban/Authentication/AuthorizationController.dart';
import 'package:kaban/Authentication/CheckMobileController.dart';
import 'package:kaban/Main/FakeMainController.dart';
import '../Styles.dart' as styles;
import '../app_localizations.dart';

class PlugView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PlugViewState();
  }

}
class PlugViewState extends State<PlugView>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: styles.Colors.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 32,vertical: 16),
                    height: 155,
                    child: SvgPicture.asset("assets/LemmiLogo.svg"),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 56),
                    child: Text(AppLocalizations.of(context).translate('plug_text'),
                      textAlign: TextAlign.center,
                      style: styles.TextStyles.darkRegularText14.copyWith(fontSize: 17),maxLines: 2,),
                  )
                ],
              ),
            )
          ),

          Container(
            margin: EdgeInsets.only(left: 20,right: 20,),
            child: FlatButton(
              padding: EdgeInsets.all(0),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                    color: Color(0xffFF4C00),
                    borderRadius: BorderRadius.circular(51)
                ),
                child: Center(
                  child: Text(AppLocalizations.of(context).translate('registration'),
                      textAlign: TextAlign.center,
                      style: styles.TextStyles.sFProTextPrimary.copyWith(color: Colors.white)),
                ),
              ),
              onPressed: (){
                Navigator.of(context).pushNamed("submit_code");
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24,vertical: 8),
            child: FlatButton(
              padding: EdgeInsets.all(0),
              child: Container(
                height: 56,

                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Уже есть аккаунт?  ",
                          textAlign: TextAlign.center,
                          style: styles.TextStyles.sFProText.copyWith(color: Colors.black)
                      ),
                      Text("Войдите",
                          textAlign: TextAlign.center,
                          style: styles.TextStyles.sFProText.copyWith(color: Color(0xffFF4C00))
                      ),
                    ],
                  )
                ),
              ),
              onPressed: (){
                _fakeroute();
              },
            ),
          ),
        ],
      ),
    );
  }
  _fakeroute() async {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => new AuthorizationController(ScreenType.registrationType)));
  }
}