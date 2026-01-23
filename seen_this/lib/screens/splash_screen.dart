import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/seen_this_logo.png',
          width: screenSize.width,
          height: screenSize.height * 0.6,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
