import 'package:flutter/material.dart';
import 'package:pexelsapp/widget/custom_scroll.dart';
import 'package:pexelsapp/widget/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomScroll(),
      home: const HomePage(),
    );
  }
}