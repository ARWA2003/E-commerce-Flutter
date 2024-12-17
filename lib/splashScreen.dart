import 'dart:async';

import 'package:ecommerceapp/const/appColors.dart';
import 'package:ecommerceapp/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule the navigation after a delay
    Timer(const Duration(seconds: 2), () {
      // Check if the widget is still mounted before navigating
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 214, 184, 225),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "E-Commerce Apps",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 40.sp,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            const CircularProgressIndicator(

              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
