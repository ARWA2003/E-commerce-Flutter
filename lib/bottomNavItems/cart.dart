import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // If no user is logged in
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No user is logged in',
            style: TextStyle(fontSize: 18.sp),
          ),
        ),
      );
    }

    // Firestore reference for the user's cart
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .collection('cart');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 214, 184, 225),
        elevation: 0,
        title: Text(
          'Cart',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle empty cart
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100.sp, color: Colors.grey),
                  SizedBox(height: 20.h),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;

          // Safe calculation of total price
          double total = cartItems.fold(0.0, (sum, item) {
            final double price = double.tryParse(item['price'].toString()) ?? 0.0;
            final int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
            return sum + (price * quantity);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10.w),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final String productName = item['productName'] ?? 'Unknown Product';
                    final double price = double.tryParse(item['price'].toString()) ?? 0.0;
                    final int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
                    final String imageUrl = item['image'] ?? '';

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageUrl,
                                  height: 80.h,
                                  width: 80.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported, size: 80.w, color: Colors.grey);
                                  },
                                ),
                              ),
                              SizedBox(width: 10.w),

                              // Product Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      'Price: \$${price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      'Quantity: $quantity',
                                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline, color: Colors.green, size: 28.sp),
                                    onPressed: () {
                                      _updateItemQuantity(item.id, quantity, true);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 28.sp),
                                    onPressed: () {
                                      _updateItemQuantity(item.id, quantity, false);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total and Checkout Section
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Add checkout logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Color.fromARGB(255, 214, 184, 225),
                      ),
                      child: Text(
                        'Checkout',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _updateItemQuantity(String cartItemId, int currentQuantity, bool isIncrement) async {
    final cartItemRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .collection('cart')
        .doc(cartItemId);

    if (isIncrement) {
      await cartItemRef.update({
        'quantity': FieldValue.increment(1),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity increased')),
      );
    } else {
      if (currentQuantity > 1) {
        await cartItemRef.update({
          'quantity': FieldValue.increment(-1),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity decreased')),
        );
      } else {
        await cartItemRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart')),
        );
      }
    }
  }
}
