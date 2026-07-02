// lib/models/food_model.dart

class VariationOption {
  String name;
  double price;

  VariationOption({required this.name, required this.price});

  Map<String, dynamic> toMap() => {'name': name, 'price': price};

  factory VariationOption.fromMap(Map<dynamic, dynamic> map) {
    return VariationOption(
      name: map['name'] ?? '',
      price: double.tryParse(map['price'].toString()) ?? 0.0,
    );
  }
}

class Variation {
  String name;
  List<VariationOption> options;

  Variation({required this.name, required this.options});

  Map<String, dynamic> toMap() => {
    'name': name,
    'options': options.map((opt) => opt.toMap()).toList(),
  };

  factory Variation.fromMap(Map<dynamic, dynamic> map) {
    return Variation(
      name: map['name'] ?? '',
      options: map['options'] != null
          ? (map['options'] as List)
                .map((x) => VariationOption.fromMap(x as Map<dynamic, dynamic>))
                .toList()
          : [],
    );
  }
}

class FoodItem {
  final String? id;
  final String name;
  final String category;
  final String subCategory;
  final double price;
  final String description;
  final String? imageUrl; // --- ADDED THIS FIELD ---
  final bool isPopular;
  final bool isActive;
  final bool inStock;
  final List<Variation> variations;

  FoodItem({
    this.id,
    required this.name,
    required this.category,
    this.subCategory = '',
    required this.price,
    required this.description,
    this.imageUrl, // --- ADDED TO CONSTRUCTOR ---
    this.isPopular = false,
    this.isActive = true,
    this.inStock = true,
    this.variations = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'description': description,
      'imageUrl': imageUrl, // --- SAVE TO DATABASE ---
      'isPopular': isPopular,
      'isActive': isActive,
      'inStock': inStock,
      'variations': variations.map((v) => v.toMap()).toList(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Factory to read from Realtime Database
  factory FoodItem.fromMap(String key, Map<dynamic, dynamic> data) {
    return FoodItem(
      id: key,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'], // --- READ FROM DATABASE ---
      isPopular: data['isPopular'] ?? false,
      isActive: data['isActive'] ?? true,
      inStock: data['inStock'] ?? true,
      variations: data['variations'] != null
          ? (data['variations'] as List)
                .map((x) => Variation.fromMap(x as Map<dynamic, dynamic>))
                .toList()
          : [],
    );
  }
}
