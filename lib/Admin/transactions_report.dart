import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionsReport extends StatelessWidget {
  const TransactionsReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transactions Report")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("transactions").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Error loading transactions");
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (_, index) {
              final transaction = transactions[index];
              final data = transaction.data() as Map<String, dynamic>;

              return ListTile(
                title: Text("User: ${data["user_name"]}"),
                subtitle: Text("Total: \$${data["total"]}"),
                trailing: Text("Date: ${data["date"]}"),
              );
            },
          );
        },
      ),
    );
  }
}
