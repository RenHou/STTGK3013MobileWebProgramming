import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/loginscreen.dart';
import 'package:pawpal/mainscreen.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String email = "";
  String password = "";

  @override
  void initState() {
    super.initState();
    autologin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/pawpallogo.png', scale: 2),
            SizedBox(height: 10),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(
              "Loading...",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  void autologin() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberme = prefs.getBool("rememberme");
      if (rememberme != null && rememberme) {
        email = (prefs.getString("email")) ?? "";
        password = (prefs.getString("password")) ?? "";

        http
            .post(
              Uri.parse("${Myconfig.baseURL}/pawpal/api/login_user.php"),
              body: {"email": email, "password": password},
            )
            .then((response) {
              if (response.statusCode == 200) {
                var jsondata = jsonDecode(response.body);
                if (jsondata['status'] == 'success') {
                  if (!mounted) return;
                  Future.delayed(Duration(seconds: 3), () {
                    User user = User.fromJson(jsondata['data'][0]);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(user: user),
                      ),
                    );
                  });
                } else {
                  if (!mounted) return;
                  Future.delayed(Duration(seconds: 3), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  });
                }
              } else {
                if (!mounted) return;
                Future.delayed(Duration(seconds: 3), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                });
              }
            });
      } else {
        if (!mounted) return;
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      }
    });
  }
}
