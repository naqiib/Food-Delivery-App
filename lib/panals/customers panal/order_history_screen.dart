import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query: Get orders where customerEmail matches logged-in user
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerEmail', isEqualTo: user?.email)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // --- 1. ERROR HANDLING ---
          if (snapshot.hasError) {
            // FIXED: Used debugPrint instead of print to resolve lint warnings
            debugPrint("----------- FIRESTORE ERROR -----------");
            debugPrint(snapshot.error.toString());
            debugPrint("---------------------------------------");

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Database Index Missing",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Check your VS Code Debug Console for a link to create the index.\n\nError: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
            );
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text(
                    "No past orders found",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = order['orderId'] ?? 'Unknown';
              final status = order['status'] ?? 'Pending';
              final total = order['total'] ?? 0.0;
              final items = order['items'] as List<dynamic>;

              final Timestamp? timestamp = order['timestamp'];
              final dateTime = timestamp?.toDate() ?? DateTime.now();
              final dateString = DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(dateTime);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderTrackingScreen(orderId: orderId),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order #$orderId",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.fastfood,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              items
                                  .map((e) => "${e['quantity']}x ${e['name']}")
                                  .join(", "),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            dateString,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Out for Delivery':
        return Colors.blue;
      case 'Preparing':
        return Colors.orange;
      case 'Pending':
      default:
        return Colors.red;
    }
  }
}
