import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
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
  TextEditingController commentController = TextEditingController();
  double? userRating; // Change userRating to nullable double

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
        'productName': widget.products['product-name'],
        'price': widget.products['price'],
        'image': getProductImages()[0],
        'addedAt': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to favorites')),
      );
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _addItemToCart() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to the cart')),
      );
      return;
    }

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.products['id']);

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.email)
        .collection('cart');

    final productSnapshot = await productRef.get();
    if (productSnapshot.exists) {
      final inStock = productSnapshot['inStock'] ?? 0;

      if (inStock > 0) {
        final existingItem = await cartRef
            .where('productName', isEqualTo: widget.products['product-name'])
            .limit(1)
            .get();

        if (existingItem.docs.isNotEmpty) {
          final cartItemRef = cartRef.doc(existingItem.docs.first.id);
          await cartItemRef.update({
            'quantity': FieldValue.increment(1),
          });
        } else {
          await cartRef.add({
            'productName': widget.products['product-name'],
            'price': widget.products['price'],
            'image': getProductImages()[0],
            'quantity': 1,
            'addedAt': DateTime.now(),
          });
        }

        await productRef.update({
          'inStock': FieldValue.increment(-1),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added to cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product is out of stock')),
        );
      }
    }
  }

  void _submitComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review')),
      );
      return;
    }

    if (commentController.text.trim().isEmpty || userRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a comment and rating')),
      );
      return;
    }

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.products['id']);

    final newComment = {
      'user': currentUser.email,
      'comment': commentController.text.trim(),
      'rating': userRating,
      'createdAt': DateTime.now(),
    };

    await productRef.update({
      'comments': FieldValue.arrayUnion([newComment]),
    });

    commentController.clear();
    setState(() {
      userRating = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted')),
    );
  }

  List<dynamic> getProductImages() {
    var productImages = widget.products['product_image'];
    if (productImages is String) {
      productImages = [productImages];
    }
    return productImages ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final productImages = getProductImages();
    final inStock = widget.products['inStock'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_outline),
            color: isFavorite ? Colors.red : Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2,
              child: CarouselSlider(
                items: productImages.map((item) {
                  return Image.network(item, fit: BoxFit.cover);
                }).toList(),
                options: CarouselOptions(
                  onPageChanged: (val, _) => setState(() {
                    _dotPosition = val;
                  }),
                ),
              ),
            ),
            DotsIndicator(
              dotsCount: productImages.length,
              position: _dotPosition,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                inStock > 0 ? "In Stock" : "Out of Stock",
                style: TextStyle(
                  fontSize: 18,
                  color: inStock > 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(labelText: 'Write a review'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<double>(
                      value: userRating, // Nullable value
                      hint: const Text('Select Rating'),
                      items: [1, 2, 3, 4, 5]
                          .map((e) => DropdownMenuItem<double>(
                                value: e.toDouble(),
                                child: Text('$e Stars'),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() {
                        userRating = val;
                      }),
                    ),
                    ElevatedButton(
                      onPressed: _submitComment,
                      child: const Text('Submit Review'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItemToCart,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
