import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cars.dart';
import 'package:shop/screens/CarRentedDetails.dart';
import 'package:shop/screens/add_Cars.dart';
import 'package:shop/screens/confirmphoneScreen.dart';
import 'package:shop/screens/ownerDetails.dart';
import 'package:shop/screens/rentedCarListScreen.dart';
import 'package:shop/screens/reservation.dart';
import 'package:shop/screens/splash_screen.dart';

import './providers/auth.dart';
import './providers/cart.dart';
import './providers/products.dart';
import './providers/theme_provider.dart';
import './screens/edit_user_screen.dart';
import 'screens/car_detail_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) {
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: CarsProvider()),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProvider.value(value: Products()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false).getThemeMode();
    var tm = Provider.of<ThemeProvider>(context, listen: true).themeMode;
    return Consumer<Auth>(
      builder: (ctx, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RentCar',
          themeMode: tm,
          darkTheme: ThemeData(
            canvasColor: const Color(0xFFedf0ef), //#edf0ef #e0e0e0
            colorScheme: ColorScheme.fromSwatch(
              cardColor: Color(0xFFedf0ef),
              primarySwatch: Colors.deepOrange,
              brightness: Brightness.light,
            ).copyWith(
              secondary: Colors.deepOrange,
            ),
          ),
          theme: ThemeData(
            canvasColor: const Color(0xFF1D1E33), //#1d232f  FF1D1E33
            dialogBackgroundColor: const Color(0xFF1D3462),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.teal,
              brightness: Brightness.dark,
            ).copyWith(
              secondary: Colors.deepOrange,
            ),
          ),
          home: const MySplash(),
          routes: {
            ProductDetailScreen.routeName: (_) => const ProductDetailScreen(
                  id: '',
                ),
            RentedCar.routeName: (_) => const RentedCar(),
            CarRentedDetailsScreen.routeName: (_) =>
                const CarRentedDetailsScreen(id: ''),
            ReservationScreen.routeName: (_) => const ReservationScreen(id: ''),
            EditUserScreen.routeName: (_) => const EditUserScreen(),
            AddCars.routeName: (_) => const AddCars(),
            ConfirmPhone.routeName: (_) => const ConfirmPhone(),
            OwnerDetails.routeName: (_) => const OwnerDetails(
                  id: '',
                ),
          },
        );
      },
    );
  }
}
