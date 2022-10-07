import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/userModel.dart';

import '../utils/const.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userId;

  String? name;
  String? email;
  String? phoneNumber;
  String? governorate;
  String? region;
  String? password;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("email");

    print('www' + prefs.getString('email').toString());
  }

  Future<String> login(Map<String, String> body) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8'
    };

    var login = await http
        .post(Uri.parse(baseUrl + 'user/login'),
            headers: headers, body: json.encode(body))
        .then((response) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (response.statusCode == 200) {
        userModel userDetails = userModel.fromJson(jsonDecode(response.body));

        prefs.setString('fullname', userDetails.user!.fullname.toString());
        prefs.setString('_id', userDetails.user!.sId.toString());
        prefs.setString('email', userDetails.user!.email.toString());
        prefs.setInt('Phone', userDetails.user!.phone!.toInt());
        prefs.setString('state', userDetails.user!.state.toString());
        prefs.setString('region', region.toString());
        prefs.setString('password', password.toString());
        prefs.setString('image', userDetails.user!.image.toString());
        print(prefs.getString('fullname'));
        return await Future((() => "good"));
      } else if (response.statusCode == 409) {
        return await Future((() => "Confirm your adress mail"));
      } else if (response.statusCode == 401) {
        return await Future((() => "check email or password"));
      } else if (response.statusCode == 404) {
        return await Future((() => "Invalid user"));
      }
    });

    return login!;
  }

  Future<String> createAccount(File file, Map<String, dynamic> body) async {
    print("object");
    try {
      var dio = Dio();
      var fileTest = await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last);

      var formData = FormData.fromMap({
        'fullname': body['name'],
        'email': body['email'],
        'Phone': body['phone_number'],
        'state': body['governorate'],
        'region': body['region'],
        'password': body['password'],
        'image': fileTest
      });

      var response = await dio.post(baseUrl + 'user', data: formData);
      if (response.statusCode == 201) {
        return await Future((() => "good"));
      }
      if (response.statusCode == 409) {
        return await Future((() => "nope"));
      }
    } catch (error) {
      print(error.toString());
    }
    return 'error ';
  }

  Future<String> confirmPhon(String confirmPhone) async {
    Map<dynamic, String> body = {'confirmPhone': confirmPhone};
    final response = await http.post(
        Uri.parse(
            baseUrl + "user/confirmsendphone/" + constPhoneNumber.toString()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(body));
    if (response.statusCode == 200) {
      print('www');
      return await Future((() => "good"));
    } else {
      throw Exception('Failed to create album.');
    }
  }

  Future<void> Resend() async {
    final response = await http.post(
      Uri.parse(baseUrl + "user/sendphone/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Phone': constPhoneNumber.toString(),
      }),
    );
    print(constPhoneNumber);
  }
}

class Phon {
  final int Phone;
  final int confirmPhone;

  const Phon({required this.confirmPhone, required this.Phone});

  factory Phon.fromJson(Map<String, dynamic> json) {
    return Phon(
      Phone: json['Phone'],
      confirmPhone: json['confirmPhone'],
    );
  }
}
