// ignore_for_file: unused_field, prefer_final_fields, avoid_function_literals_in_foreach_calls, unused_local_variable, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class WeeklyForAdmin extends StatefulWidget {
  final String id;
  const WeeklyForAdmin({super.key, required this.id});

  @override
  State<WeeklyForAdmin> createState() => _WeeklyForAdminState();
}

class _WeeklyForAdminState extends State<WeeklyForAdmin> {
  String _id = 'Loading...';
  List<DocumentSnapshot> _orders = [];
  Map<String, List<DocumentSnapshot>> _groupedOrders = {};

  @override
  void initState() {
    super.initState();
    _loadId();
  }

  Future<void> _loadId() async {
    setState(() {
      _id = widget.id;
    });
    _loadOrders();
  }

  DateTime _getWeekStart(DateTime date) {
    // Calculate how many days to subtract to get to the previous Saturday
    int daysToSubtract =
        (date.weekday == DateTime.saturday) ? 0 : (date.weekday + 1) % 7;
    DateTime startOfWeek = date.subtract(Duration(days: daysToSubtract));

    // Return the Saturday 00:00 (midnight) of the week
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0);
  }

  Future<void> _loadOrders() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('orders').get();

    Map<String, List<DocumentSnapshot>> groupedOrders = {};

    snapshot.docs.forEach((order) {
      final data = order.data() as Map<String, dynamic>;
      final clientName = data['username'] ?? 'N/A';
      final orderDateTime = data['orderDateTime'] ?? 'N/A';

      DateTime orderDate = DateTime.tryParse(orderDateTime) ?? DateTime.now();
      DateTime weekStart = _getWeekStart(orderDate);

      String weekKey = DateFormat('yyyy-MM-dd').format(weekStart);

      if (data['employeeId'] == _id && data['status'] == 'completed') {
        if (!groupedOrders.containsKey(weekKey)) {
          groupedOrders[weekKey] = [];
        }
        groupedOrders[weekKey]?.add(order);
      }
    });

    setState(() {
      _groupedOrders = groupedOrders;
    });
  }

  String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.tryParse(dateTime) ?? DateTime.now();
    return DateFormat('yyyy-MM-dd')
        .format(parsedDate); // Ensure 'yyyy-MM-dd' format
  }

  String formatWorkingTime(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '$hours hours $remainingMinutes minutes';
  }

  int _calculateTotalWorkingTime(List<DocumentSnapshot> orders) {
    int totalTime = 0;
    for (var order in orders) {
      final data = order.data() as Map<String, dynamic>;
      final workingTime = data['workingTime'] ?? 0;

      totalTime +=
          workingTime is int ? workingTime : (workingTime as double).toInt();
    }
    return totalTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _id == 'Loading...'
          ? const Center(child: CircularProgressIndicator())
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
