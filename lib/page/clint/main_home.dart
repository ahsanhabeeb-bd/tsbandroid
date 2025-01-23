// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  List<Map<String, dynamic>> _services = []; // List to store services
  List<bool> _isExpanded = []; // List to track which card is expanded

  @override
  void initState() {
    super.initState();
    _loadServices(); // Load services when the widget is initialized
  }

  void _createOrder(int index) async {
    // Fetch clientId from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clientId = prefs.getString('id'); // Retrieve clientId

    print("Client ID: $clientId");

    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client ID not found!")),
      );
      return;
    }

    // Fetch the client's details from Firestore
    DocumentSnapshot clientDoc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientId)
        .get();
    print("Client Document Data: ${clientDoc.data()}");
    String address = clientDoc['address'] ?? '';
    String phone = clientDoc['phone'] ?? '';
    String email = clientDoc['email'] ?? '';
    String username = clientDoc['username'] ?? '';

    print("Phone: $phone, Email: $email, Address: $address");

    // Get service details based on the index
    var selectedService = _services[index];
    String serviceId = selectedService['servicesid'];
    String serviceTitle = selectedService['title'];

    showDialog(
      context: context,
      builder: (context) {
        DateTime? selectedDate;
        TimeOfDay? selectedTime;

        final TextEditingController phoneController =
            TextEditingController(text: phone);
        final TextEditingController emailController =
            TextEditingController(text: email);
        final TextEditingController addressController =
            TextEditingController(text: address);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Create Order"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display client information
                    Text("Username: $username"),
                    const SizedBox(height: 10),
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

                    // Service details (pre-selected)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Selected Service: $serviceTitle",
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
                    if (selectedDate != null && selectedTime != null) {
                      // Ensure the user has provided missing information
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

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.setString(
                          'email', emailController.text); // Save 'client' role
                      await prefs.setString(
                          'phone', phoneController.text); // Save 'client' role
                      await prefs.setString('address', addressController.text);

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
                          'serviceId': serviceId,
                          'serviceTitle': serviceTitle,
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
                          content: Text("Please select date and time!"),
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

  // Method to fetch services from Firestore
  Future<void> _loadServices() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('services').get();

      // Map the snapshot to a list of services
      List<Map<String, dynamic>> services = snapshot.docs.map((doc) {
        return {
          'servicesid': doc.id,
          'title': doc['title'] ?? 'No title', // Fetch title field
          'description':
              doc['details'] ?? 'No description', // Fetch description field
        };
      }).toList();

      setState(() {
        _services = services; // Update the state with the services list
        _isExpanded = List.generate(
            services.length, (_) => false); // Initialize the expansion state
      });
    } catch (e) {
      print("Error loading services: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading services: $e")),
      );
    }
  }

  // Method to handle logout
  void _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clears all data from SharedPreferences

      // Navigate to the Login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully.")),
      );
    } catch (e) {
      print("Failed to clear SharedPreferences: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during logout: $e")),
      );
    }
  }

  // Toggle the expansion state for the selected card
  void _toggleDetails(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  void _changeUsername() async {
    final TextEditingController usernameController = TextEditingController();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    usernameController.text = prefs.getString('username')!;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Change Username"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: "New Username",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
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
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String newUsername = usernameController.text;

                    // Validate form input
                    if (formKey.currentState!.validate()) {
                      try {
                        // Assuming the employeeId is already available
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        String? employeeId = prefs
                            .getString('id'); // Replace with actual employeeId

                        // Update username in Firestore
                        await FirebaseFirestore.instance
                            .collection('clients')
                            .doc(employeeId)
                            .update({
                          'username': newUsername,
                        });
                        await prefs.setString('username', newUsername);
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Username updated to $newUsername."),
                          ),
                        );

                        Navigator.of(context).pop(); // Close the dialog
                      } catch (e) {
                        print("Failed to update username: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to update username: $e"),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _changePassword() async {
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "New Password",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
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
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String newPassword = passwordController.text;

                    // Validate form input
                    if (formKey.currentState!.validate()) {
                      try {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        String? employeeId = prefs
                            .getString('id'); // Replace with actual employeeId

                        // Update password in Firestore
                        await FirebaseFirestore.instance
                            .collection('clients')
                            .doc(employeeId)
                            .update({
                          'password': newPassword,
                        });

                        // Update password in SharedPreferences
                        await prefs.setString('password', newPassword);
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password updated successfully."),
                          ),
                        );

                        Navigator.of(context).pop(); // Close the dialog
                      } catch (e) {
                        print("Failed to update password: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to update password: $e"),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _changePhone() async {
    final TextEditingController phoneController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Change Phone Number"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "New Phone Number",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          // Optional: Add phone number validation if required
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
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String newPhoneNumber = phoneController.text;

                    // Validate form input
                    if (formKey.currentState!.validate()) {
                      try {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        String? employeeId =
                            prefs.getString('id'); // Get the employeeId

                        // Update phone number in Firestore
                        await FirebaseFirestore.instance
                            .collection('clients')
                            .doc(employeeId)
                            .update({
                          'phone': newPhoneNumber, // Update the phone field
                        });

                        // Update phone number in SharedPreferences
                        await prefs.setString('phone', newPhoneNumber);
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Phone number updated successfully."),
                          ),
                        );

                        Navigator.of(context).pop(); // Close the dialog
                      } catch (e) {
                        print("Failed to update phone number: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to update phone number: $e"),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _changeEmail() async {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Change Email"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "New Email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }
                          // Optional: Add email validation if required
                          // if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                          //   return 'Please enter a valid email address';
                          // }
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
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String newEmail = emailController.text;

                    // Validate form input
                    if (formKey.currentState!.validate()) {
                      try {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        String? employeeId =
                            prefs.getString('id'); // Get the employeeId

                        // Update email in Firestore
                        await FirebaseFirestore.instance
                            .collection('clients')
                            .doc(employeeId)
                            .update({
                          'email': newEmail, // Update the email field
                        });

                        // Update email in SharedPreferences
                        await prefs.setString('email', newEmail);
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Email updated successfully."),
                          ),
                        );

                        Navigator.of(context).pop(); // Close the dialog
                      } catch (e) {
                        print("Failed to update email: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to update email: $e"),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString('id');

    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No account ID found in SharedPreferences")),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this account?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                try {
                  // Delete the document from Firestore
                  await FirebaseFirestore.instance
                      .collection(
                          'clients') // Replace with your collection name
                      .doc(accountId)
                      .delete();

                  // Clear all SharedPreferences
                  await prefs.clear();
                } catch (e) {
                  // Show error message if deletion fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting account: $e")),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>> _getemployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve employee data from SharedPreferences
    String employeeName = prefs.getString('username') ?? 'No Username';
    String employeeEmail = prefs.getString('email') ?? 'No Email';
    String employeePhone = prefs.getString('phone') ?? 'No Phone';

    // Return the data as a map
    return {
      'username': employeeName,
      'email': employeeEmail,
      'phone': employeePhone,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: FutureBuilder(
                future:
                    _getemployeeData(), // Call a function to fetch data from SharedPreferences
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show loading while data is being fetched
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('employee data not found'));
                  }

                  var employeeData = snapshot.data as Map<String, String>;
                  String employeeName =
                      employeeData['username'] ?? 'No Username';
                  String employeeEmail = employeeData['email'] ?? 'No Email';
                  String employeePhone = employeeData['phone'] ?? 'No Phone';

                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        employeeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        employeeEmail,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        employeePhone,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Change Username"),
              onTap: _changeUsername,
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: _changePassword,
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Change phonenumber"),
              onTap: _changePhone,
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Change email"),
              onTap: _changeEmail,
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete Account"),
              onTap: () {
                Navigator.of(context).pop();
                _deleteAccount(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _services.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching services
          : ListView.builder(
              itemCount: _services.length,
              itemBuilder: (context, index) {
                var service = _services[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: InkWell(
                    // Make the entire card tappable
                    onTap: () =>
                        _toggleDetails(index), // Toggle expansion on card tap
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedSize(
                            duration: const Duration(
                                milliseconds:
                                    300), // Adjust duration for the speed
                            curve: Curves.easeInOut, // Smooth transition
                            child: _isExpanded[index]
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Description: ${service['description']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 10),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () => _createOrder(index),
                                        child: const Text("Order Now"),
                                      ),
                                    ],
                                  )
                                : const SizedBox
                                    .shrink(), // Empty widget when collapsed
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
