// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, deprecated_member_use, unused_local_variable, unnecessary_string_interpolations
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  TextEditingController hoursController = TextEditingController();
  TextEditingController minutesController = TextEditingController();
  final String functionUrl = 'https://sendama-5005.twil.io/send-sms';

  Future<void> sendSms(String toPhone, String message) async {
    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'to': toPhone,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("SMS sent successfully!"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("SMS sent failed"),
        ),
      );
    }
  }

  void _assignEmployee(String orderId, String username, String phone,
      String email, String status, String clientName, String orderDateTime) {
    final validStatuses = {"pending", "rejected"};
    TextEditingController noteController = TextEditingController();
    bool isNoteVisible = false; // Variable to control note visibility

    if (validStatuses.contains(status)) {
      String? selectedEmployeeId;
      String? selectedEmployeeName;
      bool isPhoneSelected = false;
      bool isEmailSelected = false;
      DateTime? remainderDate;
      TextEditingController emailMessageController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Booking Confirmation"),
                content: FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance.collection('employees').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    final employees = snapshot.data?.docs ?? [];
                    // Filter employees based on availableDates
                    final matchingEmployees = employees.where((employee) {
                      final availableDates =
                          (employee['availableDates'] ?? []) as List<dynamic>;
                      DateTime orderDate = DateTime.parse(orderDateTime);
                      // Convert availableDates to DateTime and check if any match orderDate (ignoring time)
                      return availableDates.any((date) {
                        final DateTime availableDate = DateTime.parse(date);
                        return availableDate.year == orderDate.year &&
                            availableDate.month == orderDate.month &&
                            availableDate.day == orderDate.day;
                      });
                    }).toList();

                    if (matchingEmployees.isEmpty) {
                      return const Text(
                          "No employees available on the selected date.");
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Employee dropdown
                          DropdownButton<String>(
                            value: selectedEmployeeId,
                            hint: const Text("Select Employee"),
                            isExpanded: true,
                            items: matchingEmployees.map((employee) {
                              final employeeId = employee.id;
                              final employeeName = employee['username'];
                              return DropdownMenuItem<String>(
                                value: employeeId,
                                child: Text(employeeName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedEmployeeId = value;
                                selectedEmployeeName = employees.firstWhere(
                                    (employee) =>
                                        employee.id == value)['username'];
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                // Toggle the note input visibility
                                isNoteVisible = !isNoteVisible;
                              });
                            },
                            child: const Text("Add Note"),
                          ),

                          if (isNoteVisible) ...[
                            const Text("Enter Note:"),
                            TextField(
                              controller: noteController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: "Write your note here",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Client phone and email selection
                          const Text("Select Information to Assign:"),
                          Row(
                            children: [
                              Checkbox(
                                value: isPhoneSelected,
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    isPhoneSelected = value!;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  "Phone: $phone",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: isEmailSelected,
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    isEmailSelected = value!;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  "Email: $email",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // TextField for custom email message if email is selected
                          if (isEmailSelected) ...[
                            const Text("Custom Email Message:"),
                            TextField(
                              controller: emailMessageController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: "Enter custom message for the client",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // DateTime Picker for remainderDate
                          TextButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null) {
                                  setDialogState(() {
                                    remainderDate = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: const Text("Select Remainder Date & Time"),
                          ),
                          if (remainderDate != null)
                            Text(
                              "${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(remainderDate.toString()).toLocal())}",
                              style: const TextStyle(color: Colors.blue),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedEmployeeId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select an employee."),
                          ),
                        );
                        return;
                      }

                      if (remainderDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please select a new remainder date and time."),
                          ),
                        );
                        return;
                      }
                      if (selectedEmployeeId != null) {
                        try {
                          final orderRef = FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId);

                          // Collect the data to update based on the user's selection
                          Map<String, dynamic> updateData = {
                            'employeeId': selectedEmployeeId,
                            'employeeName': selectedEmployeeName,
                            'status': 'accepted',
                            if (remainderDate != null)
                              'remainderDate': remainderDate!.toIso8601String(),
                            if (noteController.text.isNotEmpty)
                              'note': noteController
                                  .text, // Add the note to Firestore
                          };

                          // Add phone and/or email data based on selection
                          if (isPhoneSelected) {
                            updateData['phoneRemainder'] = phone;
                            sendSms(phone, '''Dear $clientName, 
Thank you for booking with Toronto ShineBright Cleaning Services, Your booking has been confirmed.

If you have any questions or concerns, please don’t hesitate to get in touch with us.
Thank you. 
torontoshinebright.ca
Email:contact@torontoshinebright.ca
M: 6472213051''');
                          }
                          if (isEmailSelected) {
                            updateData['emailRemainder'] = email;

                            // Send the email with the custom message
                            try {
                              String username =
                                  'Torontoshinebright23@gmail.com';
                              String password = 'bofy fhtd egwz mili';

                              final smtpServer = gmail(username, password);

                              final message = Message()
                                ..from = Address(username,
                                    'Toronto ShineBright Cleaning services')
                                ..recipients.add(email)
                                ..subject =
                                    'Booking confirmation, Toronto ShineBright Cleaning services.'
                                ..text = ''' Dear $clientName,

Thank you for booking with Toronto ShineBright Cleaning Services.

Your booking is confirmed for ${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(orderDateTime).toLocal())}

${emailMessageController.text}

If you would like to change your appointment to a different date or time, please reply to this email.

If you have any questions or concerns, please don’t hesitate to get in touch with us.

*Payment method will be E-transfer. Please send the transfer to Contact@torontoshinebright.ca

Thank you.

Toronto ShineBright Cleaning Services
torontoshinebright.ca

Email: contact@torontoshinebright.ca
M: 6472213051
33 The Links Road
Toronto, ON, M2P 1T7
''';

                              await send(message, smtpServer);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Email sent successfully!"),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Failed to send email: $e")),
                              );
                            }
                          }

                          // Update the order with the selected employee and data
                          await orderRef.update(updateData);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Booking assigned successfully!"),
                            ),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      }
                    },
                    child: const Text("Assign"),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  void _edit(String orderId, String username, String phone, String email,
      String status, String clientName, String orderDateTime) {
    final validStatuses = {"pending", "rejected", "edit", "accepted"};
    TextEditingController noteController = TextEditingController();
    bool isNoteVisible = false; // Variable to control note visibility

    if (status == "completed") {
      // Define the controllers outside to retain their values
      TextEditingController hoursController = TextEditingController();
      TextEditingController minutesController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Order Details"),
            content: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection(
                      'orders') // Replace with your Firestore collection
                  .doc(orderId) // Fetch the document by orderId
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text("Order not found.");
                }

                // Assuming 'workingTime' is a field in your Firestore document
                var orderData = snapshot.data!.data() as Map<String, dynamic>;
                int workingTime = orderData['workingTime'] ?? 0;

                // Convert working time in minutes to hours and minutes
                int hours = workingTime ~/ 60; // Integer division for hours
                int minutes = workingTime % 60; // Remainder for minutes

                // Initialize controllers only if they are empty
                if (hoursController.text.isEmpty &&
                    minutesController.text.isEmpty) {
                  hoursController.text = hours.toString();
                  minutesController.text = minutes.toString();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Display current working time
                    Text("Current Working Time: $hours hours $minutes minutes"),

                    const SizedBox(height: 10),

                    // TextField for editing hours
                    TextField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Edit Hours',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TextField for editing minutes
                    TextField(
                      controller: minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Edit Minutes',
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Close"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Get the updated working time from the TextFields
                  int newHours = int.tryParse(hoursController.text) ?? 0;
                  int newMinutes = int.tryParse(minutesController.text) ?? 0;

                  // Calculate the new workingTime in minutes
                  int newWorkingTime = (newHours * 60) + newMinutes;

                  try {
                    // Update Firestore with the new workingTime
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .update({
                      'workingTime': newWorkingTime, // Update the working time
                    });

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Working time updated successfully!"),
                      ),
                    );

                    Navigator.of(context)
                        .pop(); // Close the dialog after saving
                  } catch (e) {
                    // Show error message if update fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Save Changes"),
              ),
            ],
          );
        },
      );
    }

    if (validStatuses.contains(status)) {
      String? selectedEmployeeId;
      String? selectedEmployeeName;
      bool isPhoneSelected = false;
      bool isEmailSelected = false;
      DateTime? remainderDate;

      String? selectedDateAndTime;
      DateTime? selectedDate;
      TimeOfDay? selectedTime;
      TextEditingController emailMessageController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Edit Booking"),
                content: FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance.collection('employees').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    final employees = snapshot.data?.docs ?? [];

                    final matchingEmployees = employees.where((employee) {
                      final availableDates =
                          (employee['availableDates'] ?? []) as List<dynamic>;
                      DateTime orderDate = DateTime.parse(orderDateTime);
                      // Convert availableDates to DateTime and check if any match orderDate (ignoring time)
                      return availableDates.any((date) {
                        final DateTime availableDate = DateTime.parse(date);
                        return availableDate.year == orderDate.year &&
                            availableDate.month == orderDate.month &&
                            availableDate.day == orderDate.day;
                      });
                    }).toList();

                    if (matchingEmployees.isEmpty) {
                      return const Text(
                          "No employees available on the selected date.");
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Employee dropdown
                          DropdownButton<String>(
                            value: selectedEmployeeId,
                            hint: const Text("Select Employee"),
                            isExpanded: true,
                            items: matchingEmployees.map((employee) {
                              final employeeId = employee.id;
                              final employeeName = employee['username'];
                              return DropdownMenuItem<String>(
                                value: employeeId,
                                child: Text(employeeName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedEmployeeId = value;
                                selectedEmployeeName = employees.firstWhere(
                                    (employee) =>
                                        employee.id == value)['username'];
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          // Button to select date and time
                          TextButton(
                            onPressed: () async {
                              // Open the date picker
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                // Open the time picker
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (pickedTime != null) {
                                  setDialogState(() {
                                    selectedDate = pickedDate;
                                    selectedTime = pickedTime;

                                    // Combine date and time into a DateTime object
                                    DateTime combinedDateTime = DateTime(
                                      selectedDate!.year,
                                      selectedDate!.month,
                                      selectedDate!.day,
                                      selectedTime!.hour,
                                      selectedTime!.minute,
                                    );

                                    // Format the DateTime into the desired format
                                    selectedDateAndTime =
                                        combinedDateTime.toIso8601String();
                                    print(
                                        "Selected Date and Time: $selectedDateAndTime");
                                  });
                                }
                              }
                            },
                            child: const Text("New Booking Date and Time"),
                          ),

                          const SizedBox(height: 10),
                          if (selectedDateAndTime != null)
                            Text(
                              "${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(selectedDateAndTime.toString()).toLocal())}",
                              style: const TextStyle(color: Colors.blue),
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                // Toggle the note input visibility
                                isNoteVisible = !isNoteVisible;
                              });
                            },
                            child: const Text("Add Note"),
                          ),
                          if (isNoteVisible) ...[
                            const Text("Enter Note:"),
                            TextField(
                              controller: noteController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: "Write your note here",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Client phone and email selection
                          const Text("Select Information to Assign:"),
                          Row(
                            children: [
                              Checkbox(
                                value: isPhoneSelected,
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    isPhoneSelected = value!;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  "Phone: $phone",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Checkbox(
                                value: isEmailSelected,
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    isEmailSelected = value!;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  "Email: $email",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // TextField for custom email message if email is selected
                          if (isEmailSelected) ...[
                            const Text("Custom Email Message:"),
                            TextField(
                              controller: emailMessageController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: "Enter custom message for the client",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // DateTime Picker for remainderDate
                          TextButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null) {
                                  setDialogState(() {
                                    remainderDate = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: const Text("New Remainder Date & Time"),
                          ),
                          if (remainderDate != null)
                            Text(
                              "${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(remainderDate.toString()).toLocal())}",
                              style: const TextStyle(color: Colors.blue),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedEmployeeId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select an employee."),
                          ),
                        );
                        return;
                      }
                      if (selectedDateAndTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please select a new booking date and time."),
                          ),
                        );
                        return;
                      }
                      if (remainderDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please select a new remainder date and time."),
                          ),
                        );
                        return;
                      }
                      if (selectedEmployeeId != null) {
                        try {
                          final orderRef = FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId);

                          // Collect the data to update based on the user's selection
                          Map<String, dynamic> updateData = {
                            'employeeId': selectedEmployeeId,
                            'employeeName': selectedEmployeeName,
                            'status': 'edit',
                            if (remainderDate != null)
                              'remainderDate': remainderDate!.toIso8601String(),
                            if (noteController.text.isNotEmpty)
                              'note': noteController
                                  .text, // Add the note to Firestore

                            if (selectedDateAndTime != null)
                              'orderDateTime': selectedDateAndTime
                          };

                          // Add phone and/or email data based on selection
                          if (isPhoneSelected) {
                            updateData['phoneRemainder'] = phone;
                            sendSms(phone, '''Dear $clientName, 
Thank you for booking with Toronto ShineBright Cleaning Services, Your booking has been rescheduled.
Your new booking is confirmed for ${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(selectedDateAndTime!).toLocal())}
If you have any questions or concerns, please don’t hesitate to get in touch with us.
Thank you. 
torontoshinebright.ca
Email:contact@torontoshinebright.ca
M: 6472213051''');
                          }
                          if (isEmailSelected) {
                            updateData['emailRemainder'] = email;

                            // Send the email with the custom message
                            try {
                              String username =
                                  'Torontoshinebright23@gmail.com';
                              String password = 'bofy fhtd egwz mili';

                              final smtpServer = gmail(username, password);

                              final message = Message()
                                ..from = Address(username,
                                    'Toronto ShineBright Cleaning services')
                                ..recipients.add(email)
                                ..subject =
                                    'Booking has been rescheduled, Toronto ShineBright Cleaning services.'
                                ..text = ''' Dear $clientName,

Thank you for booking with Toronto ShineBright Cleaning Services.

Your booking has been confirmed for ${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.parse(selectedDateAndTime!).toLocal())}

${emailMessageController.text}

If you would like to change your appointment to a different date or time, please reply to this email.

If you have any questions or concerns, please don’t hesitate to get in touch with us.

*Payment method will be E-transfer. Please send the transfer to Contact@torontoshinebright.ca

Thank you.

Toronto ShineBright Cleaning Services
torontoshinebright.ca

Email: contact@torontoshinebright.ca
M: 6472213051
33 The Links Road
Toronto, ON, M2P 1T7
''';

                              await send(message, smtpServer);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Email sent successfully!"),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Failed to send email: $e")),
                              );
                            }
                          }

                          // Update the order with the selected employee and data
                          await orderRef.update(updateData);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Booking updated successfully!"),
                            ),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      }
                    },
                    child: const Text("Edit"),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  void _reject(
    BuildContext context,
    String orderId,
    String clientEmail,
    String status,
    String clientName,
    String orderDateTime,
    String clientPhone,
  ) async {
    // Define a set of statuses for which this function should execute
    final validStatuses = {
      "pending",
      "accepted",
      "edit",
    };

    // Check if the provided status matches any in the valid set
    if (validStatuses.contains(status)) {
      bool showEmail = false;
      bool showPhone = false;

      // Show dialog for checkboxes
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text("Cancel Booking"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: const Text("Include Email"),
                      value: showEmail,
                      onChanged: (value) {
                        setDialogState(() {
                          showEmail = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Include Phone"),
                      value: showPhone,
                      onChanged: (value) {
                        setDialogState(() {
                          showPhone = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog

                      if (showPhone) {
                        sendSms(clientPhone, '''Dear $clientName, 
Thank you for booking with Toronto ShineBright Cleaning Services, Your booking has been cancelled.
Please contact for new booking.
If you have any questions or concerns, please don’t hesitate to get in touch with us.
Thank you. 
torontoshinebright.ca
Email:contact@torontoshinebright.ca
M: 6472213051''');
                      }

                      // Print selected values
                      if (showEmail) {
                        try {
                          String username =
                              'Torontoshinebright23@gmail.com'; // Your Gmail email
                          String password =
                              'bofy fhtd egwz mili'; // Your Gmail password or app password

                          final smtpServer = gmail(username, password);
                          final message = Message()
                            ..from = Address(username,
                                'Toronto ShineBright Cleaning services')
                            ..recipients.add(clientEmail)
                            ..subject =
                                'Booking has been cancelled, Toronto ShineBright Cleaning services.'
                            ..text = """ Dear $clientName, 

Thank you for booking with Toronto ShineBright Cleaning Services. Your booking has been cancelled.

If you would like to change your appointment to a different date or time, please reply to this email.

If you have any questions or concerns, please don’t hesitate to get in touch with us.

Thank you. 

Toronto ShineBright Cleaning Services

Email: contact@torontoshinebright.ca
M: 6472213051
33 The Links Road 
Toronto, ON, M2P 1T7

""";

                          // Send the email
                          final sendReport = await send(message, smtpServer);

                          // Update Firestore status to "rejected"

                          // Show success SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Email sent successfully, and status updated to rejected.'),
                            ),
                          );
                        } catch (e) {
                          // Show error SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to send email or update status: $e'),
                            ),
                          );
                        }
                      }

                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orderId)
                          .update({
                        'status': 'rejected',
                        'remainderDate': FieldValue.delete(),
                      });

                      // Proceed with email sending and Firestore update
                    },
                    child: const Text("Proceed"),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      // Show invalid status SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid status: $status. No email sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final orders = snapshot.data?.docs ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text("No orders available."),
            );
          }

          // Parse and sort orders by orderDateTime
          final sortedOrders = orders.where((order) {
            final data = order.data() as Map<String, dynamic>;
            return data.containsKey('orderDateTime') &&
                data['orderDateTime'] != null;
          }).toList()
            ..sort((a, b) {
              final aDate = DateTime.parse(
                  (a.data() as Map<String, dynamic>)['orderDateTime']);
              final bDate = DateTime.parse(
                  (b.data() as Map<String, dynamic>)['orderDateTime']);
              return bDate.compareTo(aDate); // Descending order
            });

          return Scrollbar(
            thumbVisibility: true, // Ensures the scrollbar is always visible
            child: ListView.builder(
              itemCount: sortedOrders.length,
              itemBuilder: (context, index) {
                final order = sortedOrders[index];
                final data = order.data() as Map<String, dynamic>;

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
                final orderDateTime1 = data['orderDateTime'] ?? 'N/A';

                final workingTimeRaw = data['workingTime'] ??
                    'N/A'; // Default to 'N/A' if not found

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
                  Color _color = Colors.white;
                  if (status == "pending") {
                    _color = Colors.white;
                  } else if (status == "accepted") {
                    _color = const Color.fromARGB(85, 76, 175, 79);
                  } else if (status == "completed") {
                    _color = const Color.fromARGB(85, 200, 196, 204);
                  } else if (status == "rejected") {
                    _color = const Color.fromARGB(85, 225, 33, 20);
                  } else if (status == "edit") {
                    _color = const Color.fromARGB(85, 33, 148, 242);
                  } else if (status == "working") {
                    _color = const Color.fromARGB(85, 249, 225, 1);
                  }

                  return _color;
                }

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _edit(order.id, username, phone,
                                  email, status, username, orderDateTime1),
                              child: const Text("Edit"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _assignEmployee(
                                  order.id,
                                  username,
                                  phone,
                                  email,
                                  status,
                                  username,
                                  orderDateTime1),
                              child: const Text("Confirm"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                _reject(context, orderId, email, status,
                                    username, orderDateTime, phone);
                              },
                              child: const Text("Cancel"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
