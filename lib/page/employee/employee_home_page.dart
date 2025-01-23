// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:TSB/page/employee/booking_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat_with_admin.dart';
import '../login_screen.dart';
import 'avable_date.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const BookingTab(),
      const ChatWithAdmin(),
      const AvableDate(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.event),
        title: ("Bookings"),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.chat_bubble),
        title: ("Chat"),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.calendar_month),
        title: ("Available Date"),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
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
                            .collection('employees')
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
                            .collection('employees')
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
                            .collection('employees')
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
                            .collection('employees')
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
                          'employees') // Replace with your collection name
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
      body: PersistentTabView(
        context, // Pass the context here as the first argument
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        navBarStyle: NavBarStyle.style3,
        //  confineInSafeArea: true,
        backgroundColor: const Color.fromARGB(255, 235, 235, 230),
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        // hideNavigationBarWhenKeyboardShows: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: const Color.fromARGB(255, 235, 235, 230),
        ),
        //  popAllScreensOnTapOfSelectedTab: true,
      ),
    );
  }
}
