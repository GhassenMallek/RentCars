import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shop/screens/add_Cars.dart';
import 'package:shop/screens/edit_user_screen.dart';
import 'package:shop/screens/rentedCarListScreen.dart';
import 'package:store_redirect/store_redirect.dart';

import '../providers/auth.dart';
import '../screens/auth_screen.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final _dialog = RatingDialog(
    // your app's name?
    title: const Text(
      'Rate us',
      textAlign: TextAlign.center,
    ),
    // encourage your user to leave a high rating?
    // your app's logo?
    image: const FlutterLogo(size: 60),
    commentHint: 'Add comments',
    submitButtonText: 'Send',
    onSubmitted: (response) {
      log('rating: ${response.rating}, comment: ${response.comment}');

      if (response.rating < 3.0) {
        // send their comments to your email or anywhere you wish
        // ask the user to contact you instead of leaving a bad review
      } else {
        //go to app store
        StoreRedirect.redirect(androidAppId: '', iOSAppId: '');
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        children: [
          const SizedBox(height: 20),
          mListTile(
            context,
            Icons.person_pin_outlined,
            'Edit profile',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const EditUserScreen(),
                ),
              );
            },
          ),
          mListTile(
            context,
            Icons.directions_car_filled_outlined,
            'add your own car',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddCars(),
                ),
              );
            },
          ),
          mListTile(
            context,
            Icons.directions_car_filled_outlined,
            ' your used cars',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const RentedCar(),
                ),
              );
            },
          ),
          mListTile(
            context,
            Icons.star_border_outlined,
            'Rate us ',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _dialog,
              );
            },
          ),
          mListTile(
            context,
            Icons.exit_to_app_outlined,
            'Logout',
            onTap: () async {
              await Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => const AuthScreen(),
                ),
              );
            },
          ),
          const ExpansionTile(
            trailing: Icon(Icons.info_outline_rounded, size: 33),
            leading: Icon(Icons.arrow_drop_down_rounded, size: 33),
            title: Text(
              'About us ',
              style: TextStyle(fontSize: 26),
              textAlign: TextAlign.left,
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Car rental and utility rental for professionals and individuals',
                  style: TextStyle(fontSize: 26),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ListTile mListTile(BuildContext context, IconData? icon, String data,
      {Function()? onTap}) {
    return ListTile(
      title: Text(
        data,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 26,
          color: onTap == null
              ? Theme.of(context).colorScheme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.5)
              : null,
        ),
      ),
      trailing: Icon(icon, size: 33),
      leading: const Icon(Icons.arrow_back_ios),
      onTap: onTap,
    );
  }
}
