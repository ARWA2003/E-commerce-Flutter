import 'package:flutter/material.dart';
import 'manage_products.dart';
import 'manage_categories.dart';
import 'transactions_report.dart';
import 'feedback_ratings.dart';


class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: Column(
        children: [
          _buildAdminSection(context, "Manage Products", Icons.shopping_cart, const ManageProducts()),
          _buildAdminSection(context, "Manage Categories", Icons.category, const ManageCategories()),
          _buildAdminSection(context, "Transactions Report", Icons.receipt, const TransactionsReport()),
          _buildAdminSection(context, "Feedback & Ratings", Icons.feedback, const FeedbackRatings()),
        ],
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context, String title, IconData icon, Widget route) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => route));
        },
      ),
    );
  }
}
