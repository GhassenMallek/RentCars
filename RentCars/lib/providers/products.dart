import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/CarMode.dart';
import 'package:shop/models/UserModelDetails.dart';
import 'package:shop/models/carModel.dart';
import 'package:shop/models/rentedCarList.dart';
import 'package:shop/utils/const.dart';

class Products with ChangeNotifier {
  String? authToken;
  String? userId;

  bool isListView = false;

  switchView() {
    isListView = !isListView;
    notifyListeners();
  }

  Future<CarMode> findById(String id) async {
    CarMode carmodel;
    final response = await http.get(Uri.parse(baseUrl + 'car/$id'));

    if (response.statusCode == 200) {
      carmodel = CarMode.fromJson(jsonDecode(response.body));
      return await Future((() => carmodel));
    }
    throw Exception('Failed to load album');
  }

  Future<RentedCarList> findRentedCarById(String id) async {
    RentedCarList rentedCarList;
    final response = await http.get(Uri.parse(baseUrl + 'carrent/details/$id'));

    if (response.statusCode == 200) {
      rentedCarList = RentedCarList.fromJson(jsonDecode(response.body));
      return await Future((() => rentedCarList));
    }
    throw Exception('Failed to load album');
  }

  Future<List<DateTime>> getResDates(String id) async {
    Map<dynamic, dynamic> res;
    final response = await http.get(Uri.parse(baseUrl + 'carrent/$id'));

    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
      List<DateTime> dates = [];
      res.values.forEach((v) => dates.add(DateTime.parse(v)));
      return await Future((() => dates));
    }
    throw Exception('Failed to load album');
  }

  Future<UserModelDetails> findByUserId(String id) async {
    UserModelDetails carmodel;
    final response = await http.get(Uri.parse(baseUrl + 'car/userdetails/$id'));

    if (response.statusCode == 200) {
      carmodel = UserModelDetails.fromJson(jsonDecode(response.body));
      print(carmodel.user!.fullname);

      return await Future((() => carmodel));
    }

    throw Exception('Failed to load album');
  }

  Future<String> getCars() async {
    CarModel? carmodel;
    final response = await http.get(Uri.parse(baseUrl + 'car'));

    if (response.statusCode == 200) {
      carmodel = CarModel.fromJson(jsonDecode(response.body));
      return 'carmodel';
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<double> findRatebyId(String id) async {
    final response = await http.get(Uri.parse(baseUrl + 'rate/$id'));

    if (response.statusCode == 200) {
      return await Future((() => double.parse(response.body)));
    }

    throw Exception('Failed to load album');
  }
}
