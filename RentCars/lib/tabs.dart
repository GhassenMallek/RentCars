import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/favourite.dart';
import 'package:shop/tabs/favourites.dart';

import 'providers/auth.dart';
import 'providers/products.dart';
import 'providers/theme_provider.dart';
import 'tab_items.dart';
import 'tabs/account.dart';
import 'tabs/cart.dart';
import 'tabs/home.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _currentTab = TabItem.one;

  void _selectTab(TabItem tabItem) {
    setState(() => _currentTab = tabItem);
  }

  @override
  Widget build(BuildContext context) {
    var tm = Provider.of<ThemeProvider>(context, listen: true).themeMode;
    final auth = Provider.of<Auth>(context, listen: false);
    final bool isAuth = auth.isAuth;
    final products = Provider.of<Products>(context, listen: false);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: (_currentTab != TabItem.one)
            ? AppBar(
                shape: const MyShapeBorder(20),
                backgroundColor: Color.fromARGB(255, 137, 138, 148),
                elevation: 0,
                actions: [
                  if (auth.name != null)
                    IconButton(
                      icon: Icon(tm == ThemeMode.light
                          ? Icons.dark_mode
                          : Icons.wb_sunny),
                      onPressed: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .changeMode(tm == ThemeMode.light ? 'd' : 'l');
                      },
                    ),
                ],
              )
            : null,
        body: _buildBody(),
        bottomNavigationBar: BottomNavigation(
          currentTab: _currentTab,
          onSelectTab: _selectTab,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_currentTab == TabItem.one)
      return const Home();
    else if (_currentTab == TabItem.two)
      return const CartPage();
    else if (_currentTab == TabItem.three) {
      return Favourites();
    } else {
      return const Account();
    }
  }
}

class MyShapeBorder extends ContinuousRectangleBorder {
  const MyShapeBorder(this.curveHeight);
  final double curveHeight;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..lineTo(0, rect.size.height)
    ..quadraticBezierTo(
      rect.size.width / 114,
      rect.size.height + curveHeight * 1.5,
      rect.size.width,
      rect.size.height,
    )
    ..lineTo(rect.size.width, 0)
    ..close();
}

class BottomNavigation extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  const BottomNavigation(
      {Key? key, required this.currentTab, required this.onSelectTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentTab.index,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        _buildItem(TabItem.one),
        _buildItem(TabItem.two),
        _buildItem(TabItem.three),
        _buildItem(TabItem.four),
      ],
      onTap: (index) => onSelectTab(
        TabItem.values[index],
      ),
      height: 60,
      backgroundColor: Theme.of(context).canvasColor,
      color: Theme.of(context).canvasColor.computeLuminance() > 0.5
          ? Color.fromARGB(255, 204, 205, 226)
          : const Color(0xFFedf0ef),
    );
  }

  _buildItem(TabItem tabItem) {
    return Icon(
      tabItem == TabItem.one
          ? Icons.home_outlined
          : tabItem == TabItem.three
              ? Icons.favorite_outline
              : tabItem == TabItem.two
                  ? Icons.file_copy_outlined
                  : Icons.person_outline,
      color: currentTab == tabItem
          ? activeTabColor[tabItem]
          : Color.fromARGB(255, 32, 64, 81),
    );
  }
}
