import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/loginscreen.dart';
import 'package:pawpal/myconfig.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController comfirmpasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool passwordvisible = false;
  bool comfirmpasswordvisible = false;
  late double height, width;
  bool isloading = false;

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
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  Image.asset('assets/images/pawpallogo.png', scale: 2),
                  
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
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
                  TextField(
                    controller: comfirmpasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.password),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            comfirmpasswordvisible = !comfirmpasswordvisible;
                          });
                        },
                        icon: comfirmpasswordvisible
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                      ),
                    ),
                    obscureText: !comfirmpasswordvisible,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        registerDialog();
                      },
                      child: Text('Register'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text('Already have an account? Login here'),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void registerDialog() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmpassword = comfirmpasswordController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmpassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all the fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmpassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration'),
        content: Text(
          'Do you want to register with the following details?\n\n'
          'Name: $name\n'
          'Email: $email\n'
          'Phone: $phone',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close the comfimation dialog
              registerUser(name, email, password, phone);
            },
            child: Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);// close the comfimation dialog
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void registerUser(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    setState(() {
      isloading = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Registering...'),
          ],
        ),
      ),
    );
    await http
        .post(
          Uri.parse("${Myconfig.baseURL}/pawpal/api/register_user.php"),
          body: {
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            log(resarray.toString());
            if (resarray['success'] == true) {
              if (!mounted) return;
              if (isloading) {
                Navigator.pop(context); // close the loading dialog
                setState(() {
                  isloading = false;
                });
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registration Successful'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            } else {
              if (!mounted) return;
              if (isloading) {
                Navigator.pop(context);
                setState(() {
                  isloading = false;
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            if (!mounted) return;
            if (isloading) {
              Navigator.pop(context);
              setState(() {
                isloading = false;
              });
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration Failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        })
        .timeout(
          Duration(seconds: 10),
          onTimeout: () {
            if (!mounted) return;
            SnackBar snackBar = const SnackBar(
              content: Text('Request timed out. Please try again.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        );
        if (!mounted) return;
        if(isloading){
          Navigator.pop(context);
          setState(() {
            isloading = false;
          });
        }
  }
}
