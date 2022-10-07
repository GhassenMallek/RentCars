import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cars.dart';
import 'package:shop/tabs.dart';

import '../models/http_exception.dart';
import '../widgets/custom_dropdown.dart';

class AddCars extends StatelessWidget {
  static const routeName = '/addCar';

  const AddCars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

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
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 25),
                        transform: Matrix4.rotationZ(0)..translate(1.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.teal[300],
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              color: Color(0x00000428),
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                        child: Text(
                          'Put your car',
                          style: TextStyle(
                            color: Colors.grey[50],
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      flex: deviceSize.width > 600 ? 6 : 17,
                      child: const CarsCard(),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarsCard extends StatefulWidget {
  const CarsCard({Key? key}) : super(key: key);
  @override
  _CarsCardState createState() => _CarsCardState();
}

class _CarsCardState extends State<CarsCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  File? singleImage;
  final singlePicker = ImagePicker();
  final Map<dynamic, dynamic> _carData = {
    'user': '',
    'brand': 'Choose a brand',
    'price': '',
    'image': '',
    'Model': '',
    'Description': '',
    'Criteria': '',
  };

  var _isLoading = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  List<String> carList = [
    'Alfa Romeo',
    'Audi',
    'BMW',
    'BYD',
    'Changan',
    'Chery',
    'Chevrolet',
    'Cupra',
    'Dacia',
    'DFSK',
    'Dongfeng',
    'Faw',
    'Fiat',
    'Foday',
    'Ford',
    'Geely',
    'Great Wall',
    'Haval',
    'Honda',
    'Huanghai',
    'Hyundai',
    'Jaguar',
    'Jeep',
    'KIA',
    'Land Rover',
    'Mercedes-Benz',
    'MG',
    'Porsche',
    'Renault',
    'Seat',
    'Skoda',
    'Soueast',
    'Ssangyong',
    'Suzuki',
    'Volkswagen',
    'Toyota',
    'Other'
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> body = {
        'user': _carData['user']!,
        'brand': _carData['brand']!,
        'price': _carData['price']!,
        'image': _carData['image']!,
        'Model': _carData['Model']!,
        'Description': _carData['Description']!,
        'Criteria': _carData['Criteria']!,
      };
      var addCar = await Provider.of<CarsProvider>(context, listen: false)
          .addNewCar(singleImage!, body);
      if (addCar == "good") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => const HomePage(),
          ),
        );
      }
    } on HttpException catch (error) {
      developer.log(error.toString());
      var errorMessage = 'Try again';

      _showErrorDialog(errorMessage);
      rethrow;
    } catch (error) {
      developer.log('Error: $error');
      const errorMessage = 'Try again';
      _showErrorDialog(errorMessage);
      setState(() => _isLoading = false);

      rethrow;
    }
    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Something wrong', textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
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

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final isLandScape = deviceSize.width > deviceSize.height;
    return Card(
      color: const Color(0x00000428),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 10.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: 650,
        constraints: const BoxConstraints(minHeight: 570),
        width: deviceSize.width * 0.85,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            getSingleImage();
                          },
                          child: singleImage == null
                              ? Container(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey,
                                      )),
                                  width: 100,
                                  height: 100,
                                  child: const Icon(
                                    CupertinoIcons.camera,
                                    color: Colors.grey,
                                  ),
                                )
                              : Container(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey,
                                      )),
                                  width: 100,
                                  height: 100,
                                  child: Image.file(
                                    singleImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ]),
                ),
                CustomDropdown(
                  carList,
                  (String? newValue) {
                    setState(() {
                      _carData['brand'] = newValue!;
                    });
                  },
                  _carData['brand']!,
                  title: 'Choose car\s brand ',
                ),
                TextFormField(
                  key: const ValueKey('price'),
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'price per day',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'invalid price';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _carData['price'] = val!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('Model'),
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 3)
                      return 'Model too short';
                    return null;
                  },
                  onSaved: (val) {
                    _carData['Model'] = val!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('Criteria'),
                  decoration: const InputDecoration(
                    hintText: 'Energy, speed...',
                    labelText: 'Criteria',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 3)
                      return 'Criteria too short';
                    return null;
                  },
                  onSaved: (val) {
                    _carData['Model'] = val!;
                  },
                ),
                TextFormField(
                  maxLength: 200,
                  maxLines: 5,
                  minLines: 1,
                  key: const ValueKey('Description'),
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (val) {
                    if (val!.isEmpty || val.length < 2) {
                      return 'Description too short';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _carData['Description'] = val!;
                  },
                ),
                AnimatedContainer(
                  constraints: const BoxConstraints(
                    minHeight: 20,
                    maxHeight: 65,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading) const CircularProgressIndicator(),
                Wrap(
                  direction: isLandScape ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 8),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          Colors.teal,
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          Colors.white,
                        ),
                      ),
                      child: const Text('Add car'),
                      onPressed: _submit,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getSingleImage() async {
    final pickedImage =
        await singlePicker.getImage(source: (ImageSource.gallery));
    setState(() {
      if (pickedImage != null) {
        singleImage = File(pickedImage.path);
      } else {
        print('No Image Selected');
      }
    });
  }
}
