import 'package:flutter/material.dart';
import 'package:pawpal/loginscreen.dart';
import 'package:pawpal/user.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PawPal'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: widget.user!.userId == "0"
            ? Text('Welcome to PawPal!')
            : Text("Hello, ${widget.user!.name}!. Welcome back to PawPal !"),
      ),

      floatingActionButton: ElevatedButton(
        onPressed: () {
          if (widget.user!.userId == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
