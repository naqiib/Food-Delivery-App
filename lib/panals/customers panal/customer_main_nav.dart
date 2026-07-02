import 'package:flutter/material.dart';
import 'customer_home_screen.dart';
import 'customer_menu_screen.dart';
import 'customer_favorites_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainNav extends StatefulWidget {
  const CustomerMainNav({super.key});

  @override
  State<CustomerMainNav> createState() => _CustomerMainNavState();
}

class _CustomerMainNavState extends State<CustomerMainNav> {
  int _selectedIndex = 0;
  String _selectedCategoryForMenu = 'All'; // Default

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return CustomerHomeScreen(
          // 1. Order Now -> Go to Menu (All)
          onOrderNow: () {
            setState(() {
              _selectedCategoryForMenu = 'All';
              _selectedIndex = 1;
            });
          },
          // 2. Click Category -> Go to Menu (Specific Category)
          onCategorySelected: (String category) {
            setState(() {
              _selectedCategoryForMenu = category;
              _selectedIndex = 1; // Switch to Menu Tab
            });
          },
        );
      case 1:
        // 3. Pass the category to the Menu Screen
        return CustomerMenuScreen(
          key: ValueKey(_selectedCategoryForMenu), // Forces rebuild
          initialCategory: _selectedCategoryForMenu,
        );
      case 2:
        return const CustomerFavoritesScreen();
      case 3:
        return const CustomerProfileScreen();
      default:
        // Fallback
        return CustomerHomeScreen(
          onOrderNow: () => setState(() => _selectedIndex = 1),
          onCategorySelected: (_) {},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
