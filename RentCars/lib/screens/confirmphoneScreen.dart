import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/auth_screen.dart';

import '../providers/auth.dart';
import '../utils/const.dart';

class ConfirmPhone extends StatefulWidget {
  static const routeName = '/ConfirmPhone';

  const ConfirmPhone({Key? key}) : super(key: key);

  @override
  State<ConfirmPhone> createState() => _ConfirmPhoneState();
}

class _ConfirmPhoneState extends State<ConfirmPhone> {
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
                          'Continue with phone',
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
  final Map<dynamic, dynamic> _authData = {
    //phone_number: 0,
    'ValidatorCode': '',
  };
  var _isLoading = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

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
    // Map<String, dynamic> body = {
    //   'phone_number': phoneNumber,
    //   'ValidatorCode': _authData['ValidatorCode']!
    // };
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    print(_authData['ValidatorCode']!);
    var login = await Provider.of<Auth>(context, listen: false)
        .confirmPhon(_authData['ValidatorCode']!);
    if (login == "good") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => const AuthScreen(),
        ),
      );
    } else if (login == "Confirm your adress mail") {
      const errorMessage = 'Confirm your adress mail';
      _showErrorDialog(errorMessage);
      setState(() => _isLoading = false);
    } else {
      const errorMessage = 'try again';
      _showErrorDialog(errorMessage);
      setState(() => _isLoading = false);
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

  void resendCode() async {
    print('+' + constPhoneNumber.toString());
    await Provider.of<Auth>(context, listen: false).Resend();
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
        height: 250,
        constraints: const BoxConstraints(minHeight: 50),
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
                      ]),
                ),
                TextFormField(
                  key: const ValueKey('ValidatorCode'),
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'Validator Code',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'invalid code';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['ValidatorCode'] = val;
                    ;
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
                      child: const Text('Confirm '),
                      onPressed: _submit,
                    ),
                    TextButton(
                      child: const Text(
                        'You didn\'t recieve code ? try again',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      onPressed: resendCode,
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 4),
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          Colors.blue[100],
                        ),
                      ),
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
}
