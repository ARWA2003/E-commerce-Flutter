import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageProducts extends StatelessWidget {
  const ManageProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Products")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("products").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Error loading products");
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];
              final data = product.data() as Map<String, dynamic>;

              return ListTile(
                leading: data["product_image"] != null
                    ? Image.network(data["product_image"], width: 50, height: 50)
                    : const Icon(Icons.image),
                title: Text(data["product-name"] ?? "Unnamed"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Price: \$${data["price"]}"),
                    Text("Description: ${data["product_description"] ?? "No description"}"),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance.collection("products").doc(product.id).delete();
                  },
                ),
                onTap: () {
                  // Open edit product dialog
                  _showProductDialog(context, product.id, data);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open add product dialog
          _showProductDialog(context, null, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProductDialog(BuildContext context, String? productId, Map<String, dynamic>? productData) {
    final TextEditingController nameController =
        TextEditingController(text: productData?["product-name"] ?? "");
    final TextEditingController priceController =
        TextEditingController(text: productData?["price"]?.toString() ?? "");
    final TextEditingController imageController =
        TextEditingController(text: productData?["product_image"] ?? "");
    final TextEditingController descriptionController =
        TextEditingController(text: productData?["product_description"] ?? "");

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(productId == null ? "Add Product" : "Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: "Image URL"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Product Description"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String priceText = priceController.text.trim();
                final String imageUrl = imageController.text.trim();
                final String description = descriptionController.text.trim();

                if (name.isEmpty || priceText.isEmpty || imageUrl.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                  return;
                }

                final double? price = double.tryParse(priceText);
                if (price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid price value")),
                  );
                  return;
                }

                final data = {
                  "product-name": name,
                  "price": price,
                  "product_image": imageUrl,
                  "product_description": description,
                };

                if (productId == null) {
                  // Add new product
                  FirebaseFirestore.instance.collection("products").add(data);
                } else {
                  // Update existing product
                  FirebaseFirestore.instance.collection("products").doc(productId).update(data);
                }

                Navigator.pop(context);
              },
              child: Text(productId == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }
}
