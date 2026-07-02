import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:yummies_food_app/models/food_model.dart';
import '../../providers/cart_provider.dart';

// --- HELPER FUNCTION ---
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

class ProductCustomizationSheet extends StatefulWidget {
  final FoodItem food;
  const ProductCustomizationSheet({super.key, required this.food});

  @override
  State<ProductCustomizationSheet> createState() =>
      _ProductCustomizationSheetState();
}

class _ProductCustomizationSheetState extends State<ProductCustomizationSheet> {
  Map<String, VariationOption> selectedOptions = {};

  List<FoodItem> selectedDrinks = [];
  List<FoodItem> selectedSauces = [];

  final TextEditingController _instructionsController = TextEditingController();
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    for (var v in widget.food.variations) {
      if (v.options.isNotEmpty) {
        selectedOptions[v.name] = v.options[0];
      }
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  DatabaseReference get _productsRef {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://yammies-food-app-default-rtdb.firebaseio.com',
    ).ref().child('products');
  }

  double get totalPrice {
    double foodTotal = widget.food.price;
    selectedOptions.forEach((_, opt) => foodTotal += opt.price);

    double extrasTotal = 0;
    for (var drink in selectedDrinks) {
      extrasTotal += drink.price;
    }
    for (var sauce in selectedSauces) {
      extrasTotal += sauce.price;
    }

    return (foodTotal * quantity) + extrasTotal;
  }

  // --- Helper to count quantity of a specific item ---
  int _getItemCount(List<FoodItem> list, String itemName) {
    return list.where((item) => item.name == itemName).length;
  }

  // --- Helper to remove a single instance ---
  void _removeSingleItem(List<FoodItem> list, String itemName) {
    for (var item in list) {
      if (item.name == itemName) {
        list.remove(item);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final redColor = const Color(0xFFC2185B);
    final bool hasUrl =
        (widget.food.imageUrl != null && widget.food.imageUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 5),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Customize Your Meal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // --- SCROLLABLE BODY ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Food Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: hasUrl
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.food.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    getAssetImage(widget.food.category),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.food.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.food.description.isNotEmpty
                                    ? widget.food.description
                                    : "Delicious meal",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Variations
                    if (widget.food.variations.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: redColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Choose Size & Options",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...widget.food.variations.map((v) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 8,
                              children: v.options.map((opt) {
                                bool isSelected =
                                    selectedOptions[v.name] == opt;
                                return ChoiceChip(
                                  label: Text("${opt.name} (+${opt.price})"),
                                  selected: isSelected,
                                  selectedColor: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ),
                                  labelStyle: TextStyle(
                                    color: isSelected ? redColor : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setState(
                                        () => selectedOptions[v.name] = opt,
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const Divider(),
                          ],
                        );
                      }),
                      const SizedBox(height: 20),
                    ],

                    // 3. Sauces
                    _buildSectionHeader("Add Extra Sauces", redColor),
                    _buildExtrasList("Sauces", selectedSauces),
                    const SizedBox(height: 20),

                    // 4. Drinks
                    _buildSectionHeader("Complete With a Drink", redColor),
                    _buildExtrasList("Drinks", selectedDrinks),
                    const SizedBox(height: 20),

                    // 5. Special Instructions
                    const Text(
                      "Special Instructions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _instructionsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText:
                            "e.g. No onions, extra spicy, cut in squares...",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                  ),
                  Text(
                    "$quantity",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    0,
                    0,
                    0,
                  ), // --- UPDATED TO BLACK ---
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  final cart = Provider.of<CartProvider>(
                    context,
                    listen: false,
                  );
                  List<VariationOption> finalSelections = selectedOptions.values
                      .toList();
                  String notes = _instructionsController.text.trim();

                  for (int i = 0; i < quantity; i++) {
                    cart.addItem(
                      widget.food,
                      selectedVariations: finalSelections,
                    );
                  }
                  for (var drink in selectedDrinks) {
                    cart.addItem(drink, selectedVariations: []);
                  }
                  for (var sauce in selectedSauces) {
                    cart.addItem(sauce, selectedVariations: []);
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        notes.isNotEmpty
                            ? "Added with notes: $notes"
                            : "Added to Bucket!",
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "  Rs ${totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "ADD TO BUCKET",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "(Optional)",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildExtrasList(String category, List<FoodItem> selectedList) {
    return StreamBuilder(
      stream: _productsRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text("Loading..."),
            ),
          );
        }
        List<FoodItem> items = [];
        final dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        dataMap.forEach((key, value) {
          final itemMap = value as Map<dynamic, dynamic>;
          if (itemMap['category'] == category && itemMap['isActive'] == true) {
            items.add(FoodItem.fromMap(key, itemMap));
          }
        });
        if (items.isEmpty) {
          return Text("No $category available.");
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (ctx, i) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            final int count = _getItemCount(selectedList, item.name);

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(getAssetImage(category)),
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text("+Rs ${item.price}"),
              // --- QUANTITY CONTROLLER ---
              trailing: count == 0
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC2185B),
                        minimumSize: const Size(70, 30),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedList.add(item);
                        });
                      },
                      child: const Text(
                        "ADD",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _removeSingleItem(selectedList, item.name);
                            });
                          },
                        ),
                        Text(
                          "$count",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedList.add(item);
                            });
                          },
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
