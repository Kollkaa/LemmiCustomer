import '../Managers.dart';

class CheckOtpResponse {

  final String phone;
  final  otp;
  final String status;

  CheckOtpResponse(this.phone, this.otp, this.status);

  CheckOtpResponse.fromJson(Map<dynamic, dynamic> json):
        phone = json['phone'],
        otp = json['otp'],
        status = json['status'];

  Map<dynamic, dynamic> toJson() =>
      {
        'phone': phone,
        'otp': otp,
        'status': status
      };
}

class TokenResponse {

  final String refreshToken;

  TokenResponse(this.refreshToken);

  TokenResponse.fromJson(Map<String, dynamic> json) :
        refreshToken = json['accesToken'];

  Map<String, dynamic> toJson() =>
      {
        'accesToken': refreshToken,
      };

}

class TokenRegResponse {

  final String refreshToken;

  TokenRegResponse(this.refreshToken);

  TokenRegResponse.fromJson(Map<String, dynamic> json) :
        refreshToken = json['accessToken'];

  Map<String, dynamic> toJson() =>
      {
        'accessToken': refreshToken,
      };

}

class UserResponse {

  final Map<String, dynamic> userInfo;
  final List<dynamic> reviews;
  final List<dynamic> services;

  UserResponse(this.userInfo, this.reviews, this.services);


  UserResponse.fromJson(Map<String, dynamic> json):
        userInfo = json['info'],
        reviews = json['reviews'],
        services = json['services']
  ;

}

class ProfileUserInfo {
  final String _phone;
  final String _firstName;
  final String _lastName;
  final String _email;
  final String _gender;
  final String _birthday;
  final String _photo;
  var _rating;
  bool _verified;

  ProfileUserInfo(this._phone, this._firstName, this._lastName, this._email,
      this._gender,  this._birthday, this._photo, this._rating, this._verified);

  ProfileUserInfo.fromJson(Map<dynamic, dynamic> json):
        _phone = json['phone'],
        _firstName = json['first_name'],
        _lastName = json['last_name'],
        _email = json['email'],
        _birthday = json['birthday'],
        _photo = json['photo'],
        _gender = json['gender'],
        _rating = '${json['rating']}',
        _verified =  json['verified']
  ;

  String get birthday => _birthday;

  double get rating {
    if (_rating == 0 || _rating == null) return 0.0;
    _rating = double.parse(_rating);
    assert(_rating is double);
    return _rating;
  }

  String get gender => _gender;
  bool get verified => _verified;
  String get email => _email;

  String get lastName {
    if (_lastName == null) return" ";
    return _lastName;
  }

  String get firstName {
    if (_firstName == null) return" ";
    return _firstName;
  }

  String get photo {
    if (_photo == null) return"uploads/user/default-non-user-no-photo.jpg";
    return _photo;
  }

  String get phone => _phone;


  User getUser(){
    return User(
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
        gender: _gender,
        phone: _phone,
        birthday: DateTime.parse(_birthday),
        image: photo,
    );
  }
}

class Review {
  final String review;
  final String date;
  final Map<String, dynamic> user;
  //final int rating;

  Review(this.review, this.date, this.user);

  Review.fromJson(Map<dynamic, dynamic> json):
        review = json['review'],
        date = json['createdAt'],
        user = json['user'];
//rating = json['user']['rating'];
}

class ReviewUser {

  final String _photo;
  final String _firstName;
  final String _lastName;

  ReviewUser(this._photo, this._firstName, this._lastName, );

  ReviewUser.fromJson(Map<String, dynamic> json):
        _photo = json['photo'],
        _firstName = json['first_name'],
        _lastName = json['last_name']
  ;

  String get lastName {
    if (_lastName == null) return" ";
    return _lastName;
  }

  String get firstName {
    if (_firstName == null) return" ";
    return _firstName;
  }

  String get photo {
    if (_photo == null) return"uploads/user/default-non-user-no-photo.jpg";
    return _photo;
  }

}


class Specialisation {

  final String specialization;
  final int id;
  final List<dynamic> subSpecialization;


  Specialisation(this.specialization, this.id, this.subSpecialization);

  Specialisation.fromJson(Map<String, dynamic> json):
        specialization = json['specialization'],
        id = json['specializationId'],
        subSpecialization = json['subspecialization'];
}


class SubSpecialisation {

  final String name;
  final int id;
  final bool display;

  SubSpecialisation(this.name, this.id, this.display);

  SubSpecialisation.fromJson(Map<String, dynamic> json):
        name = json['name'],
        id = json['id'],
        display = json["display"]

  ;
}







