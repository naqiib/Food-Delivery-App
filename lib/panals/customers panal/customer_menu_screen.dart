import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:yummies_food_app/models/food_model.dart';
import 'package:yummies_food_app/provider/favorites_provider.dart';
// Ensure this path is correct based on your folder structure
import '../../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'product_customization_sheet.dart';

// --- HELPER FUNCTION: Maps categories to your local assets ---
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

class CustomerMenuScreen extends StatefulWidget {
  final String? initialCategory;

  const CustomerMenuScreen({super.key, this.initialCategory});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Pizza',
    'Burger',
    'Pasta',
    'Shawarma',
    'Wraps',
    'Drinks',
    'Sauces',
    'Sandwiches',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory!;
    }
  }

  DatabaseReference get _productsRef {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://yammies-food-app-default-rtdb.firebaseio.com',
    ).ref().child('products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Our Menu",
          style: TextStyle(
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Color(0xFF6A1B9A),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Scroller
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: categories.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6A1B9A)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Product Grid
          Expanded(
            child: StreamBuilder(
              stream: _productsRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<FoodItem> categoryItems = [];

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final dataMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                  dataMap.forEach((key, value) {
                    final itemMap = value as Map<dynamic, dynamic>;
                    final String itemCategory = itemMap['category'] ?? '';
                    final bool isActive = itemMap['isActive'] == true;

                    bool isMatch = false;
                    if (selectedCategory == 'All') {
                      isMatch = true;
                    } else if (selectedCategory == 'Burger') {
                      if (itemCategory.contains('Burger')) isMatch = true;
                    } else {
                      if (itemCategory == selectedCategory) isMatch = true;
                    }

                    if (isMatch && isActive) {
                      categoryItems.add(FoodItem.fromMap(key, itemMap));
                    }
                  });
                }

                if (categoryItems.isEmpty) {
                  return Center(
                    child: Text("No items found for $selectedCategory"),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: categoryItems.length,
                  itemBuilder: (context, index) {
                    return _buildFoodCard(context, categoryItems[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, FoodItem food) {
    // Check if URL exists and is not empty
    final bool hasUrl = (food.imageUrl != null && food.imageUrl!.isNotEmpty);

    return GestureDetector(
      onTap: () => _openCustomizationSheet(context, food),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- IMAGE SECTION ---
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Container(
                  color: Colors.orange.shade50,
                  child: hasUrl
                      ? Image.network(
                          food.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) {
                            // URL broken -> Fallback to Asset
                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Image.asset(getAssetImage(food.category)),
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(15.0),
                          // No URL -> Fallback to Asset
                          child: Image.asset(getAssetImage(food.category)),
                        ),
                ),
              ),
            ),

            // --- INFO SECTION ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  if (food.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      food.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\Rs ${food.price}",
                        style: const TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Consumer<FavoritesProvider>(
                            builder: (context, favProvider, child) {
                              final isFav = favProvider.isFavorite(food);
                              return InkWell(
                                onTap: () => favProvider.toggleFavorite(food),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _openCustomizationSheet(context, food),
                            child: const Icon(
                              Icons.add_circle,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomizationSheet(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductCustomizationSheet(food: food),
    );
  }
}
