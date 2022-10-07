import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tabs.dart';
import 'auth_screen.dart';

class MySplash extends StatefulWidget {
  const MySplash({Key? key}) : super(key: key);

  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  late Future<bool> fetchedUser;

  Future<bool> fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("email") != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => const HomePage(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => const AuthScreen(),
        ),
      );
    }
    return true;
  }

  @override
  void initState() {
    fetchedUser = fetchUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchedUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyWidget(nextScreen: const AuthScreen());
        } else {
          return MyWidget(nextScreen: const HomePage());
        }
      },
    );
  }
}

class MyWidget extends StatelessWidget {
  Widget nextScreen;
  MyWidget({required this.nextScreen, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 50,
      nextScreen: nextScreen,
      splashTransition: SplashTransition.fadeTransition,
      splash: const Text('Rent car', style: TextStyle(fontSize: 80)),
      splashIconSize: 400,
      backgroundColor: const Color(0xFF1D1E33),
    );
  }
}
