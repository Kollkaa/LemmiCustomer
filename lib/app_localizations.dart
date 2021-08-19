import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context){
    return Localizations.of<AppLocalizations>(context, AppLocalizations);    
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  Map <String, String> _localizedStrings;

   Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    //locale.languageCode
    String jsonString;
    final storage = new FlutterSecureStorage();
    String language =  await storage.read(key: 'language');
    if (language != null){
      if (language == "uk"){
        jsonString = await rootBundle.loadString('lang/uk.json');
      }else {
        jsonString = await rootBundle.loadString('lang/ru.json');
      }
      }else{
        if ((ui.window.locale.languageCode) == "uk-UA") {
        jsonString =await rootBundle.loadString('lang/${ui.window.locale.languageCode}.json');
        storage.write(key: "language", value: "uk");
        }else{
         jsonString = await rootBundle.loadString('lang/${ui.window.locale.languageCode}.json');
         storage.write(key: "language", value: "ru");
        }
      }

    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key){
    return _localizedStrings[key] ?? '** $key not found';
  }
}

class _AppLocalizationsDelegate 
  extends LocalizationsDelegate<AppLocalizations>{
  
  const _AppLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('ru', ''), 
      Locale('uk', ''),
      Locale('en','')
    ];
  }

  @override 
  bool isSupported(Locale locale){
    return ['ru', 'uk', 'en'].contains(locale.languageCode);
  }

  @override 
  Future<AppLocalizations> load(Locale locale) async {

    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override 
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}