import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yummies_food_app/provider/favorites_provider.dart';
import 'package:yummies_food_app/models/food_model.dart';
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

class CustomerFavoritesScreen extends StatelessWidget {
  const CustomerFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favProvider, child) {
          final favorites = favProvider.favoriteItems;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "No Favorites Yet",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75, // Taller aspect ratio
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final food = favorites[index];
              return _buildFavFoodCard(context, food, favProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavFoodCard(
    BuildContext context,
    FoodItem food,
    FavoritesProvider provider,
  ) {
    // Check if URL exists
    final bool hasUrl = (food.imageUrl != null && food.imageUrl!.isNotEmpty);

    return GestureDetector(
      // --- CHANGE 1: Tapping the card opens the popup ---
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
                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Image.asset(getAssetImage(food.category)),
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.all(15.0),
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
                  Text(
                    "\$${food.price}",
                    style: const TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remove from Fav
                      InkWell(
                        onTap: () => provider.toggleFavorite(food),
                        child: const Icon(Icons.favorite, color: Colors.red),
                      ),
                      // Add to Cart (Opens Popup)
                      InkWell(
                        // --- CHANGE 2: Tapping Plus also opens the popup ---
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
            ),
          ],
        ),
      ),
    );
  }

  // --- CHANGE 3: Logic to open the sheet directly ---
  void _openCustomizationSheet(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensures rounded corners work
      builder: (_) => ProductCustomizationSheet(food: food),
    );
  }
}
