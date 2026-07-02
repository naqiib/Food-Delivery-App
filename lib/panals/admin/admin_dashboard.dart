import 'package:flutter/material.dart';
// Adjust this import path if your file is in a different folder
import '../customers panal/welcome_screen.dart';
import 'admin_add_item.dart';
import 'admin_manage_items.dart';
import 'admin_order_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Panel"),
          backgroundColor: const Color(0xFF6A1B9A),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Add Item"),
              Tab(text: "Manage"),
              Tab(text: "Orders"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminAddItem(),
            AdminManageItems(),
            AdminOrderManagementScreen(),
          ],
        ),
      ),
    );
  }
}
