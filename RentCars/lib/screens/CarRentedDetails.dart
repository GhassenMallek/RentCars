import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/rentedCarList.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../providers/products.dart';

class CarRentedDetailsScreen extends StatefulWidget {
  static const routeName = '/CarRented-detail';
  const CarRentedDetailsScreen({required this.id, Key? key}) : super(key: key);
  final String id;
  @override
  State<CarRentedDetailsScreen> createState() => _CarRentedDetailsScreenState();
}

class _CarRentedDetailsScreenState extends State<CarRentedDetailsScreen> {
  RentedCarList? DetailsModelCarRented;
  late Future<RentedCarList> carMode;
  Future<RentedCarList> GetCarDetails() async {
    DetailsModelCarRented = await Provider.of<Products>(context, listen: false)
        .findRentedCarById(widget.id);
    return DetailsModelCarRented!;
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
        title: const Text('Tenant Details', textAlign: TextAlign.center),
        content: Column(
          children: [
            InkWell(
              onTap: () {},
              child: Image.network(
                DetailsModelCarRented!.cars![0].tenant!.image!,
                fit: BoxFit.fill,
              ),
            ),
            Text(DetailsModelCarRented!.cars![0].tenant!.fullname!,
                textAlign: TextAlign.center),
            Text(DetailsModelCarRented!.cars![0].tenant!.email!,
                textAlign: TextAlign.center),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                UrlLauncher.launch(
                    'tel://+${DetailsModelCarRented!.cars![0].tenant!.phone!.toString()}');
              },
              child: Text(
                '+${DetailsModelCarRented!.cars![0].tenant!.phone!.toString()}',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
          ],
        ),
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
                                              DetailsModelCarRented!
                                                  .cars![0].car!.image
                                                  .toString(),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                              children: <TextSpan>[
                                                const TextSpan(
                                                    text: 'this Mr(s)  '),
                                                TextSpan(
                                                    text: DetailsModelCarRented!
                                                        .cars![0]
                                                        .tenant!
                                                        .fullname,
                                                    style: const TextStyle(
                                                        color: Colors.blue),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            _showDialog();
                                                          }),
                                                const TextSpan(
                                                    text:
                                                        ' want to rent this car : ')
                                              ]),
                                        ),
                                        ListTile(
                                          title: Text(
                                            '${DetailsModelCarRented!.cars![0].car!.model}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30),
                                          ),
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
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'from :   ${DetailsModelCarRented!.cars![0].locationDatefrom!}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'to :   ${DetailsModelCarRented!.cars![0].locationDateto!}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {},
                                          child: Text('Accept'),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
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
                                              // Navigator.of(context).push(
                                              //   MaterialPageRoute(
                                              //     builder: (ctx) =>
                                              //         CarRentedDetailsScreen(
                                              //             id: DetailsModelCarRented!
                                              //                 .sId
                                              //                 .toString()),
                                              //   ),
                                              // );
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
}
