import 'dart:convert';

UserResponseModel userResponseFromJson(String str) => UserResponseModel.fromJson(json.decode(str));

class UserModel {
  String? userName;
  String? emailId;
  String? password;
  String? token;

  UserModel({
    required this.userName,
    required this.emailId,
    required this.password,
    this.token,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    userName = json['username'];
    emailId = json['email'];
    password = json['password'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = userName;
    data['email'] = emailId;
    data['password'] = password;
    data['token'] = token;
    return data;
  }
}





class UserResponseModel {
  int? code;
  String? message;

  UserResponseModel({this.code, this.message});

  UserResponseModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}


class UserProfile {
  final int? id;
  final String name;
  final String gender;
  final int age;
  final double heightCm;
  final String chairType;
  final double chairHeight;

  UserProfile({
    this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.chairType,
    required this.chairHeight,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'gender': gender,
    'age': age,
    'heightCm': heightCm,
    'chairType': chairType,
    'chairHeight': chairHeight,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'],
    name: map['name'],
    gender: map['gender'],
    age: map['age'],
    heightCm: (map['heightCm'] as num).toDouble(),
    chairType: map['chairType'],
    chairHeight: (map['chairHeight'] as num).toDouble(),
  );

  String toJson() => jsonEncode(toMap());

  static UserProfile fromJson(String source) => UserProfile.fromMap(jsonDecode(source));
}
