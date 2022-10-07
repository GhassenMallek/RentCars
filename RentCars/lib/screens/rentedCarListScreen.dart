// ignore_for_file: dead_code

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/rentedCarList.dart';
import 'package:shop/providers/theme_provider.dart';
import 'package:shop/screens/CarRentedDetails.dart';
import 'package:shop/widgets/rentedCarList.dart';

import '../utils/const.dart';

class RentedCar extends StatefulWidget {
  const RentedCar({Key? key}) : super(key: key);
  static const routeName = '/RentedCar';
  @override
  _RentedCarState createState() => _RentedCarState();
}

class _RentedCarState extends State<RentedCar> {
  var _isLoading = false;
  RentedCarList? rentedCar;
  @override
  void initState() {
    super.initState();
    funcgetCars = getCars();
    _isLoading = true;
  }

  late String testingValue = '';
  late Future<RentedCarList> funcgetCars;
  Icon customIcon = const Icon(Icons.search);
  TextEditingController editingController = TextEditingController();
  List<Car?> items = [];

  @override
  Widget build(BuildContext context) {
    var tm = Provider.of<ThemeProvider>(context, listen: true).themeMode;
    final deviceSize = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: funcgetCars,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: ListView(children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: deviceSize.height * 0.05,
                          bottom: deviceSize.height * 0.012),
                      child: Card(
                        color: Color.fromARGB(0, 233, 235, 245),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 10.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          height: height * 0.72,
                          width: deviceSize.width * 1.0,
                          padding: const EdgeInsets.all(1),
                          child: GridView.builder(
                            itemCount: testingValue.isEmpty
                                ? items.isNotEmpty
                                    ? items.length
                                    : rentedCar!.cars!.length
                                : items.isNotEmpty
                                    ? items.length
                                    : 0,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () {
                                    var idCar = rentedCar!.cars![index].sId;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) =>
                                            CarRentedDetailsScreen(
                                          id: idCar.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: rentedCarListGrid(
                                    rentedCar!.cars![index].tenant!.fullname!,
                                    rentedCar!.cars![index].car!.model!,
                                    rentedCar!.cars![index].car!.image!,
                                  ));
                            },
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 200,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            );
          } else {
            return Scaffold(
              body: Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(226, 20, 30, 48),
                            Color.fromARGB(245, 36, 59, 85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          // stops: [0, 1],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: SizedBox(
                        height: deviceSize.height,
                        width: deviceSize.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 25),
                                    transform: Matrix4.rotationZ(0)
                                      ..translate(1.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color.fromARGB(100, 26, 55, 77),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 8,
                                          color: Color(0x00000428),
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    duration: const Duration(seconds: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Navigator.of(context)
                                            //     .pushReplacement(
                                            //   MaterialPageRoute(
                                            //     builder: (ctx) =>
                                            //         RentedCarPage(),
                                            //   ),
                                            // );
                                          },
                                          child: Text('Refresh'),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Future<RentedCarList> getCars() async {
    do {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse(
          baseUrl + 'carrent/owner/' + prefs.getString('_id').toString()));
      if (response.statusCode == 200) {
        rentedCar = RentedCarList.fromJson(jsonDecode(response.body));
        return rentedCar!;
      } else {
        throw Exception('Failed to load Cars');
      }
    } while (true);
  }
}
