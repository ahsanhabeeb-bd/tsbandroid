// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:flutter/material.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'booking_tap.dart';
import 'chat_page.dart';
import 'clint_page.dart';
import 'employee_page.dart';
import 'services_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 2);

  List<Widget> _buildScreens() {
    return [
      const EmployeePage(),
      const ClintPage(),
      const BookingTabs(),
      const ServicesPage(),
      const ChatPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.group),
        title: ("Employee"),
        activeColorPrimary: const Color.fromARGB(255, 33, 150, 243),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: ("Clients"),
        activeColorPrimary: const Color.fromARGB(255, 33, 150, 243),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.event),
        title: ("Bookings"),
        activeColorPrimary: const Color.fromARGB(255, 33, 150, 243),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.compost_sharp),
        title: ("Services"),
        activeColorPrimary: const Color.fromARGB(255, 33, 150, 243),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.chat_bubble),
        title: ("Chat"),
        activeColorPrimary: const Color.fromARGB(255, 33, 150, 243),
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
