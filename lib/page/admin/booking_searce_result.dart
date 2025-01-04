// ignore_for_file: library_private_types_in_public_api, unnecessary_cast, unused_local_variable, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingSearchResult extends StatefulWidget {
  final List<DateTime> selectedDates; // List of all selected dates

  const BookingSearchResult({
    super.key,
    required this.selectedDates,
  });

  @override
  _BookingSearchResultState createState() => _BookingSearchResultState();
}

class _BookingSearchResultState extends State<BookingSearchResult> {
  String selectedStatus = 'all'; // Dropdown selected value

  // Function to match dates ignoring time
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Query Firestore and check for matching orders
  Future<List<Map<String, dynamic>>> getMatchingOrders(
      List<DateTime> selectedDates) async {
    List<Map<String, dynamic>> matchingOrders = [];
    final ordersRef = FirebaseFirestore.instance.collection('orders');
    final querySnapshot = await ordersRef.get(); // Fetch all orders

    for (var doc in querySnapshot.docs) {
      var orderDateTimeData = doc['orderDateTime'];

      // Handle Timestamp or String type
      DateTime orderDateTime;
      if (orderDateTimeData is Timestamp) {
        orderDateTime = orderDateTimeData.toDate();
      } else if (orderDateTimeData is String) {
        orderDateTime =
            DateTime.parse(orderDateTimeData); // Parse the string as DateTime
      } else {
        continue; // Skip if the data is not valid
      }

      // Match selected dates with order date
      for (var selectedDate in selectedDates) {
        if (isSameDate(orderDateTime, selectedDate)) {
          matchingOrders.add({
            'orderid': doc.id,
            ...doc.data() as Map<String, dynamic>, // Spread all fields
          });
        }
      }
    }

    // Filter orders by selected status
    if (selectedStatus != 'all') {
      matchingOrders = matchingOrders
          .where((order) => order['status'] == selectedStatus)
          .toList();
    }

    return matchingOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Results"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedStatus,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Colors.white,
              items: const [
                DropdownMenuItem(value: 'all', child: Text("All")),
                DropdownMenuItem(value: 'pending', child: Text("Pending")),
                DropdownMenuItem(value: 'accepted', child: Text("Accepted")),
                DropdownMenuItem(value: 'completed', child: Text("Completed")),
                DropdownMenuItem(value: 'rejected', child: Text("Cancelled")),
                DropdownMenuItem(value: 'edit', child: Text("Edit")),
                DropdownMenuItem(value: 'working', child: Text("Working")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getMatchingOrders(widget.selectedDates),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final matchingOrders = snapshot.data ?? [];

            if (matchingOrders.isEmpty) {
              return const Center(
                  child: Text('No orders found for selected dates.'));
            }

            return ListView.builder(
              itemCount: matchingOrders.length,
              itemBuilder: (context, index) {
                var data = matchingOrders[index];
                final clientId = data['clientid'] ?? 'N/A';
                final username = data['username'] ?? 'N/A';
                final email = data['email'] ?? 'N/A';
                final phone = data['phone'] ?? 'N/A';
                final serviceTitle = data['serviceTitle'] ?? 'N/A';
                final address = data['address'] ?? 'N/A';
                final employeeName =
                    data['employeeName'] ?? 'wait for employee';
                final status = data['status'] ?? 'N/A';
                final orderId = data['orderId'] ?? 'N/A';

                final note = data['note'] ?? 'N/A';

                final workingTimeRaw = data['workingTime'] ??
                    'N/A'; // Default to 'N/A' if not found

                final remainderDate = data['remainderDate'] != null
                    ? DateFormat('yyyy-MM-dd hh:mm a', 'en_US')
                        .format(DateTime.parse(data['remainderDate']).toLocal())
                    : 'N/A';

                final startTime = data['startTime'] != null
                    ? DateFormat('yyyy-MM-dd hh:mm a', 'en_US')
                        .format(DateTime.parse(data['startTime']).toLocal())
                    : 'N/A';

                final stopTime = data['stopTime'] != null
                    ? DateFormat('yyyy-MM-dd hh:mm a', 'en_US')
                        .format(DateTime.parse(data['stopTime']).toLocal())
                    : 'N/A';

                final orderDateTime = data.containsKey('orderDateTime') &&
                        data['orderDateTime'] != null
                    ? DateFormat('yyyy-MM-dd hh:mm a', 'en_US')
                        .format(DateTime.parse(data['orderDateTime']).toLocal())
                    : 'N/A';

// Try to parse workingTime if it's a valid number, otherwise handle the case where it's not a valid number
                int workingTime = 0;

                if (workingTimeRaw is String) {
                  // If the value is a String and not 'N/A', try to parse it
                  if (workingTimeRaw != 'N/A') {
                    workingTime = int.tryParse(workingTimeRaw) ??
                        0; // Try to parse, fallback to 0 if invalid
                  }
                } else if (workingTimeRaw is int) {
                  workingTime =
                      workingTimeRaw; // If it's already an integer, use it directly
                }

// Convert minutes into hours and minutes if workingTime is greater than 0
                int hours = workingTime > 0
                    ? workingTime ~/ 60
                    : 0; // Integer division for hours
                int minutes = workingTime > 0
                    ? workingTime % 60
                    : 0; // Remainder for minutes

                String workingTimeFormatted = hours > 0 || minutes > 0
                    ? "$hours hours $minutes minutes"
                    : "0"; // Show a default message if no valid time

                Color _outcolor() {
                  switch (status) {
                    case "pending":
                      return Colors.white;
                    case "accepted":
                      return const Color.fromARGB(85, 76, 175, 80);
                    case "completed":
                      return const Color.fromARGB(85, 200, 196, 204);
                    case "rejected":
                      return const Color.fromARGB(85, 244, 67, 54);
                    case "edit":
                      return const Color.fromARGB(85, 32, 149, 245);
                    case "working":
                      return const Color.fromARGB(85, 253, 234, 59);
                    default:
                      return Colors.white;
                  }
                }

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _outcolor(),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Service: $serviceTitle",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text("Client: $username"),
                        Text("Email: $email"),
                        Text("Phone: $phone"),
                        Text("Order Date: $orderDateTime"),
                        Text("Address: $address"),
                        Text("Employee: $employeeName"),
                        Text("Status: $status"),
                        Text("Remainder Date: $remainderDate"),
                        Text("Start Time: $startTime"),
                        Text("Stop Time: $stopTime"),
                        Text("Working Time: $workingTimeFormatted"),
                        Text("Note: $note"),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
