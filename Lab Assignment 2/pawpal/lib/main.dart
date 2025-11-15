import 'package:flutter/material.dart';
import 'package:pawpal/splashscreen.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override


  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawPal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
        
  }
}
