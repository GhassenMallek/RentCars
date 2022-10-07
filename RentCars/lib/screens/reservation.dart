import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/CarMode.dart';
import 'package:shop/models/UserModelDetails.dart';
import 'package:shop/models/rentCar.dart';
import 'package:shop/models/rentedCarList.dart';
import 'package:shop/models/userModel.dart';
import 'package:shop/models/userSimpleModel.dart';
import 'package:shop/providers/pdfFunction.dart';
import 'package:shop/screens/ownerDetails.dart';
import 'package:shop/utils/const.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../providers/products.dart';

class ReservationScreen extends StatefulWidget {
  static const routeName = '/Reservation';
  const ReservationScreen({required this.id, Key? key}) : super(key: key);
  final String id;
  @override
  State<ReservationScreen> createState() => ReservationScreenState();
}

class ReservationScreenState extends State<ReservationScreen> {
  CarMode? DetailsModelCar;
  RentedCarList? DetailsModelCarRented;
  UserModelDetails? usermodel;
  RentedCarList? rentedCarListtenant;
  UserSimplemodel? userSimplemodel;
  late Future<CarMode> carMode;
  Future<CarMode> GetCarDetails() async {
    DetailsModelCar =
        await Provider.of<Products>(context, listen: false).findById(widget.id);
    return DetailsModelCar!;
  }

  UserModelDetails? carmodel;
  getUserDetails() async {
    final response =
        await http.get(Uri.parse(baseUrl + 'car/userdetails/' + widget.id));
    if (response.statusCode == 200) {
      carmodel = UserModelDetails.fromJson(jsonDecode(response.body));
      print(carmodel!.user!.fullname);

      return await Future((() => carmodel));
    }

    throw Exception('Failed to load album');
  }

  getResDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http
        .get(Uri.parse(baseUrl + 'user/' + prefs.getString('_id').toString()));

    if (response.statusCode == 200) {
      userSimplemodel = UserSimplemodel.fromJson(jsonDecode(response.body));
      print('Owner' + userSimplemodel!.fullname.toString());
      return await Future((() => usermodel));
    }
    throw Exception('Failed to load album');
  }

  @override
  void initState() {
    super.initState();
    carMode = GetCarDetails();
    getUserDetails();
    getResDates();
  }

  pdfCreator() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    final PdfPageTemplateElement headerTemplate =
        PdfPageTemplateElement(const Rect.fromLTWH(0, 0, 515, 50));
//Draw text in the header.
    headerTemplate.graphics.drawString(
        'Rent Car Application', PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(0, 15, 200, 20));
//Add the header element to the document.
    document.template.top = headerTemplate;
    page.graphics.drawString('Car Rental Contract\r\n\r\n ',
        PdfStandardFont(PdfFontFamily.helvetica, 30));
    String text =
        'This Car Rental Agreement (“Agreement”) is made and entered into as of ${today!.day}-${today!.month}-${today!.year} between  ${userSimplemodel!.fullname.toString()} ("Renter") who want to rent the car of ${carmodel!.user!.fullname} ("Owner"), with total price ${priceTotal.toString()} TND';

    String signature =
        'signature  :Tunisia, On ${today!.day}-${today!.month}-${today!.year},   ${userSimplemodel!.fullname.toString()} && ${carmodel!.user!.fullname}  ';

    String Contract =
        "By accepting the privacy policy, your car is ready to be rented when it is available. All cars posted in Rental car application should be in good conditions, otherwise the owner will be banned with hefty fines in the case of accident caused by safety related to shown cars.  You can\t decline any rental offer. You can choose to custom or to accept our contract. In the case of contract was signed, the contract couldn\t be cancelled by the car\s owner or the tenant, or both will be banned. The tenant should pay the location fee, or he will be banned. The Parties agree that this Agreement terminates upon the End Date specified in application. Not with standing anything to. Owner Warranty:  The Owner represents that to the best of his knowledge and belief that the Vehicle is in sound and safe condition and free of any known faults or defects that would affect its safe operation under normal use. ";
    PdfTextElement textElement = PdfTextElement(
        text: text, font: PdfStandardFont(PdfFontFamily.timesRoman, 20));
    PdfTextElement textElement1 = PdfTextElement(
        text: Contract, font: PdfStandardFont(PdfFontFamily.timesRoman, 20));
    PdfTextElement textElement2 = PdfTextElement(
        text: signature, font: PdfStandardFont(PdfFontFamily.timesRoman, 20));

