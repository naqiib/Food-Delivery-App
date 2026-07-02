import 'package:flutter/material.dart';
import 'package:yummies_food_app/models/food_model.dart';

class CartItem {
  final String id; // Unique ID for this specific cart entry
  final FoodItem food;
  final int quantity;
  final List<VariationOption>
  selectedVariations; // Store selected options (e.g. Size: Small)
  final double price; // The final price (Base + Variations)

  CartItem({
    required this.id,
    required this.food,
    this.quantity = 1,
    this.selectedVariations = const [],
    required this.price,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // Calculate total: (Unit Price * Quantity) for all items
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  int get itemCount {
    return _items.length;
  }

  // MODIFIED: Now accepts selectedVariations
  void addItem(
    FoodItem food, {
    List<VariationOption> selectedVariations = const [],
  }) {
    // 1. Calculate Final Price (Base Price + All selected options)
    double variationTotal = 0.0;
    for (var option in selectedVariations) {
      variationTotal += option.price;
    }
    double finalUnitPrice = food.price + variationTotal;

    // 2. Generate a Unique Key
    // If user buys "Pizza (Small)" and "Pizza (Large)", they should be separate items.
    // Key format: "productId_Option1_Option2"
    String variationKey = selectedVariations.map((e) => e.name).join('_');
    String cartKey = "${food.id}_$variationKey";

    if (_items.containsKey(cartKey)) {
      // If exactly the same item (same size/options) exists, just increase quantity
      _items.update(
        cartKey,
        (existing) => CartItem(
          id: existing.id,
          food: existing.food,
          quantity: existing.quantity + 1,
          selectedVariations: existing.selectedVariations,
          price: existing.price,
        ),
      );
    } else {
      // Add new item to cart
      _items.putIfAbsent(
        cartKey,
        () => CartItem(
          id: cartKey, // Use our generated composite key
          food: food,
          quantity: 1,
          selectedVariations: selectedVariations,
          price: finalUnitPrice,
        ),
      );
    }
    notifyListeners();
  }

  // Decrease quantity or remove item
  void removeSingleItem(String cartKey) {
    if (!_items.containsKey(cartKey)) {
      return;
    }
    if (_items[cartKey]!.quantity > 1) {
      _items.update(
        cartKey,
        (existing) => CartItem(
          id: existing.id,
          food: existing.food,
          quantity: existing.quantity - 1,
          selectedVariations: existing.selectedVariations,
          price: existing.price,
        ),
      );
    } else {
      _items.remove(cartKey);
    }
    notifyListeners();
  }

  // Remove item completely regardless of quantity
  void removeItem(String cartKey) {
    _items.remove(cartKey);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
