import 'package:assignment/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialScreen());
}

class MaterialScreen extends StatelessWidget {
  const MaterialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}
