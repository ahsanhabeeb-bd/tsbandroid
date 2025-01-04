// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatDetails extends StatefulWidget {
  final String clientId;
  final String clientUsername;

  const ChatDetails(
      {super.key, required this.clientId, required this.clientUsername});

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  final TextEditingController _messageController = TextEditingController();

  // Send a message to Firestore
  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Get reference to the messages subcollection
    CollectionReference messages = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.clientId)
        .collection('messages');

    try {
      await messages.add({
        'text': message,
        'senderId': 'admin', // You can set the senderId to 'admin'
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the text field after sending the message
      _messageController.clear();
    } catch (e) {
      print("Failed to send message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientUsername),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Stream to fetch chat messages from Firestore
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.clientId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                // Get the list of messages from Firestore documents
                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    String messageText = message['text'];
                    String senderId = message['senderId'];
                    Timestamp? timestamp = message['timestamp'];

                    // Handle null timestamp value
                    String time = timestamp != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                                timestamp.seconds * 1000)
                            .toLocal()
                            .toString()
                        : 'Unknown time';

                    return ListTile(
                      title: Text(senderId == 'admin'
                          ? 'Admin: $messageText'
                          : 'Client: $messageText'),
                      subtitle: Text(time),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage, // Call the send message function
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
