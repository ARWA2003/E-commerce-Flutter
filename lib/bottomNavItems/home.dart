import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:ecommerceapp/const/appColors.dart';
import 'package:ecommerceapp/product_details/productDetails.dart';
import 'package:ecommerceapp/search/searchItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _dotPosition = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _carouselImageList = [];

  // Fetch Carousel Images
  _fetchCarouselImage() async {
    QuerySnapshot qn =
        await FirebaseFirestore.instance.collection("Cursor-product").get();
    setState(() {
      for (var doc in qn.docs) {
        List<dynamic> productImages = doc["product-image"];
        _carouselImageList.addAll(productImages.cast<String>());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCarouselImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: Column(
              children: [
                _buildSearchBar(),
                SizedBox(height: 15.h),
                _buildCarousel(),
                SizedBox(height: 10.h),
                _buildProductGrid(), // Product Grid with Real-time Fetching
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchingItem()));
            },
            decoration: InputDecoration(
              hintText: "Search your items...",
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              filled: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3,
          child: CarouselSlider(
            items: _carouselImageList.map((item) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(item), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(15),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.4,
              onPageChanged: (val, reason) {
                setState(() {
                  _dotPosition = val;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 10.h),
        DotsIndicator(
          dotsCount: _carouselImageList.isEmpty ? 1 : _carouselImageList.length,
          position: _dotPosition.toInt(),
          decorator: DotsDecorator(
            activeColor: Colors.orange,
            spacing: const EdgeInsets.all(2),
            activeSize: const Size(8, 8),
            size: const Size(6, 6),
            color: Colors.orange.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

 Widget _buildProductGrid() {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.6,
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("products").snapshots(),
      builder: (context, snapshot) {
        // Handle Errors
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading products"),
          );
        }

        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if No Data
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No products found"),
          );
        }

        // Build Grid View
        final products = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            childAspectRatio: 0.85, // Reduced aspect ratio to make items smaller
            mainAxisSpacing: 12, // Vertical spacing
            crossAxisSpacing: 12, // Horizontal spacing
          ),
          itemBuilder: (_, index) {
            final product = products[index];
            final data = product.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetails(data)),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.2, // Aspect ratio for smaller images
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          data["product_image"] ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5), // Space below the image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["product-name"] ?? "Unnamed Product",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "\$${data["price"] ?? "0"}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

}
