// ignore_for_file: use_super_parameters, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen.dart';
import 'booking_page.dart';
import 'booking_scarch.dart';

class BookingTabs extends StatefulWidget {
  const BookingTabs({Key? key}) : super(key: key);
  @override
  State<BookingTabs> createState() => _BookingTabsState();
}

class _BookingTabsState extends State<BookingTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                        // Assuming the adminId is already available
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        String? adminId = prefs
                            .getString('id'); // Replace with actual adminId

                        // Update username in Firestore
                        await FirebaseFirestore.instance
                            .collection('admin')
                            .doc(adminId)
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
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
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

                        String? adminId = prefs
                            .getString('id'); // Replace with actual adminId

                        // Update password in Firestore
                        await FirebaseFirestore.instance
                            .collection('admin')
                            .doc(adminId)
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
            // Initialize phoneController with '+1' if it's empty
            phoneController.text = '+1'; // This will add +1 by default

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

                        String? adminId =
                            prefs.getString('id'); // Get the adminId

                        // Update phone number in Firestore
                        await FirebaseFirestore.instance
                            .collection('admin')
                            .doc(adminId)
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
                          if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
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

                        String? adminId =
                            prefs.getString('id'); // Get the adminId

                        // Update email in Firestore
                        await FirebaseFirestore.instance
                            .collection('admin')
                            .doc(adminId)
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

  void _allAdmin() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('admin').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: const Text("Loading Admins"),
                content: const Center(child: CircularProgressIndicator()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text("Failed to load admins: ${snapshot.error}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AlertDialog(
                title: const Text("No Admins Found"),
                content: const Text("There are no admins available."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            }

            // List of admins
            final admins = snapshot.data!.docs;

            return AlertDialog(
              title: const Text("Admins List"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final admin = admins[index];
                    final adminData = admin.data() as Map<String, dynamic>;
                    final username = adminData['username'] ?? "Unknown";

                    return ListTile(
                      title: Text(username),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addAdmin() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    // Define a GlobalKey for form validation
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Add Admin"),
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
                          labelText: "Username",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          // Regular expression for email validation
                          final emailRegex = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          // Ensure phone number starts with +1
                          if (!value.startsWith('+1')) {
                            return 'Phone number must start with +1';
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
                    String newAdminUsername = usernameController.text;
                    String newAdminEmail = emailController.text;
                    String newAdminPassword = passwordController.text;
                    String newAdminPhone = phoneController.text;

                    // Validate form
                    if (formKey.currentState!.validate()) {
                      String adminId =
                          DateTime.now().millisecondsSinceEpoch.toString();

                      try {
                        // Save admin details in Firestore
                        await FirebaseFirestore.instance
                            .collection('admin')
                            .doc(adminId)
                            .set({
                          'username': newAdminUsername,
                          'email': newAdminEmail,
                          'password': newAdminPassword,
                          'phone': newAdminPhone,
                          'id': adminId,
                          'role': 'admin',
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Admin $newAdminUsername added successfully."),
                          ),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        print("Failed to add admin: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to add admin: $e"),
                          ),
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
      },
    );
  }

  Future<Map<String, String>> _getAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve admin data from SharedPreferences
    String adminName = prefs.getString('username') ?? 'No Username';
    String adminEmail = prefs.getString('email') ?? 'No Email';
    String adminPhone = prefs.getString('phone') ?? 'No Phone';

    // Return the data as a map
    return {
      'username': adminName,
      'email': adminEmail,
      'phone': adminPhone,
    };
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
                      .collection('admin') // Replace with your collection name
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
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
                    _getAdminData(), // Call a function to fetch data from SharedPreferences
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show loading while data is being fetched
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('Admin data not found'));
                  }

                  var adminData = snapshot.data as Map<String, String>;
                  String adminName = adminData['username'] ?? 'No Username';
                  String adminEmail = adminData['email'] ?? 'No Email';
                  String adminPhone = adminData['phone'] ?? 'No Phone';

                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        adminName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        adminEmail,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        adminPhone,
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
              leading: const Icon(Icons.person_add),
              title: const Text("Add Admin"),
              onTap: _addAdmin,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("All Admin"),
              onTap: _allAdmin,
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
      body: Column(
        children: [
          // TabBar in the body
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(
                text: 'Booking Page',
              ),
              Tab(
                text: 'Booking Search',
              ),
            ],
          ),

          // TabBarView to show content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BookingPage(), // Replace with your BookingPage widget
                BookingScarch(), // Replace with your BookingSearch widget
              ],
            ),
          ),
        ],
      ),
    );
  }
}
