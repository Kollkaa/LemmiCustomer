
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaban/ServerManager.dart';

class User {
  String _firstName;
  String _lastName;
  String _gender;
  DateTime _birthday;
  String _city;
  String _email;
  String _phone;
  String _image;


  User({String firstName, String lastName, String gender, DateTime birthday, String city, String email, String phone, String image}) {
    _firstName = firstName;
    _lastName = lastName;
    _gender = gender;
    _birthday = birthday;
    _city = city;
    _email = email;
    _phone = phone;
    _image = image;
  }


  bool isUserValid() {
    //todo: implement function, that returns true if all user data is inputted and correct, otherwise - false
  }

  User init(Map userInfo) {
   
    print("user info = $userInfo");
    _firstName= "${userInfo["first_name"]}";
    _lastName= "${userInfo["last_name"]}";
    _phone="${userInfo["phone"]}";
    _image='https://api.lemmi.app/${userInfo['photo']}';
    
    return User(
      firstName: _firstName,
      lastName: _lastName,
      phone: _phone,
      image: _image,
    );
    
   }

  String get firstName => _firstName;
   set firstName(String value)  {    
    _firstName = value;    
  }
 
  String get lastName => _lastName;
  set lastName(String value) {
    _lastName = value;
  }

  String get phone => _phone;

  set phone(String value) {
    _phone = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get city => _city;

  set city(String value) {
    _city = value;
  }

  DateTime get birthday => _birthday;

  set birthday(DateTime value) {
    _birthday = value;
  }

  String get gender => _gender;

  set gender(String value) {
    _gender = value;
  }
}

class Message{
  final String title;
  final String body;
  final String action;

  const Message({
    @required this.title,
    @required this.body,
    @optionalTypeArgs this.action
  });
}


class UserService {
  BuildContext context;

  //UserService(this.context);

  User _cachedUser; //<----- Cached Here

  UserService() {
  }

  User getCachedUser() {

    if (_cachedUser == null) {

      return User();
    }

    return _cachedUser;
  }

  Future<User> getUser() async {

    await ServerManager(context).getUserInfoRequest( (user){
       
      _cachedUser = User();//user;
      return _cachedUser;

    }, (error) {

    });

    _cachedUser = User();
    return _cachedUser;
  }
}



class Utils {
  static void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static bool isTheSameDay(DateTime one, DateTime two) =>
      one.year == two.year && one.month == two.month && one.day == two.day;
}
  class Places{
    String name;
    Places(this.name);
  }
  
class OrderDeal {
  List <dynamic> subCategories;
  String title;
  String description;
  String price;
  String changePrice;
  String startDate;
  String startTime;
  String address;
  String detailAddress;
  String rating;
  String name;
  String imageUrl;
  String comment;
  OrderDeal(this.subCategories, this.title, this.description, this.price, this.changePrice, this.startDate, this.startTime, this.address, this.detailAddress, this.rating, this.name, this.imageUrl, this.comment);
}
class OrderInfo {
  List<dynamic> subCategories;
  String taskId;
  String title;
  String subtitle;
  String description;
  String price;
  String startDate;
  String status;
  String order_status;
  double rating;
  String idRating;
  String startTime;
  String address;
  String detailAddress;
  List <String> images;
  List<Map<String,Object>> user;
  OrderInfo(this.subCategories, this.taskId, this.title, this.description, this.subtitle, this.price, this.rating,this.order_status,  this.idRating, this.startDate,this.startTime, 
  this.status, this.address, this.detailAddress, this.user, this.images);
  
 
  
  @override
  String toString() {
    return '${this.title}';
  }
}
class MyOrderInfo {
  String title;
  String subtitle;
  String description;
  String price;
  String startDate;
  String status;
  double rating;
  String startTime;
  String address;
  String detailAddress;
  List <String> images;
  List<Map<String,Object>> user;
  MyOrderInfo(this.title, this.description, this.subtitle, this.price, this.rating, this.startDate,this.startTime, this.status, this.address, this.detailAddress, this.images,this.user);

  @override
  String toString() {
    return '${this.title}';
  }
}
class RequestComment{
  String userName;
  String userSurname;
  String userImage;
  String performerComment;
  String activityTaskId;
  String theId;
  String userId;
  RequestComment(this.userName, this.userSurname, this.userImage, this.performerComment, this.activityTaskId, this.theId, this.userId);
  @override
   String userFullName() {
    return '${this.userName} ${this.userSurname}';
  }
}

class Comment {
  String userName;
  String userSurname;
  String userImage;
  String commentBody;
  String date;
 // DateTime date;
  //List<Map<String, Object>> performerReviews;
  Comment(this.userName, this.userSurname, this.userImage, this.commentBody, this.date);
  //this.commentBody, this.date);

  @override

