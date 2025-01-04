// ignore_for_file: prefer_final_fields, avoid_function_literals_in_foreach_calls, unused_local_variable, unused_field, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';

class WeaklyWorking extends StatefulWidget {
  const WeaklyWorking({super.key});

  @override
  State<WeaklyWorking> createState() => _WeaklyWorkingState();
}

class _WeaklyWorkingState extends State<WeaklyWorking> {
  String _id = 'Loading...';
  List<DocumentSnapshot> _orders = []; // List to store orders
  Map<String, List<DocumentSnapshot>> _groupedOrders =
      {}; // Group orders by week

  @override
  void initState() {
    super.initState();
    _loadId(); // Load the ID when the widget is initialized
  }

  // Method to load the id from SharedPreferences
  Future<void> _loadId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? 'No ID found'; // Get the 'id' value
    setState(() {
      _id = id; // Update the state with the loaded id
    });
    _loadOrders(); // After loading the id, load the orders
  }

  // Helper method to get the start of the current week (Monday at 00:00)
  DateTime _getWeekStart(DateTime date) {
    // Calculate how many days to subtract to get to the previous Saturday
    int daysToSubtract =
        (date.weekday == DateTime.saturday) ? 0 : (date.weekday + 1) % 7;
    DateTime startOfWeek = date.subtract(Duration(days: daysToSubtract));

    // Return the Saturday 00:00 (midnight) of the week
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0);
  }

  // Method to load orders from Firestore based on current week and employeeId
  Future<void> _loadOrders() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('orders').get();

    // Group orders by week
    Map<String, List<DocumentSnapshot>> groupedOrders = {};

    snapshot.docs.forEach((order) {
      final data = order.data() as Map<String, dynamic>;
      final clientName = data['username'] ?? 'N/A';
      final orderDateTime = data['orderDateTime'] ?? 'N/A';

      // Parse the orderDateTime string to a DateTime object
      DateTime orderDate = DateTime.tryParse(orderDateTime) ?? DateTime.now();
      DateTime weekStart = _getWeekStart(orderDate);

      // Convert the weekStart DateTime to a string for grouping (make sure the format is yyyy-MM-dd)
      String weekKey = DateFormat('yyyy-MM-dd').format(weekStart);

      // Check if the employeeId matches and the order is completed
      if (data['employeeId'] == _id && data['status'] == 'completed') {
        if (!groupedOrders.containsKey(weekKey)) {
          groupedOrders[weekKey] = [];
        }
        groupedOrders[weekKey]?.add(order);
      }
    });

    setState(() {
      _groupedOrders = groupedOrders; // Update the map with grouped orders
    });
  }

  // Helper method to format DateTime as "Month Day, Year Hours:Minutes"
  String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.tryParse(dateTime) ?? DateTime.now();
    return DateFormat('MMMM dd, yyyy hh:mm a').format(parsedDate);
  }

  // Helper method to format working time from minutes to hours and minutes
  String formatWorkingTime(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '$hours hours $remainingMinutes minutes';
  }

  // Method to calculate the total working time for each week
  int _calculateTotalWorkingTime(List<DocumentSnapshot> orders) {
    int totalTime = 0;
    for (var order in orders) {
      final data = order.data() as Map<String, dynamic>;
      final workingTime = data['workingTime'] ?? 0;

      // Ensure workingTime is treated as an int, whether it's initially an int or num
      totalTime +=
          workingTime is int ? workingTime : (workingTime as double).toInt();
    }
    return totalTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _id == 'Loading...'
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading while id is being fetched
          : _groupedOrders.isEmpty
              ? const Center(child: Text("No orders for this week"))
              : ListView.builder(
                  itemCount: _groupedOrders.keys.length,
                  itemBuilder: (context, index) {
                    String weekKey = _groupedOrders.keys.elementAt(index);
                    List<DocumentSnapshot> orders = _groupedOrders[weekKey]!;

                    int totalWorkingTime = _calculateTotalWorkingTime(orders);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Week: $weekKey",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Total Working Time: ${formatWorkingTime(totalWorkingTime)}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            ...orders.map((order) {
                              final data = order.data() as Map<String, dynamic>;
                              final clientName = data['username'] ?? 'N/A';
                              final orderDateTime =
                                  data['orderDateTime'] ?? 'N/A';
                              final workingTime = data['workingTime'] ?? 0;

                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Client Name: $clientName"),
                                    Text(
                                        "Order Date: ${formatDateTime(orderDateTime)}"),
                                    Text(
                                        "Working Time: ${formatWorkingTime(workingTime)}"),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
