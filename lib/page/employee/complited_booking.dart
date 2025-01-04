// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplitedBooking extends StatefulWidget {
  const ComplitedBooking({super.key});

  @override
  State<ComplitedBooking> createState() => _ComplitedBookingState();
}

class _ComplitedBookingState extends State<ComplitedBooking> {
  String _id = 'Loading...'; // Default value while loading
  List<DocumentSnapshot> _orders = []; // List to store completed orders

  @override
  void initState() {
    super.initState();
    _loadId(); // Load the id when the widget is initialized
  }

  String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    return DateFormat('MMMM dd, yyyy hh:mm a').format(parsedDate);
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

  // Method to load orders from Firestore where employeeId matches and status is 'completed'
  Future<void> _loadOrders() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('orders').get();

    // Filter orders based on employeeId and status 'completed'
    List<DocumentSnapshot> filteredOrders = snapshot.docs.where((order) {
      final data = order.data() as Map<String, dynamic>;

      // Check if the employeeId matches and if the status is 'completed'
      return data['employeeId'] == _id && data['status'] == 'completed';
    }).toList();

    // Sort the orders by 'orderDateTime' in descending order (latest first)
    filteredOrders.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      final orderDateTimeA = DateTime.tryParse(dataA['orderDateTime'] ?? '');
      final orderDateTimeB = DateTime.tryParse(dataB['orderDateTime'] ?? '');

      if (orderDateTimeA == null || orderDateTimeB == null) {
        return 0; // If parsing fails, treat them as equal
      }

      return orderDateTimeB
          .compareTo(orderDateTimeA); // Sort in descending order
    });

    setState(() {
      _orders =
          filteredOrders; // Update the list with the filtered and sorted orders
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _id == 'Loading...'
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading while id is being fetched
          : _orders.isEmpty
              ? const Center(
                  child: Text("No completed orders found for this employee"))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final data = order.data() as Map<String, dynamic>;
                    final address = data['address'] ?? 'N/A';
                    final username = data['username'] ?? 'N/A';
                    final employeeName = data['employeeName'] ?? 'N/A';
                    final orderDateTime = data['orderDateTime'] ?? 'N/A';
                    final phone = data['phone'] ?? 'N/A';
                    final serviceTitle = data['serviceTitle'] ?? 'N/A';
                    final status = data['status'] ?? 'N/A';
                    final startTime = data['startTime'] ?? '';
                    final stopTime = data['stopTime'] ?? '';
                    final workingTime = data['workingTime'] ??
                        0; // Default to 0 if it's not available
                    final orderId = order.id; // Get the order's ID

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Service: $serviceTitle",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text("Employee Name: $employeeName"),
                            Text(
                                "Order Date: ${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(orderDateTime).toLocal())}"),

                            Text("Client Name: $username"),
                            Text("Phone: $phone"),
                            Text("Address: $address"),
                            Text("Status: $status"),
                            const SizedBox(height: 10),
                            // Display start time if available
                            if (startTime.isNotEmpty)
                              Text(
                                  "Start Time: ${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(startTime).toLocal())}"),
                            // Display stop time if available
                            if (stopTime.isNotEmpty)
                              Text(
                                  "Stop Time: ${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(stopTime).toLocal())}"),
                            // Display working time if available
                            if (workingTime > 0)
                              Text("Working Time: $workingTime minutes"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
