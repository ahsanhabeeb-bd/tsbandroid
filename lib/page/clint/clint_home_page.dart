// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../chat_with_admin.dart';
import 'client_services.dart';
import 'main_home.dart';

class ClintHomePage extends StatefulWidget {
  const ClintHomePage({super.key});

  @override
  State<ClintHomePage> createState() => _ClintHomePageState();
}

class _ClintHomePageState extends State<ClintHomePage> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const MainHome(),
      const ClientServices(),
      const ChatWithAdmin(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.compost_sharp),
        title: ("My services"),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.chat_bubble),
        title: ("Chat"),
        activeColorPrimary: Colors.green,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
