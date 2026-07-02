import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Track Order",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text("Order not found"));
          }

          final status = data['status'] ?? 'Pending';

          // Determine Step Index based on status text (FIXED CURLY BRACES)
          int stepIndex = 0;
          if (status == 'Pending') {
            stepIndex = 1;
          } else if (status == 'Preparing') {
            stepIndex = 2;
          } else if (status == 'Out for Delivery') {
            stepIndex = 3;
          } else if (status == 'Completed') {
            stepIndex = 4;
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // --- PROGRESS BAR ---
                  Row(
                    children: [
                      Expanded(child: _buildProgressBar(stepIndex >= 1)),
                      const SizedBox(width: 5),
                      Expanded(child: _buildProgressBar(stepIndex >= 2)),
                      const SizedBox(width: 5),
                      Expanded(child: _buildProgressBar(stepIndex >= 3)),
                      const SizedBox(width: 5),
                      Expanded(child: _buildProgressBar(stepIndex >= 4)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- STATUS TEXT ---
                  Text(
                    "STATUS: ${status.toUpperCase()}",
                    style: const TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- ICON ---
                  Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFFFFF3E0,
                      ), // Fixed color to avoid withOpacity error
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      size: 60,
                      color: const Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- HEADLINE ---
                  Text(
                    _getHeadline(status),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- SUBTITLE ---
                  Text(
                    _getSubtitle(status),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  // --- FOOTER ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.black12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "RECEIPT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "ORDER# $orderId",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(bool isActive) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6A1B9A) : Colors.grey[200],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Preparing':
        return Icons.soup_kitchen;
      case 'Out for Delivery':
        return Icons.delivery_dining;
      case 'Completed':
        return Icons.check_circle;
      default:
        return Icons.receipt_long; // Pending
    }
  }

  String _getHeadline(String status) {
    switch (status) {
      case 'Preparing':
        return "NOW WE'RE\nCOOKIN'";
      case 'Out for Delivery':
        return "ORDER IS\nON THE WAY";
      case 'Completed':
        return "ENJOY\nYOUR MEAL";
      default:
        return "ORDER\nRECEIVED";
    }
  }

  String _getSubtitle(String status) {
    switch (status) {
      case 'Preparing':
        return "PREPARING YOUR DELICIOUS MEAL\nWITH LOVE AND SPICES";
      case 'Out for Delivery':
        return "OUR RIDER IS ON THE WAY\nTO YOUR DOORSTEP";
      case 'Completed':
        return "THANK YOU FOR ORDERING\nSEE YOU SOON!";
      default:
        return "WAITING FOR RESTAURANT\nTO CONFIRM";
    }
  }
}
