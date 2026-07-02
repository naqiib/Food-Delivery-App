import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed for Logout
import 'package:yummies_food_app/models/food_model.dart';
// --- IMPORTS FOR DRAWER NAVIGATION ---
import 'order_history_screen.dart';
import 'welcome_screen.dart';

// --- HELPER: Maps categories to assets ---
String getAssetImage(String category) {
  switch (category) {
    case 'Pizza':
      return 'assets/categories/pizza.png';
    case 'Burger':
      return 'assets/categories/burger.png';
    case 'Pasta':
      return 'assets/categories/pasta.png';
    case 'Shawarma':
      return 'assets/categories/shwarma.png';
    case 'Wraps':
      return 'assets/categories/wrap.png';
    case 'Drinks':
      return 'assets/categories/drink.png';
    case 'Sauces':
      return 'assets/categories/sauce.png';
    case 'Sandwiches':
      return 'assets/categories/sandwitch.png';
    default:
      return 'assets/categories/burger.png';
  }
}

class CustomerHomeScreen extends StatefulWidget {
  final VoidCallback onOrderNow;
  final Function(String) onCategorySelected;

  const CustomerHomeScreen({
    super.key,
    required this.onOrderNow,
    required this.onCategorySelected,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _isDarkMode = false;

  final List<String> categories = [
    'Pizza',
    'Burger',
    'Pasta',
    'Shawarma',
    'Wraps',
    'Drinks',
    'Sauces',
    'Sandwiches',
  ];

  DatabaseReference get _productsRef {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://yammies-food-app-default-rtdb.firebaseio.com',
    ).ref().child('products');
  }

  Future<List<FoodItem>> _getSearchSuggestions(String query) async {
    if (query.isEmpty) return [];
    final snapshot = await _productsRef.get();
    if (!snapshot.exists || snapshot.value == null) return [];
    final dataMap = snapshot.value as Map<dynamic, dynamic>;
    final List<FoodItem> suggestions = [];
    dataMap.forEach((key, value) {
      final itemMap = value as Map<dynamic, dynamic>;
      final foodItem = FoodItem.fromMap(key, itemMap);
      if (foodItem.name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(foodItem);
      }
    });
    return suggestions;
  }

  // --- LOGOUT FUNCTION ---
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
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
    final theme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    final user = FirebaseAuth.instance.currentUser; // Get current user info

    return Theme(
      data: theme,
      child: Scaffold(
        // --- ADDED DRAWER HERE ---
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF6A1B9A), // Brand Orange
                ),
                accountName: Text(
                  user?.displayName ?? "Dear Customer",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(user?.email ?? "No Email"),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF6A1B9A)),
                ),
              ),

              // --- ORDER HISTORY LINK ---
              ListTile(
                leading: const Icon(Icons.history, color: Colors.black87),
                title: const Text("Order History"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen(),
                    ),
                  );
                },
              ),
              const Divider(),

              // --- LOGOUT LINK ---
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),

        appBar: AppBar(
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 0,
          // Icon Theme controls the color of the Drawer (Hamburger) Icon
          iconTheme: IconThemeData(
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Deli-GO",
                style: TextStyle(
                  color: Color(0xFF6A1B9A),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Text(
                "Order Tasty Food",
                style: TextStyle(
                  color: _isDarkMode ? Colors.grey[400] : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Autocomplete<FoodItem>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return _getSearchSuggestions(textEditingValue.text);
                  },
                  displayStringForOption: (FoodItem option) => option.name,
                  fieldViewBuilder:
                      (context, controller, focusNode, onSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: "Search items or deals...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: _isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        );
                      },
                  onSelected: (FoodItem selection) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${selection.name}')),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32,
                          color: _isDarkMode ? Colors.grey[850] : Colors.white,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final FoodItem option = options.elementAt(index);
                              return ListTile(
                                title: Text(option.name),
                                subtitle: Text('\$${option.price}'),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- 2. PROMO BANNER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://static.vecteezy.com/system/resources/thumbnails/053/190/352/small/delicious-burger-meal-with-fries-and-a-drink-on-a-fiery-background-free-photo.jpg',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: widget.onOrderNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text("Order Now"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. CATEGORIES SECTION ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        widget.onCategorySelected(category);
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: _isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(getAssetImage(category)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(category),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- 4. TOP PICKS SECTION (SLIDER) ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Top Picks on Go-Deli",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: _productsRef.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<FoodItem> topPicks = [];
                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    final dataMap =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    dataMap.forEach((key, value) {
                      final item = FoodItem.fromMap(key, value);
                      if (item.isActive && item.isPopular) {
                        topPicks.add(item);
                      }
                    });
                  }

                  if (topPicks.isEmpty &&
                      snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    final dataMap =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    dataMap.forEach((key, value) {
                      final item = FoodItem.fromMap(key, value);
                      if (item.isActive && topPicks.length < 5) {
                        topPicks.add(item);
                      }
                    });
                  }

                  if (topPicks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No items available."),
                    );
                  }

                  return CarouselSlider.builder(
                    itemCount: topPicks.length,
                    itemBuilder: (context, index, realIndex) {
                      return _buildCarouselItem(context, topPicks[index]);
                    },
                    options: CarouselOptions(
                      height: 340,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      aspectRatio: 16 / 9,
                      initialPage: 0,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, FoodItem food) {
    // Check if URL exists
    final bool hasUrl = (food.imageUrl != null && food.imageUrl!.isNotEmpty);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.orange.shade50,
                  child: hasUrl
                      ? Image.network(
                          food.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Image.asset(getAssetImage(food.category)),
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Image.asset(getAssetImage(food.category)),
                        ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        "30-45 min",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Free Delivery",
                        style: TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "\$${food.price}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
