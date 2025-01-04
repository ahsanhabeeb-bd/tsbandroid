// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat_screen.dart';

class ChatWithEmployee extends StatefulWidget {
  const ChatWithEmployee({super.key});

  @override
  State<ChatWithEmployee> createState() => _ChatWithEmpoyeeState();
}

class _ChatWithEmpoyeeState extends State<ChatWithEmployee> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? username;
  String? userId;

  Map<String, bool> _selectedClients = {}; // Map to track selected clients
  bool _selectAll = false; // State of the "select all" checkbox

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Unknown User';
      userId = prefs.getString('id') ?? 'Unknown ID';
    });
  }

  void _sendMessageToSelectedClients() {
    if (_selectedClients.values.every((selected) => !selected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No clients selected!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController messageController = TextEditingController();

        return AlertDialog(
          title: const Text('Send Message'),
          content: TextField(
            controller: messageController,
            decoration:
                const InputDecoration(hintText: 'Write your message here...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final message = messageController.text.trim();

                if (message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message cannot be empty!')),
                  );
                  return;
                }

                for (var entry in _selectedClients.entries) {
                  if (entry.value) {
                    final clientId = entry.key;
                    final chatId = '${userId}_$clientId';

                    // Send the message to the Firestore collection for each selected client
                    await _firestore
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .add({
                      'senderId': userId,
                      'text': message,
                      'timestamp': FieldValue.serverTimestamp(),
                      'read': false,
                    });
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sent successfully!')),
                );

                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getClients() async {
    try {
      // Fetch clients from Firestore
      final clientsSnapshot = await _firestore.collection('employees').get();
      final clients = clientsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'username': doc['username'],
        };
      }).toList();

      final List<Map<String, dynamic>> clientsWithUnreadMessages = [];

      for (var client in clients) {
        final chatId = '${userId}_${client['id']}';
        final messagesSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('read', isEqualTo: false)
            .get();

        final hasUnreadMessages = messagesSnapshot.docs.isNotEmpty &&
            messagesSnapshot.docs.any((doc) => doc['read'] == false);

        clientsWithUnreadMessages.add({
          'id': client['id'],
          'username': client['username'],
          'hasUnreadMessages': hasUnreadMessages,
        });
      }

      // Sort clients, putting those with unread messages at the top
      clientsWithUnreadMessages.sort((a, b) {
        return (b['hasUnreadMessages'] ? 1 : 0) -
            (a['hasUnreadMessages'] ? 1 : 0);
      });

      return clientsWithUnreadMessages;
    } catch (e) {
      print('Error fetching clients: $e');
      return [];
    }
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      _selectAll = value;
      _selectedClients.updateAll((key, _) => value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 15),
              Checkbox(
                value: _selectAll,
                onChanged: (value) {
                  if (value != null) {
                    _toggleSelectAll(value);
                  }
                },
              ),
              const Text("Select All"),
              SizedBox(width: MediaQuery.of(context).size.width * 0.2),
              ElevatedButton(
                onPressed: _sendMessageToSelectedClients,
                child: const Text("Send Message"),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getClients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No clients available.'));
                }

                final clients = snapshot.data!;

                // Ensure all clients are initialized in _selectedClients
                for (var client in clients) {
                  _selectedClients.putIfAbsent(client['id'], () => false);
                }

                return ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    final isSelected = _selectedClients[client['id']] ?? false;

                    return ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            _selectedClients[client['id']] = value ?? false;

                            // Update "select all" checkbox state
                            _selectAll = _selectedClients.values
                                .every((selected) => selected);
                          });
                        },
                      ),
                      title: Text(client['username']),
                      trailing: client['hasUnreadMessages']
                          ? const Icon(Icons.circle,
                              color: Colors.green, size: 12)
                          : null,
                      onTap: () {
                        // Mark as read only when tapping
                        _markMessagesAsRead(client['id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId: '${userId}_${client['id']}',
                              currentUserId: userId!,
                              otherUserName: client['username'],
                            ),
                          ),
                        );
                      },
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

  void _markMessagesAsRead(String clientId) async {
    final chatId = '${userId}_$clientId';
    final messagesRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('read', isEqualTo: false);

    final snapshot = await messagesRef.get();
    for (var doc in snapshot.docs) {
      doc.reference.update({'read': true});
    }
  }
}
