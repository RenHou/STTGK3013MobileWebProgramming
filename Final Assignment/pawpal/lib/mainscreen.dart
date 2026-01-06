import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/loginscreen.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/mydrawer.dart';
import 'package:pawpal/mypet.dart';
import 'package:pawpal/petdetailscreen.dart';
import 'package:pawpal/submitpetscreen.dart';
import 'package:pawpal/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  User? user;

  MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<MyPet?> listPets = [];
  String status = "Loading...";
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
  late double width, height;
  List<String> types = ['All', 'Dog', 'Cat', 'Rabbit', 'Other'];
  String selectedType = 'All';
  TextEditingController nameController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  List<String> donationTypes = ['Food', 'Medical', 'Money'];
  String selectedDonationType = 'Food';
  TextEditingController donationAmountController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadPets("", "");
    loadProfile();
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
      appBar: AppBar(
        title: Text('PawPal'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),

        actions: [
          IconButton(onPressed: submitPet, icon: Icon(Icons.add)),
          IconButton(
            onPressed: () {
              selectedType = 'All';
              nameController.text = '';
              loadPets("", "");
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: MyDrawer(user: widget.user),
      body: Center(
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              // 🔍 SEARCH + FILTER BAR
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // SEARCH BY NAME
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: nameController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          loadPets(value, selectedType);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search pet name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // FILTER BY TYPE
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        isDense: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: types
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          selectedType = value!;
                          loadPets(nameController.text, selectedType);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              listPets.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.find_in_page_outlined, size: 64),
                            SizedBox(height: 12),
                            Text(
                              status,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: listPets.length,
                        itemBuilder: (BuildContext context, int index) {
                          String imagePath =
                              listPets[index]!.imagePaths!; // in Json format
                          String firstImage = jsonDecode(
                            imagePath,
                          )[0]; // example: uploads/pet_1_0.png

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // IMAGE
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: width * 0.28, // more responsive
                                      height:
                                          width * 0.22, // balanced aspect ratio
                                      color: Colors.grey[200],
                                      child: Image.network(
                                        '${Myconfig.baseURL}/pawpal/api/$firstImage',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.broken_image,
                                                size: 60,
                                                color: Colors.grey,
                                              );
                                            },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // TEXT AREA
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // NAME
                                        Text(
                                          listPets[index]!.petName.toString(),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        // TYPE
                                        const SizedBox(height: 4),
                                        Text(
                                          listPets[index]!.petType.toString(),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 4),
                                        // DESCRIPTION
                                        Text(
                                          listPets[index]!.description
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 6),

                                        // CATEGORY TAG
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            listPets[index]!.category
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // TRAILING ARROW BUTTON
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PetDetailScreen(
                                            pet: listPets[index]!,
                                            user: widget.user,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void submitPet() async {
    if (widget.user!.userId == "0") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please login to submit pets!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubmitPetScreen(user: widget.user),
        ),
      );
      loadPets("", "");
    }
  }

  void loadPets(String name, String type) {
    listPets.clear();
    setState(() {
      status = "Loading...";
    });
    if (type == 'All') {
      type = '';
    }
    http
        .get(
          Uri.parse(
            '${Myconfig.baseURL}/pawpal/api/get_my_pets.php?searchQuery=$name&filterQuery=$type',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            
            if (jsonResponse['success'] == 'true' &&
                jsonResponse['data'] != null &&
                jsonResponse['data'].isNotEmpty) {
              // has data → load to list
              listPets.clear();
              for (var item in jsonResponse['data']) {
                listPets.add(MyPet.fromJson(item));
              }

              setState(() {
                status = "";
              });
            } else {
              // success but EMPTY data
              setState(() {
                listPets.clear();
                status = "No submissions yet";
              });
            }
          } else {
            // request failed
            setState(() {
              listPets.clear();
              status = "Failed to load services";
            });
          }
        });
  }

  void loadProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('user')) {
      setState(() {
        widget.user = User.fromJson(jsonDecode(pref.getString('user')!));
      });
    }
  }
}
