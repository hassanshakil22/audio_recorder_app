import 'package:audiorecorder_app/audioPlayerView.dart';
import 'package:audiorecorder_app/homeView.dart';
import 'package:audiorecorder_app/splashView.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        home: const SplashView(),
        // debugShowCheckedModeBanner: false,
        theme: ThemeData());
  }
}
