// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  // Fetch services from Firestore
  Stream<List<Map<String, dynamic>>> _fetchServices() {
    return FirebaseFirestore.instance
        .collection('services')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'title': doc['title'],
          'details': doc['details'],
          'serviceId': doc['serviceId'],
        };
      }).toList();
    });
  }

  // Function to open the dialog to add a new service
  void _addService() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Service"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Field
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Service Title",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a service title";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Details Field - Multi-line TextField
                  TextFormField(
                    controller: detailsController,
                    maxLines: 5, // Makes the field taller (vertical expansion)
                    keyboardType:
                        TextInputType.multiline, // Enables multi-line input
                    decoration: const InputDecoration(
                      labelText: "Service Details",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter service details";
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
                  String title = titleController.text;
                  String details = detailsController.text;

                  // Generate a unique serviceId using the current timestamp
                  String serviceId =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  try {
                    // Add service to Firestore
                    await FirebaseFirestore.instance
                        .collection('services')
                        .doc(serviceId)
                        .set({
                      'title': title,
                      'details': details,
                      'serviceId': serviceId,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Service added successfully!"),
                      ),
                    );

                    Navigator.of(context).pop(); // Close dialog
                  } catch (e) {
                    print("Error adding service: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: const Text("Add Service"),
            ),
          ],
        );
      },
    );
  }

  // Function to open the dialog to edit an existing service
  void _editService(Map<String, dynamic> service) {
    final TextEditingController titleController =
        TextEditingController(text: service['title']);
    final TextEditingController detailsController =
        TextEditingController(text: service['details']);

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Service"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Field
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Service Title",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a service title";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Details Field - Multi-line TextField
                  TextFormField(
                    controller: detailsController,
                    maxLines: 5, // Makes the field taller (vertical expansion)
                    keyboardType:
                        TextInputType.multiline, // Enables multi-line input
                    decoration: const InputDecoration(
                      labelText: "Service Details",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter service details";
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
                  String title = titleController.text;
                  String details = detailsController.text;

                  try {
                    // Update service in Firestore
                    await FirebaseFirestore.instance
                        .collection('services')
                        .doc(service['serviceId'])
                        .update({
                      'title': title,
                      'details': details,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Service updated successfully!"),
                      ),
                    );

                    Navigator.of(context).pop(); // Close dialog
                  } catch (e) {
                    print("Error updating service: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: const Text("Update Service"),
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
        actions: [
          ElevatedButton(
            onPressed: _addService, // Open the dialog when button is pressed
            child: const Text("Add Service"),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final services = snapshot.data ?? [];

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () => _editService(service),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['details'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
