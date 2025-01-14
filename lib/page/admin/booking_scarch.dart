// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'booking_searce_result.dart';

class BookingScarch extends StatefulWidget {
  const BookingScarch({super.key});
  @override
  State<BookingScarch> createState() => _BookingScarchState();
}

class _BookingScarchState extends State<BookingScarch> {
  DateTime? _rangeStart; // Start date of the range
  DateTime? _rangeEnd; // End date of the range
  DateTime _focusedDay = DateTime.now(); // Currently focused day
  CalendarFormat _calendarFormat = CalendarFormat.month; // Calendar format

  // Generate all dates between the start and end dates
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    DateTime currentDate = start;
    while (!currentDate.isAfter(end)) {
      dates.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format; // Update calendar format
                });
              },
              selectedDayPredicate: (day) {
                // Highlight both start and end dates
                return (_rangeStart != null && isSameDay(_rangeStart, day)) ||
                    (_rangeEnd != null && isSameDay(_rangeEnd, day));
              },
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  if (_rangeStart == null ||
                      (_rangeStart != null && _rangeEnd != null)) {
                    // Start a new range
                    _rangeStart = selectedDay;
                    _rangeEnd = null;
                  } else if (_rangeStart != null && _rangeEnd == null) {
                    // Complete the range
                    if (selectedDay.isBefore(_rangeStart!)) {
                      // If the second date is earlier than the start, swap them
                      _rangeEnd = _rangeStart;
                      _rangeStart = selectedDay;
                    } else {
                      _rangeEnd = selectedDay;
                    }
                  }
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                withinRangeDecoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Display the selected range
            ElevatedButton(
              onPressed: () {
                if (_rangeStart != null && _rangeEnd != null) {
                  // Get the list of all dates between rangeStart and rangeEnd
                  List<DateTime> selectedDates =
                      getDatesInRange(_rangeStart!, _rangeEnd!);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingSearchResult(
                        selectedDates: selectedDates,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Please select a date range before searching."),
                    ),
                  );
                }
              },
              child: const Text("Search"),
            ),
          ],
        ),
      ),
    );
  }
}
