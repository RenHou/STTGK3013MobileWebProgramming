import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/donation.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/mydrawer.dart';
import 'package:pawpal/user.dart';

class MyDonation extends StatefulWidget {
  final User? user;
  const MyDonation({super.key, required this.user});

  @override
  State<MyDonation> createState() => _MyDonationState();
}

class _MyDonationState extends State<MyDonation> {
  late double width, height;
  List<Donation?> listDonation = [];
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadDonation();
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
        title: const Text("My Donation"),
        backgroundColor: const Color(0xFFFF9800),
      ),
      drawer: MyDrawer(user: widget.user),
      body: Center(
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              listDonation.isEmpty
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
                        itemCount: listDonation.length,
                        itemBuilder: (BuildContext context, int index) {
                          String imagePath =
                              "uploads/pet_${listDonation[index]!.petId!}_0.png"; // example: uploads/pet_1_0.png

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
                                        '${Myconfig.baseURL}/pawpal/api/$imagePath',
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

                                  // PET NAME
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                            listDonation[index]!.donationType
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // NAME
                                        Text(
                                          "Donation to ${listDonation[index]!.petName.toString()}",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        // DONATION TYPE TAG
                                        Text(
                                          "Description: ${listDonation[index]!.donationDescription.toString()}",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 4),
                                        Text(
                                          "Date: ${listDonation[index]!.donationDate!.split(' ')[0].toString()}",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 10,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Donation amount
                                  listDonation[index]!.donationType != "Money"
                                      ? const SizedBox()
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '- RM${(listDonation[index]!.donationAmountCents! / 100).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
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

  void loadDonation() {
    listDonation.clear();
    setState(() {
      status = "Loading...";
    });

    http
        .get(
          Uri.parse(
            '${Myconfig.baseURL}/pawpal/api/get_my_donation.php?userid=${widget.user!.userId}',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            if (jsonResponse['success'] == 'true' &&
                jsonResponse['data'] != null &&
                jsonResponse['data'].isNotEmpty) {
              // has data → load to list
              listDonation.clear();
              for (var item in jsonResponse['data']) {
                listDonation.add(Donation.fromJson(item));
              }

              setState(() {
                status = "";
              });
            } else {
              // success but EMPTY data
              setState(() {
                listDonation.clear();
                status = "No submissions yet";
              });
            }
          } else {
            // request failed
            setState(() {
              listDonation.clear();
              status = "Failed to load services";
            });
          }
        });
  }
}
