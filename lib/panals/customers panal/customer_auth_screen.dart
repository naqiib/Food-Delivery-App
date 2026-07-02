import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_main_nav.dart';

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({super.key});

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _confirmPassController = TextEditingController();

  String _selectedGender = 'Male';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isLogin) {
        // --- LOGIN ---
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // --- SIGN UP ---
        if (_passwordController.text != _confirmPassController.text) {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: "Passwords do not match",
          );
        }

        UserCredential userCred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
              'username': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'dob': _dobController.text.trim(),
              'gender': _selectedGender,
              'role': 'customer',
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CustomerMainNav()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? "Customer Login" : "Create Account"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "User Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Enter Name" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: const InputDecoration(
                    labelText: "Date of Birth",
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Select DOB" : null,
                ),
                const SizedBox(height: 10),
                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGender = v!),
                ),
                const SizedBox(height: 10),
              ],

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.contains('@') ? null : "Enter valid email",
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
              ),

              if (!isLogin) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: Icon(Icons.lock_clock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v != _passwordController.text
                      ? "Passwords do not match"
                      : null,
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isLogin ? "Login" : "Sign Up",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Login",
                  style: const TextStyle(color: Color(0xFF6A1B9A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
