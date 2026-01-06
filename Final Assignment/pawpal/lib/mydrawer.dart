import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawpal/animated_route.dart';
import 'package:pawpal/loginscreen.dart';
import 'package:pawpal/mainscreen.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/mydonation.dart';
import 'package:pawpal/myprofile.dart';
import 'package:pawpal/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatefulWidget {
  User? user;

  MyDrawer({super.key, required this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  late double height;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> refreshFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user')) return;

    final userJson = prefs.getString('user')!;
    final user = User.fromJson(jsonDecode(userJson));

    if (mounted) {
      setState(() {
        widget.user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    return Drawer(
      child: ListView(
        children: [
          Center(
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFFF9800)),
              currentAccountPicture: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.orange,
                child: ClipOval(
                  child: Image.network(
                    '${Myconfig.baseURL}/pawpal/api/userimages/${widget.user!.userId}.png',
                    fit: BoxFit.cover,
                    width: 70,
                    height: 70,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          widget.user?.name?.substring(0, 1).toUpperCase() ??
                              '',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Color(0xFFFF9800),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              accountName: Text(
                widget.user?.name ?? "Guest",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(widget.user?.email ?? "Guest"),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFFFF9800)),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(MainScreen(user: widget.user)),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.volunteer_activism,
              color: Color(0xFFFF9800),
            ),
            title: const Text("My Donation"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(MyDonation(user: widget.user)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFFFF9800)),
            title: const Text("Profile"),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                AnimatedRoute.slideFromRight(MyProfile(user: widget.user)),
              );
              await loadProfile();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log out"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await SharedPreferences.getInstance().then(
                          (value) => value.remove("user"),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            height: height / 3,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "PawPal",
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text("Version 0.1", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('user')) {
      if (mounted) {
        setState(() {
          widget.user = User.fromJson(jsonDecode(pref.getString('user')!));
        });
      }
    }
  }
}
