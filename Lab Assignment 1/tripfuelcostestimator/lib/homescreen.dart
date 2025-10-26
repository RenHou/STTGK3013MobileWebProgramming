import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController distanceController = TextEditingController();
  TextEditingController fuelEfficiencyController = TextEditingController();
  String fuelPrice = "1.99";
  bool firstTimeDistance = true;
  bool firstTimeFuel = true;
    double totalCost = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Fuel Cost Estimator'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16.0),
          child: Column(
            children: [
              Image.asset("assets/images/TripFuelCostEstimator.png", scale: 4),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 110, child: Text("Distance: ")),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: distanceController,
                      decoration: InputDecoration(
                        errorText:
                            (firstTimeDistance || validateData(distanceController.text))// detect the error of the input, ignore the first time before the user typing
                            ? null
                            : "The distance should more than 0",
                        labelText: 'Distance (km)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (firstTimeDistance) {
                          firstTimeDistance = false;
                        }
                        setState(() {});
                      },
                      
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 110, child: Text("Fuel Eccifiency: ")),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: fuelEfficiencyController,
                      decoration: InputDecoration(
                        errorText: (firstTimeFuel|| validateData(fuelEfficiencyController.text))// detect the error of the input, ignore the first time before the user typing
                            ? null
                            : "The fuel efficiency should more than 0",
                        border: OutlineInputBorder(),
                        labelText: 'Fuel Efficiency (km/L)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if(firstTimeFuel){
                          firstTimeFuel=false;
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 110, child: Text("Fuel Price: ")),
                  SizedBox(
                    width: 250,
                    child: DropdownButton(
                      value: fuelPrice,
                      items: const <String>["1.99", "2.60", "3.14"]
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text("RM $value per L"),
                            );
                          })
                          .toList(),

                      onChanged: (String? newValue) {
                        fuelPrice = newValue!;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Total Fuel Cost: RM ${totalCost.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: calculateCost,
                child: Text(
                  'Calculate Fuel Cost',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void calculateCost() {
    double? distance = double.tryParse(distanceController.text);
    double? fuelEfficiency = double.tryParse(fuelEfficiencyController.text);
    double? pricePerLitre = double.tryParse(fuelPrice);
    if (distance == null ||
        distance <= 0 ||
        fuelEfficiency == null ||
        fuelEfficiency <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Invalid Input"),
          content: Text(
            "Please enter valid numbers for distance and fuel efficiency.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    totalCost = (distance / fuelEfficiency) * pricePerLitre!;
    setState(() {});
  }

  bool validateData(String value) {
    return !(double.tryParse(value) == null || double.parse(value) <= 0);
  }
}
