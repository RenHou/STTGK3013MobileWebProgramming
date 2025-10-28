# Trip Fuel Cost Estimator

TThis Fuel Cost Estimator is an application designed to estimate the cost of fuel for a trip.   
This application is estimated based on the distance (km), car fuel efficiency (km/L), and fuel price (RM/L).

Input: distance (km), car fuel efficiency (km/L), fuel price (RM/L).  
Process: calculate the total fuel cost  by using the formula:
total fuel cost = (distance / car fuel efficiency) * fuel price   
Output: total fuel cost  
	
Widget list used:
1.	Scaffold
2.	AppBar
3.	SingleChildScrollView
4.	Padding
5.	Column
6.	Image
7.	SizedBox
8.	Row
9.	Text
10.	TextField
11.	DropdownButton
12.	ElevatedButton
13.	CircularProgressIndicator

Basic validation approach:
1.	The double.tryParse() method is used to parse the input of distance and fuel efficiency into a number. If the input cannot be parsed as a number, it will return null without throwing an exception.
2.	Then, the parsed input will be checked to ensure the input is not null and is more than 0.
3.	If the parsed inputs are invalid, the border of TextField will become red and display error text.
4.	If all the parsed inputs are valid, the calculation will start.


 <img width="609" height="254" alt="image" src="https://github.com/user-attachments/assets/cfccf490-cd24-4c33-b3bf-f4a2609d45b2" />

