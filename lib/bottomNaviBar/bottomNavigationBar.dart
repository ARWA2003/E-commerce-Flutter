import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bottomNavItems/cart.dart';
import '../bottomNavItems/favor.dart';
import '../bottomNavItems/home.dart';
import '../bottomNavItems/profile.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final _items = [const Home(), const Cart(), const Favor(), const Profile()];
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          "SnapShop",
          style: TextStyle(
              fontSize: 35, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[700],
        selectedItemColor: Colors.indigo,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: "Home",
              backgroundColor: Colors.green[700]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart),
              label: "Cart",
              backgroundColor: Colors.green[700]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline),
              label: "Favor",
              backgroundColor: Colors.green[700]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: "Person",
              backgroundColor: Colors.green[700]),
        ],
      ),
      body: _items[_selectedIndex],
    );
  }
}
