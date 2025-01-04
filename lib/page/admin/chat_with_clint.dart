// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat_screen.dart';

class ChatWithClient extends StatefulWidget {
  const ChatWithClient({super.key});

  @override
  State<ChatWithClient> createState() => _ChatWithClientState();
}

class _ChatWithClientState extends State<ChatWithClient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? username;
  String? userId;

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

  Future<List<Map<String, dynamic>>> _getClients() async {
    try {
      // Fetch clients from Firestore
      final clientsSnapshot = await _firestore.collection('clients').get();
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

      print(
          'Clients with unread messages: $clientsWithUnreadMessages'); // Debugging line

      return clientsWithUnreadMessages;
    } catch (e) {
      print('Error fetching clients: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clients available.'));
          }

          final clients = snapshot.data!;

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                title: Text(client['username']),
                trailing: client['hasUnreadMessages']
                    ? const Icon(Icons.circle, color: Colors.green, size: 12)
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
