import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;

  const AppLogo({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_banner.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
  }
}
