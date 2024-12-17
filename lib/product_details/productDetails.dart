import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> products;

  const ProductDetails(this.products, {super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  var _dotPosition = 0;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  void checkIfFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final favoriteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .collection('favorites')
          .doc(widget.products['id']);

      final doc = await favoriteRef.get();
      setState(() {
        isFavorite = doc.exists;
      });
    }
  }

  void toggleFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to favorites')),
      );
      return;
    }

    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.email)
        .collection('favorites')
        .doc(widget.products['id']);

    if (isFavorite) {
      await favoriteRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from favorites')),
      );
    } else {
      await favoriteRef.set({
        'product-name': widget.products['product-name'],
        'price': widget.products['price'],
        'product_image': widget.products['product_image'],
        'product_description': widget.products['product_description'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to favorites')),
      );
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        children: [
          CarouselSlider(
            items: widget.products["product_image"].map<Widget>((imageUrl) {
              return Image.network(imageUrl, fit: BoxFit.cover);
            }).toList(),
            options: CarouselOptions(
              onPageChanged: (index, reason) {
                setState(() {
                  _dotPosition = index;
                });
              },
              height: 300.h,
            ),
          ),
          SizedBox(height: 20.h),
          Text(widget.products["product-name"], style: TextStyle(fontSize: 24.sp)),
          SizedBox(height: 10.h),
          Text("\$${widget.products["price"]}", style: TextStyle(fontSize: 18.sp)),
          SizedBox(height: 10.h),
          Text(widget.products["product_description"]),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              // Handle adding to cart logic
              if (widget.products["quantity_in_stock"] > 0) {
                // Update stock in Firestore and cart
                FirebaseFirestore.instance.collection('products').doc(widget.products['id']).update({
                  'quantity_in_stock': FieldValue.increment(-1),
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Out of stock')),
                );
              }
            },
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
