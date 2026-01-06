import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/mydrawer.dart';
import 'package:pawpal/paymentpage.dart';
import 'package:pawpal/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  User? user;
  MyProfile({super.key, required this.user});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final GlobalKey<State<MyDrawer>> drawerKey = GlobalKey<State<MyDrawer>>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  int amount = 0;
  Image? profileImage;
  Uint8List? webImage;
  File? image;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    nameController.text = widget.user?.name.toString() ?? '';
    phoneController.text = widget.user?.phone ?? '';
    emailController.text = widget.user?.email ?? '';
    amount = widget.user?.walletBalanceCents ?? 0;
    setState(() {});
  }

  // ================= LOAD PROFILE IMAGE =================
  void pickImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick Profile Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        image = File(pickedFile.path);
        cropImage();
      }
    }
  }

  Future<void> openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        image = File(pickedFile.path);
        cropImage(); // only for mobile
      }
    }
  }

  Future<void> cropImage() async {
    if (kIsWeb) return; // skip cropping on web
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
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
      image = File(croppedFile.path);
      setState(() {});
    }
  }

  // ================= UPDATE PROFILE =================
  Future<void> _updateProfile() async {
    String base64image = "NA";
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    if (kIsWeb) {
      if (webImage != null) {
        base64image = base64Encode(webImage!);
      } else {
        base64image = "NA";
      }
    } else {
      if (image == null) {
        base64image = "NA";
      } else {
        base64image = base64Encode(image!.readAsBytesSync());
      }
    }
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${Myconfig.baseURL}/pawpal/api/update_profile.php'),
        body: {
          'user_id': widget.user?.userId,
          'user_name': nameController.text,
          'user_phone': phoneController.text,
          'user_email': emailController.text,
          'user_image': base64image,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
          loadProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Update failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server Error: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void loadProfile() {
    http
        .get(
          Uri.parse(
            '${Myconfig.baseURL}/pawpal/api/getuserdetails.php?userid=${widget.user!.userId}',
          ),
        )
        .then((response) async {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            if (resarray['success'] == true) {
              User user = User.fromJson(resarray['data'][0]);

              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.setString('user', jsonEncode(user.toJson()));
              if (mounted) {
                setState(() {
                  widget.user = user; // Update the entire user object
                  nameController.text = user.name ?? '';
                  phoneController.text = user.phone ?? '';
                  emailController.text = user.email ?? '';
                  amount = user.walletBalanceCents ?? 0;
                });
              }
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width > 500
        ? 500.0
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFF9800), //0xFFFF9800
        foregroundColor: Colors.white,
        titleSpacing: 16,

        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () {
              loadProfile();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // AVATAR
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFFF9800),

                          child: GestureDetector(
                            onTap: pickImageDialog,
                            child: ClipOval(
                              child: (!kIsWeb && image != null)
                                  ? Image.file(image!, fit: BoxFit.cover)
                                  : (webImage != null)
                                  ? Image.memory(webImage!, fit: BoxFit.cover)
                                  : Image.network(
                                      '${Myconfig.baseURL}/pawpal/api/userimages/${widget.user!.userId}.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            // fallback to first letter
                                            return Center(
                                              child: Text(
                                                widget.user?.name
                                                        ?.substring(0, 1)
                                                        .toUpperCase() ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _readonlyField("User ID", widget.user?.userId),
                        _readonlyField("Email", widget.user?.email),

                        const Divider(height: 30),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "My Wallet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // My Wallet balance
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "RM",
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (amount / 100).toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),

                                  const Spacer(),

                                  // Top up button
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF9800),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text(
                                      "Top up",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      showTopUpDialog();
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Hint
                              Text(
                                "My Wallet are used to donations",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 30),
                        const SizedBox(height: 8),
                        _inputField(
                          controller: nameController,
                          label: "Name",
                          icon: Icons.person,
                          keyboard: TextInputType.name,
                        ),
                        const SizedBox(height: 12),
                        _inputField(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboard: TextInputType.phone,
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _updateProfile,
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // LOADING OVERLAY
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      drawer: MyDrawer(user: widget.user, key: drawerKey),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          (drawerKey.currentState as dynamic)?.refreshFromPrefs();
        }
      },
    );
  }

  void showTopUpDialog() {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF1F3C88),
                  ),
                  SizedBox(width: 8),
                  Text("Top Up"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter amount to top up your wallet",
                    style: TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.money),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3C88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final text = amountController.text.trim();

                    if (text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter an amount"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final double? amount = double.tryParse(text);

                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid amount"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // convert RM → cents
                    final int topUpCents = (amount * 100).round();

                    Navigator.pop(context);

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          user: widget.user!,
                          topUpCents: topUpCents,
                        ),
                      ),
                    );

                    loadProfile();
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= HELPERS =================
  Widget _readonlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value ?? "-"),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
