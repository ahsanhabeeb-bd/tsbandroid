// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_string_interpolations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClintPage extends StatefulWidget {
  const ClintPage({super.key});

  @override
  State<ClintPage> createState() => _ClintPageState();
}

class _ClintPageState extends State<ClintPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void _addClint() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Client"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Username Field
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a username";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a password";
                      }
                      if (value.length != 6) {
                        return "Password must be exactly 6 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an email";
                      }

                      // Regular expression for basic email validation
                      String pattern =
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                      RegExp regExp = RegExp(pattern);

                      if (!regExp.hasMatch(value)) {
                        return "Please enter a valid email address";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Phone Field
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a phone number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Address Field
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an address";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String username = usernameController.text;
                  String password = passwordController.text;
                  String email = emailController.text;
                  String phone = phoneController.text;
                  String address = addressController.text;

                  // Generate a unique clientId using the current timestamp
                  String clientId =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  try {
                    // Add client to Firestore
                    await FirebaseFirestore.instance
                        .collection('clients')
                        .doc(clientId)
                        .set({
                      'username': username,
                      'password': password,
                      'email': email,
                      'phone': phone,
                      'address': address, // Save the address
                      'id': clientId,
                      'role': 'client',
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Client added successfully!"),
                      ),
                    );

                    Navigator.of(context).pop(); // Close dialog
                  } catch (e) {
                    print("Error adding client: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: const Text("Add Client"),
            ),
          ],
        );
      },
    );
  }

  void _createOrder(
      String clientId, String username, String email, String phone) async {
    // Fetch the client's address from Firestore
    DocumentSnapshot clientDoc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientId)
        .get();

    String address = clientDoc['address'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        String? selectedService;
        String? selectedServiceTitle;
        DateTime? selectedDate;
        TimeOfDay? selectedTime;

        // Variables to handle missing information
        final TextEditingController phoneController =
            TextEditingController(text: phone);
        final TextEditingController emailController =
            TextEditingController(text: email);
        final TextEditingController addressController =
            TextEditingController(text: address);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Create Booking"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display or input client information
                    Text("Username: $username"),

                    if (phone.isEmpty)
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Phone",
                          hintText: "Enter phone number",
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          if (!value.startsWith('+1')) {
                            phoneController.text = '+1';
                            phoneController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: phoneController.text.length),
                            );
                          }
                        },
                      )
                    else
                      Text("Phone: $phone"),

                    const SizedBox(height: 10),
                    if (email.isEmpty)
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintText: "Enter email address",
                          errorText:
                              null, // This will dynamically show error text if needed.
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'); // Email regex
                          if (!emailRegex.hasMatch(value)) {
                            // Update error text dynamically if needed
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Please enter a valid email address")),
                            );
                          }
                        },
                      )
                    else
                      Text("Email: $email"),

                    const SizedBox(height: 10),

                    if (address.isEmpty)
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          hintText: "Enter address",
                        ),
                      )
                    else
                      Text("Address: $address"),

                    const SizedBox(height: 10),

                    // Service Dropdown
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('services')
                          .get(),
                      builder: (context, serviceSnapshot) {
                        if (serviceSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (serviceSnapshot.hasError) {
                          return Text('Error: ${serviceSnapshot.error}');
                        }

                        final services = serviceSnapshot.data!.docs;
                        if (services.isEmpty) {
                          return const Text("No services available.");
                        }

                        return DropdownButton<String>(
                          value: null, // Always show placeholder text
                          hint: const Text("Select Service"),
                          isExpanded: true,
                          items: services.map((serviceDoc) {
                            final serviceId = serviceDoc['serviceId'];
                            final serviceTitle = serviceDoc['title'];
                            return DropdownMenuItem<String>(
                              value: serviceId,
                              child: Text(serviceTitle),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedService = value;
                              selectedServiceTitle = services.firstWhere(
                                  (serviceDoc) =>
                                      serviceDoc['serviceId'] ==
                                      value)['title'];
                            });
                          },
                        );
                      },
                    ),
                    // Display the selected service title if any
                    if (selectedServiceTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Selected Service: $selectedServiceTitle",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Date Picker
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: const Text("Date"),
                        ),
                        if (selectedDate != null)
                          Text(
                              selectedDate!.toLocal().toString().split(' ')[0]),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Time Picker
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setDialogState(() {
                                selectedTime = pickedTime;
                              });
                            }
                          },
                          child: const Text("Time"),
                        ),
                        if (selectedTime != null)
                          Text("${selectedTime!.format(context)}"),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedService != null &&
                        selectedDate != null &&
                        selectedTime != null) {
                      // Ensure that user has provided missing information
                      if (phoneController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Please fill in all required fields."),
                          ),
                        );
                        return;
                      }

                      String orderId =
                          DateTime.now().millisecondsSinceEpoch.toString();

                      // Combine date and time
                      DateTime orderDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );

                      try {
                        FirebaseFirestore.instance
                            .collection('clients')
                            .doc(clientId)
                            .update({
                          'address': addressController.text,
                          'phone': phoneController.text,
                          'email': emailController.text,
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }

                      try {
                        // Create order in Firestore with updated data
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .set({
                          'clientid': clientId,
                          'username': username,
                          'email': emailController.text,
                          'phone': phoneController.text,
                          'address': addressController.text,
                          'serviceId': selectedService,
                          'serviceTitle': selectedServiceTitle,
                          'orderId': orderId,
                          'orderDateTime': orderDateTime.toIso8601String(),
                          'createdAt': Timestamp.now(),
                          'status': 'pending',
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Booking created successfully!"),
                          ),
                        );

                        Navigator.of(context).pop(); // Close dialog
                      } catch (e) {
                        print("Error creating order: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Please select service, date, and time!"),
                        ),
                      );
                    }
                  },
                  child: const Text("Create Booking"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeDetailsDialog(String employeeId) async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username Field
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter a username";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Password Field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter a password";
                  }
                  if (value != null && value.length != 6) {
                    return "Password must be exactly 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Phone Number Field
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter a phone number";
                  }
                  if (value != null && value.length != 10) {
                    return "Phone number must be 10 digits";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Email Field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Please enter an email";
                  }
                  if (value != null &&
                      !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newUsername = usernameController.text.trim();
                String newPassword = passwordController.text.trim();
                String newPhone = phoneController.text.trim();
                String newEmail = emailController.text.trim();

                // Create a map of values to update
                Map<String, String> updatedValues = {};

                // Check if fields have been updated
                if (newUsername.isNotEmpty) {
                  updatedValues['username'] = newUsername;
                }
                if (newPassword.isNotEmpty) {
                  updatedValues['password'] = newPassword;
                }
                if (newPhone.isNotEmpty) {
                  updatedValues['phone'] = newPhone;
                }
                if (newEmail.isNotEmpty) {
                  updatedValues['email'] = newEmail;
                }

                // Only update fields that are not empty
                if (updatedValues.isNotEmpty) {
                  try {
                    // Update the fields in Firestore
                    await FirebaseFirestore.instance
                        .collection('clients')
                        .doc(employeeId)
                        .update(updatedValues);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Details changed successfully!"),
                      ),
                    );

                    Navigator.of(context).pop(); // Close dialog
                  } catch (e) {
                    print("Error changing details: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                } else {
                  // If no fields are updated, just close the dialog
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Change Details"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients"),
        actions: [
          ElevatedButton(
            onPressed: _addClint, // Open the dialog when button is pressed
            child: const Text("Add Client"),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase(); // Update the search query
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clients')
                  .snapshots(), // Fetch all clients from Firestore in real-time
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No clients available.'));
                }

                final clients = snapshot.data!.docs.reversed.toList();

                // Filter clients based on search query
                final filteredClients = clients.where((client) {
                  final username = client['username'] ?? '';
                  return username.toLowerCase().contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    // Use safe access with null checks for missing fields
                    final username = client['username'] ?? 'No username';
                    final email = client['email'] ?? 'No email';
                    final phone = client['phone'] ?? 'No phone';
                    final clientId = client['id'];

                    return GestureDetector(
                      onTap: () {
                        _showChangeDetailsDialog(clientId);
                      },
                      child: ListTile(
                        title: Text(username),
                        subtitle: Text('Email: $email\nPhone: $phone'),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          child: const Icon(
                            Icons.eco_sharp,
                            color: Colors.lightGreen,
                          ),
                          onPressed: () {
                            // Open order creation dialog when pressed
                            _createOrder(clientId, username, email, phone);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
