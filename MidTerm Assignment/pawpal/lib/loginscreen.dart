import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pawpal/mainscreen.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/registerscreen.dart';
import 'package:pawpal/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passwordvisible = false;
  bool isChecked = false;
  late double height, width;
  late User user;

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  Image.asset('assets/images/pawpallogo.png', scale: 2),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.password),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordvisible = !passwordvisible;
                          });
                        },
                        icon: passwordvisible
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                      ),
                    ),
                    obscureText: !passwordvisible,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Row(
                      children: [
                        Text('Remember Me'),
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                            });
                            if (isChecked) {
                              if (emailController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Prefereces Saved"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                prefUpdate(isChecked);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please fill in email and password to save preferences",
                                    ),
                                    backgroundColor: Colors.yellow,
                                  ),
                                );
                                setState(() {
                                  isChecked = false;
                                });
                              }
                            } else {
                              prefUpdate(isChecked);
                              if (emailController.text.isEmpty &&
                                  passwordController.text.isEmpty) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Preferences Removed"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              emailController.clear();
                              passwordController.clear();
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        loginUser();
                      },
                      child: Text('Login'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text("Not yet have an account? Register"),
                  ),
                  TextButton(
                    onPressed: () {
                      User user = User(
                        userId: '0',
                        name: 'guest',
                        email: 'guest@email.com',
                        password: 'guest',
                        phone: '0000000000',
                        regDate: '0000-00-00',
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  MainScreen(user: user),
                        ),
                      );
                    },
                    child: Text("Login as Guest"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all the fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords must be more than or equal to 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print('before login');
    await http
        .post(
          Uri.parse("${Myconfig.baseURL}/pawpal/api/login_user.php"),
          body: {'email': email, 'password': password},
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            log(resarray.toString());

            if (resarray['success'] == true) {
              user = User.fromJson(resarray['data'][0]);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Login successful"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen(user: user)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login failed: ${response.statusCode}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  void prefUpdate(bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      prefs.setString("email", emailController.text.trim());
      prefs.setString("password", passwordController.text.trim());
      prefs.setBool("rememberme", isChecked);
    } else {
      prefs.remove("email");
      prefs.remove("password");
      prefs.remove("rememberme");
    }
  }

  void loadPref() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberme = prefs.getBool("rememberme");
      if (rememberme != null && rememberme) {
        String? email = prefs.getString("email");
        String? password = prefs.getString("password");
        setState(() {
          isChecked = true;
          emailController.text = email ?? '';
          passwordController.text = password ?? '';
        });
      }
    });
  }
}
