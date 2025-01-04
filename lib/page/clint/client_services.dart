// ignore_for_file: avoid_print, unused_local_variable, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientServices extends StatefulWidget {
  const ClientServices({super.key});

  @override
  State<ClientServices> createState() => _ClientServicesState();
}

class _ClientServicesState extends State<ClientServices> {
  List<QueryDocumentSnapshot> sortedOrders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // Function to fetch orders from Firestore and filter by clientid
  Future<void> fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String sherpafranceId =
        prefs.getString('id') ?? 'No ID found'; // Get the 'id' value

    if (sherpafranceId != 'No ID found') {
      setState(() {});
    }

    FirebaseFirestore.instance
        .collection('orders')
        .where('clientid', isEqualTo: sherpafranceId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        sortedOrders = querySnapshot.docs;
      });
    }).catchError((e) {
      print("Error fetching orders: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: sortedOrders.isEmpty
          ? const Center(
              child: Text(
                  "No orders found for you")) // Show loading indicator if no orders
          : ListView.builder(
              itemCount: sortedOrders.length,
              itemBuilder: (context, index) {
                final order = sortedOrders[index];
                final data = order.data() as Map<String, dynamic>;
                final clientId = data['clientid'] ?? 'N/A';
                final username = data['username'] ?? 'N/A';
                final email = data['email'] ?? 'N/A';
                final phone = data['phone'] ?? 'N/A';
                final serviceTitle = data['serviceTitle'] ?? 'N/A';
                final address = data['address'] ?? 'N/A';
                final employeeName =
                    data['employeeName'] ?? 'Wait for employee';
                final status = data['status'] ?? 'N/A';
                final orderId = data['orderId'] ?? 'N/A';
                final remainderDate = data['remainderDate'] ?? 'N/A';
                final note = data['note'] ?? 'N/A';
                final startTime = data['startTime'] ?? 'N/A';
                final stopTime = data['stopTime'] ?? 'N/A';
                final workingTimeRaw = data['workingTime'] ?? 'N/A';

                // Try to parse workingTime if it's a valid number
                int workingTime = 0;
                if (workingTimeRaw is String && workingTimeRaw != 'N/A') {
                  workingTime = int.tryParse(workingTimeRaw) ?? 0;
                } else if (workingTimeRaw is int) {
                  workingTime = workingTimeRaw;
                }

                int hours = workingTime > 0 ? workingTime ~/ 60 : 0;
                int minutes = workingTime > 0 ? workingTime % 60 : 0;
                String workingTimeFormatted = hours > 0 || minutes > 0
                    ? "$hours hours $minutes minutes"
                    : "0";

                Color _outcolor() {
                  Color _color = Colors.white;
                  if (status == "pending") {
                    _color = Colors.white;
                  } else if (status == "accepted") {
                    _color = const Color.fromARGB(85, 76, 175, 80);
                  } else if (status == "completed") {
                    _color = const Color.fromARGB(85, 200, 196, 204);
                  } else if (status == "rejected") {
                    _color = const Color.fromARGB(85, 244, 67, 54);
                  } else if (status == "edit") {
                    _color = const Color.fromARGB(85, 31, 147, 242);
                  } else if (status == "working") {
                    _color = const Color.fromARGB(85, 251, 232, 58);
                  }
                  return _color;
                }

                final orderDateTime = data.containsKey('orderDateTime') &&
                        data['orderDateTime'] != null
                    ? DateTime.parse(data['orderDateTime']).toLocal().toString()
                    : 'N/A';

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
                        Text("Email: $email"),
                        Text("Phone: $phone"),
                        Text("Address: $address"),
                        Text("Order Date: $orderDateTime"),
                        Text("Status: $status"),
                        Text("Remainder Date: $remainderDate"),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
