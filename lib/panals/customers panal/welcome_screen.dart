import 'package:flutter/material.dart';
import '../admin/admin_login_screen.dart';
import 'customer_auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                "https://img.icons8.com/color/144/hamburger.png",
                height: 120,
              ),
              const SizedBox(height: 30),
              const Text(
                "Welcome to DeliGO",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Select your role to continue",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 50),

              // Admin Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Login as Admin",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Customer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerAuthScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text(
                    "Login as Customer",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
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
