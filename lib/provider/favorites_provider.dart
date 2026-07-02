import 'package:flutter/material.dart';
import 'package:yummies_food_app/models/food_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<FoodItem> _favoriteItems = [];

  List<FoodItem> get favoriteItems => _favoriteItems;

  void toggleFavorite(FoodItem food) {
    final isExist = _favoriteItems.contains(food);
    if (isExist) {
      _favoriteItems.remove(food);
    } else {
      _favoriteItems.add(food);
    }
    notifyListeners();
  }

  bool isFavorite(FoodItem food) {
    return _favoriteItems.contains(food);
  }
}
