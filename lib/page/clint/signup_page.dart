// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'clint_home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to handle signup
  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      // Create a clientId using current time
      final String clientId = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        // Add data to Firestore
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(clientId)
            .set({
          'username': username, // Storing username
          'password': password, // Storing password
          'id': clientId,
          'role': 'client', // Default role as 'client'
          'email': '',
          'phone': '',
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString('username', username);
        await prefs.setString('password', password);
        await prefs.setString('clientId', clientId);
        await prefs.setString('role', 'client'); // Save 'client' role
        await prefs.setString('email', ''); // Save 'client' role
        await prefs.setString('phone', ''); // Save 'client' role

        // You can show a success message or navigate to another screen
        print('User signed up with clientId: $clientId');
      } catch (e) {
        // Handle errors, like network issues
        print('Error signing up: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Change the label to 'Username'
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
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

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _signup();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClintHomePage()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: (8.0),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
