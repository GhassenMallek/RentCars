import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shop/models/UserModelDetails.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/const.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class OwnerDetails extends StatefulWidget {
  static const routeName = '/OwnerDetails';
  const OwnerDetails({required this.id, Key? key}) : super(key: key);
  final String id;

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();
}

class _OwnerDetailsState extends State<OwnerDetails> {
  var rating = 0.0;
  bool _isPressed = false;

  UserModelDetails? usermodel;
  double? ratemodel;
  late Future<double> ratemodelfu;
  late Future<bool> usermodelfu;
  late Map<String, dynamic> rateMap;

  Future<bool> getUserDetails() async {
    usermodel = await Provider.of<Products>(context, listen: false)
        .findByUserId(widget.id);
    ratemodel = await Provider.of<Products>(context, listen: false)
        .findRatebyId(widget.id);
    return true;
  }

  @override
  void initState() {
    super.initState();
    usermodelfu = getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: usermodelfu,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                              child: AnimatedContainer(
                                margin: const EdgeInsets.only(
                                    top: 60, left: 10, bottom: 10.0, right: 10),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 25),
                                transform: Matrix4.rotationZ(0)..translate(1.0),
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
                                duration: const Duration(seconds: 2),
                                child: Column(
                                  //
                                  children: [
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(150),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey,
                                          )),
                                      width: 200,
                                      height: 200,
                                      child: InkWell(
                                        onTap: () {},
                                        child: Image.network(
                                          usermodel!.user!.image!,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    ListTile(
                                      title: Text(
                                        usermodel!.user!.fullname!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      usermodel!.user!.email!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          '   Phone number :',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            UrlLauncher.launch(
                                                'tel://+${usermodel!.user!.phone!}');
                                          },
                                          child: Text(
                                            '+${usermodel!.user!.phone!}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    RatingBar.builder(
                                      initialRating: 3,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rate) {
                                        rating = rate;
                                      },
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        sendRate(rating);
                                      },
                                      child: const Text('Rate'),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      ratemodel!.toStringAsFixed(2),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30),
                                    ),
                                    const SizedBox(
                                      height: 60,
                                    ),
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          'Report',
                                          textAlign: TextAlign.left,
                                        ))
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
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (ctx) => OwnerDetails(
                                                    id: usermodel!.sId
                                                        .toString()),
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

  Future<void> sendRate(double rate) async {
    await http.post(
      Uri.parse(baseUrl + 'rate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'rate': rate,
        'user': usermodel!.user!.sId,
      }),
    );
  }
}
