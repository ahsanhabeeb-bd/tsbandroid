// ignore_for_file: use_build_context_synchronously, avoid_print, unused_local_variable, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'avable_date_for_admin.dart';
import 'weekly_for_admin.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  void _addEmployee() async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Employee"),
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

                  // Generate a unique ID using the current timestamp
                  String employeeId =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  try {
                    // Add employee to Firestore
                    await FirebaseFirestore.instance
                        .collection('employees')
                        .doc(employeeId)
                        .set({
                      'username': username,
                      'password': password,
                      'email': email,
                      'phone': phone,
                      'id': employeeId,
                      'role': 'employee',
                      'availableDates': []
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Employee added successfully!"),
                      ),
                    );

                    Navigator.of(context).pop(); // Close dialog
                  } catch (e) {
                    print("Error adding employee: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Method to show the dialog for changing password
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
                        .collection('employees')
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

  String searchQuery = ""; // Holds the current search query
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees"),
        actions: [
          ElevatedButton(
            onPressed: _addEmployee,
            child: const Text("Add Employee"),
          ),
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
                  .collection('employees')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No employees found."));
                }

                // Filter employees based on the search query
                final employees = snapshot.data!.docs
                    .where((doc) {
                      final username =
                          doc['username']?.toLowerCase() ?? ''; // Safe access
                      return username.contains(searchQuery);
                    })
                    .toList()
                    .reversed
                    .toList();

                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    final username = employee['username'] ?? 'No username';
                    final email = employee['email'] ?? 'No email';
                    final phone = employee['phone'] ?? 'No phone';
                    final role = employee['role'] ?? 'No role';
                    final id = employee['id'] ?? 'No id';

                    return GestureDetector(
                      onTap: () =>
                          _showChangeDetailsDialog(id), // Show dialog on tap
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Email: $email',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Phone: $phone',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            WeeklyForAdmin(id: id),
                                      ),
                                    );
                                  },
                                  child: const Text("Hours"),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AvableDateForAdmin(id: id),
                                      ),
                                    );
                                  },
                                  child: const Text("Available Date"),
                                ),
                              ],
                            ),
                          ],
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
