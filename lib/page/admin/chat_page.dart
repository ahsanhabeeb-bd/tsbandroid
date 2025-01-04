import 'package:flutter/material.dart';

import 'chat_with_clint.dart';
import 'chat_with_empoyee.dart';

// Assuming you have the following chat pages for Client and Employee
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 tabs for ClientChat and EmployeeChat
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            indicatorColor:
                Color.fromARGB(255, 33, 150, 243), // Indicator color
            labelColor:
                Color.fromARGB(255, 33, 150, 243), // Selected tab text color
            unselectedLabelColor: Colors.grey, // Unselected tab text color
            tabs: [
              Tab(text: 'Client Chat'),
              Tab(text: 'Employee Chat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChatWithClient(),
            ChatWithEmployee(),
          ],
        ),
      ),
    );
  }
}
