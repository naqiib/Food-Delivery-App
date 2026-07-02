import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummies_food_app/models/food_model.dart';
// Removed image_picker import

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  String name = '';
  String description = '';
  String selectedCategory = 'Pizza';
  String? selectedSubCategory;
  double basePrice = 0.0;
  bool isActive = true;
  bool inStock = true;
  bool isPopular = false;

  // Dynamic Variations
  List<Variation> variations = [];

  // Data Configuration
  final Map<String, List<String>> categoryData = {
    'Pizza': ['Chicken Pizza', 'Beef Pizza', 'Veg Pizza', 'Cheese Pizza'],
    'Burger': ['Chicken Burger', 'Beef Burger', 'Zinger Burger', 'Veg Burger'],
    'Wraps': ['Chicken Wrap', 'Veg Wrap'],
    'Pasta': ['Alfredo', 'Red Sauce'],
    'Drinks': ['Cold Drinks', 'Juices', 'Water'],
  };

  void _addVariationGroup() {
    setState(() => variations.add(Variation(name: '', options: [])));
  }

  void _addOptionToVariation(int index) {
    setState(
      () => variations[index].options.add(VariationOption(name: '', price: 0)),
    );
  }

  void _removeVariation(int index) {
    setState(() => variations.removeAt(index));
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      FoodItem newItem = FoodItem(
        name: name,
        category: selectedCategory,
        subCategory: selectedSubCategory ?? '',
        price: basePrice,
        // Removed imageUrl
        description: description,
        isPopular: isPopular,
        isActive: isActive,
        inStock: inStock,
        variations: variations,
      );

      try {
        await FirebaseFirestore.instance
            .collection('products')
            .add(newItem.toMap());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Item Added!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentSubCategories = categoryData[selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Add New Item")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // REMOVED IMAGE PICKER WIDGET

              // 1. Basic Info
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Required' : null,
                onSaved: (val) => name = val!,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onSaved: (val) => description = val ?? '',
              ),
              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categoryData.keys
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() {
                        selectedCategory = val!;
                        selectedSubCategory = null;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubCategory,
                      hint: Text("Type"),
                      items: currentSubCategories
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedSubCategory = val),
                      decoration: InputDecoration(
                        labelText: 'Sub Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Base Price',
                  prefixText: 'Rs',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
                onSaved: (val) => basePrice = double.parse(val!),
              ),

              SizedBox(height: 20),
              // 2. Status & Tags
              SwitchListTile(
                title: Text("Active (Visible)"),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
              ),
              SwitchListTile(
                title: Text("In Stock"),
                value: inStock,
                onChanged: (val) => setState(() => inStock = val),
              ),
              SwitchListTile(
                title: Text("Mark as Popular"),
                value: isPopular,
                activeColor: Colors.amber,
                onChanged: (val) => setState(() => isPopular = val),
              ),

              SizedBox(height: 20),
              // 3. Variations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Variations",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: _addVariationGroup,
                  ),
                ],
              ),
              ...variations.asMap().entries.map((entry) {
                int idx = entry.key;
                Variation v = entry.value;
                return Card(
                  color: Colors.blue[50],
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Group Name (e.g. Size)',
                          ),
                          initialValue: v.name,
                          onChanged: (val) => v.name = val,
                        ),
                        ...v.options
                            .map(
                              (opt) => Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Option',
                                      ),
                                      initialValue: opt.name,
                                      onChanged: (val) => opt.name = val,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: '+ Price',
                                      ),
                                      initialValue: opt.price.toString(),
                                      onChanged: (val) =>
                                          opt.price = double.tryParse(val) ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _addOptionToVariation(idx),
                              child: Text("+ Option"),
                            ),
                            TextButton(
                              onPressed: () => _removeVariation(idx),
                              child: Text(
                                "Remove",
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

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  child: Text("SAVE PRODUCT", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
