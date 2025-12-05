import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/user.dart';

class SubmitPetScreen extends StatefulWidget {
  final User? user;

  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  late double height, width;
  late Position myPosition;

  List<Uint8List?> webImages = [null, null, null];
  List<File?> images = [null, null, null];
  List<String> categories = ['Adoption', 'Donation', 'Help'];
  TextEditingController petNameController = TextEditingController();
  TextEditingController petTypeController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  String selectedCategory = 'Adoption';
  bool isLoading = false;
  int maxImageNum = 3;

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
      appBar: AppBar(title: Text('New Pet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                TextField(
                  controller: petNameController,
                  decoration: InputDecoration(
                    labelText: 'Pet Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: petTypeController,
                  decoration: InputDecoration(
                    labelText: 'Pet Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedCategory = newValue!;
                    setState(() {});
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: latitudeController,
                  decoration: InputDecoration(
                    labelText: 'latitude',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: getLocation,
                      icon: Icon(Icons.location_on_sharp),
                    ),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: longitudeController,
                  decoration: InputDecoration(
                    labelText: 'longitude',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: getLocation,
                      icon: Icon(Icons.location_on_sharp),
                    ),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Images:", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),

                    // Generate up to 3 boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(maxImageNum, (index) {
                        // Only show slot if previous slot is filled OR it's first slot
                        if (index == 0 ||
                            images[index - 1] != null ||
                            webImages[index - 1] != null) {
                          return GestureDetector(
                            onTap: () {
                              if (kIsWeb) {
                                openGallery(index);
                              } else {
                                pickImageDialog(index);
                              }
                            },
                            child: Container(
                              width: width / 3.5,
                              height: height / 10.5,
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.grey.shade400),
                                image: (images[index] != null && !kIsWeb)
                                    ? DecorationImage(
                                        image: FileImage(images[index]!),
                                        fit: BoxFit.cover,
                                      )
                                    : (webImages[index] != null)
                                    ? DecorationImage(
                                        image: MemoryImage(webImages[index]!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  (images[index] == null &&
                                      webImages[index] == null)
                                  ? Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey,
                                      size: 30,
                                    )
                                  : null,
                            ),
                          );
                        }
                        return Container(); // hidden slot
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(width, 50),
                      ),
                      onPressed: showSubmitDialog,
                      child: Text('Submit', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pickImageDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> openCamera(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImages[index] = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        images[index] = File(pickedFile.path);
        cropImage(index);
      }
    }
  }


  Future<void> openGallery(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImages[index] = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        images[index] = File(pickedFile.path);
        cropImage(index); // only for mobile
      }
    }
  }

  Future<void> cropImage(int index) async {
    if (kIsWeb) return; // skip cropping on web
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: images[index]!.path,
      aspectRatio: CropAspectRatio(ratioX: 5, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Please Crop Your Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );

    if (croppedFile != null) {
      images[index] = File(croppedFile.path);
      setState(() {});
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void getLocation() async {
    isLoading = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading...'),
          ],
        ),
      ),
    );
    myPosition = await _determinePosition();

    latitudeController.text = myPosition.latitude.toString();
    longitudeController.text = myPosition.longitude.toString();

    if (isLoading) {
      Navigator.pop(context);
      isLoading = false;
    }
    setState(() {});
  }

  void showSubmitDialog() {
    if (petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Pet Name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (petTypeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Pet Type"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Pet Name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (latitudeController.text.trim().isEmpty ||
        longitudeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please click the location icon to get the latitude and longitude",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (descController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The description is too short"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (webImages[0] == null && images[0] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide at least one image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Pet'),
          content: const Text('Are you sure you want to submit this?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                submitPet();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void submitPet() {
    String petName = petNameController.text.trim();
    String petType = petTypeController.text.trim();
    String category = selectedCategory.trim();
    String latitude = latitudeController.text.trim();
    String longitude = longitudeController.text.trim();
    String desc = descController.text.trim();
    List<String> base64Images = [];

    if (kIsWeb) {
      for (int i = 0; i < maxImageNum && webImages[i] != null; i++) {
        base64Images.add(base64Encode(webImages[i]!));
      }
    } else {
      for (int i = 0; i < maxImageNum && images[i] != null; i++) {
        base64Images.add(base64Encode(images[i]!.readAsBytesSync()));
      }
    }

    http
        .post(
          Uri.parse("${Myconfig.baseURL}/pawpal/api/submit_pet.php"),

          body: {
            "userid": widget.user!.userId,
            "name": petName,
            "type": petType,
            "category": category,
            "latitude": latitude,
            "longitude": longitude,
            "description": desc,
            "images": jsonEncode(base64Images),
          },
        )
        .then((response) {
          print(response.body);
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            if (resarray['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
  }
}
