import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() =>
      _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState
    extends State<AdminOrderManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final orderId = orderData['orderId'] ?? orders[index].id;
              final status = orderData['status'] ?? 'Pending';
              final Timestamp? timestamp = orderData['timestamp'];

              final DateTime orderTime = timestamp?.toDate() ?? DateTime.now();
              final formattedTime = DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(orderTime);

              final items = (orderData['items'] as List<dynamic>? ?? []);

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Info
                      _buildInfoRow(
                        Icons.person,
                        orderData['customerName'] ?? 'Unknown',
                      ),
                      _buildInfoRow(
                        Icons.phone,
                        orderData['phone'] ?? 'No Phone',
                      ),
                      _buildInfoRow(
                        Icons.location_on,
                        orderData['address'] ?? 'No Address',
                      ),
                      _buildInfoRow(
                        Icons.payment,
                        orderData['paymentMethod'] ?? 'Cash',
                      ),
                      const Divider(),

                      // Items
                      const Text(
                        "Items:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                "${item['quantity']}x ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: Text(item['name'] ?? 'Item')),
                              Text("\$${item['price']}"),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),

                      // Total & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "\$${(orderData['total'] ?? 0).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Status Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Status: $status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == 'Completed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          DropdownButton<String>(
                            value: ['Pending', 'Completed'].contains(status)
                                ? status
                                : 'Pending',
                            items: <String>['Pending', 'Completed'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null && newStatus != status) {
                                _updateStatus(orders[index].id, newStatus);
                              }
                            },
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
