import 'package:flutter/material.dart';

import '../widgets/custom_dropdown.dart';

class EditUserScreen extends StatefulWidget {
  static const routeName = '/edit_user';

  const EditUserScreen({Key? key}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _phoneNumberFocusNode = FocusNode();
  final _regionFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _paswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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

  Map<String, String> _authData = {
    'name': '',
    'phone_number': '',
    'governorate': '',
    'region': '',
    'password': '',
    'password_confirmation': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _phoneNumberFocusNode.dispose();
    _regionFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _paswordController.dispose();
  }

  // Future<void> _saveForm() async {
  //   final isValid = _formKey.currentState!.validate();
  //   if (!isValid) {
  //     return;
  //   }
  //   _formKey.currentState!.save();
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     await Provider.of<Auth>(context, listen: false).update(
  //       _authData['name']!,
  //       _authData['phone_number']!,
  //       _authData['governorate']!,
  //       _authData['region']!,
  //       _authData['password']!,
  //       _authData['password_confirmation']!,
  //     );
  //   } catch (e) {
  //     log('Error: $e');
  //     await showDialog(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         title: const Text('خطأ'),
  //         content: const Text('حدث خطأ ما'),
  //         actionsAlignment: MainAxisAlignment.start,
  //         actions: [
  //           TextButton(
  //             child: const Text('موافق'),
  //             onPressed: () => Navigator.of(ctx).pop(),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });
  //   Navigator.of(context).pop();
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D1E33),
          elevation: 0,
          title: const Text('Edit profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {},
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            // key: ,
            child: ListView(
              children: [
                TextFormField(
                  key: const ValueKey('name'),
                  initialValue: _authData['name'],
                  decoration: const InputDecoration(labelText: 'name'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_phoneNumberFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7)
                      return 'name too short';
                    return null;
                  },
                  onSaved: (val) {
                    _authData['name'] = val!;
                  },
                ),
                TextFormField(
                  textDirection: TextDirection.ltr,
                  key: const ValueKey('phone_number'),
                  initialValue: _authData['phone_number'],
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  focusNode: _phoneNumberFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_regionFocusNode);
                  },
                  validator: (val) {
                    if (val!.isEmpty || val.length != 8) {
                      return 'Invalid phone number';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['phone_number'] = val!;
                  },
                ),
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
                TextFormField(
                  key: const ValueKey('region'),
                  initialValue: _authData['region'],
                  decoration: const InputDecoration(labelText: 'Address'),
                  keyboardType: TextInputType.text,
                  focusNode: _regionFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  validator: (val) {
                    if (val!.isEmpty || val.length < 7)
                      return 'Address too short';
                    return null;
                  },
                  onSaved: (val) {
                    _authData['region'] = val!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const ValueKey('password'),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  controller: _paswordController,
                  focusNode: _passwordFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocusNode);
                  },
                  validator: (val) {
                    if (val!.isEmpty || val.length < 6) {
                      return 'Password too short';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['password'] = val!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('password_confirmation'),
                  decoration:
                      const InputDecoration(labelText: 'Confirm password'),
                  keyboardType: TextInputType.text,
                  focusNode: _confirmPasswordFocusNode,
                  obscureText: true,
                  validator: (val) {
                    if (val != _paswordController.text) {
                      return 'Passwords didn’t match.';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['password_confirmation'] = val!;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
