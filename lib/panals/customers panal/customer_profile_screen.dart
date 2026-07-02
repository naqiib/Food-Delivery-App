import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart'; // Ensure this path is correct

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    // 1. Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // 2. Navigate back to Welcome Screen
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF6A1B9A),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text("Logged in as:", style: TextStyle(color: Colors.grey[600])),
              Text(
                user?.email ?? "Guest",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Fetch extra details from Firestore if needed
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Hello, ${data['username']}!",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),

              const SizedBox(height: 50),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
