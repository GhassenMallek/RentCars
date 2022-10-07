import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/CarMode.dart';
import 'package:shop/models/favourite.dart';
import 'package:shop/screens/ownerDetails.dart';
import 'package:shop/screens/reservation.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:shop/utils/const.dart';

import '../providers/products.dart';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';
  const ProductDetailScreen({required this.id, Key? key}) : super(key: key);
  final String id;
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  CarMode? DetailsModelCar;
  late Future<CarMode> carMode;
  Future<CarMode> GetCarDetails() async {
    DetailsModelCar =
        await Provider.of<Products>(context, listen: false).findById(widget.id);
    return DetailsModelCar!;
  }

  @override
  void initState() {
    super.initState();
    carMode = GetCarDetails();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(DetailsModelCar!.model!, textAlign: TextAlign.center),
        content:
            Text(DetailsModelCar!.description!, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            child: const Text('Back'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    bool isliked = false;
    return FutureBuilder(
        future: carMode,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
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
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
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
                                  child: AnimatedContainer(
                                    margin: const EdgeInsets.only(
                                        top: 60,
                                        left: 10,
                                        bottom: 10.0,
                                        right: 10),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 25),
                                    transform: Matrix4.rotationZ(0)
                                      ..translate(1.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color.fromARGB(205, 24, 40, 72),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 8,
                                          color: Color(0x00000428),
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                    child: Column(
                                      //
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 50,
                                                width: 130,
                                                child: OutlinedButton(
                                                  onPressed: () => {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            OwnerDetails(
                                                                id: DetailsModelCar!
                                                                    .sId
                                                                    .toString()),
                                                      ),
                                                    )
                                                  },
                                                  child: Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.person_pin,
                                                        size: 24,
                                                      ),
                                                      Text('Owner details'),
                                                    ],
                                                  ),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    side: const BorderSide(
                                                        width: 1.0,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.white,
                                              border: Border.all(
                                                width: 2.0,
                                                color: const Color.fromARGB(
                                                    255, 1, 97, 109),
                                              )),
                                          width: 300,
                                          height: 200,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Image.network(
                                              DetailsModelCar!.image!,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        ListTile(
                                          title: Text(
                                            '${DetailsModelCar!.brand!} : ',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30),
                                          ),
                                        ),
                                        Text(
                                          DetailsModelCar!.model!,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        AnimatedContainer(
                                          width: 400,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color:
                                                Color.fromARGB(0, 255, 40, 72),
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 8,
                                                color: Color.fromARGB(
                                                    87, 0, 35, 40),
                                                offset: Offset(0, 10),
                                              )
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 30,
                                              ),
                                              ListTile(
                                                title: Text(
                                                  DetailsModelCar!.criteria!,
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    _showDialog();
                                                  },
                                                  child:
                                                      Text("more information")),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ListTile(
                                          title: Text(
                                            'Price : ${DetailsModelCar!.price!.toString()} TND per day',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FavoriteButton(
                                              isFavorite: false,
                                              // iconDisabledColor: Colors.white,
                                              valueChanged: (_isFavorite) {
                                                print(
                                                    'Is Favorite : $_isFavorite');
                                                if (_isFavorite) {
                                                  addFavorite();
                                                } else {
                                                  print('delete one');
                                                }
                                              },
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          ReservationScreen(
                                                              id: DetailsModelCar!
                                                                  .sId
                                                                  .toString()),
                                                    ),
                                                  );
                                                },
                                                child: Text('Reserver')),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const SizedBox(height: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
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
                                    margin: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 25),
                                    transform: Matrix4.rotationZ(0)
                                      ..translate(1.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color:
                                          const Color.fromARGB(100, 26, 55, 77),
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
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const CircularProgressIndicator(),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Future.delayed(
                                                const Duration(seconds: 2), () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      ProductDetailScreen(
                                                          id: DetailsModelCar!
                                                              .sId
                                                              .toString()),
                                                ),
                                              );
                                            });
                                          },
                                          child: const Text('Refresh'),
                                        ),
                                        const SizedBox(
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

  Future<Favourit> addFavorite() async {
    Favourit userDetails;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(baseUrl + 'favorite'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user': prefs.getString('_id').toString(),
        'car': DetailsModelCar!.sId!.toString(),
      }),
    );
    if (response.statusCode == 201) {
      print("added");
      return Favourit.fromJson(jsonDecode(response.body));
    } else {
      return Favourit.fromJson(jsonDecode(response.body));
    }
  }
}
