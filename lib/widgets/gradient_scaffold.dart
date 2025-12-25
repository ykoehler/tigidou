import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.black],
          ),
        ),
        child: SafeArea(top: appBar != null, bottom: false, child: body),
      ),
    );
  }
}
