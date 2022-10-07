import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/const.dart';

class CarsProvider with ChangeNotifier {
  String? id;
  Future getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('_id');
  }

  Future<String> addNewCar(File file, Map<String, dynamic> body) async {
    try {
      var dio = Dio();
      var fileTest = await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last);

      var formData = FormData.fromMap({
        'user': id,
        'brand': body['brand'],
        'price': body['price'],
        'Model': body['Model'],
        'Description': body['Description'],
        'Criteria': body['Criteria'],
        'image': fileTest
      });

      var response = await dio.post(baseUrl + 'car', data: formData);
      if (response.statusCode == 201) {
        return await Future((() => "good"));
      }
    } catch (error) {
      print(error.toString());
    }
    return 'error ';
  }
}
