import 'package:ecommerceapp/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 
      await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC5koCm46qwsEZC_3zfT8hQw8VS0_jgpiA",
  authDomain: "mobile-r-48a3f.firebaseapp.com",
  projectId: "mobile-r-48a3f",
  storageBucket: "mobile-r-48a3f.firebasestorage.app",
  messagingSenderId: "902331019500",
  appId: "1:902331019500:web:836a1d0d29c8def819f5c9"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375,812),
      builder: (_,child){
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(

            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home:  SplashScreen(),
        );
      },

    );
  }
}

