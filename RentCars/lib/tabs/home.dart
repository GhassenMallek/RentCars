// ignore_for_file: dead_code

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shop/models/carModel.dart';
import 'package:shop/providers/theme_provider.dart';
import 'package:shop/screens/car_detail_screen.dart';
import 'package:shop/tabs.dart';

import '../utils/const.dart';
import '../widgets/car_info.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _isLoading = false;
  CarModel? carmodel;
  @override
  void initState() {
    super.initState();
    funcgetCars = getCars();
    _isLoading = true;
  }

  late String testingValue = '';
  late Future<CarModel> funcgetCars;
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Search car');
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
              appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 137, 138, 148),
                  shape: const MyShapeBorder(20),
                  title: customSearchBar,
                  actions: [
                    IconButton(
                      icon: Icon(tm == ThemeMode.light
                          ? Icons.dark_mode
                          : Icons.wb_sunny),
                      onPressed: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .changeMode(tm == ThemeMode.light ? 'd' : 'l');
                      },
                    ),
                    IconButton(
                      //icon: const Icon(Icons.search),
                      tooltip: 'Search products',
                      onPressed: () {
                        setState(() {
                          if (customIcon.icon == Icons.search) {
                            customIcon = const Icon(Icons.cancel);

                            customSearchBar = ListTile(
                              leading: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 28,
                              ),
                              title: TextField(
                                onChanged: (value) {
                                  filterSearchResults(value);
                                  testingValue = value;
                                },
                                controller: editingController,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                          if (customIcon.icon == Icons.cancel) {
                            editingController.clear();
                            items = carmodel!.car!;
                          }
                        });
                      },
                      icon: customIcon,
                    ),
                  ]),
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
                                    : carmodel!.car!.length
                                : items.isNotEmpty
                                    ? items.length
                                    : 0,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () {
                                    var idCar = carmodel!.car![index].sId;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => ProductDetailScreen(
                                            id: idCar.toString()),
                                      ),
                                    );
                                  },
                                  child: testingValue.isEmpty
                                      ? items.isNotEmpty
                                          ? CarGrid(
                                              items[index]!.model!,
                                              items[index]!.brand!,
                                              items[index]!.image!,
                                              items[index]!.price!)
                                          : CarGrid(
                                              carmodel!.car![index].model!,
                                              carmodel!.car![index].brand!,
                                              carmodel!.car![index].image!,
                                              carmodel!.car![index].price!)
                                      : CarGrid(
                                          items[index]!.model!,
                                          items[index]!.brand!,
                                          items[index]!.image!,
                                          items[index]!.price!));
                            },
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 300,
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
                            // const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                            // const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),

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
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (ctx) => HomePage(),
                                              ),
                                            );
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

  Future<CarModel> getCars() async {
    final response = await http.get(Uri.parse(baseUrl + 'car'));

    if (response.statusCode == 200) {
      carmodel = CarModel.fromJson(jsonDecode(response.body));
      return carmodel!;
    } else {
      throw Exception('Failed to load Cars');
    }
  }

  void filterSearchResults(String query) async {
    var test = await getCars();
    List<String?> dummySearchList = test.car!.map((e) => e.brand).toList();
    print(dummySearchList);
    // dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String?> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item!.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        for (var i = 0; i < test.car!.length; i++) {
          for (var j = 0; j < dummyListData.length; j++) {
            if (dummyListData[j] == test.car![i].brand) {
              items.add(test.car![i]);
            }
          }
        }
      });
      return;
    } else {
      setState(() {
        items.clear();
        //items.addAll(duplicateItems);
      });
    }
  }
}

class MyShapeBorder extends ContinuousRectangleBorder {
  const MyShapeBorder(this.curveHeight);
  final double curveHeight;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..lineTo(0, rect.size.height)
    ..quadraticBezierTo(
      rect.size.width / 114,
      rect.size.height + curveHeight * 1.5,
      rect.size.width,
      rect.size.height,
    )
    ..lineTo(rect.size.width, 0)
    ..close();
}
