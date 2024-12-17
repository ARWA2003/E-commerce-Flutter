import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackRatings extends StatelessWidget {
  const FeedbackRatings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback & Ratings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("feedback").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Error loading feedback");
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final feedbacks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbacks.length,
            itemBuilder: (_, index) {
              final feedback = feedbacks[index];
              final data = feedback.data() as Map<String, dynamic>;

              return ListTile(
                title: Text("Feedback: ${data["comment"]}"),
                subtitle: Text("Rating: ${data["rating"]} / 5"),
              );
            },
          );
        },
      ),
    );
  }
}
