import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AvableDate extends StatefulWidget {
  const AvableDate({super.key});

  @override
  State<AvableDate> createState() => _AvableDateState();
}

class _AvableDateState extends State<AvableDate> {
  String _id = 'Loading...'; // Default value while loading
  List<DateTime> _selectedDates = []; // Store selected dates
  late DateTime _focusedDay; // Currently focused day

  @override
  void initState() {
    super.initState();
    _loadId(); // Load the ID when the widget is initialized
    _focusedDay = DateTime.now(); // Initialize focused day to the current day
    _loadSelectedDatesFromFirestore(); // Load selected dates from Firestore
  }

  // Method to load the ID from SharedPreferences
  Future<void> _loadId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? 'No ID found'; // Get the 'id' value
    setState(() {
      _id = id; // Update the state with the loaded ID
    });

    // Load selected dates after loading the ID
    if (_id != 'No ID found') {
      _loadSelectedDatesFromFirestore(); // Load from Firestore when ID is found
    }
  }

  // Method to load the selected dates from Firestore
  Future<void> _loadSelectedDatesFromFirestore() async {
    if (_id != 'Loading...') {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      try {
        // Get the employee document from Firestore
        DocumentSnapshot employeeDoc =
            await firestore.collection('employees').doc(_id).get();

        // Check if the document exists and if 'availableDates' exists
        if (employeeDoc.exists) {
          List<dynamic> availableDates = employeeDoc['availableDates'] ?? [];

          // Convert the available dates (strings) to DateTime objects
          setState(() {
            _selectedDates = availableDates
                .map((date) => DateTime.parse(date)) // Convert to DateTime
                .toList();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dates: $e')),
        );
      }
    }
  }

  // Method to handle date selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDates.contains(selectedDay)) {
        // If the date is already selected, remove it
        _selectedDates.remove(selectedDay);
      } else {
        // Otherwise, add it
        _selectedDates.add(selectedDay);
      }
      _focusedDay = focusedDay; // Update the focused day
    });
  }

  // Method to save the selected dates to SharedPreferences and Firestore
  Future<void> _saveDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Format the selected dates in 'yyyy-MM-dd' format
    List<String> selectedDates = _selectedDates
        .map((date) =>
            DateFormat('yyyy-MM-dd').format(date)) // Format to 'yyyy-MM-dd'
        .toList();

    // Save the formatted dates to SharedPreferences
    await prefs.setStringList('selectedDates', selectedDates);

    // Save the dates to Firestore
    if (_id != 'Loading...') {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      try {
        // Save the formatted dates in Firestore under the employee document
        await firestore.collection('employees').doc(_id).update({
          'availableDates': selectedDates, // Store the available dates
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dates saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving dates: $e')),
        );
      }
    }
  }

  // Method to compare if two DateTime objects represent the same date
  bool _isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // TableCalendar for date selection
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              selectedDayPredicate: (day) {
                // Use the helper method _isSameDay to check if the date is selected
                return _selectedDates
                    .any((selectedDate) => _isSameDay(day, selectedDate));
              },
              onDaySelected: _onDaySelected,
            ),
            const SizedBox(height: 20),
            // Display selected dates
            const SizedBox(height: 20),
            // Save button
            ElevatedButton(
              onPressed: _saveDates,
              child: const Text('Save Selected Dates'),
            ),
          ],
        ),
      ),
    );
  }
}
