import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/const.dart';

class Cart with ChangeNotifier {
  // Map<String, CartItem> _items = {};

  // Map<String, CartItem> get items {
  //   return {..._items};
  //}

  // int get itemCount {
  //   //print('item Length: ${_items.length}');
  //   return _items.length;
  // }

  // double get totalAmount {
  //   var total = 0.0;
  //   _items.forEach((key, cartItem) {
  //     total += cartItem.price * cartItem.quantity;
  //   });
  //   return total;
  // }
  Future<double> findRatebyId(String id) async {
    final response = await http.get(Uri.parse(baseUrl + 'pdf/$id'));

    if (response.statusCode == 200) {
      return await Future((() => double.parse(response.body)));
    }

    throw Exception('Failed to load album');
  }
}
