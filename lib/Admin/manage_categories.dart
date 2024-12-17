import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCategories extends StatelessWidget {
  const ManageCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("categories").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Error loading categories");
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final category = categories[index];
              final data = category.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data["name"] ?? "Unnamed Category"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance.collection("categories").doc(category.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add New Category
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
