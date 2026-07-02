import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummies_food_app/models/food_model.dart';

class AdminAddItem extends StatefulWidget {
  const AdminAddItem({super.key});

  @override
  State<AdminAddItem> createState() => _AdminAddItemState();
}

class _AdminAddItemState extends State<AdminAddItem> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Pizza';
  String? _selectedSubCategory;

  bool _isActive = true;
  bool _inStock = true;
  bool _isPopular = false;

  List<Variation> _variations = [];

  final Map<String, List<String>> _categoryData = {
    'Pizza': ['Chicken Pizza', 'Beef Pizza', 'Veg Pizza', 'Cheese Pizza'],
    'Burger': ['Chicken Burger', 'Beef Burger', 'Zinger Burger', 'Veg Burger'],
    'Wraps': ['Chicken Wrap', 'Veg Wrap'],
    'Pasta': ['Alfredo', 'Red Sauce'],
    'Shawarma': ['Chicken', 'Platter'],
    'Drinks': ['Cold Drinks', 'Juices', 'Water'],
    'Sauces': ['Dip', 'Ketchup'],
    'Sandwiches': ['Club', 'Chicken'],
  };

  DatabaseReference get _productsRef {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://yammies-food-app-default-rtdb.firebaseio.com',
    ).ref().child('products');
  }

  // --- THESE WERE MISSING OR INCOMPLETE ---
  void _addVariationGroup() {
    setState(() => _variations.add(Variation(name: '', options: [])));
  }

  void _addOptionToVariation(int index) {
    setState(
      () => _variations[index].options.add(VariationOption(name: '', price: 0)),
    );
  }

  void _removeVariation(int index) {
    setState(() => _variations.removeAt(index));
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    setState(() {
      _selectedCategory = 'Pizza';
      _selectedSubCategory = null;
      _isActive = true;
      _inStock = true;
      _isPopular = false;
      _variations = [];
    });
  }

  Future<void> _addFoodItem() async {
    if (_formKey.currentState!.validate()) {
      // Create the item using your FoodModel
      FoodItem newItem = FoodItem(
        name: _nameController.text,
        category: _selectedCategory,
        subCategory: _selectedSubCategory ?? '',
        price: double.tryParse(_priceController.text) ?? 0.0,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text.trim(), // Save the URL
        isPopular: _isPopular,
        isActive: _isActive,
        inStock: _inStock,
        variations: _variations,
      );

      try {
        // Push to Firebase
        await _productsRef.push().set(newItem.toMap());

        _clearForm();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item Saved Successfully")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> subCats = _categoryData[_selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Add New Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Food Name"),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 2,
              ),
              const SizedBox(height: 10),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: "Image URL (Optional)",
                  hintText: "Paste link or leave empty for default icon",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Category & Subcategory
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: _categoryData.keys
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedCategory = v!;
                          _selectedSubCategory = null;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Category"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedSubCategory,
                      hint: const Text("Sub Category"),
                      items: subCats
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedSubCategory = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Price",
                  prefixText: "\$ ",
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              // Toggles
              SwitchListTile(
                title: const Text("Active"),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              SwitchListTile(
                title: const Text("In Stock"),
                value: _inStock,
                onChanged: (v) => setState(() => _inStock = v),
              ),
              SwitchListTile(
                title: const Text("Popular"),
                value: _isPopular,
                onChanged: (v) => setState(() => _isPopular = v),
              ),

              const Divider(),

              // Variations Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Variations",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addVariationGroup,
                  ),
                ],
              ),

              ..._variations.asMap().entries.map((entry) {
                int idx = entry.key;
                Variation v = entry.value;
                return Card(
                  color: Colors.grey[100],
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Group Name (e.g. Size)
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Group Name (e.g. Size)',
                          ),
                          initialValue: v.name,
                          onChanged: (val) => v.name = val,
                        ),

                        // Options List (e.g. Small, Large)
                        ...v.options
                            .map(
                              (opt) => Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Option',
                                      ),
                                      initialValue: opt.name,
                                      onChanged: (val) => opt.name = val,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: '+ Price',
                                      ),
                                      initialValue: opt.price.toString(),
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) =>
                                          opt.price = double.tryParse(val) ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),

                        // Action Buttons for this group
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _addOptionToVariation(idx),
                              child: const Text("+ Add Option"),
                            ),
                            TextButton(
                              onPressed: () => _removeVariation(idx),
                              child: const Text(
                                "Remove Group",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addFoodItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "SAVE ITEM",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
