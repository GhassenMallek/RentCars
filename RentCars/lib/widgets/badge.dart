import 'package:flutter/material.dart';

import 'package:badges/badges.dart';

class QBadge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? color;

  const QBadge({
    Key? key,
    required this.child,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Badge(
      child: child,
      badgeContent: Text(value),
      badgeColor: color ?? Theme.of(context).colorScheme.secondary,
      position: BadgePosition.bottomStart(bottom: -5, start: -5),
    );
  }
}
