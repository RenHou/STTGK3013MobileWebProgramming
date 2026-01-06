import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/animated_route.dart';
import 'package:pawpal/loginscreen.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/mypet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pawpal/user.dart';

class PetDetailScreen extends StatefulWidget {
  final MyPet pet;
  User? user;

  PetDetailScreen({super.key, required this.pet, required this.user});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController donationAmountController =
      TextEditingController();

  String selectedDonationType = 'Food';
  final List<String> donationTypes = ['Food', 'Money', 'Medicine'];

  @override
  Widget build(BuildContext context) {
    String firstImage = jsonDecode(widget.pet.imagePaths!)[0];
    String formattedDate = formatter.format(
      DateTime.parse(widget.pet.createdAt.toString()),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.petName ?? 'pet Details'),
        backgroundColor: const Color(0xFFFF9800),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                '${Myconfig.baseURL}/pawpal/api/$firstImage',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 120),
              ),
            ),

            const SizedBox(height: 16),

            // BASIC INFO
            Text(
              widget.pet.petName ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.pet.petType} • ${widget.pet.category}',
              style: TextStyle(color: Colors.grey[700]),
            ),

            const Divider(height: 30),

            // DETAILS TABLE
            _infoRow('Gender', widget.pet.petGender),
            _infoRow('Age', widget.pet.petAge),
            _infoRow('Health', widget.pet.petHealth),
            _infoRow('Description', widget.pet.description),
            _infoRow('Posted By', widget.pet.name),
            _infoRow('Phone', widget.pet.phone),
            _infoRow('Email', widget.pet.email),
            _infoRow('Date', formattedDate),

            const SizedBox(height: 16),

            // ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.call,
                  onTap: () => launchUrl(
                    Uri.parse('tel:${widget.pet.phone}'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                _actionButton(
                  icon: Icons.message,
                  onTap: () => launchUrl(
                    Uri.parse('sms:${widget.pet.phone}'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                _actionButton(
                  icon: Icons.email,
                  onTap: () => launchUrl(
                    Uri.parse('mailto:${widget.pet.email}'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                _actionButton(
                  icon: Icons.wechat,
                  onTap: () => launchUrl(
                    Uri.parse('https://wa.me/${widget.pet.phone}'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MAIN ACTION
            if (widget.pet.category == 'Adoption')
              _primaryButton(
                context,
                text: 'Request to Adopt',
                onPressed: () {
                  if (widget.user?.userId == '0') {
                    //showdialog
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: const [
                            Icon(Icons.lock_outline, color: Color(0xFFFF9800)),
                            SizedBox(width: 8),
                            Text("Login Required"),
                          ],
                        ),
                        content: const Text(
                          "Please login to continue and access this feature.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                AnimatedRoute.slideFromRight(
                                  const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );

                    return;
                  }
                  showAdoptionDialog();
                },
              ),

            if (widget.pet.category == 'Donation')
              _primaryButton(
                context,
                text: 'Donate',
                onPressed: () {
                  if (widget.user?.userId == '0') {
                    //showdialog
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: const [
                            Icon(Icons.lock_outline, color: Color(0xFFFF9800)),
                            SizedBox(width: 8),
                            Text("Login Required"),
                          ],
                        ),
                        content: const Text(
                          "Please login to continue and access this feature.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                AnimatedRoute.slideFromRight(
                                  const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );

                    return;
                  }
                  showDonationDialog();
                },
              ),
          ],
        ),
      ),
    );
  }

  void showAdoptionDialog() {
    if (widget.pet.userId == widget.user!.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot donate to your own pet!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Request to Adopt'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adopt a pet today and change a life forever. Your kindness gives them a home, and their love gives you a family',
                ),
                SizedBox(height: 15),
                Text("Reason to adopt a pet:"),
                SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Request'),
              onPressed: () {
                requestAdoption(widget.pet.petId!);
              },
            ),
          ],
        );
      },
    );
  }

  void requestAdoption(String? petId) {
    String reason = reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a reason'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    http
        .post(
          Uri.parse("${Myconfig.baseURL}/pawpal/api/request_adopt.php"),
          body: {
            'pet_id': petId,
            'user_id': widget.user!.userId,
            'reason': reason,
          },
        )
        .then((response) {
          var data = jsonDecode(response.body);
          if (data['success'] == true) {
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message']),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
          reasonController.clear();
        });
  }

  showDonationDialog() {
    // Add this check to prevent self-donation
    if (widget.pet.userId == widget.user!.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot donate to your own pet post!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the function so the dialog doesn't open
    }
    // Reset controllers and selection when dialog opens
    donationAmountController.clear();
    reasonController.clear();
    selectedDonationType = 'Food'; // Reset to default

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Request to Donate'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pet Donation'),
                    SizedBox(height: 15),
                    DropdownButtonFormField(
                      initialValue: selectedDonationType,
                      decoration: InputDecoration(
                        labelText: 'Select Type of Donation',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      items: donationTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedDonationType = newValue!;
                          // Clear the amount field when not Money
                          if (selectedDonationType != 'Money') {
                            donationAmountController.clear();
                          }
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    TextField(
                      controller: donationAmountController,
                      keyboardType: TextInputType.number,
                      enabled: selectedDonationType == 'Money',
                      decoration: InputDecoration(
                        labelText: 'Donation Amount (RM)',
                        hintText: selectedDonationType == 'Money'
                            ? 'Enter amount'
                            : 'Not applicable',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: selectedDonationType != 'Money',
                        fillColor: selectedDonationType != 'Money'
                            ? Colors.grey[200]
                            : null,
                      ),
                    ),

                    SizedBox(height: 20),
                    TextField(
                      controller: reasonController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter your message or details',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Clear controllers when canceling
                    donationAmountController.clear();
                    reasonController.clear();
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800),
                  ),
                  onPressed: () {
                    // Validate before submitting
                    if (selectedDonationType == 'Money') {
                      if (donationAmountController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter donation amount'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      double? amount = double.tryParse(
                        donationAmountController.text.trim(),
                      );
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid amount'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      // Convert amount to cents for comparison
                      int amountInCents = (amount * 100).round();
                      int walletBalance = widget.user!.walletBalanceCents ?? 0;

                      if (amountInCents > walletBalance) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Insufficient balance. Your wallet: RM ${(walletBalance / 100).toStringAsFixed(2)}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }

                    if (reasonController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a description'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Process donation
                    processDonation();
                  },
                  child: Text('Donate', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add this method to process the donation
  void processDonation() async {
    String description = reasonController.text.trim();
    String amountRM = selectedDonationType == 'Money'
        ? donationAmountController.text.trim()
        : '0';

    try {
      final response = await http.post(
        Uri.parse("${Myconfig.baseURL}/pawpal/api/donate_pet.php"),
        body: {
          'pet_id': widget.pet.petId,
          'user_id': widget.user!.userId,
          'donation_type': selectedDonationType,
          'amount': amountRM, // Send in RM
          'description': description,
        },
      );

      var data = jsonDecode(response.body);

      Navigator.pop(context); // Close donation dialog
      Navigator.pop(context); // Close details dialog

      if (data['success'] == true) {
        // Reload user profile to get updated wallet balance
        await loadUserProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Donation successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Donation failed'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      // Clear controllers
      donationAmountController.clear();
      reasonController.clear();
    }
  }

  Future<void> loadUserProfile() async {
    final response = await http.get(
      Uri.parse(
        '${Myconfig.baseURL}/pawpal/api/getuserdetails.php?userid=${widget.user!.userId}',
      ),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        User user = User.fromJson(jsonResponse['data'][0]);

        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('user', jsonEncode(user.toJson()));

        setState(() {
          widget.user = user;
        });
      }
    }
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
    return IconButton(icon: Icon(icon, size: 28), onPressed: onTap);
  }

  Widget _primaryButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
