import 'package:flutter/material.dart';
import 'package:pawpal/animated_route.dart';
import 'package:pawpal/loginscreen.dart';
import 'package:pawpal/mainscreen.dart';
import 'package:pawpal/user.dart';

class MyDrawer extends StatefulWidget {
  final User? user;
  
  const MyDrawer({super.key, required this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late double height;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

     return Drawer(
      child: ListView(
        children: [
          Center(
            child: UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(radius: 15, child: Text("A")),
              accountName: Text(widget.user?.name ?? "Guest"),
              accountEmail: Text(widget.user?.email ?? "Guest"),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
             Navigator.push(
                context,
                AnimatedRoute.slideFromRight(MainScreen(user: widget.user)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.pets),
            title: Text("My Pet"),
            onTap: () {
              // Navigator.push(
              //   context,
              //   AnimatedRoute.slideFromRight(Myservicepage(user: widget.user)),
              // );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Log out"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          const Divider(color: Colors.blue),
          SizedBox(
            height: height /3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text("Version 0.1", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}