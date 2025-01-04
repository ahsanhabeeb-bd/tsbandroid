import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';

class ChatWithAdmin extends StatefulWidget {
  const ChatWithAdmin({super.key});

  @override
  State<ChatWithAdmin> createState() => _ChatWithAdminState();
}

class _ChatWithAdminState extends State<ChatWithAdmin> {
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

  void _markMessagesAsRead(String adminId) async {
    final chatId = '${adminId}_$userId';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('admin').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No admins available.'));
          }

          final admins = snapshot.data!.docs.map((doc) {
            return {
              'id': doc.id,
              'username': doc['username'],
            };
          }).toList();

          return ListView.builder(
            itemCount: admins.length,
            itemBuilder: (context, index) {
              final admin = admins[index];
              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc('${admin['id']}_$userId')
                    .collection('messages')
                    .where('senderId', isNotEqualTo: userId)
                    .where('read', isEqualTo: false)
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  final hasUnreadMessages = messageSnapshot.hasData &&
                      messageSnapshot.data!.docs
                          .any((doc) => doc['read'] == false);

                  return ListTile(
                    title: Text(admin['username']),
                    trailing: hasUnreadMessages
                        ? const Icon(Icons.circle,
                            color: Colors.green, size: 12)
                        : null,
                    onTap: () {
                      _markMessagesAsRead(
                          admin['id']); // Mark as read only when tapping
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: '${admin['id']}_$userId',
                            currentUserId: userId!,
                            otherUserName: admin['username'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
