// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin/admin_homepage.dart';
import 'clint/clint_home_page.dart';
import 'clint/signup_page.dart';
import 'employee/employee_home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Simulate loading state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logging in...")),
      );

      try {
        // Search in admin collection first
        var userDoc = await FirebaseFirestore.instance
            .collection('admin')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        if (userDoc.docs.isEmpty) {
          // If not found in admin, search in clients
          userDoc = await FirebaseFirestore.instance
              .collection('clients')
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .get();
        }

        if (userDoc.docs.isEmpty) {
          // If not found in clients, search in employees
          userDoc = await FirebaseFirestore.instance
              .collection('employees')
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .get();
        }

        if (userDoc.docs.isNotEmpty) {
          var userData = userDoc.docs.first.data();

          // Save the user data to SharedPreferences

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', userData['username']);
          await prefs.setString('email', userData['email']);
          await prefs.setString('password', userData['password']);
          await prefs.setString('phone', userData['phone']);
          await prefs.setString('id', userData['id']);
          await prefs.setString('role', userData['role']);

          // Navigate based on role
          if (userData['role'] == 'admin') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => AdminHomePage()));
          } else if (userData['role'] == 'employee') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => EmployeeHomePage()));
          } else if (userData['role'] == 'client') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ClintHomePage()));
          }
        } else {
          // Show SnackBar if no match found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid username or password")),
          );
        }
      } catch (e) {
        print("Login failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _gestUser() async {
    final String clientId = DateTime.now().millisecondsSinceEpoch.toString();
    String username = "C$clientId";
    String password = "C$clientId";

    try {
      await FirebaseFirestore.instance.collection('clients').doc(clientId).set({
        'username': username, // Storing username
        'password': password, // Storing password
        'id': clientId,
        'role': 'client', // Default role as 'client'
        'email': '',
        'phone': '',
        'address': '',
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('username', username);
      await prefs.setString('password', password);
      await prefs.setString('id', clientId);
      await prefs.setString('role', 'client'); // Save 'client' role
      await prefs.setString('email', ''); // Save 'client' role
      await prefs.setString('phone', ''); // Save 'client' role
      await prefs.setString('address', '');

      // You can show a success message or navigate to another screen
      print('User signed up with clientId: $clientId');
    } catch (e) {
      // Handle errors, like network issues
      print('Error signing up: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Login",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your username";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  } else if (value.length < 6) {
                    return "Password must be at least 6 characters long";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24.0),

              // Login Button with Gradient
              GestureDetector(
                onTap: _login,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 6, 155, 255), // Purple
                        Color.fromARGB(255, 20, 60, 242), // Light Purple
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text("Sign Up"),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  _gestUser();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => ClintHomePage()));
                },
                child: Text("Gest User"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
