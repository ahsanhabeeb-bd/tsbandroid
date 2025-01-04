import 'package:flutter/material.dart';
import 'complited_booking.dart';
import 'employee_booking.dart';
import 'weakly_working.dart'; // Make sure to import your EmployeeBooking widget

class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the number of tabs (2)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Add TabBar in the body instead of AppBar
          Material(
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Booking"),
                Tab(text: "Completed"),
                Tab(text: "Weekly"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                EmployeeBooking(), // Your EmployeeBooking widget
                ComplitedBooking(), // Your CompletedBooking widget
                WeaklyWorking(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
