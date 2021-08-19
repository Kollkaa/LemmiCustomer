
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:kaban/Main/CustomAppBar.dart';
import '../app_localizations.dart';
import 'package:kaban/Styles.dart' as styles;

class ContactsPage extends StatefulWidget {
  
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  TextEditingController editingController = TextEditingController();
  Iterable<Contact> _contacts;
  Iterable<Item> phones = [];
  String phoneNumber;
bool send= false;
  //StreamSubscription _eventSub;
String text = '';
  String subject = '';
  @override
  void initState() {
    getContacts();
    super.initState();
    //refreshContacts();

    }
    String message = "Приглашение на установку приложения https://www.kaban.com/invites/contact";
    _sendsms() async {
       if(Platform.isAndroid){
        //FOR Android
       String url ='sms:$phoneNumber?body=$message';
        await launch(url);
    } 
    else if(Platform.isIOS){
        //FOR IOS
      String  url ='sms:$phoneNumber&body=$message';
        await launch(url);
    }
    }

    getProgressDialog() {
    return new Container(
        decoration: const BoxDecoration(        
        ),
        child: new Center(child: const CupertinoActivityIndicator(radius: 15.0)));
  }
  
    refreshContacts() async {

    if (editingController.text == '') {

      var contactsFull = await ContactsService.getContacts();
      setState(() {
        _contacts = contactsFull;
      });

    }else{

      var contacts = await ContactsService.getContacts(query: '${editingController.text}');
      setState(() {
        _contacts = contacts;
      });
    }

  }


   @override
  dispose() {

    super.dispose();
  }



  String getPhone(Iterable<Item> phonesList)  {

    if (phonesList.length >= 1) {

      return phonesList.first.value ?? "";

    }

//    phones?.first?.value ?? ""

    return "";
  }

  Future<void> getContacts() async {
    //We already have permissions for contact when we get to this page, so we
    // are now just retrieving it

    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts =contacts;
    });
    }

    Future<void> share() async {
    await FlutterShare.share(
      title: 'Invite',
      text: 'Your invite link to Lemmi',
      linkUrl: 'https://lemmi.app/',
      chooserTitle: AppLocalizations.of(context).translate('choose')
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: styles.Colors.background,
      appBar: SearchAppBar(textField: TextField(
            controller: editingController,
            onChanged:
            (String value) async {
            //if(value.isNotEmpty){
              return refreshContacts();
             //}
             },

            style: TextStyle(fontFamily: 'Gilroy',
                fontStyle: FontStyle.normal,
                fontSize: 16,
                color: Color(0xFFA8A8A8),
            ),
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('hintContact'),
                prefixIcon: Icon(Icons.search,
                color: Colors.grey,),
                focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),),                 
                border: UnderlineInputBorder(
                )
            ),
          ),
            height: 118.1,
            topConstraint: MediaQuery.of(context).padding.top,
            titleAppBar: AppLocalizations.of(context).translate('titleContact'),
        ),
      body: _contacts != null
          //Build a list view of all contacts, displaying their avatar and
          // display name
          ? ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 20),
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {

                Contact contact = _contacts?.elementAt(index);

                return Card(
              shadowColor: Color.fromRGBO(0,0,0,0.25),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: GestureDetector(            
                child: ListTile(
                  trailing: new InkWell( 
              onTap: (){
                
                 send = true;
                phoneNumber = getPhone(contact.phones ?? []);
                share();
                //_sendsms();
              },
              child: Image(
              image: 
                    send == true
                  ? AssetImage('assets/check_green_icon.png')
                  : AssetImage('assets/check_orange_ic.png'),
              width: 28.3,
              height: 28.3,
            ),),
                contentPadding:
                      const EdgeInsets.symmetric(vertical:1, horizontal: 30),
                leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                      ? CircleAvatar(
                        radius: 25,
                          backgroundColor: Color.fromRGBO(221, 98, 67, 1),
                          backgroundImage: MemoryImage(contact.avatar),
                         )
                      : CircleAvatar(
                          radius: 25,
                          child: Text(contact.initials(), style: styles.TextStyles.whiteText18,),                         
                          backgroundColor: styles.Colors.orange,
                        ),
                 title: Text(contact.displayName ?? '', style: styles.TextStyles.darkText18,),
                 subtitle: Text(getPhone(contact.phones ?? []), style: styles.TextStyles.darkRegularText14,)//Text ("phone"),
                  //This can be further expanded to showing contacts detail
                   //onPressed().
                )));
              },
            )
          : Center(child: getProgressDialog()),
    );
  }
}
