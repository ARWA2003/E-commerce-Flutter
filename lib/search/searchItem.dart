import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/const/appColors.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:camera/camera.dart';
import 'package:ecommerceapp/product_details/productDetails.dart';

class SearchingItem extends StatefulWidget {
  const SearchingItem({super.key});

  @override
  State<SearchingItem> createState() => _SearchingItemState();
}

class _SearchingItemState extends State<SearchingItem> {
  String inputText = "";
  late stt.SpeechToText speechToText;
  bool isListening = false;

  CameraController? _cameraController;
  bool _isCameraOpen = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Initialize Speech-to-Text
  void startListening() async {
    bool available = await speechToText.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    if (available) {
      setState(() => isListening = true);
      speechToText.listen(
        onResult: (result) {
          setState(() {
            inputText = result.recognizedWords.trim();
            isListening = false;
          });
        },
      );
    }
  }

  void stopListening() {
    speechToText.stop();
    setState(() => isListening = false);
  }

  // Camera Initialization
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[0], // Use the first available camera (rear camera)
        ResolutionPreset.high,
      );

      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      debugPrint("No cameras available.");
    }
  }

  void _openCamera() async {
    setState(() {
      _isCameraOpen = true;
    });
    await _initializeCamera();
  }

  void _closeCamera() {
    setState(() {
      _isCameraOpen = false;
      _isCameraInitialized = false;
    });
    _cameraController?.dispose();
    _cameraController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deep_green,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Search Items",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {
              if (_isCameraOpen) {
                _closeCamera();
              } else {
                _openCamera();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isCameraOpen
            ? _buildCameraPreview()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Search Input Field with Voice Search
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            onChanged: (val) {
                              setState(() {
                                inputText = val.trim();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search for products...",
                              prefixIcon: const Icon(Icons.search),
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    const BorderSide(color: Colors.green),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                            ),
                            controller: TextEditingController(text: inputText),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: isListening ? Colors.red : Colors.black,
                          ),
                          onPressed:
                              isListening ? stopListening : startListening,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search Results
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: inputText.isEmpty
                            ? FirebaseFirestore.instance
                                .collection("products")
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection("products")
                                .where("product-name",
                                    isGreaterThanOrEqualTo: inputText)
                                .where("product-name",
                                    isLessThanOrEqualTo: "$inputText\uf8ff")
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                "An error occurred!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.red),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No products found!",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            );
                          }

                          return ListView(
                            children: snapshot.data!.docs.map((document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;

                              final String productName =
                                  data['product-name'] ?? 'Unnamed Product';
                              final String productDescription =
                                  data['product-description'] ??
                                      'No Description';
                              final String productImage =
                                  data['product_image'] ??
                                      "https://via.placeholder.com/150";
                              final double price = double.tryParse(
                                      data['price']?.toString() ?? '0.0') ??
                                  0.0;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetails({
                                        'product-name': productName,
                                        'product_description':
                                            productDescription,
                                        'product_image': productImage,
                                        'price': price,
                                      }),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        productImage,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                              color: Colors.grey);
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      productName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      productDescription,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Text(
                                      "\$${price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.green),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        if (_isCameraInitialized && _cameraController != null)
          CameraPreview(_cameraController!),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: _closeCamera,
          ),
        ),
      ],
    );
  }
}
