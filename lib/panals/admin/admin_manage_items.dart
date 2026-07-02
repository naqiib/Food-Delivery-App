import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:yummies_food_app/models/food_model.dart';

class AdminManageItems extends StatefulWidget {
  const AdminManageItems({super.key});

  @override
  State<AdminManageItems> createState() => _AdminManageItemsState();
}

class _AdminManageItemsState extends State<AdminManageItems> {
  // Database Reference
  final DatabaseReference _productsRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://yammies-food-app-default-rtdb.firebaseio.com',
  ).ref().child('products');

  // --- ACTIONS ---

  // 1. Delete Item
  void _deleteItem(String key) {
    _productsRef.child(key).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item Deleted"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // 2. Toggle Active Status
  void _toggleActive(String key, bool currentStatus) {
    _productsRef.child(key).update({'isActive': !currentStatus});
  }

  // 3. Show Edit Dialog
  void _showEditDialog(BuildContext context, FoodItem item) {
    final TextEditingController editNameCtrl = TextEditingController(
      text: item.name,
    );
    final TextEditingController editPriceCtrl = TextEditingController(
      text: item.price.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Edit ${item.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: editPriceCtrl,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
              ),
              onPressed: () async {
                if (editNameCtrl.text.isNotEmpty &&
                    editPriceCtrl.text.isNotEmpty) {
                  await _productsRef.child(item.id!).update({
                    'name': editNameCtrl.text.trim(),
                    'price':
                        double.tryParse(editPriceCtrl.text.trim()) ??
                        item.price,
                  });
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Item Updated Successfully!"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _productsRef.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text("No items found in Database"));
        }

        // Convert Map to List
        Map<dynamic, dynamic> dataMap =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<FoodItem> items = [];
        dataMap.forEach((key, value) {
          items.add(FoodItem.fromMap(key, value as Map<dynamic, dynamic>));
        });

        return ListView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.only(bottom: 50),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${item.category} ${item.subCategory} - \$${item.price}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit Button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, item),
                    ),
                    // Active Switch
                    Switch(
                      value: item.isActive,
                      activeColor: Colors.green,
                      onChanged: (val) =>
                          _toggleActive(item.id!, item.isActive),
                    ),
                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(item.id!),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
