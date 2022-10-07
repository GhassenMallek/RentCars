import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/confirmphoneScreen.dart';
import 'package:shop/utils/const.dart';
import '../models/http_exception.dart';
import '../providers/auth.dart';
import '../tabs.dart';
import '../widgets/custom_dropdown.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

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
                          'WELCOME',
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
                      child: const AuthCard(),
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

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  File? singleImage;
  final singlePicker = ImagePicker();
  final Map<dynamic, dynamic> _authData = {
    'name': '',
    'email': '',
    'phone_number': '',
    'governorate': 'Choose your state',
    'region': '',
    'password': '',
  };

  var _isLoading = false;

  final _paswordController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  List<String> governorateList = [
    'Ariana',
    'Béja',
    'Ben Arous',
    'Bizerte',
    'Gabès',
    'Gafsa',
    'Jendouba',
    'Kairouan',
    'Kasserine',
    'Kebili',
    'Kef',
    'Mahdia',
    'Manouba',
    'Medenine',
    'Monastir',
    'Nabeul',
    'Sfax',
    'Sidi Bouzid',
    'Siliana',
    'Sousse',
    'Tataouine',
    'Tozeur',
    'Tunis',
    'Zaghouan'
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
    _paswordController.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      _authMode;
      if (_authMode == AuthMode.Login) {
        Map<String, String> body = {
          'email': _authData['email'].toString(),
          'password': _authData['password'].toString()
        };

        var login = await Provider.of<Auth>(context, listen: false).login(body);
        if (login == "good") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => const HomePage(),
            ),
          );
        } else if (login == "Confirm your adress mail") {
          const errorMessage = 'Confirm your adress mail';
          _showErrorDialog(errorMessage);
          setState(() => _isLoading = false);
        } else if (login == "check email or password") {
          const errorMessage = 'Invalid email or password';
          _showErrorDialog(errorMessage);
          setState(() => _isLoading = false);
        } else if (login == "Invalid user") {
          const errorMessage = 'Invalid user';
          _showErrorDialog(errorMessage);
          setState(() => _isLoading = false);
        } else {
          const errorMessage = 'try again';
          _showErrorDialog(errorMessage);
          setState(() => _isLoading = false);
        }
      }

      if (_authMode == AuthMode.SignUp) {
        Map<String, dynamic> body = {
          'name': _authData['name']!,
          'email': _authData['email']!,
          'phone_number': _authData['phone_number']!,
          'governorate': _authData['governorate']!,
          'region': _authData['region']!,
          'password': _authData['password']!,
        };
        var signup = await Provider.of<Auth>(context, listen: false)
            .createAccount(singleImage!, body);
        if (signup == "good") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => const ConfirmPhone(),
            ),
          );
        }
        if (signup == "nope") {
          const errorMessage = ' mail already exists';
          _showErrorDialog(errorMessage);
          setState(() => _isLoading = false);
        }
      }
    } on HttpException catch (error) {
      developer.log(error.toString());
      var errorMessage = 'Try again';
      if (error.toString().contains('Confirm your adress mail')) {
        errorMessage = 'Phone number is required';
      }

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

  void _showDialogTerms() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy policy', textAlign: TextAlign.center),
        content: const Text(
            'By accepting the privacy policy, your car is ready to be rented when it is available.'
            'All cars posted in Rental car application should be in good conditions, otherwise the owner will be banned with hefty fines in the case of accident caused by safety related to shown cars.  '
            'You can\'t decline any rental offer.'
            'You can choose to custom or to accept our contract.'
            'In the case of contract was signed, the contract couldn\'t be cancelled by the car\'s owner or the tenant, or both will be banned.'
            'The tenant should pay the location fee, or he will be banned.'
            'The Parties agree that this Agreement terminates upon the End Date specified in application. Not with standing anything to.'
            'Owner Warranty'
            'The Owner represents that to the best of his knowledge and belief that the Vehicle is in sound and safe condition and free of any known faults or defects that would affect its safe operation under normal use. ',
            textAlign: TextAlign.left),
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

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
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
        height: _authMode == AuthMode.SignUp ? 650 : 210,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 700 : 300),
        width: deviceSize.width * 0.85,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_authMode == AuthMode.SignUp)
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
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    key: const ValueKey('name'),
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val!.isEmpty || val.length < 7)
                        return 'name is too short';
                      return null;
                    },
                    onSaved: (val) {
                      _authData['name'] = val!;
                    },
                  ),
                TextFormField(
                  key: const ValueKey('email'),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 7) return 'Invalid email';
                    return null;
                  },
                  onSaved: (val) {
                    _authData['email'] = val!;
                  },
                ),
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    key: const ValueKey('phone_number'),
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val!.isEmpty || val.length < 8) {
                        return 'invalid phone number';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _authData['phone_number'] = '+216' + val!;
                      constPhoneNumber = '216' + val;
                    },
                  ),
                if (_authMode == AuthMode.SignUp)
                  CustomDropdown(
                    governorateList,
                    (String? newValue) {
                      setState(() {
                        _authData['governorate'] = newValue!;
                      });
                    },
                    _authData['governorate']!,
                    title: 'State ',
                  ),
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    key: const ValueKey('region'),
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val!.isEmpty || val.length < 7)
                        return 'Address too short';
                      return null;
                    },
                    onSaved: (val) {
                      _authData['region'] = val!;
                    },
                  ),
                TextFormField(
                  key: const ValueKey('password'),
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  controller: _paswordController,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 2) {
                      return 'Password too short';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['password'] = val!;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.SignUp ? 20 : 0,
                    maxHeight: _authMode == AuthMode.SignUp ? 65 : 0,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        textDirection: TextDirection.ltr,
                        enabled: _authMode == AuthMode.SignUp,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: _authMode == AuthMode.SignUp
                            ? (val) {
                                if (val != _paswordController.text) {
                                  return 'Passwords didn’t match. Try again.';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
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
                      child: Text(
                          _authMode == AuthMode.Login ? 'Sign In' : 'Sign Up'),
                      onPressed: _submit,
                    ),
                    TextButton(
                      child: Text(
                        '${_authMode == AuthMode.Login ? 'Create account' : 'Try to login'}  ',
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      onPressed: _switchAuthMode,
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 4),
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          Colors.blue[100],
                        ),
                      ),
                    ),
                    if (_authMode == AuthMode.SignUp)
                      RichText(
                        text: TextSpan(
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 8),
                            children: <TextSpan>[
                              const TextSpan(text: 'By clicking signup, '),
                              const TextSpan(
                                  text:
                                      ' I state that I have read and understood '),
                              TextSpan(
                                  text: 'the terms and conditions .',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _showDialogTerms();
                                    }),
                            ]),
                      )
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
