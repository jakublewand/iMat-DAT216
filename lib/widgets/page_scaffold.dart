import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/widgets/app_navbar.dart';

class PageScaffold extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const PageScaffold({required this.child, this.backgroundColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor ?? Colors.white,
        child: SafeArea(
          child: Column(children: [AppNavbar(), Expanded(child: child)]),
        ),
      ),
    );
  }
}