//Create layout format
    PdfLayoutFormat layoutFormat = PdfLayoutFormat(
        layoutType: PdfLayoutType.paginate,
        breakType: PdfLayoutBreakType.fitPage);

//Draw the first paragraph
    PdfLayoutResult result = textElement.draw(
        page: page,
        bounds: Rect.fromLTWH(
            0, 40, page.getClientSize().width / 2, page.getClientSize().height),
        format: layoutFormat)!;

//Draw the second paragraph from the first paragraph end position
    textElement1.draw(
        page: page,
        bounds: Rect.fromLTWH(0, result.bounds.bottom + 50,
            page.getClientSize().width, page.getClientSize().height),
        format: layoutFormat);
    textElement2.draw(
        page: page,
        bounds: Rect.fromLTWH(
            0, 650, page.getClientSize().width, page.getClientSize().height),
        format: layoutFormat);

    var url = DetailsModelCar!.image!;
    var response = await http.get(Uri.parse(url));
    var data = response.bodyBytes;
    PdfBitmap image = PdfBitmap(data);

    page.graphics.drawImage(
        image, Rect.fromLTWH(page.getClientSize().width - 200, 0, 150, 150));
    List<int> bytes = await document.save();
    document.dispose();
    saveAndLaunchFile(bytes, 'bill.pdf');
  }

  void getRentedCar() async {
    List<DateTime> res = await Provider.of<Products>(context, listen: false)
        .getResDates(widget.id);
    for (DateTime d in res) {}
  }

  DateTimeRange? selectedDateRange;
  int? priceTotal;
  var difference;
  bool Calendar = false;
  DateTime? endDate;
  DateTime? startDate;
  DateTime? today = DateTime.now();

  void _showDialogError() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy policy', textAlign: TextAlign.center),
        content: const Text('Date already reserved', textAlign: TextAlign.left),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  void _showDialogErrorSubmit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy policy', textAlign: TextAlign.center),
        content: const Text('Please choose a date', textAlign: TextAlign.left),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  late DateTime rangeStartDate;
  late DateTime rangeEndDate;
  var end;
  var start;
  void _show() async {
    late DateTime d;
    late List<PickerDateRange> selectedRanges;

    List<DateTime> res = await Provider.of<Products>(context, listen: false)
        .getResDates(widget.id);
    showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              body: SfDateRangePicker(
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is PickerDateRange) {
                DateTime rangeStartDate = args.value.startDate;
                DateTime rangeEndDate = args.value.endDate;

                if (rangeEndDate != null) {
                  setState(() {
                    start = rangeStartDate;
                    end = rangeEndDate;
                    final difference = end.difference(start).inDays;
                    priceTotal = (difference + 1) * DetailsModelCar!.price!;
                  });
                  List<DateTime> days = [];
                  for (int i = 0;
                      i <= rangeEndDate.difference(rangeStartDate).inDays;
                      i++) {
                    days.add(rangeStartDate.add(Duration(days: i)));
                    for (int j = 0; j <= res.length - 1; j++) {
                      if (res[j].day == days[i].day &&
                          res[j].month == days[i].month &&
                          res[j].year == days[i].year) {
                        return _showDialogError();
                      }
                    }
                  }
                }
              }
            },
            selectionMode: DateRangePickerSelectionMode.range,
            view: DateRangePickerView.month,
            monthViewSettings: DateRangePickerMonthViewSettings(
                blackoutDates: [for (d in res) d],
                showTrailingAndLeadingDates: false),
            monthCellStyle: DateRangePickerMonthCellStyle(
              blackoutDatesDecoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(color: const Color(0xFFF44436), width: 1),
                  shape: BoxShape.circle),
            ),
            rangeTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            startRangeSelectionColor: Color.fromARGB(201, 203, 224, 235),
            endRangeSelectionColor: Color.fromARGB(201, 203, 224, 235),
            showActionButtons: true,
            onSubmit: (rangeEndDate) {
              Calendar = true;
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ));
        });
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
                                        Calendar == false
                                            ? AnimatedContainer(
                                                width: 400,
                                                height: 170,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Color.fromARGB(
                                                      0, 255, 40, 72),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      blurRadius: 8,
                                                      color: Color.fromARGB(
                                                          87, 0, 35, 40),
                                                      offset: Offset(0, 10),
                                                    )
                                                  ],
                                                ),
                                                duration:
                                                    const Duration(seconds: 2),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Text(
                                                        'Press the button to show the picker!',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: _show,
                                                      child: const Icon(
                                                          Icons.date_range),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : AnimatedContainer(
                                                width: 400,
                                                height: 170,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Color.fromARGB(
                                                      0, 255, 40, 72),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      blurRadius: 8,
                                                      color: Color.fromARGB(
                                                          87, 0, 35, 40),
                                                      offset: Offset(0, 10),
                                                    )
                                                  ],
                                                ),
                                                duration:
                                                    const Duration(seconds: 2),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 190,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .deepPurpleAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Center(
                                                        child: Text(
                                                          'Start date: ${start}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Container(
                                                      width: 190,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .deepOrangeAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Center(
                                                        child: Text(
                                                          'End date: ${end}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          Calendar = false;
                                                          start = null;
                                                          end = null;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: Colors
                                                                    .redAccent,
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: const Center(
                                                            child: Icon(
                                                          CupertinoIcons.delete,
                                                          color: Colors.white,
                                                          size: 35,
                                                        )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Calendar == false
                                            ? ListTile(
                                                title: Text(
                                                  'Price : ${DetailsModelCar!.price!.toString()} TND per day',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              )
                                            : ListTile(
                                                title: Text(
                                                  'Price total : ${priceTotal.toString()} TND ',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                            LikeButton(
                                              size: 100,
                                              circleColor: const CircleColor(
                                                  start: Color.fromARGB(
                                                      255, 204, 40, 111),
                                                  end: Color.fromARGB(
                                                      255, 129, 59, 111)),
                                              bubblesColor: const BubblesColor(
                                                dotPrimaryColor: Color.fromARGB(
                                                    255, 141, 21, 83),
                                                dotSecondaryColor:
                                                    Color.fromARGB(
                                                        255, 230, 123, 137),
                                              ),
                                              likeBuilder: (bool isLiked) {
                                                return Icon(
                                                  Icons
                                                      .favorite_border_outlined,
                                                  color: isLiked
                                                      ? Color.fromARGB(
                                                          255, 218, 50, 95)
                                                      : Color.fromARGB(
                                                          255, 213, 14, 14),
                                                  size: 40,
                                                );
                                              },
                                            ),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  sendReservation();
                                                },
                                                child: Text('Confirm')),
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
                                                      ReservationScreen(
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

  Future<CarRent> sendReservation() async {
    userModel userDetails;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(baseUrl + 'carrent'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'owner': DetailsModelCar!.sId.toString(),
        'tenant': prefs.getString('_id'),
        'car': DetailsModelCar!.sId!.toString(),
        'locationDatefrom': start.toString(),
        'locationDateto': end.toString()
      }),
    );
    if (response.statusCode == 201) {
      pdfCreator();
      return CarRent.fromJson(jsonDecode(response.body));
    } else {
      _showDialogErrorSubmit();
      return CarRent.fromJson(jsonDecode(response.body));
    }
  }
}

Future<Uint8List> _readImageData(String name) async {
  final data = await rootBundle.load(name);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
