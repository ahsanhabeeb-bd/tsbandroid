import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class EmployeeBooking extends StatefulWidget {
  const EmployeeBooking({super.key});

  @override
  State<EmployeeBooking> createState() => _EmployeeBookingState();
}

class _EmployeeBookingState extends State<EmployeeBooking> {
  String _id = 'Loading...'; // Default value while loading
  List<DocumentSnapshot> _orders = []; // List to store orders

  @override
  void initState() {
    super.initState();
    _loadId(); // Load the id when the widget is initialized
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

  // Method to load orders from Firestore where employeeId matches the saved id
  Future<void> _loadOrders() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('orders').get();

    // Filter orders based on employeeId and status (accepted, edit, or working)
    List<DocumentSnapshot> filteredOrders = snapshot.docs.where((order) {
      final data = order.data() as Map<String, dynamic>;

      // Check if the employeeId matches and if the status is either 'accepted', 'edit', or 'working'
      return data['employeeId'] == _id &&
          (data['status'] == 'accepted' ||
              data['status'] == 'edit' ||
              data['status'] == 'working');
    }).toList();

    // Sort orders by orderDateTime in descending order (most recent first)
    filteredOrders.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      // Parse orderDateTime to DateTime objects
      final orderDateTimeA = DateTime.tryParse(dataA['orderDateTime'] ?? '');
      final orderDateTimeB = DateTime.tryParse(dataB['orderDateTime'] ?? '');

      if (orderDateTimeA == null || orderDateTimeB == null) {
        return 0; // If parsing fails, treat them as equal
      }

      // Compare dates in descending order (most recent first)
      return orderDateTimeB.compareTo(orderDateTimeA);
    });

    setState(() {
      _orders =
          filteredOrders; // Update the list with the filtered and sorted orders
    });
  }

  // Method to start the order by changing the status to 'working' and adding startTime
  Future<void> _startOrder(String orderId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the order document
    DocumentSnapshot orderSnapshot =
        await firestore.collection('orders').doc(orderId).get();

    if (orderSnapshot.exists) {
      Map<String, dynamic>? orderData =
          orderSnapshot.data() as Map<String, dynamic>?;
      if (orderData != null) {
        // Extract the orderDateTime field
        String orderDateTimeStr = orderData['orderDateTime'];
        DateTime orderDateTime = DateTime.parse(orderDateTimeStr);

        // Get the current date and time
        DateTime now = DateTime.now();

        // Check if the orderDateTime is today
        bool isToday = orderDateTime.year == now.year &&
            orderDateTime.month == now.month &&
            orderDateTime.day == now.day;

        if (!isToday) {
          // Show a message that the order cannot be started
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Order cannot be started because it is not scheduled for today."),
            ),
          );
          return;
        }

        // Check if the current time is after the orderDateTime
        if (now.isBefore(orderDateTime)) {
          // Show a message that the order cannot be started
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Order cannot be started before the scheduled time (${orderDateTime.hour}:${orderDateTime.minute}).",
              ),
            ),
          );
          return;
        }

        // Get the current time for the startTime
        String startTime = now.toIso8601String();

        // Update the order status and add startTime
        await firestore.collection('orders').doc(orderId).update({
          'status': 'working',
          'startTime': startTime,
        });

        // Refresh the orders to reflect the updated status and startTime
        _loadOrders();

        // Optionally, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order started successfully."),
          ),
        );
      }
    } else {
      // Show an error if the order does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order not found."),
        ),
      );
    }
  }

  // Method to stop the order by changing the status to 'completed' and adding stopTime and workingTime
  Future<void> _stopOrder(String orderId, String startTime) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the current time for the stopTime
    String stopTime = DateTime.now().toIso8601String();

    // Calculate the working time in minutes
    DateTime startDateTime = DateTime.parse(startTime);
    DateTime stopDateTime = DateTime.parse(stopTime);
    Duration workingDuration = stopDateTime.difference(startDateTime);
    int workingTimeMinutes =
        workingDuration.inMinutes; // Store the working time in minutes

    // Update the order status, add stopTime, and workingTime
    await firestore.collection('orders').doc(orderId).update({
      'status': 'completed',
      'stopTime': stopTime,
      'workingTime': workingTimeMinutes,
    });

    // Refresh the orders to reflect the updated status, stopTime, and workingTime
    _loadOrders();
  }

  // Helper method to format DateTime as "Month Day, Year Hours:Minutes"
  String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    return DateFormat('MMMM dd, yyyy hh:mm a').format(parsedDate);
  }

  // Helper method to format working time from minutes to hours and minutes
  String formatWorkingTime(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '$hours hours $remainingMinutes minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _id == 'Loading...'
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading while id is being fetched
          : _orders.isEmpty
              ? const Center(child: Text("No orders found for this employee"))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final data = order.data() as Map<String, dynamic>;
                    final clientName = data['username'] ?? 'N/A';
                    final address = data['address'] ?? 'N/A';
                    final employeeName = data['employeeName'] ?? 'N/A';
                    final note = data['note'] ?? 'N/A';
                    final orderDateTime = data['orderDateTime'] ?? 'N/A';
                    final phone = data['phone'] ?? 'N/A';
                    final serviceTitle = data['serviceTitle'] ?? 'N/A';
                    final status = data['status'] ?? 'N/A';
                    final startTime = data['startTime'] ?? '';
                    final stopTime = data['stopTime'] ?? '';
                    final workingTime = data['workingTime'] ??
                        0; // Default to 0 if not available
                    final orderId = order.id; // Get the order's ID
                    Color _outcolor() {
                      Color _color = Colors.white;
                      if (status == "pending") {
                        _color = Colors.white;
                      } else if (status == "accepted") {
                        _color = Colors.green;
                      } else if (status == "completed") {
                        _color = const Color.fromARGB(255, 200, 196, 204);
                      } else if (status == "rejected") {
                        _color = Colors.red;
                      } else if (status == "edit") {
                        _color = Colors.blue;
                      } else if (status == "working") {
                        _color = Colors.yellow;
                      }
                      return _color;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        color: _outcolor(),
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
                            Text("Note: $note"),
                            Text(
                                "Order Date: ${formatDateTime(orderDateTime)}"),
                            Text("Client Name: $clientName"),
                            Text("Phone: $phone"),
                            Text("Address: $address"),
                            Text("Status: $status"),
                            const SizedBox(height: 10),
                            // Display start time if available
                            if (startTime.isNotEmpty)
                              Text("Start Time: ${formatDateTime(startTime)}"),
                            // Display stop time if available
                            if (stopTime.isNotEmpty)
                              Text("Stop Time: ${formatDateTime(stopTime)}"),
                            // Display working time if available
                            if (workingTime > 0)
                              Text(
                                  "Working Time: ${formatWorkingTime(workingTime)}"),
                            const SizedBox(height: 10),
                            // "Start" button only if the status is not already "working"
                            if (status != 'working' && status != 'completed')
                              ElevatedButton(
                                onPressed: () => _startOrder(orderId),
                                child: const Text("Start"),
                              ),
                            // "Stop" button if the status is "working"
                            if (status == 'working')
                              ElevatedButton(
                                onPressed: () => _stopOrder(orderId, startTime),
                                child: const Text("Stop"),
                              ),
                            if (status == 'working')
                              const Text("Order is in progress"),
                            if (status == 'completed')
                              const Text("Order is completed"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
