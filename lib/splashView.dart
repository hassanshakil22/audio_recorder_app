import 'package:audiorecorder_app/homeView.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                const Homeview()), // Replace with your next screen
      );
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color(0xFfd9d9d9),
      body: Center(
          child: Image.asset(
              'C:/Users/HP/Desktop/apps/audiorecorder_app/lib/assets/splash.png')),
    );
  }
}