 /* String get formattedDate {
    String date = '';
    if (Utils.isTheSameDay(DateTime.now(), this.date))
      date = 'Сегодня, ${DateFormat("HH:mm").format(this.date)}';
    else if (Utils.isTheSameDay(DateTime.now().add(Duration(days: 1)), this.date))
      date = 'Завтра, ${DateFormat("HH:mm").format(this.date)}';
    date = DateFormat("HH:mm dd MMMM yyyy").format(this.date);
    return date;
  }*/

  String userFullName() {
    return '${this.userName} ${this.userSurname}';
  }
}

class ServiceInfo {
  String title;
  List<Map<String, String>> categoryList;
 
  ServiceInfo(this.title, this.categoryList);

}

class Address {

  bool isEmpty;
  var id = '';
  var type = '';
  var city = '';
  var street = '';
  var apartmentNumber = '';
  var apartment = '';
  var latitude;
  var longitude;
  Address(this.isEmpty, this.type, this.city, this.street, this.apartmentNumber, this.apartment, this.id, this.latitude, this.longitude,);


  String fullStreetAddress() {
    return '${this.street} ${this.apartmentNumber}';// ${this.city}';
  }
  String fullApartmentAddress() {
    return '${this.apartment}';
  }
  
}
  
 /* factory Address.fromJson(Map<String, dynamic> result) {
  //  result = json['result'],
    return Address(
      isEmpty:"false" as bool,
      type: result[[{'type'}]] as String,
      city: result[{'town'}] as String,
      street: result[{'adress'}] as String,
      apartmentNumber: result[{'description'}] as String,
      apartment:"",
      
    );*/
  //}

 
 class Specialists{
   String _id;
   String _title;
   String _image;

   Specialists({String id, String title, String image}){
     _id = id;
     _title = title;
     _image = image;
   }

   Specialists init(Map<String, dynamic> specialists ){

      return Specialists(
        id: _id,
       title: _title,
       image: _image,
     );
   }

   String get title => _title;
   set title(String value)  {    
    _title = value;    
  }
   String get image => _image;
   set image(String value)  {    
    _image = value;    
  }
  String get id => _id;
   set id(String value)  {    
    _id = value;    
  }
  
 }
 class SpecialistsList {
  final List<Specialists> photos;

  SpecialistsList({
    this.photos,
  });
    factory SpecialistsList.fromJson(List<dynamic> parsedJson) {

    List<Specialists> photos = new List<Specialists>();
    //photos = parsedJson.map((i)=>Specialists.fromJson(i)).toList();

    return new SpecialistsList(
      photos: photos
    );
  }
}
  class Services{
    String title;
    String specialist;
    String id;
    Services(String title, String specialist, String id){

    }
  }
   class Task{
    String _globalCategory;
    String _description;
    String _price;
    String price0;
    String data;
    String address_id;
    String _services_id;
    String indexToRemember;
    String _hours;
    String day;
    String _category ="";
    var photo=[];
    var subCategory =[];
    var subCategoryId =[];
    String activity_task_id;
    String performer_id;
    List <String> images =[];
    double longitude;
    double latitude;
    bool _published;
    //constructor
    Task({String globalCategory, String description, String price, String price0, this.data, String address_id, String services_id, this.indexToRemember,this.day,
    String hours, String category, List<dynamic> photo, List<dynamic> subCategory, List<dynamic> subCategoryId, String activity_task_id, String performer_id, List <String> images, double longitude, double latitude, bool published}){
      _globalCategory: globalCategory; 
      _description: description;
      _price: price;
      _hours: hours;
      _category:category;
      _services_id:services_id;
      _published:published;
    }
   
  Task init(Map<String, dynamic> task ){

      return Task(
        description: _description,
        price: _price,
        hours: _hours,
        category: _category,
        services_id: _services_id,
       
     );
   }
   String get globalCategory => _globalCategory;
   set globalCategory(String value)  {    
    _globalCategory = value;    
  }
   String get services_id => _services_id;
   set services_id(String value)  {    
    _services_id = value;    
  }
  String get category => _category;
   set category(String value)  {    
    _category = value;    
  }
   String get description => _description;
   set description(String value)  {    
    _description = value;    
  }
   String get price => _price;
   set price(String value)  {    
    _price = value;    
  }
  
  String get hours => _hours;
   set hours(String value)  {    
    _hours = value;    
  }

  bool get published => _published;
   set published(bool value)  {    
    _published = value;
  }  
}

class Test {
  String _phone;
  String firstName;
  String lastName;
  String email;
  String password;
  String gender;
Test({String phone, this.firstName, this.lastName, this.email, this.password, this.gender}){
_phone=phone;
}

String get phone => _phone;
   set phone(String value)  {    
    _phone = value;    
  }
}
class Category1 {
  var name = "";
  var id = "";
  Category1(this.name, this.id);

   String fullName() {
    return '${this.name}';
  }
}
