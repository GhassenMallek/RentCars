import 'package:flutter/material.dart';

enum TabItem { one, two, three, four }

const Map<TabItem, String> tabName = {
  TabItem.one: 'Home',
  TabItem.two: 'MyContarcts',
  TabItem.three: 'Favourites',
  TabItem.four: 'Account',
};

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.one: Colors.red,
  TabItem.two: Colors.blue,
  TabItem.three: Colors.purple,
  TabItem.four: Colors.green,
};
